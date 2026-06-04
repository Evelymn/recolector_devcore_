// ============================================================
//  ARCHIVO: dashboard.dart
//  DESCRIPCIÓN: Pantalla principal del Dashboard con navegación
//  dinámica y formulario para registrar clientes.
// ============================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/menulateral.dart';
import 'reportes_page.dart';  // Tu tabla
import 'usuarios_page.dart';  // La lista de tu compañero

// ─────────────────────────────────────────────────────────────
// CONSTANTES DE COLOR
// ─────────────────────────────────────────────────────────────
const Color kVerdePrincipal = Color(0xFF2E7D32);
const Color kVerdeBoton = Color(0xFF388E3C);
const Color kVerdeClaro = Color(0xFFE8F5E9);
const Color kGrisBorde = Color(0xFFE0E0E0);
const Color kGrisTexto = Color(0xFF616161);
const Color kBlanco = Colors.white;

class DashboardRegistrarCliente extends StatefulWidget {
  const DashboardRegistrarCliente({super.key});

  @override
  State<DashboardRegistrarCliente> createState() =>
      _DashboardRegistrarClienteState();
}

class _DashboardRegistrarClienteState extends State<DashboardRegistrarCliente> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _telefonoController = TextEditingController();

  String _estadoSeleccionado = 'Activo';
  bool _isLoading = false;

  // 0=Dashboard, 1=Clientes, 2=Pagos, 3=Empleados, 4=Reportes
  int _menuSeleccionado = 0;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _coloniaController.dispose();
    _telefonoController.dispose();
    super.dispose();
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
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Supabase: ${e.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
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
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kGrisBorde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kVerdePrincipal, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // AQUÍ ESTÁ EL SWITCH MÁGICO 
  // ─────────────────────────────────────────────────────────
  Widget _obtenerVistaActual() {
    switch (_menuSeleccionado) {
      case 0:
        return _buildContenidoDashboard(); // Vista original del formulario
      case 1:
        return const UsuariosPage(); // ¡Tu vista de Clientes!
      case 4:
        return const ReportesPage(); // ¡Tu vista de Reportes!
      default:
        return const Center(
          child: Text(
            'Pantalla en construcción...',
            style: TextStyle(fontSize: 18, color: kGrisTexto),
          ),
        );
    }
  }

  // ─────────────────────────────────────────────────────────
  // BUILD PRINCIPAL
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          MenuLateral(
            seleccionado: _menuSeleccionado,
            onItemTap: (index) => setState(() => _menuSeleccionado = index),
          ),
          Expanded(
            child: Column(
              children: [
                _AppBarPersonalizado(),
                // AQUÍ INYECTAMOS LA VISTA DINÁMICA
                Expanded(
                  child: _obtenerVistaActual(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // INTERFAZ ORIGINAL DEL DASHBOARD (Formulario)
  // ─────────────────────────────────────────────────────────
  Widget _buildContenidoDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _ColumnaIzquierda(
                  onRegistrarTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: _FormularioRegistro(
                  formKey: _formKey,
                  nombreController: _nombreController,
                  direccionController: _direccionController,
                  coloniaController: _coloniaController,
                  telefonoController: _telefonoController,
                  estadoSeleccionado: _estadoSeleccionado,
                  isLoading: _isLoading,
                  inputDecoration: _inputDecoration,
                  onEstadoChanged: (val) => setState(() => _estadoSeleccionado = val!),
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
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════

class _AppBarPersonalizado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: kBlanco,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: kVerdeClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.recycling, color: kVerdePrincipal, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'EcoRecolector',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF212121),
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              const Icon(Icons.notifications_none, color: kGrisTexto, size: 26),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          const Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kGrisBorde,
                child: Icon(Icons.person, color: kGrisTexto, size: 18),
              ),
              SizedBox(width: 6),
              Text(
                'Admin',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColumnaIzquierda extends StatelessWidget {
  final VoidCallback onRegistrarTap;
  const _ColumnaIzquierda({required this.onRegistrarTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14, color: Color(0xFF212121)),
            children: [
              TextSpan(text: 'Bienvenido: '),
              TextSpan(
                text: 'Admin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _TarjetaEstadistica(
          cantidad: '350',
          descripcion: 'Total Clientes Registrados',
          icono: Icons.people_alt,
          colorIcono: kVerdePrincipal,
        ),
        const SizedBox(height: 12),
        const _TarjetaEstadistica(
          cantidad: '300',
          descripcion: 'Clientes Activos',
          icono: Icons.check_circle_outline,
          colorIcono: Colors.blue,
        ),
        const SizedBox(height: 12),
        const _TarjetaEstadistica(
          cantidad: '50',
          descripcion: 'Clientes Inactivos',
          icono: Icons.person_off_outlined,
          colorIcono: Colors.orange,
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: kVerdePrincipal, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: onRegistrarTap,
            child: const Text(
              'Registrar Cliente',
              style: TextStyle(
                color: kVerdePrincipal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaEstadistica extends StatelessWidget {
  final String cantidad;
  final String descripcion;
  final IconData icono;
  final Color colorIcono;

  const _TarjetaEstadistica({
    required this.cantidad,
    required this.descripcion,
    required this.icono,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kBlanco,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            cantidad,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icono, color: colorIcono, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              descripcion,
              style: const TextStyle(fontSize: 11, color: kGrisTexto),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormularioRegistro extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController direccionController;
  final TextEditingController coloniaController;
  final TextEditingController telefonoController;
  final String estadoSeleccionado;
  final bool isLoading;
  final InputDecoration Function(String) inputDecoration;
  final ValueChanged<String?> onEstadoChanged;
  final VoidCallback onGuardar;

  const _FormularioRegistro({
    required this.formKey,
    required this.nombreController,
    required this.direccionController,
    required this.coloniaController,
    required this.telefonoController,
    required this.estadoSeleccionado,
    required this.isLoading,
    required this.inputDecoration,
    required this.onEstadoChanged,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBlanco,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard/\nRegistrar cliente',
                  style: TextStyle(fontSize: 13, color: kGrisTexto, height: 1.4),
                ),
                ElevatedButton.icon(
                  onPressed: onGuardar,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Registrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kVerdeBoton,
                    foregroundColor: kBlanco,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 15),
            const _EtiquetaCampo(texto: 'Dirección'),
            const SizedBox(height: 6),
            TextFormField(
              controller: direccionController,
              decoration: inputDecoration('Ingrese dirección'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 15),
            const _EtiquetaCampo(texto: 'Colonia'),
            const SizedBox(height: 6),
            TextFormField(
              controller: coloniaController,
              decoration: inputDecoration('Ingrese colonia'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 15),
            const _EtiquetaCampo(texto: 'Teléfono'),
            const SizedBox(height: 6),
            TextFormField(
              controller: telefonoController,
              decoration: inputDecoration('Ingrese teléfono'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
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
              validator: (v) => (v == null || v.isEmpty) ? 'Seleccione un estado' : null,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: kBlanco, strokeWidth: 2.5),
                        )
                      : const Text('Guardar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtiquetaCampo extends StatelessWidget {
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