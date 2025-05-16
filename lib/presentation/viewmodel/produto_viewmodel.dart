import 'dart:io';

import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/produto_repositories.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ProdutoViewModel extends ChangeNotifier {
  final ProdutoRepositories _repository = ProdutoRepositories();

  List<ProdutoModel> _produto = [];
  List<ProdutoModel> get produto => _produto;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProduto() async {
    _isLoading = true;
    notifyListeners();

    try {
      _produto = await _repository.getProduto();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao buscar materiais: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportProdutoToPdf() async {
  try {
    final resultado = await _repository.getProdutoAgrupado();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Relatório de Estoque',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Código',
                  'Produto',
                  'Local',
                  'Total Entrada',
                  'Total Saída',
                  'Saldo',
                ],
                data: resultado.map((item) {
                  return [
                    item['Codigo']?.toString() ?? '',
                    item['PRODUTO'] ?? '',
                    item['LOCAL'] ?? '',
                    item['TOTAL_ENTRADA']?.toString() ?? '0',
                    item['TOTAL_SAIDA']?.toString() ?? '0',
                    item['SALDO']?.toString() ?? '0',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Obtém o diretório de documentos
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/relatorio_estoque.pdf';

    // Salva o arquivo
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Abre o arquivo
    await OpenFile.open(filePath);
  } catch (e) {
    throw Exception('Erro ao gerar o PDF: $e');
  }


}

  Future<void> addProduto(ProdutoModel produto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.insertProduto(produto);
      _produto.add(produto);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao adicionar material: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduto(ProdutoModel produto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateProduto(produto);
      final index =
          _produto.indexWhere((m) => m.idMaterial == produto.idMaterial);
      if (index != -1) {
        _produto[index] = produto;
      }
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao atualizar material: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduto(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteProduto(id);
      _produto.removeWhere((m) => m.idMaterial == id);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao excluir material: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
