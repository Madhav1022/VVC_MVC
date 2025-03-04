import 'package:virtual_visiting_card_mvc/database/db_helper.dart';
import 'package:virtual_visiting_card_mvc/models/contact_model.dart';

class ContactController {
  final DbHelper _dbHelper = DbHelper();

  // Insert a new contact into the database
  Future<int> addContact(ContactModel contact) async {
    
    return await _dbHelper.insertContact(contact);
  }

  // Fetch all contacts from the database
  Future<List<ContactModel>> fetchAllContacts() async {
    return await _dbHelper.getAllContacts();
  }

  // Fetch only favorite contacts
  Future<List<ContactModel>> fetchFavoriteContacts() async {
    return await _dbHelper.getAllFavoriteContacts();
  }

  // Fetch a specific contact by ID
  Future<ContactModel?> fetchContactById(int id) async {
    return await _dbHelper.getContactById(id);
  }

  // Delete a contact from the database
  Future<int> deleteContact(int id) async {
    return await _dbHelper.deleteContact(id);
  }

  // Toggle a contact's favorite status
  Future<void> toggleFavorite(ContactModel contact) async {
    int newValue = contact.favorite ? 0 : 1;
    await _dbHelper.updateFavorite(contact.id!, newValue);
  }
}
