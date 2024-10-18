import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/firebase_options.dart';
import 'package:flutter_application_5/vista/RegistroScreen.dart';
import 'package:flutter_application_5/vista/Vproducts.dart';
import 'package:flutter_application_5/vista/Vventa.dart';
import 'package:flutter_application_5/vista/usuarios_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta el banner de depuración
      title: 'Tienda Don Paco\'s',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50, // Fondo de la pantalla
        appBarTheme: AppBarTheme(
          color: Colors.blue.shade800, // Color de la barra superior
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.blue, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.blueAccent),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue.shade700,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: VPrincipal(), // Cambia a VPrincipal
    );
  }
}

class VPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda Don Paco\'s'),
      ),
      body: SingleChildScrollView(
        // Para permitir que la vista sea desplazable
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.pink[50], // Fondo de la vista
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de la empresa centrado en la parte superior
              Image.network(
                'https://media.licdn.com/dms/image/v2/D4D0BAQHvRXWjZu_Q-g/company-logo_200_200/company-logo_200_200/0/1715180322831/paco_app_logo?e=2147483647&v=beta&t=BO0XuAwd4FtdMeYx0C5pd9LKBrtPF5tLpX9YD6DmGOM',
                width: 150, // Tamaño del logo
                height: 150,
              ),
              const SizedBox(height: 40), // Espacio entre el logo y los botones
              // Primera fila con dos botones (Venta y Almacén)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(context, 'Venta',
                      navigateToVenta: true), // Cambiado aquí
                  _buildButton(context, 'Almacén', navigateToProducts: true),
                ],
              ),
              const SizedBox(height: 20), // Espacio entre filas
              // Segunda fila con el botón de Usuarios
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.supervised_user_circle_sharp),
                  const SizedBox(width: 10),
                  _buildButton(context, 'Usuarios', navigateToUsuarios: true),
                ],
              ),
              const SizedBox(height: 20), // Espacio entre botones
              // Tercera fila con el botón de Registros
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 10),
                  _buildButton(context, 'Registros',
                      navigateToRegistro: true), // Nuevo botón
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modificación para incluir la opción de navegación
  Widget _buildButton(BuildContext context, String text,
      {bool navigateToUsuarios = false,
      bool navigateToProducts = false,
      bool navigateToVenta = false,
      bool navigateToRegistro = false}) {
    // Nuevo parámetro
    return ElevatedButton(
      onPressed: () {
        if (navigateToUsuarios) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UsuariosView()), // Navega a UsuariosView
          );
        } else if (navigateToProducts) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductsView()), // Navega a ProductsView
          );
        } else if (navigateToVenta) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VVenta()), // Navega a VVenta
          );
        } else if (navigateToRegistro) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RegistroScreen()), // Navega a RegistroScreen
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        backgroundColor: Colors.blue[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
