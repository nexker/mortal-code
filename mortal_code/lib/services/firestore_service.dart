import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<int> obtenerProgreso() async {
    if (_uid == null) return 0;
    try {
      final doc = await _db.collection('usuarios').doc(_uid).get();
      if (doc.exists) {
        return doc.data()?['nivelActual'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> actualizarProgreso(int nivelCompletado) async {
    if (_uid == null) return;
    final progresoActual = await obtenerProgreso();
    if (nivelCompletado > progresoActual) {
      await _db.collection('usuarios').doc(_uid).set({
        'nivelActual': nivelCompletado,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> reiniciarProgreso() async {
    if (_uid == null) return;
    await _db.collection('usuarios').doc(_uid).set({
      'nivelActual': 0,
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    });
  }
}