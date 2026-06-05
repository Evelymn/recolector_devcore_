import 'package:flutter/material.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  // Variables de estado falsas para los interruptores
  bool _notificaciones = true;
  bool _modoOscuro = false;
  bool _respaldoAuto = true;
  bool _autenticacionDosPasos = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración del Sistema',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // SECCIÓN: PREFERENCIAS
                  _buildSeccion('Preferencias de Interfaz', Icons.palette_outlined, [
                    SwitchListTile(
                      title: const Text('Modo Oscuro (BETA)'),
                      subtitle: const Text('Cambiar el tema visual de la aplicación'),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      activeColor: const Color(0xFF2E7D32),
                      value: _modoOscuro,
                      onChanged: (bool value) {
                        setState(() => _modoOscuro = value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Característica en desarrollo para la próxima versión.')),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Notificaciones Push'),
                      subtitle: const Text('Recibir alertas de nuevos registros y pagos'),
                      secondary: const Icon(Icons.notifications_active_outlined),
                      activeColor: const Color(0xFF2E7D32),
                      value: _notificaciones,
                      onChanged: (bool value) => setState(() => _notificaciones = value),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),

                  // SECCIÓN: SEGURIDAD
                  _buildSeccion('Seguridad y Respaldos', Icons.security_outlined, [
                    SwitchListTile(
                      title: const Text('Autenticación en Dos Pasos (2FA)'),
                      subtitle: const Text('Requerir código adicional al iniciar sesión'),
                      secondary: const Icon(Icons.lock_outline),
                      activeColor: const Color(0xFF2E7D32),
                      value: _autenticacionDosPasos,
                      onChanged: (bool value) => setState(() => _autenticacionDosPasos = value),
                    ),
                    SwitchListTile(
                      title: const Text('Respaldos Automáticos en la Nube'),
                      subtitle: const Text('Sincronizar base de datos con Supabase diariamente'),
                      secondary: const Icon(Icons.cloud_upload_outlined),
                      activeColor: const Color(0xFF2E7D32),
                      value: _respaldoAuto,
                      onChanged: (bool value) => setState(() => _respaldoAuto = value),
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined, color: Color(0xFF2E7D32)),
                      title: const Text('Exportar Base de Datos Local'),
                      subtitle: const Text('Descargar copia de seguridad en formato SQL'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Respaldo generado y guardado en descargas'), backgroundColor: Color(0xFF2E7D32)),
                          );
                        },
                        child: const Text('Exportar'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para crear las tarjetas blancas
  Widget _buildSeccion(String titulo, IconData icono, List<Widget> opciones) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: const Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
              ],
            ),
            const Divider(),
            ...opciones,
          ],
        ),
      ),
    );
  }
}