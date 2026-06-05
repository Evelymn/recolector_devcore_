import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PagosPage extends StatefulWidget {
  const PagosPage({super.key});

  @override
  State<PagosPage> createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<Map<String, dynamic>> pagos = [];

  final _clienteCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  String _metodoSeleccionado = 'Efectivo';

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    try {
      final data = await supabase.from('pagos').select().order('id', ascending: false);
      if (mounted) {
        setState(() {
          pagos = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar pagos: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _mostrarDialogoNuevoPago() {
    _clienteCtrl.clear();
    _montoCtrl.clear();
    _metodoSeleccionado = 'Efectivo';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Registrar Nuevo Pago', style: TextStyle(color: Color(0xFF2E7D32))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _clienteCtrl, decoration: const InputDecoration(labelText: 'Nombre del Cliente')),
                  TextField(controller: _montoCtrl, decoration: const InputDecoration(labelText: 'Monto (Q)'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _metodoSeleccionado,
                    decoration: const InputDecoration(labelText: 'Método de Pago'),
                    items: const [
                      DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                      DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                    ],
                    onChanged: (val) => setStateDialog(() => _metodoSeleccionado = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                  onPressed: () async {
                    if (_clienteCtrl.text.isNotEmpty && _montoCtrl.text.isNotEmpty) {
                      Navigator.pop(context);
                      setState(() => isLoading = true);
                      final montoNumerico = double.tryParse(_montoCtrl.text) ?? 0.0;
                      try {
                        await supabase.from('pagos').insert({
                          'cliente_nombre': _clienteCtrl.text.trim(),
                          'monto': montoNumerico,
                          'metodo_pago': _metodoSeleccionado,
                          'estado': 'Completado',
                        });
                        _cargarPagos();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Pago registrado'), backgroundColor: Color(0xFF2E7D32)));
                      } catch (e) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text('Registrar Pago'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _cambiarEstado(int id, String estadoActual) async {
    final nuevoEstado = estadoActual == 'Completado' ? 'Pendiente' : 'Completado';
    try {
      await supabase.from('pagos').update({'estado': nuevoEstado}).eq('id', id);
      _cargarPagos();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _borrarPago(int id) async {
    try {
      await supabase.from('pagos').delete().eq('id', id);
      _cargarPagos();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // AQUÍ ESTÁ EL ARREGLO DE LA FECHA SIN LIBRERÍAS EXTERNAS
  String _formatearFecha(String fechaIso) {
    try {
      final DateTime fecha = DateTime.parse(fechaIso).toLocal();
      final dia = fecha.day.toString().padLeft(2, '0');
      final mes = fecha.month.toString().padLeft(2, '0');
      final anio = fecha.year;
      return '$dia/$mes/$anio';
    } catch (e) {
      return 'Fecha inválida';
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
              const Text('Historial de Pagos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)), onPressed: () { setState(() => isLoading = true); _cargarPagos(); }),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(onPressed: _mostrarDialogoNuevoPago, icon: const Icon(Icons.payment), label: const Text('Registrar Pago'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : pagos.isEmpty
                    ? const Center(child: Text('No hay pagos registrados.'))
                    : SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.green[50]),
                              columns: const [
                                DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Método', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: List.generate(pagos.length, (index) {
                                final pago = pagos[index];
                                final esCompletado = pago['estado'] == 'Completado';
                                final id = pago['id'] as int;
                                final monto = pago['monto'] != null ? double.parse(pago['monto'].toString()).toStringAsFixed(2) : '0.00';
                                final fechaFormat = pago['fecha'] != null ? _formatearFecha(pago['fecha']) : 'N/A';

                                return DataRow(
                                  cells: [
                                    DataCell(Text(fechaFormat)),
                                    DataCell(Text(pago['cliente_nombre']?.toString() ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text('Q $monto', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold))),
                                    DataCell(Row(children: [Icon(pago['metodo_pago'] == 'Efectivo' ? Icons.money : Icons.account_balance, size: 16, color: Colors.grey[700]), const SizedBox(width: 6), Text(pago['metodo_pago']?.toString() ?? 'N/A')])),
                                    DataCell(ActionChip(label: Text(pago['estado']?.toString() ?? 'Desconocido', style: TextStyle(fontSize: 12, color: esCompletado ? Colors.blue[800] : Colors.orange[800], fontWeight: FontWeight.bold)), backgroundColor: esCompletado ? Colors.blue[100] : Colors.orange[100], side: BorderSide.none, onPressed: () => _cambiarEstado(id, pago['estado'].toString()))),
                                    DataCell(IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _borrarPago(id), tooltip: 'Eliminar')),
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