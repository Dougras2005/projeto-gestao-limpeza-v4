import 'package:app_estoque_limpeza/core/database_helper.dart';
import 'package:app_estoque_limpeza/data/model/historico_model.dart';
import 'package:app_estoque_limpeza/data/model/movimentacao_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MovimentacaoRepository {
  Future<void> insertMovimentacao(Movimentacao movimentacao) async {
    final db = await DatabaseHelper.initDb();
    await db.insert(
      'movimentacao',
      movimentacao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Movimentacao>> getMovimentacoes() async {
    final db = await DatabaseHelper.initDb();
    final List<Map<String, Object?>> movimentacaoMaps =
        await db.query('movimentacao');

    return movimentacaoMaps.map((map) {
      return Movimentacao(
        idmovimentacao: map['idmovimentacao'] as int?,
        entradaData: map['entrada_data'] as String,
        saidaData: map['saida_data'] as String,
        entrada: map['entrada'] != null ? map['entrada'] as int : null,
        saida: map['saida'] != null ? map['saida'] as int : null,
        idproduto: map['idmaterial'] as int,
        idusuario: map['idusuario'] as int,
      );
    }).toList();
  }

  Future<List<HistoricoModel>> getHistoricoDetalhado() async {
  final db = await DatabaseHelper.initDb();

  final List<Map<String, Object?>> results = await db.rawQuery('''
    SELECT
      u.matricula,
      u.nome,
      u.telefone,
      m.saida_data,
      m.saida,
      p.Nome AS produto,
      p.Quantidade AS saldo
    FROM movimentacao m
    JOIN usuario u ON u.idusuario = m.idusuario
    JOIN produto p ON p.idproduto = m.idmaterial
  ''');

  return results.map((map) {
    return HistoricoModel(
      matricula: map['matricula'] as String,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      saidaData: map['saida_data'] as String,
      saida: map['saida'] as int,
      produto: map['produto'] as String,
      saldo: map['saldo'] as int,
    );
  }).toList();
}


  Future<void> updateMovimentacao(Movimentacao movimentacao) async {
    final db = await DatabaseHelper.initDb();
    await db.update(
      'movimentacao',
      movimentacao.toMap(),
      where: 'idmovimentacao = ?',
      whereArgs: [movimentacao.idmovimentacao],
    );
  }

  Future<void> deleteMovimentacao(int id) async {
    final db = await DatabaseHelper.initDb();
    await db.delete(
      'movimentacao',
      where: 'idmovimentacao = ?',
      whereArgs: [id],
    );
  }


}
