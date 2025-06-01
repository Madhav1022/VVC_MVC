import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../models/contact_model.dart';
import '../controllers/auth_controller.dart';

class ContactRemoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage  _storage   = FirebaseStorage.instance;
  final String?         _userId    = AuthController().userId;

  Future<String> uploadContactImage({
    required File imageFile,
    required String contactId,
  }) async {
    if (_userId == null) throw Exception('Not authenticated');
    final fileName = p.basename(imageFile.path);
    final ref = _storage
        .ref()
        .child('users/$_userId/contacts/$contactId/$fileName');

    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }

  /// Add or update a contact (with optional image upload)
  Future<void> setContact(
      ContactModel contact, {
        File? imageFile,
      }) async {
    if (_userId == null) throw Exception('Not authenticated');
    final docRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('contacts')
        .doc(contact.id.toString());

    final data = contact.toMap();
    if (imageFile != null) {
      final url = await uploadContactImage(
        imageFile: imageFile,
        contactId: contact.id.toString(),
      );
      data['image'] = url;
    }

    await docRef.set(data);
  }

  /// Delete both Firestore doc and its Storage folder
  Future<void> deleteContact(String contactId) async {
    if (_userId == null) throw Exception('Not authenticated');
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('contacts')
        .doc(contactId)
        .delete();

    final folder = _storage.ref('users/$_userId/contacts/$contactId');
    final items = await folder.listAll();
    for (final item in items.items) {
      await item.delete();
    }
  }

  /// Fetch one contact by ID from Firestore
  Future<ContactModel> fetchContactById(String contactId) async {
    if (_userId == null) throw Exception('Not authenticated');
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('contacts')
        .doc(contactId)
        .get();
    if (!doc.exists) throw Exception('Contact not found');
    final data = doc.data()!..['id'] = int.parse(doc.id);
    return ContactModel.fromMap(data);
  }

  /// One-time fetch (all or only favorites)
  Future<List<ContactModel>> fetchContacts({bool favorites = false}) async {
    if (_userId == null) throw Exception('Not authenticated');
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(_userId)
        .collection('contacts');
    if (favorites) query = query.where('favorite', isEqualTo: 1);

    final snap = await query.get();
    return snap.docs.map((doc) {
      final data = doc.data()..['id'] = int.parse(doc.id);
      return ContactModel.fromMap(data);
    }).toList();
  }

  /// Real-time streaming of all contacts
  Stream<List<ContactModel>> streamContacts() {
    if (_userId == null) throw Exception('Not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('contacts')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data()..['id'] = int.parse(doc.id);
      return ContactModel.fromMap(data);
    }).toList());
  }
}
