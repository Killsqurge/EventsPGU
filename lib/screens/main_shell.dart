import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../widgets/add_event_sheet.dart';
import '../widgets/bottom_nav.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  var _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.refreshEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _tab,
              children: [
                HomePage(controller: widget.controller),
                FavoritesPage(controller: widget.controller),
                ProfilePage(controller: widget.controller),
              ],
            ),
          ),
          bottomNavigationBar: AppBottomNav(
            tab: _tab,
            controller: widget.controller,
            onTab: (tab) => setState(() => _tab = tab),
            onAdd: () => showAddEventSheet(context, widget.controller),
          ),
        );
      },
    );
  }
}
