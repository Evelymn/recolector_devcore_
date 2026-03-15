import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {

  final supabase = Supabase.instance.client;

  Future<List<dynamic>> obtenerUsuarios() async {
    final response = await supabase
        .from('usuarios')
        .select();

    print(response); // para verificar en consola

    return response;
  }

  Future insertarUsuario(String nombre, String direccion) async {
    await supabase.from('usuarios').insert({
      'nombre': nombre,
      'direccion': direccion
    });
  }

}