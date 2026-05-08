import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// CONSTANTES DE ESTILO
// Se definen colores reutilizables para mantener consistencia
// en toda la interfaz del menú lateral.
// ─────────────────────────────────────────────────────────────
const Color kVerdePrincipal = Color(0xFF2E7D32); // Color base del menú
const Color kBlanco = Colors.white; // Color de texto e íconos

// ─────────────────────────────────────────────────────────────
// WIDGET: MenuLateral
// Representa el menú lateral del dashboard.
// Muestra una lista de opciones con íconos y permite seleccionar
// una opción mediante un callback.
// ─────────────────────────────────────────────────────────────
class MenuLateral extends StatelessWidget {
  // Índice del ítem seleccionado actualmente
  final int seleccionado;

  // Callback que se ejecuta al hacer clic en un ítem
  final ValueChanged<int> onItemTap;

  const MenuLateral({
    super.key,
    required this.seleccionado,
    required this.onItemTap,
  });

  // ───────────────────────────────────────────────────────────
  // LISTA DE ÍTEMS DEL MENÚ
  // Cada elemento contiene:
  // [Icono, Texto]
  // Se puede extender fácilmente agregando más opciones.
  // ───────────────────────────────────────────────────────────
  static const _items = [
    [Icons.dashboard, 'Dashboard'],
    [Icons.people, 'Clientes'],
    [Icons.payment, 'Pagos\nEmpleados\nClientes'],
    [Icons.badge, 'Empleados'],
    [Icons.bar_chart, 'Reportes'],
    [Icons.settings, 'Configuración'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110, // Ancho fijo del menú lateral
      color: kVerdePrincipal,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ───────────────────────────────────────────────
          // GENERACIÓN DINÁMICA DE ÍTEMS
          // Recorre la lista _items y crea un widget por cada opción
          // ───────────────────────────────────────────────
          for (int i = 0; i < _items.length; i++)
            _ItemMenu(
              icono: _items[i][0] as IconData,
              label: _items[i][1] as String,
              seleccionado: seleccionado == i,
              onTap: () => onItemTap(i),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WIDGET PRIVADO: _ItemMenu
// Representa un solo elemento dentro del menú lateral.
// Maneja el estado visual (seleccionado/no seleccionado)
// y la interacción del usuario.
// ─────────────────────────────────────────────────────────────
class _ItemMenu extends StatelessWidget {
  final IconData icono;
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icono,
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Detecta clic del usuario
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),

        // ───────────────────────────────────────────────
        // ESTADO VISUAL
        // Si está seleccionado, se aplica un fondo más oscuro
        // ───────────────────────────────────────────────
        color: seleccionado
            ? Colors.black.withOpacity(0.2)
            : Colors.transparent,

        child: Column(
          children: [
            // Ícono del ítem
            Icon(icono, color: kBlanco, size: 22),
            const SizedBox(height: 4),

            // Texto del ítem
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kBlanco,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}