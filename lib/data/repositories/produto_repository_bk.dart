import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdutoRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<void> insertProduto(ProdutoModel produto) async {
    final dadosParaInserir = {
      'Codigo': produto.codigo,
      'Nome': produto.nome,
      'Quantidade': produto.quantidade,
      'Validade': produto.validade,
      'Local': produto.local,
      'idtipo': produto.idtipo,
      'idfornecedor': produto.idfornecedor,
      'entrada': produto.entrada,
      'nomeFornecedor': produto.nomeFornecedor,
      'tipoProduto': produto.tipoProduto,
    };

    final response = await client.from('produto').insert(dadosParaInserir);

    if (response == null) {
      throw Exception('Erro ao inserir produto.');
    }
  }

  Future<List<ProdutoModel>> getProduto({
    int? quantidadeMinima,
    String? dataVencimentoMinima,
  }) async {
    var query = client
        .from('produto')
        .select('*, fornecedor(nome), tipo(tipo)');

    if (quantidadeMinima != null) {
      query = query.gte('Quantidade', quantidadeMinima);
    }

    if (dataVencimentoMinima != null) {
      query = query.gte('Validade', dataVencimentoMinima);
    }

    final response = await query;

    return response.map((map) {
      return ProdutoModel(
        idproduto: map['idproduto'] as int?,
        codigo: map['Codigo'],
        nome: map['Nome'],
        quantidade: map['Quantidade'],
        validade: map['Validade'],
        local: map['Local'],
        idtipo: map['idtipo'],
        idfornecedor: map['idfornecedor'],
        entrada: map['entrada'],
        nomeFornecedor: map['fornecedor']?['nome'],
        tipoProduto: map['tipo']?['tipo'],
      );
    }).toList();
    }

  Future<void> updateProduto(ProdutoModel produto) async {
    final dadosParaAtualizar = {
      'Codigo': produto.codigo,
      'Nome': produto.nome,
      'Quantidade': produto.quantidade,
      'Validade': produto.validade,
      'Local': produto.local,
      'idtipo': produto.idtipo,
      'idfornecedor': produto.idfornecedor,
      'entrada': produto.entrada,
      'nomeFornecedor': produto.nomeFornecedor,
      'tipoProduto': produto.tipoProduto,
    };

    final response = await client
        .from('produto')
        .update(dadosParaAtualizar)
        .eq('idproduto', produto.idproduto!);

    if (response == null) {
      throw Exception('Erro ao atualizar produto.');
    }
  }

  Future<void> deleteProduto(int id) async {
    final response =
        await client.from('produto').delete().eq('idproduto', id);

    if (response == null) {
      throw Exception('Erro ao excluir produto.');
    }
  }

  Future<List<Map<String, dynamic>>> getProdutoAgrupado() async {
    final response = await client.rpc('get_produto_agrupado'); // Função SQL

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      throw Exception('Erro ao executar agregação.');
    }
  }
}
