import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_sync/models/health_data.dart';

class HealthDataRepository {
  final FirebaseFirestore _firestore;

  HealthDataRepository() : _firestore = FirebaseFirestore.instance;

  Future<void> addHealthData(String userId, HealthData healthData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .add(healthData.toMap());
  }

  Stream<List<HealthData>> getHealthData(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('health_data')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthData.fromMap(doc.data()))
            .toList());
  }
}
