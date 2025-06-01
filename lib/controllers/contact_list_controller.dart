import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/contact_model.dart';
import '../database/db_helper.dart';
import '../controllers/auth_controller.dart';
import '../services/contact_remote_service.dart';
import '../utils/helper_functions.dart';


class ContactListController {
  static final ContactListController _instance = ContactListController._internal();
  factory ContactListController() => _instance;
  ContactListController._internal();

  final _streamer    = StreamController<List<ContactModel>>.broadcast();
  Stream<List<ContactModel>> get contactStream => _streamer.stream;

  final DbHelper               _dbHelper   = DbHelper();
  final AuthController         _auth       = AuthController();
  final ContactRemoteService   _remote     = ContactRemoteService();

  bool _showingFavorites = false;
  String? get _uid => _auth.userId;

  void dispose() => _streamer.close();
  
  /// Load from Firestore with latency measurement
  Future<void> loadContacts({bool favorites = false}) async {
    _showingFavorites = favorites;
    if (_uid == null) {
      _streamer.add([]);
      return;
    }

    // Measure Firestore fetch latency
    final startTime = DateTime.now();
    final contacts = await _remote.fetchContacts(favorites: favorites);
    final endTime = DateTime.now();
    final durationMs = endTime.difference(startTime).inMilliseconds;

    // Log Firestore latency
    await logLatency('Fetch Contacts from Firestore', durationMs, source: 'Firestore');

    _streamer.add(contacts);
  }



  /// Add (SQLite + Firestore+Storage)
  Future<void> addContact(ContactModel contact) async {
    if (_uid == null) return;
    contact.userId = _uid!;

    // 1) Local insert
    final newId = await _dbHelper.insertContact(contact);
    contact.id = newId;

    // 2) Locate image in docs/ if any
    File? imgFile;
    if (contact.image.isNotEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final f = File(p.join(dir.path, contact.image));
      if (await f.exists()) imgFile = f;
    }

    // 3) Firestore + Storage
    await _remote.setContact(contact, imageFile: imgFile);

    // 4) Refresh UI
    await loadContacts(favorites: _showingFavorites);
  }

  /// Delete (SQLite + Firestore+Storage)
  Future<void> deleteContact(int id) async {
    if (_uid == null) return;
    await _dbHelper.deleteContact(id, _uid!);
    await _remote.deleteContact(id.toString());
    await loadContacts(favorites: _showingFavorites);
  }

  /// Toggle favorite (SQLite + Firestore)
  Future<void> toggleFavorite(ContactModel contact) async {
    if (_uid == null) return;
    final newVal = contact.favorite ? 0 : 1;
    await _dbHelper.updateFavorite(contact.id, newVal, _uid!);
    contact.favorite = !contact.favorite;

    await _remote.setContact(contact);
    await loadContacts(favorites: _showingFavorites);
  }

  /// Fetch single contact—from **Firestore** now
  Future<ContactModel?> getContactById(int id) async {
    if (_uid == null) return null;
    return await _remote.fetchContactById(id.toString());
  }
}
