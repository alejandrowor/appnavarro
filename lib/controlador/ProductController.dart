import 'package:cloud_firestore/cloud_firestore.dart';

class ProductController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener productos en tiempo real (Stream)
  Stream<QuerySnapshot> getProductsStream() {
    return _db.collection('products').snapshots();
  }

  // Agregar un producto nuevo
  Future<void> addProduct(Map<String, dynamic> productData) async {
    await _db.collection('products').add(productData);
  }

  // Actualizar un producto existente
  Future<void> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    await _db.collection('products').doc(productId).update(productData);
  }

  // Eliminar un producto
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}
