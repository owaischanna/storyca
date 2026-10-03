import 'package:go_router/go_router.dart';
import 'package:storryca/src/app/router/route_names.dart';
import 'package:storryca/src/core/network/models/follow_api_model.dart';
import 'package:storryca/src/features/account/presentation/pages/account_security.dart';
import 'package:storryca/src/features/account/presentation/pages/active_sessions.dart';
import 'package:storryca/src/features/account/presentation/pages/change_password.dart';
import 'package:storryca/src/features/account/presentation/pages/disable_tsv.dart';
import 'package:storryca/src/features/account/presentation/pages/enable_tsv.dart';
import 'package:storryca/src/features/account/presentation/pages/login_activity.dart';
import 'package:storryca/src/features/account/presentation/pages/security_alerts.dart';
import 'package:storryca/src/features/account/presentation/pages/tsv_enabled_success.dart';
import 'package:storryca/src/features/account/presentation/pages/two_step_verification.dart';
import 'package:storryca/src/features/auth/presentation/pages/forgot_password.dart';
import 'package:storryca/src/features/auth/presentation/pages/reset_password.dart';
import 'package:storryca/src/features/auth/presentation/pages/signin.dart';
import 'package:storryca/src/features/auth/presentation/pages/signup.dart';
import 'package:storryca/src/features/auth/presentation/pages/verify_email.dart';
import 'package:storryca/src/features/auth/presentation/pages/verify_two_factor.dart';
import 'package:storryca/src/features/author/presentation/pages/author_center.dart';
import 'package:storryca/src/features/author/presentation/pages/author_profile.dart';
import 'package:storryca/src/features/author/presentation/pages/become_author.dart';
import 'package:storryca/src/features/author/presentation/pages/see_all_author_stories.dart';
import 'package:storryca/src/features/discover/presentation/pages/see_all_stories.dart';
import 'package:storryca/src/features/earn/presentation/pages/earn.dart';
import 'package:storryca/src/features/home/presentation/pages/see_all_authors.dart';
import 'package:storryca/src/features/inbox/presentation/pages/inbox.dart';
import 'package:storryca/src/features/main/presentation/pages/main.dart';
import 'package:storryca/src/features/network/presentation/pages/network.dart';
import 'package:storryca/src/features/onboarding/presentation/pages/onboarding.dart';
import 'package:storryca/src/features/profile/presentation/pages/edit_profile.dart';
import 'package:storryca/src/features/search/presentation/pages/search.dart';
import 'package:storryca/src/features/splash/presentation/pages/splash.dart';
import 'package:storryca/src/features/story/presentation/pages/chapters.dart';
import 'package:storryca/src/features/story/presentation/pages/new_story.dart';
import 'package:storryca/src/features/story/presentation/pages/read.dart';
import 'package:storryca/src/features/story/presentation/pages/story.dart';
import 'package:storryca/src/features/story/presentation/pages/story_created.dart';
import 'package:storryca/src/features/story/presentation/pages/story_details.dart';
import 'package:storryca/src/features/story/presentation/widgets/write.dart';
import 'package:storryca/src/features/topup/presentation/pages/topup.dart';
import 'package:storryca/src/features/topup/presentation/pages/transaction_history.dart';
import 'package:storryca/src/features/user/presentation/pages/user_profile.dart';

GoRouter createRouter() {
  String initialLocation = '/';

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const Splash(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const Onboarding(),
      ),
      GoRoute(
        path: '${RouteNames.main}/:tabIndex',
        name: 'main_tab',
        builder: (context, state) {
          final index =
              int.tryParse(state.pathParameters['tabIndex'] ?? '') ?? 0;
          return Main(initialIndex: index);
        },
      ),
      GoRoute(
        path: RouteNames.main,
        name: 'main',
        builder: (context, state) => const Main(),
      ),
      GoRoute(
        path: RouteNames.accountSecurity,
        name: 'account-security',
        builder: (context, state) => const AccountSecurity(),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        name: 'edit-profile',
        builder: (context, state) => const EditProfile(),
      ),
      GoRoute(
        path: RouteNames.changePassword,
        name: 'change-password',
        builder: (context, state) => const ChangePassword(),
      ),
      GoRoute(
        path: RouteNames.twoStepVerification,
        name: 'two-step-verification',
        builder: (context, state) => const TwoStepVerification(),
      ),
      GoRoute(
        path: RouteNames.enableTSV,
        name: 'enable-tsv',
        builder: (context, state) => const EnableTSV(),
      ),
      GoRoute(
        path: RouteNames.tsvEnabledSuccess,
        name: 'tsv-enabled-success',
        builder: (context, state) => const TsvEnabledSuccess(),
      ),
      GoRoute(
        path: RouteNames.disableTSV,
        name: 'disable-tsv',
        builder: (context, state) => const DisableTSV(),
      ),
      GoRoute(
        path: RouteNames.activeSessions,
        name: 'active-sessions',
        builder: (context, state) => const ActiveSessions(),
      ),
      GoRoute(
        path: RouteNames.loginActivity,
        name: 'login-activity',
        builder: (context, state) => const LoginActivity(),
      ),
      GoRoute(
        path: RouteNames.securityAlerts,
        name: 'security-alerts',
        builder: (context, state) => const SecurityAlerts(),
      ),
      GoRoute(
        path: RouteNames.search,
        name: 'search',
        builder: (context, state) => const Search(),
      ),
      GoRoute(
        path: RouteNames.signin,
        name: 'signin',
        builder: (context, state) => const SignIn(),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignUp(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPassword(),
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        name: 'verify-email',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VerifyEmail(
            email: extra?['email'] as String? ?? '',
            token: extra?['token'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: 'reset-password',
        builder: (context, state) => const ResetPassword(),
      ),
      GoRoute(
        path: RouteNames.verifyTwoFactorLogin,
        name: 'verify-two-factor',
        builder: (context, state) => const VerifyTwoFactor(),
      ),
      GoRoute(
        path: RouteNames.topup,
        name: 'topup',
        builder: (context, state) => const Topup(),
      ),
      GoRoute(
        path: RouteNames.transactionHistory,
        name: 'transaction-history',
        builder: (context, state) => const TransactionHistory(),
      ),
      GoRoute(
        path: RouteNames.inbox,
        name: 'inbox',
        builder: (context, state) => const Inbox(),
      ),
      GoRoute(
        path: '${RouteNames.network}/:tab',
        name: 'network',
        builder: (context, state) {
          final tab = state.pathParameters['tab'] ?? '';
          final userId = int.tryParse(state.uri.queryParameters['userId'] ?? '');
          return Network(tab: tab, userId: userId);
        },
      ),
      GoRoute(
        path: '${RouteNames.authorProfile}/:id',
        name: 'author-profile',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return AuthorProfile(id: id);
        },
      ),
      GoRoute(
        path: RouteNames.seeAllAuthors,
        name: 'see-all-authors',
        builder: (context, state) => const SeeAllAuthors(),
      ),
      GoRoute(
        path: '${RouteNames.seeAllStories}/:sort',
        name: 'see-all-stories',
        builder: (context, state) {
          final sort = state.pathParameters['sort'] ?? 'popular';
          final title = switch (sort) {
            'latest' => 'New Releases',
            'popular' => 'Recommended For You',
            'trending' => 'Trending Now',
            _ => 'Stories',
          };
          return SeeAllStories(title: title, sort: sort);
        },
      ),
      GoRoute(
        path: '${RouteNames.seeAllAuthorStories}/:id',
        name: 'see-all-author-stories',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return SeeAllAuthorStories(authorId: id);
        },
      ),
      GoRoute(
        path: RouteNames.userProfile,
        name: 'user-profile',
        builder: (context, state) =>
            UserProfile(user: state.extra as FollowUserApiModel),
      ),
      GoRoute(
        path: RouteNames.earn,
        name: 'earn',
        builder: (context, state) => const Earn(),
      ),
      GoRoute(
        path: '${RouteNames.story}/:id',
        name: 'story',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return Story(id: id);
        },
      ),
      GoRoute(
        path: '${RouteNames.read}/:id',
        name: 'read',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return Read(id: id);
        },
      ),
      GoRoute(
        path: RouteNames.becomeAuthor,
        name: 'become-author',
        builder: (context, state) => const BecomeAuthor(),
      ),
      GoRoute(
        path: RouteNames.authorCenter,
        name: 'author-center',
        builder: (context, state) => const AuthorCenter(),
      ),
      GoRoute(
        path: RouteNames.newStory,
        name: 'new-story',
        builder: (context, state) => const NewStory(),
      ),
      GoRoute(
        path: '${RouteNames.storyCreated}/:storyId',
        name: 'story-created',
        builder: (context, state) {
          final storyId =
              int.tryParse(state.pathParameters['storyId'] ?? '') ?? 0;
          return StoryCreated(storyId: storyId, submitted: state.extra == true);
        },
      ),
      GoRoute(
        path: '${RouteNames.chapters}/:storyId',
        name: 'chapters',
        builder: (context, state) {
          final storyId =
              int.tryParse(state.pathParameters['storyId'] ?? '') ?? 0;
          return Chapters(storyId: storyId);
        },
      ),
      GoRoute(
        path: '${RouteNames.storyDetails}/:storyId',
        name: 'story-details',
        builder: (context, state) {
          final storyId =
              int.tryParse(state.pathParameters['storyId'] ?? '') ?? 0;
          return StoryDetails(storyId: storyId);
        },
      ),
      GoRoute(
        path: '${RouteNames.write}/:storyId/:chapterId',
        name: 'write',
        builder: (context, state) {
          final storyId =
              int.tryParse(state.pathParameters['storyId'] ?? '') ?? 0;
          final chapterId =
              int.tryParse(state.pathParameters['chapterId'] ?? '') ?? 0;
          return Write(storyId: storyId, chapterId: chapterId);
        },
      ),
    ],
  );
}
