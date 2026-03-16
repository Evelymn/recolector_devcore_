import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/usuarios_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ksylquzplmxjhtpilrwp.supabase.co',
    anonKey: 'sb_publishable_jB1xzrSaCCYVAGHqLlAcVw_GoeLKy9m',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UsuariosPage(),
    );
  }
}
