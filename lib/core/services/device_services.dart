import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';
import '../../l10n/generated/app_localizations.dart';

class DeviceServices {
  static const channel = MethodChannel('pitstop/device');
  static Future<bool> notificationsAllowed() async => Platform.isAndroid
      ? await channel.invokeMethod<bool>('notificationsAllowed') ?? false
      : false;
  static Future<void> requestNotifications() async {
    if (Platform.isAndroid) await channel.invokeMethod('requestNotifications');
  }

  /// Planuje powiadomienia Androida treściami w bieżącym języku aplikacji.
  ///
  /// Treść jest zamrożona w momencie planowania, więc zmiana języku ponownie
  /// wysyła harmonogram (patrz `ref.listen(appLanguageProvider)` w `app.dart`).
  static Future<void> sync(
      List<Reminder> reminders, List<Vehicle> vehicles, AppLocalizations l) async {
    if (!Platform.isAndroid) return;
    await channel.invokeMethod('schedule', scheduleFor(reminders, vehicles, l));
  }

  static List<Map<String, dynamic>> scheduleFor(
      List<Reminder> reminders, List<Vehicle> vehicles, AppLocalizations l,
      {DateTime? now}) {
    now ??= DateTime.now();
    final data = <Map<String, dynamic>>[];
    for (final r in reminders.where((r) => !r.isDone)) {
      final matches = vehicles.where((v) => v.id == r.vehicleId);
      if (matches.isEmpty) continue;
      final car = matches.first;
      if (r.dueDate != null) {
        for (final days in [7, 1, 0]) {
          final due = r.dueDate!;
          final time = DateTime(due.year, due.month, due.day, 9)
              .subtract(Duration(days: days));
          if (time.isAfter(now) || days == 0) {
            data.add({
              'id': r.id * 10 + days,
              'at': time.isAfter(now) ? time.millisecondsSinceEpoch : 0,
              'title': '${car.name}: ${r.title}',
              'body': days == 0
                  ? (DateTime(due.year, due.month, due.day)
                          .isBefore(DateTime(now.year, now.month, now.day))
                      ? l.notifDueOverdue
                      : l.notifDueToday)
                  : l.notifDueInDays(days),
              'route': '/reminder/${r.id}/edit?vehicleId=${r.vehicleId}'
            });
          }
        }
      }
      if (r.dueMileage != null && r.dueMileage! - car.currentMileage <= 1000) {
        data.add({
          'id': r.id * 10 + 8,
          'at': 0,
          'title': '${car.name}: ${r.title}',
          'body': r.dueMileage! <= car.currentMileage
              ? l.notifMileageReached(_km(l, r.dueMileage!))
              : l.notifMileageRemaining(
                  _km(l, r.dueMileage! - car.currentMileage)),
          'route': '/reminder/${r.id}/edit?vehicleId=${r.vehicleId}'
        });
      }
    }
    return data;
  }

  /// Przebieg w powiadomieniu z grupowaniem tysięcy właściwym dla języku.
  static String _km(AppLocalizations l, int value) =>
      NumberFormat.decimalPattern(l.localeName).format(value);

  static Future<bool> saveFile(String path, String mime) async {
    if (!Platform.isAndroid) return false;
    return await channel
            .invokeMethod<bool>('saveFile', {'path': path, 'mime': mime}) ??
        false;
  }

  static Future<String?> report(String title, List<String> lines) async {
    if (!Platform.isAndroid) return null;
    return channel
        .invokeMethod<String>('report', {'title': title, 'lines': lines});
  }
}
