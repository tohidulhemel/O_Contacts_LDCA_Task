import '../database/database_helper.dart';
import '../models/contact.dart';

// Sits between the UI (screens) and the database.
// Screens call these methods instead of talking to DatabaseHelper directly.
// This keeps screens simple and makes it easy to add extra logic later
// (e.g. logging, validation, error handling) in one place.
class ContactService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CREATE
  Future<void> addContact(Contact contact) async {
    try {
      await _dbHelper.insertContact(contact);
    } catch (e) {
      throw Exception('Failed to add contact. Please try again.');
    }
  }

  // READ all
  Future<List<Contact>> getAllContacts() async {
    try {
      return await _dbHelper.getContacts();
    } catch (e) {
      throw Exception('Failed to load contacts.');
    }
  }

  // READ one
  Future<Contact?> getContact(int id) async {
    try {
      return await _dbHelper.getContactById(id);
    } catch (e) {
      throw Exception('Failed to load contact details.');
    }
  }

  // UPDATE
  Future<void> updateContact(Contact contact) async {
    try {
      await _dbHelper.updateContact(contact);
    } catch (e) {
      throw Exception('Failed to update contact. Please try again.');
    }
  }

  // DELETE
  Future<void> deleteContact(int id) async {
    try {
      await _dbHelper.deleteContact(id);
    } catch (e) {
      throw Exception('Failed to delete contact. Please try again.');
    }
  }

  // FAVORITE: flips the favorite flag and returns the new value.
  Future<bool> toggleFavorite(Contact contact) async {
    try {
      final bool newValue = !contact.isFavorite;
      await _dbHelper.updateFavorite(contact.id!, newValue);
      return newValue;
    } catch (e) {
      throw Exception('Failed to update favorite status.');
    }
  }

  // Returns only favorite contacts.
  Future<List<Contact>> getFavorites() async {
    try {
      return await _dbHelper.getFavoriteContacts();
    } catch (e) {
      throw Exception('Failed to load favorite contacts.');
    }
  }

  // SEARCH by name. Empty query returns all contacts.
  Future<List<Contact>> searchContacts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllContacts();
      }
      return await _dbHelper.searchContacts(query.trim());
    } catch (e) {
      throw Exception('Failed to search contacts.');
    }
  }
}