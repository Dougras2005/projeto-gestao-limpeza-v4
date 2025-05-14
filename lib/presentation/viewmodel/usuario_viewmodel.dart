import 'package:flutter/material.dart';
import 'package:app_estoque_limpeza/data/repositories/usuario_repositories.dart';
import 'package:app_estoque_limpeza/data/model/usuario_model.dart';

class UsuarioViewModel with ChangeNotifier {
  final UsuarioRepository repository;

  UsuarioViewModel(this.repository);

  List<Usuario> _usuarios = [];
  List<Usuario> get usuarios => _usuarios;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Usuario? _usuarioLogado;
  Usuario? get usuarioLogado => _usuarioLogado;

  Future<void> fetchUsuarios() async {
    _isLoading = true;
    notifyListeners();

    try {
      _usuarios = await repository.getUsuarios();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao buscar usuários: $error';
      _usuarios = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUsuario(Usuario usuario) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.insertUsuario(usuario);
      await fetchUsuarios(); // Recarrega a lista atualizada
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao adicionar usuário: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUsuario(Usuario usuario) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.updateUsuario(usuario);
      await fetchUsuarios(); // Recarrega a lista atualizada
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao atualizar usuário: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUsuario(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.deleteUsuario(id);
      await fetchUsuarios(); // Recarrega a lista atualizada
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Erro ao excluir usuário: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Usuario?> loginUser(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _usuarioLogado = await repository.verifyLogin(username, password);
      _errorMessage = _usuarioLogado == null ? 'Credenciais inválidas' : null;
      return _usuarioLogado;
    } catch (error) {
      _errorMessage = 'Erro ao fazer login: $error';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _usuarioLogado = null;
    notifyListeners();
  }
}