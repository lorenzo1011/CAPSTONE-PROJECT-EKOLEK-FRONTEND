import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/route_error_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/account_status_screen.dart';
import '../features/auth/providers/auth_controller.dart';
import '../features/auth/providers/auth_state.dart';
import '../features/auth/providers/account_status_controller.dart';
import '../features/auth/screens/approved_welcome_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/password_reset_verification_screen.dart';
import '../features/auth/screens/new_password_screen.dart';
import '../features/profile/screens/change_password_screen.dart';
import '../features/events/models/resident_event.dart';
import '../features/events/screens/event_detail_screen.dart';
import '../features/events/screens/schedules_screen.dart';
import '../features/wallet/screens/wallet_activity_screen.dart';
import '../features/recycling/models/collection_transaction.dart';
import '../features/recycling/screens/collection_detail_screen.dart';
import '../features/recycling/screens/materials_screen.dart';
import '../features/recycling/screens/recycling_history_screen.dart';
import '../features/games/screens/games_screen.dart';
import '../features/games/screens/game_detail_screen.dart';
import '../features/challenges/screens/challenges_screen.dart';
import '../features/challenges/screens/challenge_detail_screen.dart';
import '../features/achievements/screens/achievements_screen.dart';
import '../features/achievements/screens/badge_detail_screen.dart';
import '../features/leaderboard/screens/leaderboard_screen.dart';
import '../features/notifications/screens/notification_center_screen.dart';
import '../features/notifications/screens/notification_detail_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/learning/screens/learn_screen.dart';
import '../features/learning/screens/video_detail_screen.dart';
import '../features/learning/screens/quiz_overview_screen.dart';
import '../features/learning/screens/quiz_taking_screen.dart';
import '../features/learning/screens/quiz_result_screen.dart';
import '../features/learning/models/quiz_result.dart';
import '../features/learning/models/learning_quiz_summary.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/about_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/help_center_screen.dart';
import '../features/profile/screens/legal_information_screen.dart';
import '../features/profile/screens/personal_information_screen.dart';
import '../features/rewards/screens/rewards_screen.dart';
import '../features/rewards/screens/reward_detail_screen.dart';
import '../features/rewards/screens/redemption_review_screen.dart';
import '../features/rewards/models/redemption_preparation.dart';
import '../features/rewards/models/redemption_request_result.dart';
import '../features/rewards/screens/redemption_result_screen.dart';
import '../features/rewards/screens/redemption_history_screen.dart';
import '../features/rewards/screens/redemption_detail_screen.dart';
import '../features/resident_id/screens/digital_id_screen.dart';
import '../features/resident_id/screens/full_screen_qr_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

GoRouter createAppRouter({
  required AuthController authController,
  AccountStatusController? accountStatusController,
}) {
  final routerRefreshListenables = <Listenable>[authController];
  if (accountStatusController case final controller?) {
    routerRefreshListenables.add(controller);
  }
  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    refreshListenable: Listenable.merge(routerRefreshListenables),
    redirect: (context, state) {
      final authState = authController.state;
      final location = state.matchedLocation;
      final onSplash = location == AppRoutes.splashPath;
      final onLogin = location == AppRoutes.loginPath;
      final onSignup = location == AppRoutes.signupPath;
      final onPublicPasswordFlow =
          location == AppRoutes.forgotPasswordPath ||
          location == AppRoutes.passwordResetVerifyPath ||
          location == AppRoutes.newPasswordPath;
      final onAccountStatus = location == AppRoutes.accountStatusPath;
      final onApprovedWelcome = location == AppRoutes.approvedWelcomePath;

      if (authState.status == AuthenticationStatus.initial) {
        return onSplash ? null : AppRoutes.splashPath;
      }
      if (authState.status == AuthenticationStatus.loading) {
        if (onLogin || onSignup) return null;
        return onSplash ? null : AppRoutes.splashPath;
      }
      if (authState.status != AuthenticationStatus.authenticated ||
          authState.user == null) {
        return (onLogin || onSignup || onPublicPasswordFlow)
            ? null
            : AppRoutes.loginPath;
      }

      final user = authState.user!;
      if (user.isApprovedResident) {
        if (authState.approvedWelcomeRequired) {
          return onApprovedWelcome ? null : AppRoutes.approvedWelcomePath;
        }
        if (onApprovedWelcome) return AppRoutes.homePath;
        if (onSplash || onLogin || onAccountStatus) return AppRoutes.homePath;
        return null;
      }

      return onAccountStatus ? null : AppRoutes.accountStatusPath;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signupPath,
        name: AppRoutes.signup,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const SignupScreen()),
      ),
      GoRoute(
        path: AppRoutes.accountStatusPath,
        name: AppRoutes.accountStatus,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const AccountStatusScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordPath,
        name: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.passwordResetVerifyPath,
        name: AppRoutes.passwordResetVerify,
        builder: (context, state) => const PasswordResetVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.newPasswordPath,
        name: AppRoutes.newPassword,
        builder: (context, state) => const NewPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePasswordPath,
        name: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.personalInformationPath,
        name: AppRoutes.personalInformation,
        builder: (context, state) => const PersonalInformationScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfilePath,
        name: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpCenterPath,
        name: AppRoutes.helpCenter,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.legalInformationPath,
        name: AppRoutes.legalInformation,
        builder: (context, state) => const LegalInformationScreen(),
      ),
      GoRoute(
        path: AppRoutes.aboutPath,
        name: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.residentIdPath,
        name: AppRoutes.residentId,
        builder: (context, state) => const DigitalIdScreen(),
      ),
      GoRoute(
        path: AppRoutes.residentIdQrPath,
        name: AppRoutes.residentIdQr,
        builder: (context, state) => const FullScreenQrScreen(),
      ),
      GoRoute(
        path: AppRoutes.schedulesPath,
        name: AppRoutes.schedules,
        builder: (context, state) => const SchedulesScreen(),
      ),
      GoRoute(
        path: AppRoutes.walletActivityPath,
        name: AppRoutes.walletActivity,
        builder: (context, state) => const WalletActivityScreen(),
      ),
      GoRoute(
        path: AppRoutes.recyclingPath,
        name: AppRoutes.recycling,
        builder: (context, state) => const RecyclingHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.materialsPath,
        name: AppRoutes.materials,
        builder: (context, state) => const MaterialsScreen(),
      ),
      GoRoute(
        path: AppRoutes.recyclingDetailPattern,
        name: AppRoutes.recyclingDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['collectionId'] ?? '');
          if (id == null) return const RouteErrorScreen();
          final extra = state.extra;
          return CollectionDetailScreen(
            id: id,
            initial: extra is CollectionTransaction ? extra : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.eventDetailPattern,
        name: AppRoutes.eventDetail,
        builder: (context, state) {
          final event = state.extra;
          final id = int.tryParse(state.pathParameters['eventId'] ?? '');
          final type = switch (state.pathParameters['eventType']) {
            'collection' => ResidentEventType.collection,
            'rewardDistribution' => ResidentEventType.rewardDistribution,
            _ => ResidentEventType.unknown,
          };
          if (id == null || type == ResidentEventType.unknown) {
            return const RouteErrorScreen();
          }
          return EventDetailScreen(
            eventId: id,
            eventType: type,
            initialEvent: event is ResidentEvent ? event : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.approvedWelcomePath,
        name: AppRoutes.approvedWelcome,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const ApprovedWelcomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.learningVideoPattern,
        name: AppRoutes.learningVideo,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['videoId'] ?? '');
          return id == null
              ? const RouteErrorScreen()
              : VideoDetailScreen(videoId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.learningQuizPattern,
        name: AppRoutes.learningQuiz,
        builder: (context, state) {
          final quiz = state.extra;
          if (quiz is! LearningQuizSummary || !quiz.isUnlocked) {
            return const RouteErrorScreen();
          }
          return QuizOverviewScreen(quiz: quiz);
        },
      ),
      GoRoute(
        path: AppRoutes.learningQuizTakingPattern,
        name: AppRoutes.learningQuizTaking,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['quizId'] ?? '');
          return id == null
              ? const RouteErrorScreen()
              : QuizTakingScreen(quizId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.learningQuizResultPattern,
        name: AppRoutes.learningQuizResult,
        builder: (context, state) {
          final result = state.extra;
          final id = int.tryParse(state.pathParameters['quizId'] ?? '');
          if (id == null || result is! QuizResult || result.quizId != id) {
            return const RouteErrorScreen();
          }
          return QuizResultScreen(result: result);
        },
      ),
      GoRoute(
        path: AppRoutes.gameDetailPattern,
        name: AppRoutes.gameDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['gameId'] ?? '');
          return id == null
              ? const RouteErrorScreen()
              : GameDetailScreen(gameId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.challengesPath,
        name: AppRoutes.challenges,
        builder: (context, state) => const ChallengesScreen(),
      ),
      GoRoute(
        path: AppRoutes.challengeDetailPattern,
        name: AppRoutes.challengeDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['challengeId'] ?? '');
          return id == null
              ? const RouteErrorScreen()
              : ChallengeDetailScreen(challengeId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.achievementsPath,
        name: AppRoutes.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.leaderboardPath,
        name: AppRoutes.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationsPath,
        name: AppRoutes.notifications,
        builder: (context, state) => const NotificationCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationDetailPattern,
        name: AppRoutes.notificationDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['notificationId'] ?? '');
          return id == null
              ? const RouteErrorScreen()
              : NotificationDetailScreen(notificationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.badgeDetailPattern,
        name: AppRoutes.badgeDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['badgeId'] ?? '');
          return id == null
              ? const RouteErrorScreen()
              : BadgeDetailScreen(badgeId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.rewardDetailPattern,
        name: AppRoutes.rewardDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['rewardId'] ?? '');
          return id == null || id <= 0
              ? const RouteErrorScreen()
              : RewardDetailScreen(rewardId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.redemptionReviewPattern,
        name: AppRoutes.redemptionReview,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['rewardId'] ?? '');
          final preparation = state.extra;
          if (id == null ||
              preparation is! RedemptionPreparation ||
              preparation.reward.id != id ||
              !preparation.preview.isNonCommitting) {
            return const RouteErrorScreen();
          }
          return RedemptionReviewScreen(preparation: preparation);
        },
      ),
      GoRoute(
        path: AppRoutes.redemptionResultPattern,
        name: AppRoutes.redemptionResult,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['redemptionId'] ?? '');
          final result = state.extra;
          if (id == null ||
              result is! RedemptionRequestResult ||
              result.redemption.id != id) {
            return const RouteErrorScreen();
          }
          return RedemptionResultScreen(result: result);
        },
      ),
      GoRoute(
        path: AppRoutes.redemptionHistoryPath,
        name: AppRoutes.redemptionHistory,
        builder: (context, state) => const RedemptionHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.redemptionDetailPattern,
        name: AppRoutes.redemptionDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['redemptionId'] ?? '');
          return id == null || id <= 0
              ? const RouteErrorScreen()
              : RedemptionDetailScreen(redemptionId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          _branch(
            path: AppRoutes.homePath,
            name: AppRoutes.home,
            screen: const HomeScreen(),
          ),
          _branch(
            path: AppRoutes.learnPath,
            name: AppRoutes.learn,
            screen: const LearnScreen(),
          ),
          _branch(
            path: AppRoutes.gamesPath,
            name: AppRoutes.games,
            screen: const GamesScreen(),
          ),
          _branch(
            path: AppRoutes.rewardsPath,
            name: AppRoutes.rewards,
            screen: const RewardsScreen(),
          ),
          _branch(
            path: AppRoutes.profilePath,
            name: AppRoutes.profile,
            screen: const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) =>
        _fadePage(state: state, child: const RouteErrorScreen()),
  );
}

StatefulShellBranch _branch({
  required String path,
  required String name,
  required Widget screen,
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        name: name,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: screen),
      ),
    ],
  );
}

CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) {
        return child;
      }
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
