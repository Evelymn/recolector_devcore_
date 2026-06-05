import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class CobradorInicioMobile extends StatefulWidget {
  const CobradorInicioMobile({super.key});

  @override
  State<CobradorInicioMobile> createState() => _CobradorInicioMobileState();
}

class _CobradorInicioMobileState extends State<CobradorInicioMobile> {
  final supabase = Supabase.instance.client;
  int _indiceSeleccionado = 0;
  bool isLoading = true;
  
  List<Map<String, dynamic>> clientesRuta = [];
  Set<String> cobradosHoy = {}; // Guardaremos los IDs de los que ya pagaron en esta sesión
  double totalRecolectado = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarRutaDelDia();
  }

  // --- 1. LEER CLIENTES ACTIVOS PARA LA RUTA ---
  Future<void> _cargarRutaDelDia() async {
    try {
      // Solo traemos a los clientes que están "Activos"
      final data = await supabase.from('clientes').select().eq('estado', 'Activo');
      if (mounted) {
        setState(() {
          clientesRuta = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar ruta: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- 2. REGISTRAR PAGO DIRECTO EN LA BASE DE DATOS ---
  Future<void> _registrarCobroRapido(Map<String, dynamic> cliente) async {
    final nombreCliente = cliente['nombre']?.toString() ?? 'Cliente Desconocido';
    final idCliente = cliente['id'].toString();
    const tarifaEstandar = 150.00; // Tarifa fija simulada para el cobro rápido

    // Cambiamos la UI de inmediato para que se sienta súper rápido
    setState(() {
      cobradosHoy.add(idCliente);
      totalRecolectado += tarifaEstandar;
    });

    try {
      // Insertamos el pago real en Supabase para que el Admin lo vea en el Dashboard
      await supabase.from('pagos').insert({
        'cliente_nombre': nombreCliente,
        'monto': tarifaEstandar,
        'metodo_pago': 'Efectivo',
        'estado': 'Completado',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Q$tarifaEstandar cobrados a $nombreCliente'), 
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Si falla, revertimos la UI
      setState(() {
        cobradosHoy.remove(idCliente);
        totalRecolectado -= tarifaEstandar;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar pago: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Mis Rutas de Hoy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TARJETA DE RECAUDACIÓN DINÁMICA
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Recaudado Hoy', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              'Q ${totalRecolectado.toStringAsFixed(2)}', 
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Clientes en Ruta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                      Text('${clientesRuta.length} paradas', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // LISTA DE COBROS REAL
                  Expanded(
                    child: clientesRuta.isEmpty
                        ? const Center(child: Text('No hay clientes activos para visitar hoy.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: clientesRuta.length,
                            itemBuilder: (context, index) {
                              final cliente = clientesRuta[index];
                              final idCliente = cliente['id'].toString();
                              final nombre = cliente['nombre']?.toString() ?? 'Sin nombre';
                              final direccion = cliente['direccion']?.toString() ?? 'Sin dirección';
                              final colonia = cliente['colonia']?.toString() ?? '';
                              final ubicacion = colonia.isNotEmpty ? '$direccion, $colonia' : direccion;
                              
                              final esCompletado = cobradosHoy.contains(idCliente);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 1,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: esCompletado ? Colors.green[100] : Colors.orange[100],
                                    child: Icon(
                                      esCompletado ? Icons.check : Icons.location_on_outlined,
                                      color: esCompletado ? Colors.green[800] : Colors.orange[800],
                                    ),
                                  ),
                                  title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(ubicacion, style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 4),
                                      const Text('Tarifa: Q 150.00', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  trailing: esCompletado
                                      ? const Text('Pagado', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2E7D32),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () => _registrarCobroRapido(cliente),
                                          child: const Text('Cobrar'),
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      // MENÚ INFERIOR ESTILO MÓVIL
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSeleccionado,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _indiceSeleccionado = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Rutas'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Escanear'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}