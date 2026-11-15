import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/contact_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const String tableName = 'contacts';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('address_book.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery('PRAGMA table_info($tableName)');
      final hasAvatar = columns.any((col) => col['name'] == 'avatar');
      if (!hasAvatar) {
        await db.execute('ALTER TABLE $tableName ADD COLUMN avatar TEXT');
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        street TEXT,
        city TEXT,
        postalCode TEXT,
        category TEXT,
        notes TEXT,
        avatar TEXT,
        createdAt TEXT
      )
    ''');

    // Seed initial data for a quick and pleasing first experience
    final initialContacts = [
      AddressContact(
        firstName: 'Jan',
        lastName: 'Kowalski',
        phone: '+48 600 123 456',
        email: 'jan.kowalski@example.pl',
        street: 'ul. Marszałkowska 10/4',
        city: 'Warszawa',
        postalCode: '00-624',
        category: 'Praca',
        notes: 'Dyrektor projektu, kontakt w dni powszednie 9-17.',
      ),
      AddressContact(
        firstName: 'Anna',
        lastName: 'Nowak',
        phone: '+48 501 987 654',
        email: 'anna.nowak@gmail.com',
        street: 'ul. Floriańska 15',
        city: 'Kraków',
        postalCode: '31-019',
        category: 'Prywatny',
        notes: 'Wspólne studia, architekt krajobrazu.',
      ),
      AddressContact(
        firstName: 'Marek',
        lastName: 'Zieliński',
        phone: '+48 722 333 444',
        email: 'm.zielinski@rodzina.pl',
        street: 'ul. Długa 42',
        city: 'Gdańsk',
        postalCode: '80-831',
        category: 'Rodzina',
        notes: 'Wujek Marek, urodziny 14 maja.',
      ),
    ];

    for (final contact in initialContacts) {
      await db.insert(tableName, contact.toMap());
    }
  }

  Future<int> insertContact(AddressContact contact) async {
    final db = await database;
    return await db.insert(tableName, contact.toMap());
  }

  Future<List<AddressContact>> getContacts({
    String? searchQuery,
    String? category,
    String? orderBy,
  }) async {
    final db = await database;

    String whereClause = '';
    final List<dynamic> whereArgs = [];

    final conditions = <String>[];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.trim().toLowerCase()}%';
      conditions.add(
        '(LOWER(firstName) LIKE ? OR LOWER(lastName) LIKE ? OR phone LIKE ? OR LOWER(email) LIKE ? OR LOWER(city) LIKE ? OR LOWER(street) LIKE ?)',
      );
      whereArgs.addAll([query, query, query, query, query, query]);
    }

    if (category != null && category.isNotEmpty && category != 'Wszystkie') {
      conditions.add('category = ?');
      whereArgs.add(category);
    }

    if (conditions.isNotEmpty) {
      whereClause = conditions.join(' AND ');
    }

    final sorting = (orderBy != null && orderBy.isNotEmpty)
        ? orderBy
        : 'lastName COLLATE NOCASE ASC, firstName COLLATE NOCASE ASC';

    final result = await db.query(
      tableName,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: sorting,
    );

    return result.map((json) => AddressContact.fromMap(json)).toList();
  }

  Future<void> clearAllContacts() async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<void> seedSampleContacts() async {
    final sampleContacts = [
      AddressContact(
        firstName: 'Jan',
        lastName: 'Kowalski',
        phone: '+48 600 123 456',
        email: 'jan.kowalski@example.pl',
        street: 'ul. Marszałkowska 10/4',
        city: 'Warszawa',
        postalCode: '00-624',
        category: 'Praca',
        notes: 'Dyrektor projektu, kontakt w dni powszednie 9-17.',
        avatar: 'preset:💼',
      ),
      AddressContact(
        firstName: 'Anna',
        lastName: 'Nowak',
        phone: '+48 501 987 654',
        email: 'anna.nowak@gmail.com',
        street: 'ul. Floriańska 15',
        city: 'Kraków',
        postalCode: '31-019',
        category: 'Prywatny',
        notes: 'Architekt wnętrz, wolne terminy po południu.',
        avatar: 'preset:👩',
      ),
      AddressContact(
        firstName: 'Marek',
        lastName: 'Zieliński',
        phone: '+48 722 333 444',
        email: 'm.zielinski@rodzina.pl',
        street: 'ul. Długa 42',
        city: 'Gdańsk',
        postalCode: '80-831',
        category: 'Rodzina',
        notes: 'Wujek Marek, urodziny 14 maja.',
        avatar: 'preset:👨',
      ),
      AddressContact(
        firstName: 'Zofia',
        lastName: 'Wiśniewska',
        phone: '+48 691 444 888',
        email: 'zofia.w@tech.io',
        street: 'ul. Piotrkowska 99',
        city: 'Łódź',
        postalCode: '90-001',
        category: 'Praca',
        notes: 'Inżynier oprogramowania.',
        avatar: 'preset:💻',
      ),
    ];

    for (final contact in sampleContacts) {
      await insertContact(contact);
    }
  }

  Future<AddressContact?> getContactById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AddressContact.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateContact(AddressContact contact) async {
    final db = await database;
    return await db.update(
      tableName,
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getContactsCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
    return count ?? 0;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
