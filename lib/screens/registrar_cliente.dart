import 'package:flutter/material.dart';

class RegistrarCliente extends StatefulWidget {
  const RegistrarCliente({super.key});

  @override
  State<RegistrarCliente> createState() => _RegistrarClienteState();
}

class _RegistrarClienteState extends State<RegistrarCliente> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController coloniaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Cliente")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),

            TextField(
              controller: direccionController,
              decoration: const InputDecoration(labelText: "Dirección"),
            ),

            TextField(
              controller: coloniaController,
              decoration: const InputDecoration(labelText: "Colonia"),
            ),

            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: "Teléfono"),
            ),

            TextField(
              controller: estadoController,
              decoration: const InputDecoration(labelText: "Estado"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                print("Guardar cliente");
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}


//Este es un comentario para prueba en DEV