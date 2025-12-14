import '../services/parent_home_service.dart';

class ParentHomeRepository {
  final ParentHomeService _service;
  ParentHomeRepository(this._service);

  Stream<Map<String, dynamic>> getDashboardData(String childUid) {
    return _service.getChildDashboardStream(childUid);
  }
}