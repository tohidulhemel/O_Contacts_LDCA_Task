import 'package:contacts_ldca_app/screens/add_contact_screen.dart';
import 'package:contacts_ldca_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../widgets/contact_card.dart';
import '../widgets/empty_contacts_view.dart';
import 'contact_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ContactService _contactService = ContactService();
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _allFavorites = []; // full favorites list, loaded from DB
  List<Contact> _displayedFavorites = []; // filtered view shown on screen
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _contactService.getFavorites();
      if (!mounted) return;
      setState(() {
        _allFavorites = favorites;
        _displayedFavorites = _filterByQuery(favorites, _searchController.text);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e);
    }
  }

  
  List<Contact> _filterByQuery(List<Contact> source, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return source;
    return source
        .where((contact) => contact.name.toLowerCase().contains(trimmed))
        .toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _displayedFavorites = _filterByQuery(_allFavorites, query);
    });
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _displayedFavorites = _allFavorites;
    });
  }

  Future<void> _toggleFavorite(Contact contact) async {
    try {
      await _contactService.toggleFavorite(contact);
      _loadFavorites();
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    showErrorSnackBar(context, e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Color.fromARGB(255, 12, 0, 0)),
                decoration: InputDecoration(
                  hintText: 'Search favorites...',
                  hintStyle: const TextStyle(color: Color.fromARGB(179, 10, 10, 10)),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                ),
                onChanged: _onSearchChanged,
              )
            : const Text('Favorites'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _displayedFavorites.isEmpty
              ? EmptyContactsView(
                  imagePath: _isSearching ? null : 'assets/images/empty_contacts.png',
                  icon: _isSearching ? Icons.search_off : Icons.star_border,
                  title: _isSearching ? 'No matching favorites' : 'No Favorite Contacts',
                  message: _isSearching
                      ? 'Try a different name.'
                      : 'Add contacts to your favorites\nto see them here.',
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: _displayedFavorites.length,
                    itemBuilder: (context, index) {
                      final contact = _displayedFavorites[index];
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
                          _loadFavorites();
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

  void showErrorSnackBar(BuildContext context, Object e) {}

  void _loadContacts() {}
}