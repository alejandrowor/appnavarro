import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Funciones para usuarios (people)

  // Obtener lista de usuarios
  Future<List<Map<String, dynamic>>> getPeople() async {
    List<Map<String, dynamic>> people = [];
    QuerySnapshot queryPeople = await _firestore.collection('people').get();
    queryPeople.docs.forEach((documento) {
      people.add(documento.data() as Map<String, dynamic>);
    });
    return people;
  }

  // Agregar usuario
  Future<void> addUser(Map<String, dynamic> userData) async {
    await _firestore.collection('people').add(userData);
  }

  // Actualizar usuario
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('people').doc(userId).update(userData);
  }

  // Eliminar usuario
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('people').doc(userId).delete();
  }

  // Funciones para productos (products)

  // Obtener lista de productos
  Future<List<Map<String, dynamic>>> getProducts() async {
    List<Map<String, dynamic>> products = [];
    QuerySnapshot queryProducts = await _firestore.collection('products').get();
    queryProducts.docs.forEach((documento) {
      products.add(documento.data() as Map<String, dynamic>);
    });
    return products;
  }

  // Agregar producto
  Future<void> addProduct(Map<String, dynamic> productData) async {
    await _firestore.collection('products').add(productData);
  }

  // Actualizar producto
  Future<void> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    await _firestore.collection('products').doc(productId).update(productData);
  }

  // Eliminar producto
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Obtener producto por código de barras
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final snapshot = await _firestore
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  // Funciones para ventas (ventas)

  // Registrar o actualizar venta diaria
  Future<void> agregarVenta(double total) async {
    final fecha = DateTime.now();
    final hoy = DateTime(fecha.year, fecha.month, fecha.day);

    // Buscar si ya existe una venta para hoy
    final querySnapshot = await _firestore
        .collection('ventas')
        .where('fecha', isEqualTo: hoy)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Si existe, actualizar el total
      final docId = querySnapshot.docs.first.id;
      await _firestore.collection('ventas').doc(docId).update({
        'total': FieldValue.increment(total),
      });
    } else {
      // Si no existe, crear una nueva venta para hoy
      await _firestore.collection('ventas').add({
        'fecha': hoy,
        'total': total,
      });
    }
  }

  // Registrar venta con lista de productos
  Future<void> addVenta(
      List<Map<String, dynamic>> productos, double total) async {
    final fechaVenta = DateTime.now();
    await _firestore.collection('ventas').add({
      'productos': productos,
      'total': total,
      'fecha': fechaVenta,
    });
  }
}
