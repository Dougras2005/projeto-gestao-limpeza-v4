import 'package:app_estoque_limpeza/core/database_helper.dart';
import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ProdutoRepositories {
  Future<void> insertProduto(ProdutoModel produto) async {
    final db = await DatabaseHelper.initDb();
    await db.insert(
      'Produto',
      produto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

 Future<List<ProdutoModel>> getProduto({
  int? quantidadeMinima, 
  String? dataVencimentoMinima
}) async {
  final db = await DatabaseHelper.initDb();
  
  // Build where clause and arguments dynamically
  String whereClause = '';
  List<dynamic> whereArgs = [];
  
  if (quantidadeMinima != null) {
    whereClause += 'Quantidade >= ?';
    whereArgs.add(quantidadeMinima);
  }
  
  if (dataVencimentoMinima != null) {
    if (whereClause.isNotEmpty) {
      whereClause += ' AND ';
    }
    whereClause += 'Validade >= ?';
    whereArgs.add(dataVencimentoMinima);
  }
  
  // Query SQL with conditional filters
  final List<Map<String, Object?>> produtoMaps = whereClause.isNotEmpty
      ? await db.query(
          'Produto',
          where: whereClause,
          whereArgs: whereArgs,
        )
      : await db.query('Produto');

  return produtoMaps.map((map) {
    return ProdutoModel(
      idproduto: map['idproduto'] as int?,
      codigo: map['Codigo'] as String,
      nome: map['Nome'] as String,
      quantidade: map['Quantidade'] as int,
      validade: map['Validade'] as String?,
      local: map['Local'] as String,
      idtipo: map['idtipo'] as int,
      idfornecedor: map['idfornecedor'] as int,
      entrada: map['entrada'] as String,
    );
  }).toList();
}


  Future<void> updateProduto(ProdutoModel produto) async {
    final db = await DatabaseHelper.initDb();
    await db.update(
      'produto',
      produto.toMap(),
      where: 'idproduto = ?',
      whereArgs: [produto.idproduto],
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
