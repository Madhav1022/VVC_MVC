import 'dart:async';
import '../models/contact_model.dart';
import '../database/db_helper.dart';

class ContactListController {
  static final ContactListController _instance = ContactListController._internal();
  factory ContactListController() => _instance;
  ContactListController._internal();

  final _contactStreamController = StreamController<List<ContactModel>>.broadcast();
  Stream<List<ContactModel>> get contactStream => _contactStreamController.stream;
  final DbHelper _dbHelper = DbHelper();
  bool _showingFavorites = false;

  void dispose() {
    _contactStreamController.close();
  }

  //Load Contacts (All or Favorites)
  Future<void> loadContacts({bool favorites = false}) async {
    _showingFavorites = favorites;
    final contacts = favorites
        ? await _dbHelper.getAllFavoriteContacts()
        : await _dbHelper.getAllContacts();
    _contactStreamController.add(contacts);
  }

  //Add Contact and Instantly Update UI
  Future<void> addContact(ContactModel contact) async {
    await _dbHelper.insertContact(contact);
    await loadContacts(favorites: _showingFavorites);
  }

  //Delete Contact and Instantly Update UI
  Future<void> deleteContact(int id) async {
    await _dbHelper.deleteContact(id);
    await loadContacts(favorites: _showingFavorites);
  }

  //Toggle Favorite and Instantly Update UI
  Future<void> toggleFavorite(ContactModel contact) async {
    await _dbHelper.updateFavorite(contact.id!, contact.favorite ? 0 : 1);
    await loadContacts(favorites: _showingFavorites);
  }

  Future<ContactModel?> getContactById(int id) async {
    return await _dbHelper.getContactById(id);
  }
}
