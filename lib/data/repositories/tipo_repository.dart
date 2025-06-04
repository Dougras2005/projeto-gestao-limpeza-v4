import 'package:app_estoque_limpeza/data/model/tipo_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TipoRepository {
  final supabase = Supabase.instance.client;

  // Future<void> insertTipo(Tipo tipo) async {
  //   final response = await supabase
  //       .from('tipo')
  //       .insert(tipo.toMap())
  //       .select()
  //       .single();

  //   if (response == null) {
  //     throw Exception('Erro ao inserir tipo.');
  //   }
  // }

  Future<List<Tipo>> getTipos() async {
    final response = await supabase.from('tipo').select();

    return (response as List)
        .map((map) => Tipo.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  // Future<void> updateTipo(Tipo tipo) async {
  //   final response = await supabase
  //       .from('tipo')
  //       .update(tipo.toMap())
  //       .eq('idtipo', tipo.idtipo!);

  //   if (response.error != null) {
  //     throw Exception('Erro ao atualizar tipo: ${response.error!.message}');
  //   }
  // }

  // Future<void> deleteTipo(int id) async {
  //   final response =
  //       await supabase.from('tipo').delete().eq('idtipo', id);

  //   if (response.error != null) {
  //     throw Exception('Erro ao deletar tipo: ${response.error!.message}');
  //   }
  // }

  Future<int?> getIdByTipo(String tipoNome) async {
    final response = await supabase
        .from('tipo')
        .select('idtipo')
        .eq('tipo', tipoNome)
        .limit(1)
        .maybeSingle();

    if (response != null && response['idtipo'] != null) {
      return response['idtipo'] as int;
    }

    return null;
  }

  Future<List<String>> getNomesTipo() async {
    final response = await supabase.from('tipo').select('tipo');

    return (response as List)
        .map((map) => map['tipo'] as String)
        .toList();
  }
}
