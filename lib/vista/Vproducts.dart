import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_5/controlador/ProductController.dart';
import 'VAgregarProdu.dart'; // Importar la nueva vista

class ProductsView extends StatefulWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  _ProductsViewState createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final ProductController _productController = ProductController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productController.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los productos'));
          }

          final products = snapshot.data?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Añadir el ID del documento al producto
            return data;
          }).toList();

          if (products == null || products.isEmpty) {
            return const Center(child: Text('No hay productos disponibles'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product['name'] ?? 'Sin nombre'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['description'] ?? 'Sin descripción'),
                    Text('Precio: \$${product['price'] ?? 'N/A'}'),
                    Text('Código de barras: ${product['barcode'] ?? 'N/A'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showProductDialog(
                          product: product, productId: product['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteProduct(product['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProductDialog({Map<String, dynamic>? product, String? productId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VAgregarProdu(
            product: product, productId: productId), // Cambiado a VAgregarProdu
      ),
    );
  }

  void _deleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _productController.deleteProduct(productId).then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print('Error al eliminar producto: $error');
                });
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
