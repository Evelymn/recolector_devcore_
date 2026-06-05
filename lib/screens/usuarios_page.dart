import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> clientes = [];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    try {
      final data = await supabase.from('clientes').select().order('id', ascending: false);
      if (mounted) {
        setState(() {
          clientes = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar clientes: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  // CAMBIO AQUÍ: Ahora espera un String en lugar de un int
  Future<void> _borrarCliente(String id, int index) async {
    setState(() {
      clientes.removeAt(index);
    });

    try {
      await supabase.from('clientes').delete().eq('id', id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Cliente eliminado de la base de datos'), backgroundColor: Colors.red),
      );
    } catch (e) {
      _cargarClientes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Directorio de Clientes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                onPressed: () {
                  setState(() => isLoading = true);
                  _cargarClientes();
                },
                tooltip: 'Actualizar lista',
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : clientes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text('No hay clientes registrados aún', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.green[50]),
                              columns: const [
                                DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Dirección / Colonia', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: List.generate(clientes.length, (index) {
                                final cliente = clientes[index];
                                final esActivo = cliente['estado'] == 'Activo';
                                
                                final nombre = cliente['nombre']?.toString() ?? 'Sin nombre';
                                final direccion = cliente['direccion']?.toString() ?? 'Sin dirección';
                                final colonia = cliente['colonia']?.toString() ?? '';
                                final ubicacionCompleta = colonia.isNotEmpty ? '$direccion, $colonia' : direccion;
                                final telefono = cliente['telefono']?.toString() ?? 'N/A';
                                final estado = cliente['estado']?.toString() ?? 'Desconocido';
                                
                                // CAMBIO AQUÍ: Convertimos el ID a String para que no importe si es UUID o número
                                final id = cliente['id']?.toString();

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.green[100],
                                            child: Text(
                                              nombre.isNotEmpty ? nombre[0].toUpperCase() : '?', 
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[800])
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        ],
                                      )
                                    ),
                                    DataCell(Text(ubicacionCompleta, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    DataCell(Text(telefono)),
                                    DataCell(
                                      Chip(
                                        label: Text(
                                          estado, 
                                          style: TextStyle(
                                            fontSize: 12, 
                                            color: esActivo ? Colors.green[800] : Colors.red[800],
                                            fontWeight: FontWeight.bold
                                          )
                                        ),
                                        backgroundColor: esActivo ? Colors.green[100] : Colors.red[100],
                                        side: BorderSide.none,
                                      )
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: id != null ? () => _borrarCliente(id, index) : null,
                                            tooltip: 'Eliminar',
                                          ),
                                        ],
                                      )
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}