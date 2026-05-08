// ============================================================
//  ARCHIVO: dashboard_registrar_cliente.dart
//  DESCRIPCIÓN: Pantalla principal del Dashboard con formulario
//  para registrar clientes, inspirada en el diseño de EcoRecolector.
//  Incluye: menú lateral, tarjetas de estadísticas y formulario.
// ============================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/menulateral.dart';

// ─────────────────────────────────────────────────────────────
// CONSTANTES DE COLOR
// Centralizamos los colores aquí para cambiarlos fácilmente
// ─────────────────────────────────────────────────────────────
const Color kVerdePrincipal = Color(0xFF2E7D32); // Verde oscuro del menú
const Color kVerdeBoton = Color(0xFF388E3C); // Verde del botón Guardar
const Color kVerdeClaro = Color(0xFFE8F5E9); // Verde muy claro de fondo
const Color kGrisBorde = Color(0xFFE0E0E0); // Gris suave para bordes
const Color kGrisTexto = Color(0xFF616161); // Gris para texto secundario
const Color kBlanco = Colors.white;

// ─────────────────────────────────────────────────────────────
// WIDGET PRINCIPAL: DashboardRegistrarCliente
// Es un StatefulWidget porque necesita manejar el estado
// del formulario (controladores, loading, etc.)
// ─────────────────────────────────────────────────────────────
class DashboardRegistrarCliente extends StatefulWidget {
  const DashboardRegistrarCliente({super.key});

  @override
  State<DashboardRegistrarCliente> createState() =>
      _DashboardRegistrarClienteState();
}

class _DashboardRegistrarClienteState extends State<DashboardRegistrarCliente> {
  // ── Clave del formulario ──────────────────────────────────
  // Permite validar todos los campos de una sola vez
  final _formKey = GlobalKey<FormState>();

  // ── Controladores de texto ────────────────────────────────
  // Cada uno captura el texto que el usuario escribe en su campo
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _telefonoController = TextEditingController();

  // ── Estado del dropdown ───────────────────────────────────
  String _estadoSeleccionado = 'Activo';

  // ── Estado de carga ───────────────────────────────────────
  // true = se está guardando en Supabase (muestra spinner)
  bool _isLoading = false;

  // ── Índice del menú lateral seleccionado ─────────────────
  // 0=Dashboard, 1=Clientes, 2=Pagos, 3=Empleados, 4=Reportes
  int _menuSeleccionado = 0;

  // ── Cliente de Supabase ───────────────────────────────────
  // Instancia global que ya fue inicializada en main.dart
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── Limpiar controladores al destruir el widget ───────────
  // Evita fugas de memoria
  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _coloniaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // MÉTODO: _guardarCliente
  // Valida el formulario y, si todo está correcto,
  // inserta el cliente en la tabla 'clientes' de Supabase.
  // ─────────────────────────────────────────────────────────
  Future<void> _guardarCliente() async {
    // Si algún campo está vacío, detiene y muestra errores
    if (!_formKey.currentState!.validate()) return;

    // Activa el indicador de carga
    setState(() => _isLoading = true);

    try {
      // Inserta el nuevo cliente en Supabase
      // Ajusta los nombres de columna si difieren en tu tabla
      await _supabase.from('clientes').insert({
        'nombre': _nombreController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'colonia': _coloniaController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'estado': _estadoSeleccionado,
      });

      if (!mounted) return;

      // Muestra mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Cliente registrado correctamente'),
          backgroundColor: kVerdePrincipal,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Limpia todos los campos después de guardar
      _limpiarFormulario();
    } on PostgrestException catch (e) {
      // Error proveniente de Supabase (ej. columna inexistente)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Supabase: ${e.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Cualquier otro error inesperado
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Siempre desactiva el spinner al terminar
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────
  // MÉTODO: _limpiarFormulario
  // Vacía todos los campos del formulario y resetea el estado
  // ─────────────────────────────────────────────────────────
  void _limpiarFormulario() {
    _nombreController.clear();
    _direccionController.clear();
    _coloniaController.clear();
    _telefonoController.clear();
    setState(() => _estadoSeleccionado = 'Activo');
    _formKey.currentState?.reset();
  }

  // ─────────────────────────────────────────────────────────
  // MÉTODO: _inputDecoration
  // Devuelve la decoración visual estándar para cada TextField.
  // Centralizado aquí para que todos los campos sean iguales.
  // ─────────────────────────────────────────────────────────
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
  // BUILD PRINCIPAL
  // Estructura: Row → [Menú lateral | Contenido principal]
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          // ══════════════════════════════════════════════════
          // SECCIÓN 1: MENÚ LATERAL (Sidebar)
          // Siempre visible a la izquierda
          // ══════════════════════════════════════════════════
          MenuLateral(
            seleccionado: _menuSeleccionado,
            onItemTap: (index) => setState(() => _menuSeleccionado = index),
          ),

          // ══════════════════════════════════════════════════
          // SECCIÓN 2: CONTENIDO PRINCIPAL
          // Ocupa todo el espacio restante
          // ══════════════════════════════════════════════════
          Expanded(
            child: Column(
              children: [
                // ── AppBar personalizado ─────────────────
                _AppBarPersonalizado(),

                // ── Cuerpo scrolleable ───────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de la sección
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Layout de dos columnas ───────
                        // Izquierda: bienvenida + tarjetas + botón
                        // Derecha: formulario de registro
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── COLUMNA IZQUIERDA ────────
                            Expanded(
                              flex: 5,
                              child: _ColumnaIzquierda(
                                onRegistrarTap: () {
                                  // Cuando presiona "Registrar Cliente"
                                  // hace scroll al formulario (derecha)
                                  // En pantallas pequeñas puedes navegar
                                  // a otra pantalla aquí
                                },
                              ),
                            ),

                            const SizedBox(width: 16),

                            // ── COLUMNA DERECHA: FORMULARIO ──
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
                                onEstadoChanged:
                                    (val) => setState(
                                      () => _estadoSeleccionado = val!,
                                    ),
                                onGuardar: _guardarCliente,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET: _AppBarPersonalizado
// Barra superior con logo, nombre de la app, campana y avatar
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
          // Logo circular con ícono de reciclaje
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: kVerdeClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.recycling,
              color: kVerdePrincipal,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // Nombre de la app
          const Text(
            'EcoRecolector',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF212121),
            ),
          ),

          const Spacer(),

          // Ícono de notificaciones con badge
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

          // Avatar del usuario + nombre
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kGrisBorde,
                child: const Icon(Icons.person, color: kGrisTexto, size: 18),
              ),
              const SizedBox(width: 6),
              const Text(
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


// ═══════════════════════════════════════════════════════════════
// WIDGET: _ColumnaIzquierda
// Contiene: saludo de bienvenida, tarjetas de estadísticas
// y botón para registrar un cliente.
// ═══════════════════════════════════════════════════════════════
class _ColumnaIzquierda extends StatelessWidget {
  final VoidCallback onRegistrarTap;

  const _ColumnaIzquierda({required this.onRegistrarTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Saludo de bienvenida ─────────────────────────
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

        // ── Tarjeta: Total Clientes Registrados ──────────
        _TarjetaEstadistica(
          cantidad: '350',
          descripcion: 'Total Clientes Registrados',
          icono: Icons.people_alt,
          colorIcono: kVerdePrincipal,
        ),
        const SizedBox(height: 12),

        // ── Tarjeta: Clientes Activos ────────────────────
        _TarjetaEstadistica(
          cantidad: '300',
          descripcion: 'Clientes Activos',
          icono: Icons.check_circle_outline,
          colorIcono: Colors.blue,
        ),
        const SizedBox(height: 12),

        // ── Tarjeta: Clientes Inactivos ──────────────────
        _TarjetaEstadistica(
          cantidad: '50',
          descripcion: 'Clientes Inactivos',
          icono: Icons.person_off_outlined,
          colorIcono: Colors.orange,
        ),
        const SizedBox(height: 20),

        // ── Botón Registrar Cliente ──────────────────────
        // Con borde verde punteado, igual al diseño
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

// ── Tarjeta de estadística individual ─────────────────────────
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
          // Número grande
          Text(
            cantidad,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(width: 12),
          // Ícono decorativo
          Icon(icono, color: colorIcono, size: 32),
          const SizedBox(width: 10),
          // Descripción de la tarjeta
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

// ═══════════════════════════════════════════════════════════════
// WIDGET: _FormularioRegistro
// Columna derecha con el formulario completo de registro.
// Recibe los controladores y callbacks del widget padre.
// ═══════════════════════════════════════════════════════════════
class _FormularioRegistro extends StatelessWidget {
  // Clave para validación del formulario
  final GlobalKey<FormState> formKey;

  // Controladores de los campos de texto
  final TextEditingController nombreController;
  final TextEditingController direccionController;
  final TextEditingController coloniaController;
  final TextEditingController telefonoController;

  // Estado del dropdown y del botón
  final String estadoSeleccionado;
  final bool isLoading;

  // Función que devuelve la decoración de cada campo
  final InputDecoration Function(String) inputDecoration;

  // Callbacks al usuario interactuar
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
            // Encabezado del formulario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard/\nRegistrar cliente',
                  style: TextStyle(
                    fontSize: 13,
                    color: kGrisTexto,
                    height: 1.4,
                  ),
                ),
                // Botón verde "+ Registrar" en la esquina
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

            // ── Campo: Nombre ────────────────────────────
            _EtiquetaCampo(texto: 'Nombre'),
            const SizedBox(height: 6),
            TextFormField(
              controller: nombreController,
              decoration: inputDecoration('Ingrese nombre del cliente'),
              textCapitalization: TextCapitalization.words,
              // Validación: campo obligatorio
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Campo obligatorio'
                          : null,
            ),
            const SizedBox(height: 15),

            // ── Campo: Dirección ─────────────────────────
            _EtiquetaCampo(texto: 'Dirección'),
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

            // ── Campo: Colonia ───────────────────────────
            _EtiquetaCampo(texto: 'Colonia'),
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

            // ── Campo: Teléfono ──────────────────────────
            _EtiquetaCampo(texto: 'Teléfono'),
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

            // ── Campo: Estado (Dropdown) ─────────────────
            _EtiquetaCampo(texto: 'Estado'),
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

            // ── Botón Guardar ────────────────────────────
            // Centrado y de ancho completo
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
                          // Spinner mientras guarda
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: kBlanco,
                              strokeWidth: 2.5,
                            ),
                          )
                          // Texto normal del botón
                          : const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Etiqueta de cada campo del formulario ──────────────────────
// Widget reutilizable para los títulos de los campos
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
//Comentario para verificar porque esta ventana no aparece en github