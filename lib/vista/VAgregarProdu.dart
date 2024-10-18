import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_application_5/controlador/ProductController.dart';

class VAgregarProdu extends StatefulWidget {
  final Map<String, dynamic>? product;
  final String? productId;

  const VAgregarProdu({Key? key, this.product, this.productId})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VAgregarProduState createState() => _VAgregarProduState();
}

class _VAgregarProduState extends State<VAgregarProdu> {
  final ProductController _productController = ProductController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _imageUrlController =
      TextEditingController(); // Controlador para la URL de la imagen

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _descriptionController.text = widget.product!['description'] ?? '';
      _priceController.text = widget.product!['price']?.toString() ?? '';
      _barcodeController.text = widget.product!['barcode'] ?? '';
      _imageUrlController.text =
          widget.product!['imageUrl'] ?? ''; // Inicializa el campo de imagen
    }
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        _barcodeController.text = result.rawContent;
      });
    } catch (e) {
      _showErrorDialog('Error al escanear el código de barras.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.productId == null ? 'Agregar Producto' : 'Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration:
                        const InputDecoration(labelText: 'Código de barras'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'URL de la Imagen'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isFormValid()) {
                  final productData = {
                    'name': _nameController.text,
                    'description': _descriptionController.text,
                    'price': double.tryParse(_priceController.text) ?? 0,
                    'barcode': _barcodeController.text,
                    'imageUrl': _imageUrlController.text, // Añadido aquí
                  };

                  if (widget.productId == null) {
                    _productController.addProduct(productData).then((_) {
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      print('Error al agregar producto: $error');
                    });
                  } else {
                    _productController
                        .updateProduct(widget.productId!, productData)
                        .then((_) {
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      print('Error al editar producto: $error');
                    });
                  }
                } else {
                  _showErrorDialog('Todos los campos deben estar llenos.');
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _barcodeController.text.isNotEmpty &&
        _imageUrlController.text.isNotEmpty; // Validación del campo URL
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
