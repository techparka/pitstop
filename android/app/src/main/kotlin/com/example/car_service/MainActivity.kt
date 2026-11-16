package com.example.car_service

import android.Manifest
import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.pdf.PdfDocument
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

class MainActivity: FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pendingSave: MethodChannel.Result? = null
    private var sourceFile: File? = null
    private var pendingPermission: MethodChannel.Result? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pitstop/device")
        channel!!.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "notificationsAllowed" -> result.success(Build.VERSION.SDK_INT < 24 || getSystemService(NotificationManager::class.java).areNotificationsEnabled())
                    "requestNotifications" -> {
                        if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                            if(pendingPermission != null) result.error("BUSY", getString(R.string.error_busy_request), null)
                            else { pendingPermission=result; requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS),42) }
                        } else result.success(null)
                    }
                    "schedule" -> {
                        ReminderReceiver.replace(this, JSONArray(call.arguments as List<*>))
                        result.success(null)
                    }
                    "initialRoute" -> { result.success(intent.getStringExtra("route")); intent.removeExtra("route") }
                    "saveFile" -> {
                        if (pendingSave != null) { result.error("BUSY", getString(R.string.error_busy_save), null) }
                        else {
                            sourceFile = File(call.argument<String>("path")!!)
                            val picker = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = call.argument<String>("mime") ?: "application/octet-stream"
                                putExtra(Intent.EXTRA_TITLE, sourceFile!!.name)
                            }
                            pendingSave = result
                            startActivityForResult(picker, 43)
                        }
                    }
                    "report" -> result.success(report(call.argument<String>("title")!!, call.argument<List<String>>("lines")!!))
                    else -> result.notImplemented()
                }
            } catch (e: Exception) { result.error("DEVICE", e.message, null) }
        }
    }
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra("route")?.let { channel?.invokeMethod("openRoute", it); intent.removeExtra("route") }
    }
    override fun onRequestPermissionsResult(requestCode:Int, permissions:Array<out String>, grantResults:IntArray) {
        super.onRequestPermissionsResult(requestCode,permissions,grantResults)
        if(requestCode==42) { pendingPermission?.success(null); pendingPermission=null }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 43) {
            try {
                if (resultCode == Activity.RESULT_OK && data?.data != null) {
                    contentResolver.openOutputStream(data.data!!)?.use { out -> sourceFile!!.inputStream().use { it.copyTo(out) } } ?: throw IllegalStateException(getString(R.string.error_destination_unwritable))
                }
                pendingSave?.success(resultCode == Activity.RESULT_OK && data?.data != null)
            } catch (e: Exception) { pendingSave?.error("SAVE", e.message, null) }
            pendingSave = null; sourceFile = null
        }
    }
    private fun report(title: String, lines: List<String>): String {
        val pdf = PdfDocument()
        val text = Paint(Paint.ANTI_ALIAS_FLAG).apply { textSize=11f; color=Color.rgb(35,38,44); typeface=Typeface.create("sans-serif",Typeface.NORMAL) }
        val heading=Paint(text).apply { textSize=20f; typeface=Typeface.create("sans-serif",Typeface.BOLD) }
        var pageNumber=0
        var page: PdfDocument.Page?=null
        var y=0f
        fun newPage() {
            page?.let { pdf.finishPage(it) }
            pageNumber++
            page=pdf.startPage(PdfDocument.PageInfo.Builder(595,842,pageNumber).create())
            page!!.canvas.drawText("PitStop • $title",40f,55f,heading)
            page!!.canvas.drawText(getString(R.string.report_footer, pageNumber),40f,805f,text)
            y=90f
        }
        newPage()
        for (line in lines) {
            var remaining=line
            if(remaining.isEmpty()) { y+=12f; continue }
            while(remaining.isNotEmpty()) {
                if(y>775) newPage()
                var count=text.breakText(remaining,true,515f,null)
                if(count<=0) count=1
                if(count<remaining.length) {
                    val space=remaining.lastIndexOf(' ',count-1)
                    if(space>count/2) count=space
                }
                page!!.canvas.drawText(remaining.substring(0,count),40f,y,text)
                remaining=remaining.substring(count).trimStart()
                y+=17f
            }
            y+=6f
        }
        page?.let { pdf.finishPage(it) }
        val file=File(cacheDir, "pitstop-history-${System.currentTimeMillis()}.pdf")
        try { file.outputStream().use { pdf.writeTo(it) } } finally { pdf.close() }
        return file.absolutePath
    }
}

class ReminderReceiver: BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val prefs=context.getSharedPreferences("pitstop_notifications",Context.MODE_PRIVATE)
        if(intent.action==Intent.ACTION_BOOT_COMPLETED || intent.action==Intent.ACTION_MY_PACKAGE_REPLACED || intent.action==Intent.ACTION_TIME_CHANGED || intent.action==Intent.ACTION_TIMEZONE_CHANGED) {
            schedule(context,JSONArray(prefs.getString("alarms","[]")))
        } else {
            val id=intent.getIntExtra("id",-1)
            val alarms=JSONArray(prefs.getString("alarms","[]"))
            for(i in 0 until alarms.length()) if(alarms.getJSONObject(i).getInt("id")==id) notify(context,alarms.getJSONObject(i))
        }
    }
    companion object {
        private fun pending(context:Context,id:Int):PendingIntent = PendingIntent.getBroadcast(context,id,Intent(context,ReminderReceiver::class.java).putExtra("id",id),PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        fun replace(context:Context,alarms:JSONArray) {
            val prefs=context.getSharedPreferences("pitstop_notifications",Context.MODE_PRIVATE)
            val previous=JSONArray(prefs.getString("alarms","[]"))
            val manager=context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val ids=(0 until alarms.length()).map { alarms.getJSONObject(it).getInt("id") }.toSet()
            for(i in 0 until previous.length()) {
                val id=previous.getJSONObject(i).getInt("id")
                manager.cancel(pending(context,id))
                if(!ids.contains(id)) { (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).cancel(id); prefs.edit().remove("sent:$id").apply() }
            }
            prefs.edit().putString("alarms",alarms.toString()).apply()
            schedule(context,alarms)
        }
        fun schedule(context:Context,alarms:JSONArray) {
            val manager=context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            for(i in 0 until alarms.length()) {
                val alarm=alarms.getJSONObject(i)
                val at=alarm.getLong("at")
                if(at<=System.currentTimeMillis()) notify(context,alarm)
                else if(Build.VERSION.SDK_INT>=23) manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP,at,pending(context,alarm.getInt("id")))
                else manager.set(AlarmManager.RTC_WAKEUP,at,pending(context,alarm.getInt("id")))
            }
        }
        private fun notify(context:Context,alarm:JSONObject) {
            if(Build.VERSION.SDK_INT>=33 && context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS)!=PackageManager.PERMISSION_GRANTED) return
            val prefs=context.getSharedPreferences("pitstop_notifications",Context.MODE_PRIVATE)
            val id=alarm.getInt("id")
            val stamp=alarm.toString()
            if(prefs.getString("sent:$id",null)==stamp) return
            val manager=context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if(Build.VERSION.SDK_INT>=26) manager.createNotificationChannel(NotificationChannel("maintenance", context.getString(R.string.channel_maintenance), NotificationManager.IMPORTANCE_DEFAULT))
            val target=Intent(context,MainActivity::class.java).putExtra("route",alarm.getString("route")).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            val action=PendingIntent.getActivity(context,id,target,PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            val builder=if(Build.VERSION.SDK_INT>=26) Notification.Builder(context,"maintenance") else Notification.Builder(context)
            manager.notify(id,builder.setSmallIcon(R.drawable.ic_notification).setContentTitle(alarm.getString("title")).setContentText(alarm.getString("body")).setStyle(Notification.BigTextStyle().bigText(alarm.getString("body"))).setContentIntent(action).setAutoCancel(true).build())
            prefs.edit().putString("sent:$id",stamp).apply()
        }
    }
}
