import '../services/child_progress_service.dart';

class ChildProgressRepository {
  final ChildProgressService _service;

  ChildProgressRepository(this._service);

  Stream<Map<String, dynamic>> getProgressStream() {
    return _service.getProgressStream();
  }
}