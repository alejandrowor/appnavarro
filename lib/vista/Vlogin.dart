import 'package:flutter/material.dart';
import 'package:flutter_application_5/controlador/LoginController.dart';
import 'vprincipal.dart'; // Asegúrate de tener esta vista creada

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda Don Paco\'s',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Establece LoginScreen como la pantalla de inicio
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UsuariosController _usuariosController = UsuariosController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100,
                width: 100,
                child: Image.network(
                  'https://media.licdn.com/dms/image/v2/D4D0BAQHvRXWjZu_Q-g/company-logo_200_200/company-logo_200_200/0/1715180322831/paco_app_logo?e=2147483647&v=beta&t=BO0XuAwd4FtdMeYx0C5pd9LKBrtPF5tLpX9YD6DmGOM',
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Tienda "DON PACO´S"\nIniciar Sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'USUARIO',
                  labelStyle: TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'CONTRASEÑA',
                  labelStyle: TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: Colors.grey[300],
                ),
                child: Text('INICIAR SESIÓN',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa todos los campos.';
      });
      return;
    }

    bool isValid = await _usuariosController.login(email, password);
    if (isValid) {
      // Navega a la vista principal (VPrincipal)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                VPrincipal()), // Asegúrate de que VPrincipal esté implementada
      );
    } else {
      setState(() {
        _errorMessage = 'Usuario o contraseña incorrectos.';
      });
    }
  }
}
