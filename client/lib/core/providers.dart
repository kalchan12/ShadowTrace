import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';
import '../data/repositories/sqlite_location_repository.dart';
import '../data/repositories/sqlite_friend_repository.dart';
import '../data/repositories/sqlite_group_repository.dart';
import '../data/repositories/location_repository.dart';
import '../data/repositories/friend_repository.dart';
import '../data/repositories/group_repository.dart';
import '../data/mock/mock_location_repository.dart';
import '../data/mock/mock_friend_repository.dart';
import '../data/mock/mock_group_repository.dart';
import '../services/service_bridge/service_bridge.dart';
import '../models/group.dart';
import '../models/friend.dart';
import '../models/location_update.dart';
import '../models/service_status.dart';

// Database & Service Providers
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  return AppDatabase.open();
});

final serviceBridgeProvider = Provider<ServiceBridge>((ref) {
  return ServiceBridge();
});

// Repository Providers
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final dbAsync = ref.watch(appDatabaseProvider);
  final bridge = ref.watch(serviceBridgeProvider);
  return dbAsync.when(
    data: (db) => SqliteLocationRepository(db, bridge),
    loading: () => MockLocationRepository(),
    error: (_, _) => MockLocationRepository(),
  );
});

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  final dbAsync = ref.watch(appDatabaseProvider);
  return dbAsync.when(
    data: (db) => SqliteFriendRepository(db),
    loading: () => MockFriendRepository(),
    error: (_, _) => MockFriendRepository(),
  );
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final dbAsync = ref.watch(appDatabaseProvider);
  return dbAsync.when(
    data: (db) => SqliteGroupRepository(db),
    loading: () => MockGroupRepository(),
    error: (_, _) => MockGroupRepository(),
  );
});

// IPC Future Providers
final deviceIdProvider = FutureProvider<String?>((ref) async {
  final bridge = ref.watch(serviceBridgeProvider);
  return bridge.getDeviceId();
});

final lastKnownLocationProvider = FutureProvider<LocationUpdate?>((ref) async {
  final bridge = ref.watch(serviceBridgeProvider);
  return bridge.getLastKnownLocation();
});

// State Providers
final activeGroupProvider = StateProvider<Group?>((ref) {
  return const Group(
    id: 'a8b3c4d5-e6f7-4a1b-8c2d-3e4f5a6b7c8d',
    createdByDeviceId: 'local-device-id-0000',
    createdAt: 1772184000000,
    inviteSecret: 'sec_7f9a8b1c2d3e4f5a6b7c8d9e0f1a2b3c',
  );
});

final serviceStatusProvider =
    StateNotifierProvider<ServiceStatusNotifier, ServiceStatus>((ref) {
      final bridge = ref.watch(serviceBridgeProvider);
      return ServiceStatusNotifier(bridge);
    });

class ServiceStatusNotifier extends StateNotifier<ServiceStatus> {
  final ServiceBridge _bridge;

  ServiceStatusNotifier(this._bridge) : super(ServiceStatus.initial()) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    final status = await _bridge.queryServiceStatus();
    state = status;
  }

  Future<void> toggleBroadcast(String groupId) async {
    if (state.isBroadcasting) {
      await _bridge.stopBroadcasting();
      state = state.copyWith(isBroadcasting: false, clearActiveGroupId: true);
    } else {
      await _bridge.startBroadcasting(groupId);
      state = state.copyWith(
        isBroadcasting: true,
        activeGroupId: groupId,
        lastUpdateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}

final groupFriendsProvider = StreamProvider.autoDispose<List<Friend>>((ref) {
  final activeGroup = ref.watch(activeGroupProvider);
  if (activeGroup == null) return Stream.value([]);
  final friendRepo = ref.watch(friendRepositoryProvider);
  return friendRepo.watchGroupFriends(activeGroup.id);
});

final liveLocationsStreamProvider = StreamProvider.autoDispose<LocationUpdate>((
  ref,
) {
  final activeGroup = ref.watch(activeGroupProvider);
  if (activeGroup == null) return const Stream.empty();
  final locRepo = ref.watch(locationRepositoryProvider);
  return locRepo.watchGroupLocations(activeGroup.id);
});
