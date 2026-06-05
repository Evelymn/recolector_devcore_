// ============================================================
//  ARCHIVO: dashboard.dart
//  DESCRIPCIÓN: Pantalla principal con estadísticas en TIEMPO REAL
// ============================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD
import 'package:fl_chart/fl_chart.dart'; 

import '../widgets/menulateral.dart';
import 'reportes_page.dart';  
import 'usuarios_page.dart';  
import 'empleados_page.dart'; 
import 'pagos_page.dart';     
import 'configuracion_page.dart'; 
=======
import '../widgets/menulateral.dart';
import 'reportes_page.dart'; // Tu tabla
import 'usuarios_page.dart'; // La lista de tu compañero
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c

const Color kVerdePrincipal = Color(0xFF2E7D32);
const Color kVerdeBoton = Color(0xFF388E3C);
const Color kVerdeClaro = Color(0xFFE8F5E9);
const Color kGrisBorde = Color(0xFFE0E0E0);
const Color kGrisTexto = Color(0xFF616161);
const Color kBlanco = Colors.white;

class DashboardRegistrarCliente extends StatefulWidget {
  const DashboardRegistrarCliente({super.key});

  @override
  State<DashboardRegistrarCliente> createState() => _DashboardRegistrarClienteState();
}

class _DashboardRegistrarClienteState extends State<DashboardRegistrarCliente> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _telefonoController = TextEditingController();

  String _estadoSeleccionado = 'Activo';
  bool _isLoading = false;
  int _menuSeleccionado = 0;

  final SupabaseClient _supabase = Supabase.instance.client;

<<<<<<< HEAD
  // Variables para las estadísticas reales
  int _totalClientes = 0;
  double _ingresosMes = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas(); // Cargar los datos reales al abrir
  }
=======
  int totalClientes = 0;
  int clientesActivos = 0;
  int clientesInactivos = 0;
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _coloniaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  // --- FUNCIÓN MÁGICA PARA LEER ESTADÍSTICAS REALES ---
  Future<void> _cargarEstadisticas() async {
    try {
      // 1. Contar los clientes
      final clientesData = await _supabase.from('clientes').select('id');
      
      // 2. Sumar los pagos completados
      final pagosData = await _supabase.from('pagos').select('monto').eq('estado', 'Completado');
      
      double sumaPagos = 0;
      for (var pago in pagosData) {
        sumaPagos += double.tryParse(pago['monto'].toString()) ?? 0.0;
      }

      if (mounted) {
        setState(() {
          _totalClientes = clientesData.length;
          _ingresosMes = sumaPagos;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar estadísticas: $e');
=======
  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    try {
      final clientes = await _supabase.from('clientes').select();

      totalClientes = clientes.length;

      clientesActivos = clientes.where((c) => c['estado'] == 'Activo').length;

      clientesInactivos =
          clientes.where((c) => c['estado'] == 'Inactivo').length;

      setState(() {});
    } catch (e) {
      debugPrint('Error: $e');
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c
    }
  }

  Future<void> _guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _supabase.from('clientes').insert({
        'nombre': _nombreController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'colonia': _coloniaController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'estado': _estadoSeleccionado,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Cliente registrado correctamente'),
          backgroundColor: kVerdePrincipal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _limpiarFormulario();
<<<<<<< HEAD
      _cargarEstadisticas(); // <--- Actualizamos los números después de guardar
=======
      await _cargarEstadisticas();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Supabase: ${e.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _direccionController.clear();
    _coloniaController.clear();
    _telefonoController.clear();
    setState(() => _estadoSeleccionado = 'Activo');
    _formKey.currentState?.reset();
  }

  InputDecoration _inputDecoration(String placeholder) {
    return InputDecoration(
      hintText: placeholder,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
      filled: true,
      fillColor: kBlanco,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kGrisBorde)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kVerdePrincipal, width: 1.8)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 1.8)),
    );
  }

<<<<<<< HEAD
=======
  // ─────────────────────────────────────────────────────────
  // AQUÍ ESTÁ EL SWITCH MÁGICO
  // ─────────────────────────────────────────────────────────
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c
  Widget _obtenerVistaActual() {
    switch (_menuSeleccionado) {
      case 0: return _buildContenidoDashboard(); 
      case 1: return const UsuariosPage(); 
      case 2: return const PagosPage(); 
      case 3: return const EmpleadosPage(); 
      case 4: return const ReportesPage(); 
      case 5: return const ConfiguracionPage(); 
      default: return const Center(child: Text('Pantalla en construcción...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          MenuLateral(
            seleccionado: _menuSeleccionado,
            onItemTap: (index) {
              setState(() => _menuSeleccionado = index);
              // Si volvemos al dashboard, refrescamos los números por si alguien pagó o se borró en otra pantalla
              if (index == 0) _cargarEstadisticas(); 
            },
          ),
          Expanded(
            child: Column(
              children: [
<<<<<<< HEAD
                const _AppBarPersonalizado(),
=======
                _AppBarPersonalizado(),
                // AQUÍ INYECTAMOS LA VISTA DINÁMICA
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c
                Expanded(child: _obtenerVistaActual()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard General',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: kVerdePrincipal),
                tooltip: 'Actualizar Estadísticas',
                onPressed: _cargarEstadisticas,
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _ColumnaIzquierda(
                  totalClientes: totalClientes,
                  clientesActivos: clientesActivos,
                  clientesInactivos: clientesInactivos,
                  onRegistrarTap: () {},
                  totalClientes: _totalClientes.toString(), // <--- Pasamos el dato real
                  ingresosMes: 'Q ${_ingresosMes.toStringAsFixed(2)}', // <--- Pasamos el dato real formateado
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: _FormularioRegistro(
                  formKey: _formKey,
                  nombreController: _nombreController,
                  direccionController: _direccionController,
                  coloniaController: _coloniaController,
                  telefonoController: _telefonoController,
                  estadoSeleccionado: _estadoSeleccionado,
                  isLoading: _isLoading,
                  inputDecoration: _inputDecoration,
                  onEstadoChanged:
                      (val) => setState(() => _estadoSeleccionado = val!),
                  onGuardar: _guardarCliente,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════

class _AppBarPersonalizado extends StatelessWidget {
  const _AppBarPersonalizado();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, color: kBlanco, padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
<<<<<<< HEAD
          Container(width: 38, height: 38, decoration: const BoxDecoration(color: kVerdeClaro, shape: BoxShape.circle), child: const Icon(Icons.recycling, color: kVerdePrincipal, size: 20)),
=======
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: kVerdeClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.recycling,
              color: kVerdePrincipal,
              size: 20,
            ),
          ),
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c
          const SizedBox(width: 10),
          const Text('EcoRecolector', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF212121))),
          const Spacer(),
          Stack(children: [const Icon(Icons.notifications_none, color: kGrisTexto, size: 26), Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)))]),
          const SizedBox(width: 16),
          const Row(children: [CircleAvatar(radius: 16, backgroundColor: kGrisBorde, child: Icon(Icons.person, color: kGrisTexto, size: 18)), SizedBox(width: 6), Text('Administrador', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF212121)))]),
        ],
      ),
    );
  }
}

class _ColumnaIzquierda extends StatelessWidget {
  final int totalClientes;
  final int clientesActivos;
  final int clientesInactivos;
  final VoidCallback onRegistrarTap;
<<<<<<< HEAD
  final String totalClientes;
  final String ingresosMes;

  const _ColumnaIzquierda({
    required this.onRegistrarTap,
    required this.totalClientes,
    required this.ingresosMes,
=======

  const _ColumnaIzquierda({
    required this.totalClientes,
    required this.clientesActivos,
    required this.clientesInactivos,
    required this.onRegistrarTap,
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 16, color: Color(0xFF212121)),
            children: [TextSpan(text: 'Bienvenido, '), TextSpan(text: 'Administrador', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)))],
          ),
        ),
<<<<<<< HEAD
=======
        const SizedBox(height: 16),
        _TarjetaEstadistica(

            cantidad: totalClientes.toString(),
          descripcion: 'Total Clientes Registrados',
          icono: Icons.people_alt,
          colorIcono: kVerdePrincipal,
        ),
        const SizedBox(height: 12),
        _TarjetaEstadistica(
            cantidad: clientesActivos.toString(),
          descripcion: 'Clientes Activos',
          icono: Icons.check_circle_outline,
          colorIcono: Colors.blue,
        ),
        const SizedBox(height: 12),
      _TarjetaEstadistica(
           cantidad: clientesInactivos.toString(),
          descripcion: 'Clientes Inactivos',
          icono: Icons.person_off_outlined,
          colorIcono: Colors.orange,
        ),
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _TarjetaEstadistica(cantidad: totalClientes, descripcion: 'Clientes Registrados', icono: Icons.people_alt, colorIcono: kVerdePrincipal)),
            const SizedBox(width: 16),
            Expanded(child: _TarjetaEstadistica(cantidad: ingresosMes, descripcion: 'Ingresos Totales', icono: Icons.monetization_on_outlined, colorIcono: Colors.blue)),
          ],
        ),
        const SizedBox(height: 24),
        const _GraficaIngresosGastos(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TarjetaEstadistica extends StatelessWidget {
  final String cantidad; final String descripcion; final IconData icono; final Color colorIcono;
  const _TarjetaEstadistica({required this.cantidad, required this.descripcion, required this.icono, required this.colorIcono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kBlanco, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: colorIcono.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icono, color: colorIcono, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cantidad, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                Text(descripcion, style: const TextStyle(fontSize: 12, color: kGrisTexto)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GraficaIngresosGastos extends StatelessWidget {
  const _GraficaIngresosGastos();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balance Financiero (Últimos 6 meses)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
          const SizedBox(height: 35),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center, groupsSpace: 45, maxY: 20,
                barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(getTooltipColor: (group) => Colors.blueGrey[800]!)),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('Ene', style: style); break;
                          case 1: text = const Text('Feb', style: style); break;
                          case 2: text = const Text('Mar', style: style); break;
                          case 3: text = const Text('Abr', style: style); break;
                          case 4: text = const Text('May', style: style); break;
                          case 5: text = const Text('Jun', style: style); break;
                          default: text = const Text('', style: style); break;
                        }
                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: text);
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200], strokeWidth: 1, dashArray: [5, 5])),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 15, 10), _makeGroupData(1, 18, 12), _makeGroupData(2, 14, 11), _makeGroupData(3, 16, 14), _makeGroupData(4, 19, 13), _makeGroupData(5, 12, 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(3)), margin: const EdgeInsets.only(right: 8)),
              const Text('Ingresos', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(width: 30),
              Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(3)), margin: const EdgeInsets.only(right: 8)),
              const Text('Gastos Operativos', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(x: x, barRods: [BarChartRodData(toY: y1, color: const Color(0xFF2E7D32), width: 22, borderRadius: BorderRadius.circular(6)), BarChartRodData(toY: y2, color: Colors.red[400], width: 22, borderRadius: BorderRadius.circular(6))]);
  }
}

class _FormularioRegistro extends StatelessWidget {
  final GlobalKey<FormState> formKey; final TextEditingController nombreController; final TextEditingController direccionController; final TextEditingController coloniaController; final TextEditingController telefonoController; final String estadoSeleccionado; final bool isLoading; final InputDecoration Function(String) inputDecoration; final ValueChanged<String?> onEstadoChanged; final VoidCallback onGuardar;
  const _FormularioRegistro({required this.formKey, required this.nombreController, required this.direccionController, required this.coloniaController, required this.telefonoController, required this.estadoSeleccionado, required this.isLoading, required this.inputDecoration, required this.onEstadoChanged, required this.onGuardar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: kBlanco, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Formulario Rápido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
            const SizedBox(height: 20),
            const _EtiquetaCampo(texto: 'Nombre Completo'), const SizedBox(height: 8),
            TextFormField(controller: nombreController, decoration: inputDecoration('Ej. Juan Pérez'), textCapitalization: TextCapitalization.words, validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null),
            const SizedBox(height: 16),
            const _EtiquetaCampo(texto: 'Dirección'), const SizedBox(height: 8),
            TextFormField(controller: direccionController, decoration: inputDecoration('Ej. 5ta Avenida 4-32'), textCapitalization: TextCapitalization.sentences, validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null),
            const SizedBox(height: 16),
            Row(
              children: [
<<<<<<< HEAD
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _EtiquetaCampo(texto: 'Teléfono'), const SizedBox(height: 8), TextFormField(controller: telefonoController, decoration: inputDecoration('Ej. 5555-0000'), keyboardType: TextInputType.phone, validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null)])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _EtiquetaCampo(texto: 'Estado'), const SizedBox(height: 8), DropdownButtonFormField<String>(value: estadoSeleccionado, decoration: inputDecoration(''), items: const [DropdownMenuItem(value: 'Activo', child: Text('Activo')), DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo'))], onChanged: onEstadoChanged, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null)])),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : onGuardar,
                style: ElevatedButton.styleFrom(backgroundColor: kVerdeBoton, foregroundColor: kBlanco, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 1),
                child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: kBlanco, strokeWidth: 2.5)) : const Text('Guardar Cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
=======
                const Text(
                  'Dashboard/\nRegistrar cliente',
                  style: TextStyle(
                    fontSize: 13,
                    color: kGrisTexto,
                    height: 1.4,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onGuardar,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Registrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kVerdeBoton,
                    foregroundColor: kBlanco,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _EtiquetaCampo(texto: 'Nombre'),
            const SizedBox(height: 6),
            TextFormField(
              controller: nombreController,
              decoration: inputDecoration('Ingrese nombre del cliente'),
              textCapitalization: TextCapitalization.words,
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Campo obligatorio'
                          : null,
            ),
            const SizedBox(height: 15),
            const _EtiquetaCampo(texto: 'Dirección'),
            const SizedBox(height: 6),
            TextFormField(
              controller: direccionController,
              decoration: inputDecoration('Ingrese dirección'),
              textCapitalization: TextCapitalization.sentences,
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Campo obligatorio'
                          : null,
            ),
            const SizedBox(height: 15),
            const _EtiquetaCampo(texto: 'Colonia'),
            const SizedBox(height: 6),
            TextFormField(
              controller: coloniaController,
              decoration: inputDecoration('Ingrese colonia'),
              textCapitalization: TextCapitalization.words,
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Campo obligatorio'
                          : null,
            ),
            const SizedBox(height: 15),
            const _EtiquetaCampo(texto: 'Teléfono'),
            const SizedBox(height: 6),
            TextFormField(
              controller: telefonoController,
              decoration: inputDecoration('Ingrese teléfono'),
              keyboardType: TextInputType.phone,
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Campo obligatorio'
                          : null,
            ),
            const SizedBox(height: 15),
            const _EtiquetaCampo(texto: 'Estado'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: estadoSeleccionado,
              decoration: inputDecoration(''),
              items: const [
                DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
              ],
              onChanged: onEstadoChanged,
              validator:
                  (v) =>
                      (v == null || v.isEmpty) ? 'Seleccione un estado' : null,
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 180,
                height: 46,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onGuardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kVerdeBoton,
                    foregroundColor: kBlanco,
                    disabledBackgroundColor: kVerdeBoton.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: kBlanco,
                              strokeWidth: 2.5,
                            ),
                          )
                          : const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtiquetaCampo extends StatelessWidget {
<<<<<<< HEAD
  final String texto; const _EtiquetaCampo({required this.texto});
  @override Widget build(BuildContext context) { return Text(texto, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF616161))); }
}
=======
  final String texto;
  const _EtiquetaCampo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF424242),
      ),
    );
  }
}
>>>>>>> 6802fe0871ccd1784d1f35e23eec2450d8a59e8c
