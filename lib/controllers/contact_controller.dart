import 'package:virtual_visiting_card_mvc/controllers/auth_controller.dart';
import 'package:virtual_visiting_card_mvc/database/db_helper.dart';
import 'package:virtual_visiting_card_mvc/models/contact_model.dart';

class ContactController {
  final DbHelper _dbHelper = DbHelper();
  final AuthController _authController = AuthController();

  // Get the current user ID
  String? get _userId => _authController.userId;

  // Insert a new contact into the database
  Future<int> addContact(ContactModel contact) async {
    // Ensure user is authenticated
    if (_userId == null) return -1;

    // Add user ID to contact
    contact.userId = _userId!;

    return await _dbHelper.insertContact(contact);
  }

  // Fetch all contacts from the database
  Future<List<ContactModel>> fetchAllContacts() async {
    // Ensure user is authenticated
    if (_userId == null) return [];

    return await _dbHelper.getAllContacts(userId: _userId!);
  }

  // Fetch only favorite contacts
  Future<List<ContactModel>> fetchFavoriteContacts() async {
    // Ensure user is authenticated
    if (_userId == null) return [];

    return await _dbHelper.getAllFavoriteContacts(userId: _userId!);
  }

  // Fetch a specific contact by ID
  Future<ContactModel?> fetchContactById(int id) async {
    // Ensure user is authenticated
    if (_userId == null) return null;

    return await _dbHelper.getContactById(id, _userId!);
  }

  // Delete a contact from the database
  Future<int> deleteContact(int id) async {
    // Ensure user is authenticated
    if (_userId == null) return 0;

    return await _dbHelper.deleteContact(id, _userId!);
  }

  // Toggle a contact's favorite status
  Future<void> toggleFavorite(ContactModel contact) async {
    // Ensure user is authenticated
    if (_userId == null) return;

    int newValue = contact.favorite ? 0 : 1;
    await _dbHelper.updateFavorite(contact.id, newValue, _userId!);
  }
}