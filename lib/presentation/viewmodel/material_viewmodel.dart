import 'package:app_estoque_limpeza/data/model/produto_model.dart';
import 'package:app_estoque_limpeza/data/repositories/produto_repository.dart';
import 'package:flutter/material.dart';


class ProdutoViewModel extends ChangeNotifier {
  final ProdutoRepository _repository = ProdutoRepository();

  List<ProdutoModel> _produtos = [];
  List<ProdutoModel> get materiais => _produtos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMateriais() async {
    _isLoading = true;
    notifyListeners();

    try {
      _produtos = await _repository.getProduto();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao buscar materiais: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduto(ProdutoModel produto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.insertProduto(produto);
      _produtos.add(produto);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao adicionar produto: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMaterial(ProdutoModel produto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateProduto(produto);
      final index =
          _produtos.indexWhere((m) => m.idproduto == produto.idproduto);
      if (index != -1) {
        _produtos[index] = produto;
      }
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao atualizar produto: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMaterial(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.deleteProduto(id);
      _produtos.removeWhere((m) => m.idproduto == id);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao excluir produto: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
