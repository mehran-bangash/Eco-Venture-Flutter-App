import 'package:firebase_database/firebase_database.dart';

class GameService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  GameService() {
    // Enable Offline Persistence for Realtime Database
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    // Ensures data stays synced for offline access
    _db.child(path).keepSynced(true);
    await _db.child(path).update(data);
  }

  Stream<DatabaseEvent> getStream(String path) {
    return _db.child(path).onValue;
  }
}