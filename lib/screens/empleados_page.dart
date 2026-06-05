import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmpleadosPage extends StatefulWidget {
  const EmpleadosPage({super.key});

  @override
  State<EmpleadosPage> createState() => _EmpleadosPageState();
}

class _EmpleadosPageState extends State<EmpleadosPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> empleados = [];

  final _nombreCtrl = TextEditingController();
  final _puestoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  // --- LEER BD ---
  Future<void> _cargarEmpleados() async {
    try {
      final data = await supabase.from('empleados').select().order('id', ascending: false);
      if (mounted) {
        setState(() {
          empleados = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- INSERTAR EN BD ---
  void _mostrarDialogoNuevoEmpleado() {
    _nombreCtrl.clear();
    _puestoCtrl.clear();
    _telefonoCtrl.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Nuevo Empleado', style: TextStyle(color: Color(0xFF2E7D32))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo')),
              TextField(controller: _puestoCtrl, decoration: const InputDecoration(labelText: 'Puesto/Rol')),
              TextField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
              onPressed: () async {
                if (_nombreCtrl.text.isNotEmpty) {
                  Navigator.pop(context); // Cierra el diálogo rápido
                  setState(() => isLoading = true);
                  try {
                    await supabase.from('empleados').insert({
                      'nombre': _nombreCtrl.text.trim(),
                      'puesto': _puestoCtrl.text.trim(),
                      'telefono': _telefonoCtrl.text.trim(),
                      'estado': 'Activo',
                    });
                    _cargarEmpleados(); // Recargamos para ver el nuevo
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Empleado registrado exitosamente'), backgroundColor: Color(0xFF2E7D32)),
                    );
                  } catch (e) {
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // --- ACTUALIZAR ESTADO EN BD ---
  Future<void> _cambiarEstado(int id, String estadoActual) async {
    final nuevoEstado = estadoActual == 'Activo' ? 'Inactivo' : 'Activo';
    try {
      await supabase.from('empleados').update({'estado': nuevoEstado}).eq('id', id);
      _cargarEmpleados(); // Refrescar la tabla
    } catch (e) {
      debugPrint('Error al actualizar estado: $e');
    }
  }

  // --- BORRAR DE BD ---
  Future<void> _borrarEmpleado(int id) async {
    try {
      await supabase.from('empleados').delete().eq('id', id);
      _cargarEmpleados(); // Refrescar la tabla
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Empleado eliminado'), backgroundColor: Colors.red),
      );
    } catch (e) {
      debugPrint('Error al borrar: $e');
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
                'Directorio de Empleados',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                    onPressed: () {
                      setState(() => isLoading = true);
                      _cargarEmpleados();
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _mostrarDialogoNuevoEmpleado,
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo Empleado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : empleados.isEmpty
                    ? const Center(child: Text('No hay empleados registrados.'))
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
                                DataColumn(label: Text('Puesto/Rol', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: List.generate(empleados.length, (index) {
                                final empleado = empleados[index];
                                final esActivo = empleado['estado'] == 'Activo';
                                final id = empleado['id'] as int;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(empleado['nombre']?.toString() ?? 'N/A')),
                                    DataCell(Text(empleado['puesto']?.toString() ?? 'N/A')),
                                    DataCell(Text(empleado['telefono']?.toString() ?? 'N/A')),
                                    DataCell(
                                      ActionChip(
                                        label: Text(
                                          empleado['estado']?.toString() ?? 'Desconocido', 
                                          style: TextStyle(
                                            fontSize: 12, 
                                            color: esActivo ? Colors.green[800] : Colors.red[800],
                                            fontWeight: FontWeight.bold
                                          )
                                        ),
                                        backgroundColor: esActivo ? Colors.green[100] : Colors.red[100],
                                        side: BorderSide.none,
                                        onPressed: () => _cambiarEstado(id, empleado['estado'].toString()),
                                      )
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _borrarEmpleado(id),
                                        tooltip: 'Eliminar',
                                      ),
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