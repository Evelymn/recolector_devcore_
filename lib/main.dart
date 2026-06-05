import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/dashboard.dart';
import 'screens/login_page.dart'; // Aquí mandamos a llamar tu nueva pantalla

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase
  await Supabase.initialize(
    url: 'https://ksylquzplmxjhtpilrwp.supabase.co',
    anonKey: 'sb_publishable_jB1xzrSaCCYVAGHqLlAcVw_GoeLKy9m',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoRecolector',
      debugShowCheckedModeBanner: false, // Esto quita la banda de "DEBUG" en la esquina
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)), // Verde oficial
        useMaterial3: true,
      ),
      home: const LoginPage(), // ¡El cambio mágico para arrancar en el Login!
    );
  }
}