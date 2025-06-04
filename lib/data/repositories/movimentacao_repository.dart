import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_estoque_limpeza/data/model/movimentacao_model.dart';
import 'package:app_estoque_limpeza/data/model/historico_model.dart';

class MovimentacaoRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // INSERT
  Future<void> insertMovimentacao(Movimentacao movimentacao) async {
    try {
      await _client.from('movimentacao').insert(movimentacao.toMap());
    } on PostgrestException catch (e) {
      throw Exception('Erro ao inserir movimentação: ${e.message}');
    }
  }

  // SELECT ALL
  Future<List<Movimentacao>> getMovimentacoes() async {
    try {
      final List<dynamic> data = await _client.from('movimentacao').select();
      return data
          .map((map) => Movimentacao.fromMap(map as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar movimentações: ${e.message}');
    }
  }

  // JOIN COM HISTÓRICO DETALHADO
  Future<List<HistoricoModel>> getHistoricoDetalhado() async {
    try {
      final List<dynamic> data = await _client
          .from('movimentacao')
          .select('''
            saida_data,
            saida,
            usuario:usuario_id (matricula, nome, telefone),
            produto:idproduto (nome, quantidade)
          ''');

      return data.map((map) {
        final usuario = map['usuario'] as Map<String, dynamic>;
        final produto = map['produto'] as Map<String, dynamic>;

        return HistoricoModel(
          matricula: usuario['matricula'] as String,
          nome: usuario['nome'] as String,
          telefone: usuario['telefone'] as String,
          saidaData: map['saida_data'] as String,
          saida: map['saida'] as int,
          produto: produto['nome'] as String,
          saldo: produto['quantidade'] as int,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar histórico: ${e.message}');
    }
  }

  // UPDATE
  Future<void> updateMovimentacao(Movimentacao movimentacao) async {
    try {
      await _client
          .from('movimentacao')
          .update(movimentacao.toMap())
          .eq('idmovimentacao', movimentacao.idmovimentacao!);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao atualizar movimentação: ${e.message}');
    }
  }

  // DELETE
  Future<void> deleteMovimentacao(int id) async {
    try {
      await _client.from('movimentacao').delete().eq('idmovimentacao', id);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao excluir movimentação: ${e.message}');
    }
  }
}
