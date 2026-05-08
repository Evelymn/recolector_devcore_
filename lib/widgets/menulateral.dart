import 'package:flutter/material.dart';

// puedes mover esto luego a un archivo de constantes
const Color kVerdePrincipal = Color(0xFF2E7D32);
const Color kBlanco = Colors.white;

class MenuLateral extends StatelessWidget {
  final int seleccionado;
  final ValueChanged<int> onItemTap;

  const MenuLateral({
    super.key,
    required this.seleccionado,
    required this.onItemTap,
  });

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
      width: 110,
      color: kVerdePrincipal,
      child: Column(
        children: [
          const SizedBox(height: 20),
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
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        color: seleccionado
            ? Colors.black.withOpacity(0.2)
            : Colors.transparent,
        child: Column(
          children: [
            Icon(icono, color: kBlanco, size: 22),
            const SizedBox(height: 4),
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