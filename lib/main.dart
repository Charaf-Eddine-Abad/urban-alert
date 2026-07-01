import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:urban_alert/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise French locale for date formatting
  await initializeDateFormatting('fr_FR');

  runApp(
    const ProviderScope(
      child: UrbanAlertApp(),
    ),
  );
}
