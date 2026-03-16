import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> obtenerUsuarios() async {
    final response = await supabase.from('usuarios').select();

    return response;
  }

  Future insertarUsuario(String nombre, String correo) async {
    await supabase.from('usuarios').insert({
      'nombre': nombre,
      'correo': correo,
    });
  }
}
