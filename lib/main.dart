import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Symboli dat potrzebują wszystkie obsługiwane języki, nie tylko polski.
  initializeDateFormatting();
  runApp(const ProviderScope(child: CarServiceApp()));
}
