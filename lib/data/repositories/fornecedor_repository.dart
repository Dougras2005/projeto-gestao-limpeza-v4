import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_estoque_limpeza/data/model/fornecedor_model.dart';

class FornecedorRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // INSERT ---------------------------------------------------------------
  Future<void> insertFornecedor(Fornecedor fornecedor) async {
    try {
      await _client.from('fornecedor').insert(fornecedor.toMap());
    } on PostgrestException catch (e) {
      throw Exception('Erro ao inserir fornecedor: ${e.message}');
    }
  }

  // SELECT ALL -----------------------------------------------------------
  Future<List<Fornecedor>> getFornecedores() async {
    try {
      final List<dynamic> data = await _client.from('fornecedor').select();
      return data
          .map((m) => Fornecedor.fromMap(m as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar fornecedores: ${e.message}');
    }
  }

  // UPDATE ---------------------------------------------------------------
  Future<void> updateFornecedor(Fornecedor fornecedor) async {
    try {
      await _client
          .from('fornecedor')
          .update(fornecedor.toMap())
          .eq('idfornecedor', fornecedor.idfornecedor!);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao atualizar fornecedor: ${e.message}');
    }
  }

  // DELETE ---------------------------------------------------------------
  Future<void> deleteFornecedor(int id) async {
    try {
      await _client.from('fornecedor').delete().eq('idfornecedor', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao remover fornecedor: ${e.message}');
    }
  }

  // OBTÉM ID PELO NOME ---------------------------------------------------
  Future<int?> getIdByFornecedor(String nome) async {
    final Map<String, dynamic>? row = await _client
        .from('fornecedor')
        .select('idfornecedor')
        .eq('nome', nome)
        .maybeSingle();

    return row?['idfornecedor'] as int?;
  }

  // LISTA SÓ OS NOMES ----------------------------------------------------
  Future<List<String>> getNomesFornecedores() async {
    final List<dynamic> data = await _client.from('fornecedor').select('nome');
    return data.map((row) => row['nome'] as String).toList();
  }
}
