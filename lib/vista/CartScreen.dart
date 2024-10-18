import 'package:flutter/material.dart';
import 'package:flutter_application_5/controlador/CartScreenController.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartScreenController _controller =
      CartScreenController(); // Controlador

  @override
  Widget build(BuildContext context) {
    final cartItems = _controller.getCartItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('El carrito está vacío'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.pink[50],
                  child: ListTile(
                    leading: cartItems[index]['imageUrl'] != null
                        ? Image.network(
                            cartItems[index]['imageUrl'],
                            width: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.shopping_bag),
                    title: Text(cartItems[index]['name']),
                    subtitle: Text('Precio: \$${cartItems[index]['price']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _controller.removeItem(cartItems[index]);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${cartItems[index]['name']} eliminado del carrito!'),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${_controller.getTotal().toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.blue),
              ),
              ElevatedButton(
                onPressed: () {
                  if (cartItems.isNotEmpty) {
                    _showTicketDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El carrito está vacío')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Vender'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketDialog(BuildContext context) {
    final ticketDetails = _controller.generateTicketDetails();
    final date = _controller.getCurrentDate();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ticket de Venta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: $date'),
              const SizedBox(height: 10),
              Text('Productos:\n$ticketDetails'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _controller.processSale();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venta completada')),
                );
              },
              child: const Text('Confirmar Venta'),
            ),
          ],
        );
      },
    );
  }
}
