import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/auth_service.dart';
import 'package:storryca/src/core/network/device_service.dart';
import 'package:storryca/src/core/network/play_billing_service.dart';
import 'package:storryca/src/core/network/push_service.dart';
import 'package:storryca/src/core/network/repositories/authors_repository.dart';
import 'package:storryca/src/core/network/repositories/chapters_repository.dart';
import 'package:storryca/src/core/network/repositories/follow_repository.dart';
import 'package:storryca/src/core/network/repositories/library_repository.dart';
import 'package:storryca/src/core/network/repositories/moderation_repository.dart';
import 'package:storryca/src/core/network/repositories/reviews_repository.dart';
import 'package:storryca/src/core/network/repositories/stories_repository.dart';
import 'package:storryca/src/core/network/repositories/users_repository.dart';
import 'package:storryca/src/core/network/repositories/wallet_repository.dart';

final ApiClient apiClient = ApiClient();
final StoriesRepository storiesRepository = StoriesRepository(apiClient);
final AuthorsRepository authorsRepository = AuthorsRepository(apiClient);
final ChaptersRepository chaptersRepository = ChaptersRepository(apiClient);
final LibraryRepository libraryRepository = LibraryRepository(apiClient);
final UsersRepository usersRepository = UsersRepository(apiClient);
final FollowRepository followRepository = FollowRepository(apiClient);
final ReviewsRepository reviewsRepository = ReviewsRepository(apiClient);
final ModerationRepository moderationRepository = ModerationRepository(apiClient);
final WalletRepository walletRepository = WalletRepository(apiClient);
final AuthService authService = AuthService(apiClient);
final DeviceService deviceService = DeviceService();
final PlayBillingService playBillingService = PlayBillingService(
  walletRepository,
  authService,
);
final PushService pushService = PushService(usersRepository, authService);
