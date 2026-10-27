import 'package:flutter/material.dart';

import '../language/ui_text.dart';
import '../navigation/app_destination.dart';
import '../services/auth_service.dart';
import 'appointments_screen.dart';
import 'consultation_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

/// Signed-in frame: app bar, one page, and the tab control.
///
/// Phones use a bottom bar. Windows at least [MainShell.railBreakpoint]
/// wide use a side rail, so the same pages work on a handset and on a
/// desktop browser.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.user, required this.authService});

  final SignedInUser user;
  final AuthService authService;

  static const railBreakpoint = 840.0;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = AppDestination.home.index;
  int _unreadMessages = 0;
  late SignedInUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _select(AppDestination destination) {
    setState(() => _index = destination.index);
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(authService: widget.authService),
      ),
    );
  }

  void _applyUser(SignedInUser user) {
    setState(() => _user = user);
  }

  void _setUnreadMessages(int count) {
    if (count == _unreadMessages) {
      return;
    }
    setState(() => _unreadMessages = count);
  }

  Widget _pageFor(AppDestination destination) {
    switch (destination) {
      case AppDestination.home:
        return HomeScreen(
          user: _user,
          authService: widget.authService,
          active: _index == AppDestination.home.index,
          onOpen: _select,
        );
      case AppDestination.appointments:
        return AppointmentsScreen(
          user: _user,
          authService: widget.authService,
        );
      case AppDestination.messages:
        return MessagesScreen(
          authService: widget.authService,
          token: _user.token,
          active: _index == AppDestination.messages.index,
          onUnreadChanged: _setUnreadMessages,
        );
      case AppDestination.consultation:
        return const ConsultationScreen();
      case AppDestination.profile:
        return ProfileScreen(
          user: _user,
          authService: widget.authService,
          onLogout: _logout,
          onUserChanged: _applyUser,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= MainShell.railBreakpoint;
    final current = AppDestination.values[_index];
    final l10n = context.l10n;
    // Off-screen tabs stay built, so a later list can keep its scroll position.
    final pages = IndexedStack(
      index: _index,
      alignment: Alignment.topCenter,
      children: [
        for (final destination in AppDestination.values) _pageFor(destination),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(current.localizedLabel(l10n))),
      body: wide
          ? Row(
              children: [
                _SideRail(
                  selectedIndex: _index,
                  unreadMessages: _unreadMessages,
                  onSelect: _select,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages),
              ],
            )
          : pages,
      bottomNavigationBar: wide
          ? null
          : _BottomBar(
              selectedIndex: _index,
              unreadMessages: _unreadMessages,
              onSelect: _select,
            ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.selectedIndex,
    required this.unreadMessages,
    required this.onSelect,
  });

  final int selectedIndex;
  final int unreadMessages;
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
            icon: _navIcon(destination, destination.icon, unreadMessages),
            selectedIcon: _navIcon(
              destination,
              destination.selectedIcon,
              unreadMessages,
            ),
            label: destination.localizedLabel(context.l10n),
          ),
      ],
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.selectedIndex,
    required this.unreadMessages,
    required this.onSelect,
  });

  final int selectedIndex;
  final int unreadMessages;
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
            icon: _navIcon(destination, destination.icon, unreadMessages),
            selectedIcon: _navIcon(
              destination,
              destination.selectedIcon,
              unreadMessages,
            ),
            label: Text(destination.localizedLabel(context.l10n)),
          ),
      ],
    );
  }
}

Widget _navIcon(AppDestination destination, IconData icon, int unreadMessages) {
  final child = Icon(icon);
  if (destination != AppDestination.messages || unreadMessages <= 0) {
    return child;
  }
  final label = unreadMessages > 99 ? '99+' : '$unreadMessages';
  return Badge(
    label: Text(label),
    backgroundColor: const Color(0xFFE53935),
    textColor: Colors.white,
    child: child,
  );
}
