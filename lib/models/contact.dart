import 'package:flutter/material.dart';
// A simple data class representing one contact.
// Handles converting between a Contact object and a Map,
// because sqflite stores/retrieves rows as Map<String, dynamic>.
class Contact {
  final int? id; // null until saved to the database (auto-generated)
  final String name;
  final String phone;
  final String email;
  final String address;
  final bool isFavorite;

  // A fixed palette of distinct, readable colors.
  // Using a static list (not Colors.primaries) keeps the result
  // predictable and visually consistent with the app's theme.
 
  Contact({
    this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.isFavorite = false,
  });

  // Converts this Contact into a Map so it can be inserted/updated in SQLite.
  // isFavorite is stored as 0 or 1 because SQLite has no boolean type.
  Map<String, dynamic> toMap() {
    return {
      // Only include id if it's not null, so autoincrement can work on insert.
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  // Builds a Contact object from a database row (Map).
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
    );
  }

String get initials {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
   // A fixed palette of distinct, readable colors.
  // Using a static list (not Colors.primaries) keeps the result
  // predictable and visually consistent with the app's theme.
  static const List<Color> _avatarColors = [
    Color(0xFF7E57C2), // purple
    Color(0xFF43A047), // green
    Color(0xFF1E88E5), // blue
    Color(0xFFFB8C00), // orange
    Color(0xFFE53935), // red
    Color(0xFF00897B), // teal
    Color(0xFFD81B60), // pink
    Color(0xFF6D4C41), // brown
  ];

  // Deterministically picks a color based on the contact's name,
  // so the same name always maps to the same color everywhere in the app.
  Color get avatarColor {
    if (name.trim().isEmpty) return _avatarColors.first;
    final int hash = name.trim().toLowerCase().codeUnits.fold(
          0,
          (previous, unit) => previous + unit,
        );
    return _avatarColors[hash % _avatarColors.length];
  } 

  // Helpful when editing: returns a copy of this contact with some fields changed.
  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    bool? isFavorite,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}