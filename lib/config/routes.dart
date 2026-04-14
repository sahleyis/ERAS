/// ERAS Named Routes
///
/// Centralized route path definitions for navigation.
library;

class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Victim
  static const String victimHome = '/victim';
  static const String emergencyType = '/victim/emergency-type';
  static const String waiting = '/victim/waiting';
  static const String match = '/victim/match';

  // Responder
  static const String responderDashboard = '/responder';
  static const String alertDetail = '/responder/alert';
  static const String navigation = '/responder/navigation';

  // Profile
  static const String medicalProfile = '/profile/medical';
  static const String responderProfile = '/profile/responder';

  // Chat
  static const String chat = '/chat';
  static const String findResponder = '/messaging/find';
  static const String messagingChat = '/messaging/chat';

  // Role Selection
  static const String roleSelection = '/role-selection';
}
