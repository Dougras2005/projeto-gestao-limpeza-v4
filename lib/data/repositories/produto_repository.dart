import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';

class ProdutoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // INSERT
  Future<void> insertProduto(ProdutoModel produto) async {
    try {
      await _client.from('produto').insert(produto.toMap());
    } on PostgrestException catch (e) {
      throw Exception('Erro ao inserir produto: ${e.message}');
    }
  }

  // SELECT ALL
  Future<List<ProdutoModel>> getProduto() async {
    try {
      final List<dynamic> data = await _client.from('produto').select();
      return data
          .map((map) => ProdutoModel.fromMap(map as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar materiais: ${e.message}');
    }
  }

  // UPDATE
  Future<void> updateProduto(ProdutoModel produto) async {
    try {
      await _client
          .from('produto')
          .update(produto.toMap())
          .eq('idproduto', produto.idproduto!);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao atualizar produto: ${e.message}');
    }
  }

  // DELETE
  Future<void> deleteProduto(int id) async {
    try {
      await _client.from('produto').delete().eq('idproduto', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao excluir produto: ${e.message}');
    }
  }
}
