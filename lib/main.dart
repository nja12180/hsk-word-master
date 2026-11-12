import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/progress_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ProgressService progressService = ProgressService();
  await progressService.init();

  runApp(
    ChangeNotifierProvider<ProgressService>.value(
      value: progressService,
      child: const HskWordMasterApp(),
    ),
  );
}

class HskWordMasterApp extends StatelessWidget {
  const HskWordMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HSK 단어마스터',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
