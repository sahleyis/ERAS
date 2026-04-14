import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/victim/victim_home_screen.dart';
import 'screens/victim/emergency_type_screen.dart';
import 'screens/victim/waiting_screen.dart';
import 'screens/victim/match_screen.dart';
import 'screens/responder/responder_dashboard.dart';
import 'screens/responder/alert_detail_screen.dart';
import 'screens/responder/navigation_screen.dart';
import 'screens/profile/medical_profile_screen.dart';
import 'screens/profile/responder_profile_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/messaging/find_responder_screen.dart';
import 'screens/messaging/messaging_chat_screen.dart';
import 'screens/role_selection_screen.dart';

class ErasApp extends ConsumerWidget {
  const ErasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ERAS - Emergency Response',
      debugShowCheckedModeBanner: false,
      theme: ErasTheme.darkTheme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
        AppRoutes.victimHome: (_) => const VictimHomeScreen(),
        AppRoutes.emergencyType: (_) => const EmergencyTypeScreen(),
        AppRoutes.waiting: (_) => const WaitingScreen(),
        AppRoutes.match: (_) => const MatchScreen(),
        AppRoutes.responderDashboard: (_) => const ResponderDashboard(),
        AppRoutes.alertDetail: (_) => const AlertDetailScreen(),
        AppRoutes.navigation: (_) => const NavigationScreen(),
        AppRoutes.medicalProfile: (_) => const MedicalProfileScreen(),
        AppRoutes.responderProfile: (_) => const ResponderProfileScreen(),
        AppRoutes.chat: (_) => const ChatScreen(),
        AppRoutes.findResponder: (_) => const FindResponderScreen(),
        AppRoutes.messagingChat: (_) => const MessagingChatScreen(),
      },
    );
  }
}
