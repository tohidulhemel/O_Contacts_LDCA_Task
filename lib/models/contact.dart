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