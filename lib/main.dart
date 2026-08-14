import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/enums/enums.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/providers.dart';
import 'features/dashboard/presentation/pages/dashboard_shell.dart';
import 'features/platform/presentation/pages/platform_panel_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SymbosysApp(),
    ),
  );
}

class SymbosysApp extends ConsumerWidget {
  const SymbosysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Symbosys SMS — Enterprise ERP',
      debugShowCheckedModeBanner: false,
      theme: getThemeData(ThemeMode.light),
      darkTheme: getThemeData(ThemeMode.dark),
      themeMode: themeMode,
      home: authState.when(
        data: (user) {
          if (user != null) {
            if (user.role == UserRole.platformAdmin) {
              return const PlatformPanelShell();
            }
            return const DashboardShell();
          }
          return const LoginPage();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(
            child: Text('Error: $err'),
          ),
        ),
      ),
    );
  }
}
