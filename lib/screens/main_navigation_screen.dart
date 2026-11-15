import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'address_book_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<AddressBookScreenState> _addressBookKey = GlobalKey<AddressBookScreenState>();

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final accent = settings.accentColor;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              AddressBookScreen(key: _addressBookKey),
              SettingsScreen(
                onDatabaseChanged: () {
                  _addressBookKey.currentState?.reloadContacts();
                },
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              backgroundColor: const Color(0xFF1E293B),
              indicatorColor: accent.withValues(alpha: 0.25),
              elevation: 0,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
                if (index == 0) {
                  _addressBookKey.currentState?.reloadContacts();
                }
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.contacts_outlined, color: Colors.white60),
                  selectedIcon: Icon(Icons.contacts, color: accent),
                  label: 'Kontakty',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white60),
                  selectedIcon: Icon(Icons.settings, color: accent),
                  label: 'Ustawienia',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
