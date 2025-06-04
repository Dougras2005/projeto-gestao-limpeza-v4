import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_estoque_limpeza/data/model/usuario_model.dart';

class UsuarioRepository with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<Usuario> _usuarios = [];

  /// Lista somente-leitura para a UI
  List<Usuario> get usuarios => List.unmodifiable(_usuarios);

  /* ---------------------------------------------------- *
   * CARREGA / LISTA                                      *
   * ---------------------------------------------------- */
  Future<void> loadUsuarios() async {
    try {
      final List<dynamic> data = await _client.from('usuario').select();
      _usuarios =
          data.map((e) => Usuario.fromMap(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao carregar usuários: ${e.message}');
    }
  }

  Future<List<Usuario>> getUsuarios() async {
    try {
      final List<dynamic> data = await _client.from('usuario').select();
      return data
          .map((e) => Usuario.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao buscar usuários: ${e.message}');
    }
  }

  /* ---------------------------------------------------- *
   * INSERE                                               *
   * ---------------------------------------------------- */
  Future<void> insertUsuario(Usuario usuario) async {
    try {
      final dados = usuario.toMap()
        ..['senha'] =
            sha256.convert(utf8.encode(usuario.senha)).toString(); // hash
      await _client.from('usuario').insert(dados);
      await loadUsuarios();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao inserir usuário: ${e.message}');
    }
  }

  /* ---------------------------------------------------- *
   * ATUALIZA                                              *
   * ---------------------------------------------------- */
  Future<void> updateUsuario(Usuario usuario) async {
    if (usuario.idusuario == null) {
      throw Exception('ID do usuário é obrigatório para atualizar.');
    }

    try {
      final dados = usuario.toMap()
        ..['senha'] =
            sha256.convert(utf8.encode(usuario.senha)).toString(); // hash

      await _client
          .from('usuario')
          .update(dados)
          .eq('idusuario', usuario.idusuario!);
      await loadUsuarios();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao atualizar usuário: ${e.message}');
    }
  }

  /* ---------------------------------------------------- *
   * EXCLUI                                                *
   * ---------------------------------------------------- */
  Future<void> deleteUsuario(int id) async {
    try {
      await _client.from('usuario').delete().eq('idusuario', id);
      await loadUsuarios();
    } on PostgrestException catch (e) {
      throw Exception('Erro ao excluir usuário: ${e.message}');
    }
  }

  /* ---------------------------------------------------- *
   * LOGIN                                                 *
   * ---------------------------------------------------- */
  Future<Usuario?> verifyLogin(String matricula, String password) async {
    final hash = sha256.convert(utf8.encode(password)).toString();

    try {
      final Map<String, dynamic>? row = await _client
          .from('usuario')
          .select()
          .eq('matricula', matricula)
          .eq('senha', hash)
          .maybeSingle();

      return row != null ? Usuario.fromMap(row) : null;
    } on PostgrestException catch (e) {
      throw Exception('Erro ao verificar login: ${e.message}');
    }
  }

  /* ---------------------------------------------------- *
   * BUSCA LOCAL (já carregados)                           *
   * ---------------------------------------------------- */
  Usuario? getUsuarioById(int id) =>
      _usuarios.firstWhere((u) => u.idusuario == id);
}
