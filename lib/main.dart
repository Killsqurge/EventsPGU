import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/event_api.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'state/app_controller.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  final controller = AppController(
    storage: StorageService(),
    auth: AuthService(),
    api: EventApi(),
    notifications: NotificationService(),
  );
  await controller.bootstrap();
  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final palette = controller.lightTheme ? AppPalette.light : AppPalette.dark;
        return MaterialApp(
          title: 'Мероприятия',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.forPalette(palette),
          home: !controller.ready
              ? Scaffold(
                  backgroundColor: palette.bg,
                  body: Center(child: CircularProgressIndicator(color: palette.indigo)),
                )
              : controller.user == null
                  ? LoginScreen(controller: controller)
                  : MainShell(controller: controller),
        );
      },
    );
  }
}
