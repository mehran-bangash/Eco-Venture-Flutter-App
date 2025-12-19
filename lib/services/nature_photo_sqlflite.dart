import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/nature_fact_{sqllite}.dart';


class LocalDBService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'eco_venture_v2.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE nature_facts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE,
            description TEXT,
            category TEXT
          )
        ''');

        await _seedData(db);
      },
    );
  }

  // ✅ FIXED + LOWERCASE MATCHING WITH MODEL LABELS
  Future<void> _seedData(Database db) async {
    print("🌱 Seeding Database with Model Labels...");

    final List<Map<String, String>> facts = [

      // ===== ANIMALS =====
      {'name': 'cat', 'category': 'Animal', 'description': 'A small fluffy mammal that loves to chase mice.'},
      {'name': 'dog', 'category': 'Animal', 'description': 'Loyal and playful friend of humans.'},
      {'name': 'elephant', 'category': 'Animal', 'description': 'The largest land animal on Earth.'},
      {'name': 'giraffe', 'category': 'Animal', 'description': 'The tallest animal with a very long neck.'},
      {'name': 'leopard', 'category': 'Animal', 'description': 'A fast big cat with beautiful spots.'},
      {'name': 'ostrich', 'category': 'Bird', 'description': 'A giant bird that cannot fly but runs fast.'},
      {'name': 'turtle', 'category': 'Animal', 'description': 'A reptile with a hard shell.'},
      {'name': 'zebra', 'category': 'Animal', 'description': 'An animal with black and white stripes.'},

      // ===== INSECTS =====
      {'name': 'cockroach', 'category': 'Insect', 'description': 'A tough insect that survives almost anything.'},
      {'name': 'fly', 'category': 'Insect', 'description': 'A small flying insect with big eyes.'},
      {'name': 'grasshopper', 'category': 'Insect', 'description': 'A jumping insect that can leap far.'},
      {'name': 'ladybugs', 'category': 'Insect', 'description': 'Cute beetles that help farmers.'},

      // ===== PLANTS & TREES =====
      {'name': 'babul', 'category': 'Tree', 'description': 'A thorny tree also called Acacia.'},
      {'name': 'bamboo', 'category': 'Plant', 'description': 'The fastest growing plant in the world.'},
      {'name': 'burnet', 'category': 'Plant', 'description': 'A wild meadow herb.'},
      {'name': 'cactus', 'category': 'Plant', 'description': 'A desert plant that stores water.'},
      {'name': 'dafodils', 'category': 'Flower', 'description': 'Yellow spring flowers.'},
      {'name': 'mango', 'category': 'Tree', 'description': 'Produces sweet mango fruit.'},
      {'name': 'neem', 'category': 'Tree', 'description': 'A tree with medical benefits.'},
      {'name': 'palm_tree', 'category': 'Tree', 'description': 'Tree found near beaches with coconuts.'},
      {'name': 'pipal', 'category': 'Tree', 'description': 'A sacred tree with heart-shaped leaves.'},
      {'name': 'purple_cornflower', 'category': 'Flower', 'description': 'A purple medicinal flower.'},
      {'name': 'sunflower', 'category': 'Flower', 'description': 'A tall plant that follows the sun.'},
      {'name': 'azalea', 'category': 'Flower', 'description': 'A colorful flowering shrub.'},
    ];

    for (var fact in facts) {
      await db.insert(
        'nature_facts',
        fact,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print("✅ Seeded ${facts.length} labels correctly!");
  }

  // ✅ ✅ ✅ FIXED SEARCH FUNCTION (THIS WAS YOUR MAIN BUG)
  Future<NatureFact> getFactFor(String label) async {
    final db = await database;

    String cleanLabel = label.trim().toLowerCase();

    print("🔍 Searching DB for: $cleanLabel");

    final List<Map<String, dynamic>> maps = await db.query(
      'nature_facts',
      where: 'LOWER(name) = ?',
      whereArgs: [cleanLabel],
    );

    if (maps.isNotEmpty) {
      print("✅ MATCH FOUND: ${maps.first['name']}");
      return NatureFact.fromMap(maps.first);
    } else {
      print("❌ NO MATCH FOUND — Showing Unknown Message");

      return NatureFact(
        name: cleanLabel,
        description: "You found a $cleanLabel! That is amazing, but I am still learning about it.",
        category: "Unknown",
      );
    }
  }
}