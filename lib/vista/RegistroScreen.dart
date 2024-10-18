import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({Key? key}) : super(key: key);

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> ventas = [];
  double totalVentas = 0.0;

  @override
  void initState() {
    super.initState();
    _obtenerVentas();
  }

  Future<void> _obtenerVentas() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('ventas').get();

      List<Map<String, dynamic>> ventasList = [];
      double total = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        ventasList.add(data);
        total += double.tryParse(data['total'].toString()) ?? 0.0;
      }

      setState(() {
        ventas = ventasList;
        totalVentas = total;
      });
    } catch (e) {
      print('Error al obtener ventas: $e');
    }
  }

  // Mostrar diálogo de confirmación antes de hacer el corte
  Future<void> _mostrarConfirmacionCorte() async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación de Corte de Caja'),
          content: const Text(
              '¿Estás seguro de que deseas realizar el corte de caja? Se borrarán todos los registros de ventas.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancelar
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmar
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    // Si el usuario confirma, proceder con la generación del PDF y corte de caja
    if (shouldProceed == true) {
      await _generarPDF();
    }
  }

  Future<void> _generarPDF() async {
    final pdf = pw.Document();

    // Nombre del archivo basado en la fecha actual

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Reporte de Ventas',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Tienda: Mi Tienda'),
              pw.Text('Fecha: ${DateTime.now()}'),
              pw.SizedBox(height: 20),
              pw.Text('Total de ventas: \$${totalVentas.toStringAsFixed(2)}'),
              pw.SizedBox(height: 20),
              pw.Text('Detalle de ventas:'),
              for (var i = 0; i < ventas.length; i++)
                _buildDetalleVenta(i, ventas[i]),
            ],
          );
        },
      ),
    );

    // Guardar el PDF con el nombre basado en la fecha
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());

    // Después de generar el PDF, borrar los registros de ventas
    await _borrarVentas();
  }

  Future<void> _borrarVentas() async {
    try {
      final ventasSnapshot = await _firestore.collection('ventas').get();
      for (var doc in ventasSnapshot.docs) {
        await _firestore.collection('ventas').doc(doc.id).delete();
      }
      print('Ventas eliminadas correctamente.');

      // Limpiar la lista de ventas en la pantalla
      setState(() {
        ventas.clear();
        totalVentas = 0.0;
      });
    } catch (e) {
      print('Error al eliminar ventas: $e');
    }
  }

  pw.Widget _buildDetalleVenta(int index, Map<String, dynamic> venta) {
    final productos = venta['productos'] ?? [];
    final totalVenta = double.tryParse(venta['total'].toString()) ?? 0.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Venta #${index + 1}: \$${totalVenta.toStringAsFixed(2)}'),
        pw.Text('Fecha: ${venta['fecha'].toDate()}'),
        if (productos.isNotEmpty) pw.Text('Productos:'),
        if (productos.isNotEmpty)
          for (var prodIndex = 0; prodIndex < productos.length; prodIndex++)
            _buildDetalleProducto(productos[prodIndex], prodIndex),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildDetalleProducto(Map<String, dynamic> producto, int index) {
    return pw.Text(
        '${index + 1}. ${producto['name']} - ${producto['description']}, Código: ${producto['barcode']}, Precio: \$${producto['price']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Ventas'),
      ),
      body: ventas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ventas.length,
              itemBuilder: (context, index) {
                final venta = ventas[index];
                final total = double.tryParse(venta['total'].toString()) ?? 0.0;
                final productos = venta['productos'] ?? [];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${venta['fecha'].toDate()}'),
                        const SizedBox(height: 5),
                        productos.isNotEmpty
                            ? Text(
                                'Productos: ${productos.map((p) => p['name']).join(', ')}',
                              )
                            : const Text('Productos: Sin productos'),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarConfirmacionCorte,
        child: const Icon(Icons.picture_as_pdf),
        tooltip: 'Generar PDF y hacer corte de caja',
      ),
    );
  }
}
