import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/run_model.dart';
import '../models/territory_model.dart';
import '../models/district_model.dart';

/// Service for handling Firestore database operations.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── User Operations ──────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }

  Stream<UserModel> streamUser(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromJson(doc.data()!));
  }

  Future<void> updateUserLocation(String uid, double lat, double lng, bool isActive) async {
    await _db.collection('users').doc(uid).update({
      'last_lat': lat,
      'last_lng': lng,
      'is_active': isActive,
      'last_updated': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<UserModel>> streamNearbyRunners() {
    // In a real app, use GeoFirestore/Geohash. 
    // Here we'll just stream all active users and filter on client for simplicity.
    return _db
        .collection('users')
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList());
  }

  // ── Run Operations ───────────────────────────────────

  Future<void> saveRun(RunModel run) async {
    await _db.collection('runs').doc(run.id).set(run.toJson());
  }

  Future<List<RunModel>> getUserRuns(String uid) async {
    final query = await _db
        .collection('runs')
        .where('userId', isEqualTo: uid)
        .orderBy('startTime', descending: true)
        .get();
    return query.docs.map((doc) => RunModel.fromJson(doc.data())).toList();
  }

  // ── Territory Operations ─────────────────────────────

  Future<void> saveTerritory(TerritoryModel territory) async {
    await _db.collection('territories').doc(territory.id).set(territory.toJson());
  }

  Stream<List<TerritoryModel>> streamNearbyTerritories(String districtId) {
    return _db
        .collection('territories')
        .where('districtId', isEqualTo: districtId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TerritoryModel.fromJson(doc.data())).toList());
  }

  Future<void> deleteTerritory(String id) async {
    await _db.collection('territories').doc(id).delete();
  }

  // ── District Operations ──────────────────────────────

  Future<void> updateDistrictStrength(
      String districtId, Map<String, double> strengths) async {
    await _db.collection('districts').doc(districtId).update({
      'teamStrengths': strengths,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<DistrictModel?> streamDistrict(String districtId) {
    return _db
        .collection('districts')
        .doc(districtId)
        .snapshots()
        .map((doc) => doc.exists ? DistrictModel.fromJson(doc.data()!) : null);
  }

  // ── Global Heatmap ───────────────────────────────────

  Stream<List<DistrictModel>> streamHeatmap() {
    return _db
        .collection('districts')
        .where('heatmapValue', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DistrictModel.fromJson(doc.data())).toList());
  }

  // ── Generic Operations ───────────────────────────────

  Future<void> createDocument(
      String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).set(data);
  }

  Future<void> updateDocument(
      String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).update(data);
  }

  Future<void> deleteDocument(String collection, String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}
