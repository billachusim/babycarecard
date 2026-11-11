import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/child_management/presentation/add_child_screen.dart';
import '../../features/care_card/presentation/care_card_screen.dart';
import '../../features/premium/presentation/premium_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

import '../../features/care_card/presentation/qr_code_screen.dart';
import '../../features/voice/presentation/voice_fill_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-child',
        builder: (context, state) => const AddChildScreen(),
      ),
      GoRoute(
        path: '/care-card/:childId',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          return CareCardScreen(childId: childId);
        },
      ),
      GoRoute(
        path: '/qr/:childId/:childName',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          final childName = state.pathParameters['childName']!;
          return QrCodeScreen(childId: childId, childName: childName);
        },
      ),
      GoRoute(
        path: '/voice-fill',
        builder: (context, state) => const VoiceFillScreen(),
      ),
      GoRoute(
        path: '/voice-fill/:childId',
        builder: (context, state) =>
            VoiceFillScreen(childId: state.pathParameters['childId']!),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
