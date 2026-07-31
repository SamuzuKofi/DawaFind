import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Bindings must be ready before any plugin call.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Restore the saved theme before the first frame so the app never flashes
  // light before switching to dark.
  await ThemeController.instance.load();
  runApp(const DawaFindApp());
}
