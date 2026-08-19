import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../utils/app_theme.dart';

// Reusable row widget showing one contact.
// Used on Home, Favorites, and Search results — never duplicated.
class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onFavoriteTap,
  });

  // Builds "AS" style initials from the contact's name.
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        // new
 leading: CircleAvatar(
  backgroundColor: contact.avatarColor.withValues(alpha: .15),
  child: Text(
    contact.initials,
    style: TextStyle(
      color: contact.avatarColor,
      fontWeight: FontWeight.bold,
    ),
  ),
),
        title: Text(
          contact.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.phone, style: Theme.of(context).textTheme.bodySmall),
            if (contact.email.isNotEmpty)
              Text(contact.email, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: contact.isFavorite
                    ? AppTheme.favoriteColor
                    : Colors.grey,
              ),
              onPressed: onFavoriteTap,
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}