import 'package:contacts_ldca_app/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../widgets/contact_card.dart';
import '../widgets/empty_contacts_view.dart';
import 'add_contact_screen.dart';
import 'contact_details_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ContactService _contactService = ContactService();

  List<Contact> _contacts = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _contactService.getAllContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e);
    }
  }

  Future<void> _runSearch(String query) async {
    try {
      final results = await _contactService.searchContacts(query);
      if (!mounted) return;
      setState(() => _contacts = results);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _toggleFavorite(Contact contact) async {
    try {
      await _contactService.toggleFavorite(contact);
      _loadContacts();
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
    );
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Color.fromARGB(255, 10, 0, 0)),
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(color: Color.fromARGB(179, 14, 0, 0)),
                  border: InputBorder.none,
                ),
                onChanged: _runSearch,
              )
            : const Text('My Contacts'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              if (_isSearching) {
                _stopSearching();
              } else {
                setState(() => _isSearching = true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
  drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: const BoxDecoration(color: AppTheme.primaryColor),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.groups, color: Colors.white, size: 40),
            SizedBox(height: 12),
            Text(
              'My Contacts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Manage your friends easily',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
      ListTile(
        leading: const Icon(Icons.people_alt_outlined, color: AppTheme.primaryColor),
        title: const Text('My Contacts'),
        selected: true,
        selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.08),
        onTap: () => Navigator.pop(context), // already on this screen
      ),

       ListTile(
        leading: const Icon(Icons.star_border),
        title: const Text('Favorites'),
        onTap: () async {
          Navigator.pop(context); // close drawer first
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          );
          _loadContacts();
        },
      ), 
      ListTile(
        leading: const Icon(Icons.person_add_alt_outlined),
        title: const Text('Add Contact'),
        onTap: () async {
          Navigator.pop(context);
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddContactScreen()),
          );
          _loadContacts();
        },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('About App'),
        onTap: () {
          Navigator.pop(context);
          showAboutDialog(
            context: context,
            applicationName: 'Contact Management App',
            applicationVersion: '1.0.0',
            children: const [
              Text('A simple Flutter app for managing contacts locally using SQLite.'),
            ],
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.settings_outlined),
        title: const Text('Settings'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
ListTile(
        leading: const Icon(Icons.logout_outlined),
        title: const Text('Log Out'),
      ),
    ],
  ),
),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? // new
   EmptyContactsView(
    imagePath: _isSearching ? null : 'assets/images/image_1.png',
    icon: _isSearching ? Icons.search_off : Icons.people_outline,
    title: _isSearching ? 'No matching contacts' : 'No contacts yet',
    message: _isSearching
        ? 'Try a different name.'
        : 'Add your first contact using the + button below.',
  )
              : RefreshIndicator(
                  onRefresh: _loadContacts,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ContactCard(
                        contact: contact,
                        onFavoriteTap: () => _toggleFavorite(contact),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ContactDetailsScreen(contactId: contact.id!),
                            ),
                          );
                          _loadContacts();
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddContactScreen()),
          );
          _loadContacts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}