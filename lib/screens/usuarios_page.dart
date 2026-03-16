import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final service = SupabaseService();
  List usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  void cargarUsuarios() async {
    final data = await service.obtenerUsuarios();

    setState(() {
      usuarios = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Usuarios")),
      body: ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(usuarios[index]['nombre'] ?? ''),
            subtitle: Text(usuarios[index]['correo'] ?? ''),
          );
        },
      ),
    );
  }
}
