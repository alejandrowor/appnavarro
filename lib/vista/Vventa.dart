import 'package:barcode_scan2/barcode_scan2.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_5/controlador/CartScreenController.dart';
import 'package:flutter_application_5/service/FirebaseService.dart';
import 'package:flutter_application_5/vista/CartScreen.dart';

class VVenta extends StatefulWidget {
  const VVenta({Key? key}) : super(key: key);

  @override
  _VVentaState createState() => _VVentaState();
}

class _VVentaState extends State<VVenta> {
  final FirebaseService _firebaseService = FirebaseService();
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  String searchBarcode = '';

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Cargar los productos al iniciar la vista
  }

  // Función para cargar productos desde Firebase usando FirebaseService
  Future<void> _loadProducts() async {
    try {
      List<dynamic> productList =
          await _firebaseService.getProducts(); // Usar el servicio

      setState(() {
        products = productList;
        filteredProducts =
            productList; // Inicialmente mostrar todos los productos
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e')),
      );
    }
  }

  // Función para filtrar productos según el código de barras
  void _filterProducts() {
    setState(() {
      filteredProducts = products
          .where((product) =>
              product['barcode'] != null &&
              product['barcode'].toString().contains(searchBarcode))
          .toList();
    });
  }

  // Función para agregar un producto al carrito
  void _addToCart(dynamic product) {
    setState(() {
      Cart.addItem(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} agregado al carrito')),
    );
  }

  // Función para escanear código de barras
  Future<void> _scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode) {
        setState(() {
          searchBarcode = result.rawContent; // Guardar el código escaneado
        });

        _filterProducts(); // Filtrar productos por el código escaneado

        if (filteredProducts.isNotEmpty) {
          _addToCart(filteredProducts.first); // Agregar al carrito
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto no encontrado')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al escanear el código')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.barcode_reader),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por código de barras',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchBarcode = value;
                });
                _filterProducts();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return ListTile(
                  title: Text(
                    product['name'] ?? 'Sin nombre',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['description'] ?? 'Sin descripción',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Código de barras: ${product['barcode'] ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Precio: \$${product['price'] ?? 'Sin precio'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  leading: product['imageUrl'] != null
                      ? Image.network(
                          product['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.shopping_bag),
                  tileColor: Colors.blue.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _addToCart(product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
