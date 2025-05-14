import 'package:app_estoque_limpeza/core/database_helper.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ProdutoRepositories {
  Future<void> insertProduto(ProdutoModel produto) async {
    final db = await DatabaseHelper.initDb();
    
    // Cria um novo map sem os campos de relacionamento
    final Map<String, dynamic> dadosParaInserir = {
      'Codigo': produto.codigo,
      'Nome': produto.nome,
      'Quantidade': produto.quantidade,
      'Validade': produto.validade,
      'Local': produto.local,
      'idtipo': produto.idtipo,
      'idfornecedor': produto.idfornecedor,
      'entrada': produto.entrada,
    };
    
    await db.insert(
      'Produto',
      dadosParaInserir,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProdutoModel>> getProduto({
    int? quantidadeMinima, 
    String? dataVencimentoMinima
  }) async {
    final db = await DatabaseHelper.initDb();
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (quantidadeMinima != null) {
      whereClause += 'p.Quantidade >= ?';
      whereArgs.add(quantidadeMinima);
    }
    
    if (dataVencimentoMinima != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'p.Validade >= ?';
      whereArgs.add(dataVencimentoMinima);
    }
    
    final query = '''
      SELECT p.*, f.nome as fornecedor, t.tipo 
      FROM produto p 
      JOIN fornecedor f ON f.idfornecedor = p.idfornecedor 
      JOIN tipo t ON p.idtipo = t.idtipo
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
    ''';
    
    final List<Map<String, Object?>> produtoMaps = await db.rawQuery(query, whereArgs);

    return produtoMaps.map((map) {
      return ProdutoModel(
        idMaterial: map['idproduto'] as int?,
        codigo: map['Codigo'] as String,
        nome: map['Nome'] as String,
        quantidade: map['Quantidade'] as int,
        validade: map['Validade'] as String?,
        local: map['Local'] as String,
        idtipo: map['idtipo'] as int,
        idfornecedor: map['idfornecedor'] as int,
        entrada: map['entrada'] as String,
        nomeFornecedor: map['fornecedor'] as String?,
        tipoProduto: map['tipo'] as String?,
      );
    }).toList();
  }

  Future<void> updateProduto(ProdutoModel produto) async {
    final db = await DatabaseHelper.initDb();
    
    // Cria um novo map sem os campos de relacionamento
    final Map<String, dynamic> dadosParaAtualizar = {
      'Codigo': produto.codigo,
      'Nome': produto.nome,
      'Quantidade': produto.quantidade,
      'Validade': produto.validade,
      'Local': produto.local,
      'idtipo': produto.idtipo,
      'idfornecedor': produto.idfornecedor,
      'entrada': produto.entrada,
    };
    
    await db.update(
      'produto',
      dadosParaAtualizar,
      where: 'idproduto = ?',
      whereArgs: [produto.idMaterial],
    );
  }

  Future<void> deleteProduto(int id) async {
    final db = await DatabaseHelper.initDb();
    await db.delete(
      'produto',
      where: 'idproduto = ?',
      whereArgs: [id],
    );
  }
  }