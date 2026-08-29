import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../widgets/tactical_bottom_nav.dart';
import '../map/live_map_screen.dart';
import '../squad/squad_screen.dart';
import '../group/group_management_screen.dart';
import '../settings/settings_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize local network P2P listener
    ref.watch(p2pTelemetryServiceProvider);
    final currentIndex = ref.watch(selectedTabProvider);

    final List<Widget> screens = const [
      LiveMapScreen(),
      SquadScreen(),
      GroupManagementScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: TacticalBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
      ),
    );
  }
}
