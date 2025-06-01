import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:virtual_visiting_card_mvc/models/contact_model.dart';
import 'package:virtual_visiting_card_mvc/utils/constants.dart';

class DbHelper {
  final String _createTableContact = '''
    CREATE TABLE $tableContact(
      $tblContactColId INTEGER PRIMARY KEY AUTOINCREMENT,
      $tblContactColName TEXT,
      $tblContactColMobile TEXT,
      $tblContactColEmail TEXT,
      $tblContactColAddress TEXT,
      $tblContactColCompany TEXT,
      $tblContactColDesignation TEXT,
      $tblContactColWebsite TEXT,
      $tblContactColImage TEXT,
      $tblContactColFavorite INTEGER,
      $tblContactColUserId TEXT
    )
  ''';

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    final dbPath = path.join(root, 'contact.db');
    return openDatabase(
      dbPath,
      version: 3, // Increment version number for schema change
      onCreate: (db, version) {
        db.execute(_createTableContact);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // If upgrading from version 1 or 2 to version 3, add the user_id column
          await db.execute('ALTER TABLE $tableContact ADD COLUMN $tblContactColUserId TEXT');
        }
      },
    );
  }

  Future<int> insertContact(ContactModel contactModel) async {
    final db = await _open();
    return db.insert(tableContact, contactModel.toMap());
  }

  Future<List<ContactModel>> getAllContacts({required String userId}) async {
    final db = await _open();
    final mapList = await db.query(
      tableContact,
      where: '$tblContactColUserId = ?',
      whereArgs: [userId],
    );
    return List.generate(
      mapList.length,
          (index) => ContactModel.fromMap(mapList[index]),
    );
  }

  Future<ContactModel> getContactById(int id, String userId) async {
    final db = await _open();
    final mapList = await db.query(
      tableContact,
      where: '$tblContactColId = ? AND $tblContactColUserId = ?',
      whereArgs: [id, userId],
    );

    if (mapList.isEmpty) {
      throw Exception('Contact not found');
    }

    return ContactModel.fromMap(mapList.first);
  }

  Future<List<ContactModel>> getAllFavoriteContacts({required String userId}) async {
    final db = await _open();
    final mapList = await db.query(
      tableContact,
      where: '$tblContactColFavorite = ? AND $tblContactColUserId = ?',
      whereArgs: [1, userId],
    );
    return List.generate(
      mapList.length,
          (index) => ContactModel.fromMap(mapList[index]),
    );
  }

  Future<int> deleteContact(int id, String userId) async {
    final db = await _open();
    return db.delete(
      tableContact,
      where: '$tblContactColId = ? AND $tblContactColUserId = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> updateFavorite(int id, int value, String userId) async {
    final db = await _open();
    return db.update(
      tableContact,
      {tblContactColFavorite: value},
      where: '$tblContactColId = ? AND $tblContactColUserId = ?',
      whereArgs: [id, userId],
    );
  }
}