import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Usamos Supabase directo

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  // Instancia directa que sabemos que sí funciona
  final supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> usuarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  void cargarUsuarios() async {
    try {
      // Jalamos los datos directo de la tabla 'clientes'
      final data = await supabase.from('clientes').select();
      
      if (mounted) {
        setState(() {
          usuarios = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar usuarios: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Directorio de Clientes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    )
                  : usuarios.isEmpty
                      ? const Center(child: Text('No hay clientes registrados.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: usuarios.length,
                          separatorBuilder: (context, index) => const Divider(color: Color(0xFFE0E0E0), height: 1),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8F5E9),
                                child: Icon(Icons.person, color: Color(0xFF2E7D32)),
                              ),
                              title: Text(
                                usuarios[index]['nombre']?.toString() ?? 'Sin nombre',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(usuarios[index]['direccion']?.toString() ?? 'Sin dirección'),
                              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}