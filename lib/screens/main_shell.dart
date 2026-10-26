import 'package:flutter/material.dart';

import '../navigation/app_destination.dart';
import 'appointments_screen.dart';
import 'consultation_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

/// Signed-in frame: app bar, one page, and the tab control.
///
/// Phones use a bottom bar. Windows at least [MainShell.railBreakpoint]
/// wide use a side rail, so the same pages work on a handset and on a
/// desktop browser.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.username});

  final String username;

  static const railBreakpoint = 840.0;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = AppDestination.home.index;

  void _select(AppDestination destination) {
    setState(() => _index = destination.index);
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  Widget _pageFor(AppDestination destination) {
    switch (destination) {
      case AppDestination.home:
        return HomeScreen(username: widget.username, onOpen: _select);
      case AppDestination.appointments:
        return const AppointmentsScreen();
      case AppDestination.consultation:
        return const ConsultationScreen();
      case AppDestination.profile:
        return ProfileScreen(username: widget.username, onLogout: _logout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= MainShell.railBreakpoint;
    final current = AppDestination.values[_index];
    // Off-screen tabs stay built, so a later list can keep its scroll position.
    final pages = IndexedStack(
      index: _index,
      alignment: Alignment.topCenter,
      children: [
        for (final destination in AppDestination.values) _pageFor(destination),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(current.label)),
      body: wide
          ? Row(
              children: [
                _SideRail(selectedIndex: _index, onSelect: _select),
                const VerticalDivider(width: 1),
                Expanded(child: pages),
              ],
            )
          : pages,
      bottomNavigationBar: wide
          ? null
          : _BottomBar(selectedIndex: _index, onSelect: _select),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<AppDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) {
        onSelect(AppDestination.values[index]);
      },
      destinations: [
        for (final destination in AppDestination.values)
          NavigationDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: destination.label,
          ),
      ],
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<AppDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      backgroundColor: Theme.of(context).colorScheme.surface,
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: (index) {
        onSelect(AppDestination.values[index]);
      },
      destinations: [
        for (final destination in AppDestination.values)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}
