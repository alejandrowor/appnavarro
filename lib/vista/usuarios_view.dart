import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_5/controlador/LoginController.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda Don Paco\'s',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50,
        appBarTheme: AppBarTheme(
          color: Colors.blue.shade800,
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
      debugShowCheckedModeBanner: false,
      home: const UsuariosView(),
    );
  }
}

class UsuariosView extends StatefulWidget {
  const UsuariosView({Key? key}) : super(key: key);

  @override
  _UsuariosViewState createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<UsuariosView> {
  final UsuariosController _usuariosController = UsuariosController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUserDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usuariosController.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }

          final usuarios = snapshot.data?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Agregar ID del documento a los datos
            return data;
          }).toList();

          return ListView.builder(
            itemCount: usuarios?.length ?? 0,
            itemBuilder: (context, index) {
              final user = usuarios![index];
              return ListTile(
                title: Text(user['name'] ?? 'Sin nombre'),
                subtitle: Text(
                    'Correo: ${user['correo'] ?? 'Sin correo'}\nContraseña: ${user['contraseña'] ?? 'Sin contraseña'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showUserDialog(user: user, userId: user['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteUser(user['id']),
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

  void _showUserDialog({Map<String, dynamic>? user, String? userId}) {
    final nameController = TextEditingController(text: user?['name']);
    final emailController = TextEditingController(text: user?['correo']);
    final passwordController = TextEditingController(
        text: user?['contraseña']); // Controlador para la contraseña

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(userId == null ? 'Agregar Usuario' : 'Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true, // Ocultar la contraseña
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final userData = {
                  'name': nameController.text,
                  'correo': emailController.text,
                  'contraseña':
                      passwordController.text, // Incluir la contraseña
                };
                if (userId == null) {
                  // Agregar nuevo usuario
                  _usuariosController.addUser(userData).then((_) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print(
                        'Error al agregar usuario: $error'); // Manejar el error
                  });
                } else {
                  // Editar usuario existente
                  _usuariosController.updateUser(userId, userData).then((_) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print(
                        'Error al editar usuario: $error'); // Manejar el error
                  });
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _usuariosController.deleteUser(userId).then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print(
                      'Error al eliminar usuario: $error'); // Manejar el error
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
