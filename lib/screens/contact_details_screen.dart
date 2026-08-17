import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../utils/app_theme.dart';
import 'edit_contact_screen.dart';

class ContactDetailsScreen extends StatefulWidget {
  final int contactId;

  const ContactDetailsScreen({super.key, required this.contactId});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  final ContactService _contactService = ContactService();

  Contact? _contact;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    setState(() => _isLoading = true);
    try {
      final contact = await _contactService.getContact(widget.contactId);
      if (!mounted) return;
      setState(() {
        _contact = contact;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e);
    }
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_contact == null) return;
    try {
      await _contactService.toggleFavorite(_contact!);
      _loadContact();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _editContact() async {
    if (_contact == null) return;
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditContactScreen(contact: _contact!)),
    );
    if (changed == true) {
      _loadContact();
    }
  }

  Future<void> _confirmDelete() async {
    if (_contact == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text(
          'Are you sure you want to delete ${_contact!.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _contactService.deleteContact(_contact!.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted')),
        );
        Navigator.pop(context);
      } catch (e) {
        _showError(e);
      }
    }
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(value.isEmpty ? '-' : value),
        subtitle: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_contact == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contact Details')),
        body: const Center(child: Text('Contact not found.')),
      );
    }

    final contact = _contact!;
    final initials = contact.name.isNotEmpty
        ? contact.name.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editContact),
          IconButton(icon: const Icon(Icons.delete), onPressed: _confirmDelete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(contact.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    contact.isFavorite ? Icons.star : Icons.star_border,
                    color: contact.isFavorite
                        ? AppTheme.favoriteColor
                        : Colors.grey,
                  ),
                  label: Text(
                    contact.isFavorite ? 'Favorite' : 'Add to Favorites',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _infoTile(Icons.phone_outlined, 'Phone', contact.phone),
          _infoTile(Icons.email_outlined, 'Email', contact.email),
          _infoTile(Icons.location_on_outlined, 'Address', contact.address),
        ],
      ),
    );
  }
}