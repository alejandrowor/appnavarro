import 'package:cloud_firestore/cloud_firestore.dart';

class UsuariosController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUsersStream() {
    return _db.collection('people').snapshots();
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    await _db.collection('people').add(userData);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await _db.collection('people').doc(userId).update(userData);
  }

  Future<void> deleteUser(String userId) async {
    await _db.collection('people').doc(userId).delete();
  }

  // Método para iniciar sesión
  Future<bool> login(String email, String password) async {
    final querySnapshot = await _db
        .collection('people')
        .where('correo', isEqualTo: email)
        .where('contraseña', isEqualTo: password)
        .get();

    return querySnapshot
        .docs.isNotEmpty; // Retorna true si hay un documento que coincide
  }
}
