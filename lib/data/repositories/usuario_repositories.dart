import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:app_estoque_limpeza/core/database_helper.dart';
import 'package:app_estoque_limpeza/data/model/usuario_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class UsuarioRepository with ChangeNotifier {
  List<Usuario> _usuarios = [];

  List<Usuario> get usuarios => _usuarios;

  Future<void> loadUsuarios() async {
    final db = await DatabaseHelper.initDb();
    final List<Map<String, Object?>> usuarioMaps = await db.query('usuario');
    _usuarios = usuarioMaps.map((map) {
      return Usuario(
        idusuario: map['idusuario'] as int?,
        matricula: map['matricula'] as String,
        nome: map['nome'] as String,
        telefone: map['telefone'] as String,
        email: map['email'] as String,
        idperfil: map['idperfil'] as int,
        senha: map['senha'] as String,
      );
    }).toList();
    notifyListeners();
  }
  
  Future<List<Usuario>> getUsuarios() async {
    final db = await DatabaseHelper.initDb();
    final List<Map<String, Object?>> usuarioMaps = await db.query('usuario');
    return usuarioMaps.map((map) {
      return Usuario(
        idusuario: map['idusuario'] as int?,
        matricula: map['matricula'] as String,
        nome: map['nome'] as String,
        telefone: map['telefone'] as String,
        email: map['email'] as String,
        idperfil: map['idperfil'] as int,
        senha: map['senha'] as String,
      );
    }).toList();
  }

  Future<void> insertUsuario(Usuario usuario) async {
    final db = await DatabaseHelper.initDb();
    await db.insert(
      'usuario',
      usuario.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await loadUsuarios(); // Recarrega a lista após inserção
  }

  Future<void> updateUsuario(Usuario usuario) async {
    final db = await DatabaseHelper.initDb();
    await db.update(
      'usuario',
      usuario.toMap(),
      where: 'idusuario = ?',
      whereArgs: [usuario.idusuario],
    );
    await loadUsuarios(); // Recarrega a lista após atualização
  }

  Future<void> deleteUsuario(int id) async {
    final db = await DatabaseHelper.initDb();
    await db.delete(
      'usuario',
      where: 'idusuario = ?',
      whereArgs: [id],
    );
    await loadUsuarios(); // Recarrega a lista após exclusão
  }

  Future<Usuario?> verifyLogin(String matricula, String password) async {
    final db = await DatabaseHelper.initDb();
    final encryptedPassword = sha256.convert(utf8.encode(password)).toString();
    final result = await db.query(
      'usuario',
      where: 'matricula = ? AND senha = ?',
      whereArgs: [matricula, encryptedPassword],
    );

    if (result.isNotEmpty) {
      return Usuario(
        idusuario: result.first['idusuario'] as int?,
        matricula: result.first['matricula'] as String,
        nome: result.first['nome'] as String,
        telefone: result.first['telefone'] as String,
        email: result.first['email'] as String,
        idperfil: result.first['idperfil'] as int,
        senha: result.first['senha'] as String,
      );
    }
    return null;
  }

  // Método adicional para buscar usuário por ID
  Usuario? getUsuarioById(int id) {
    try {
      return _usuarios.firstWhere((usuario) => usuario.idusuario == id);
    } catch (e) {
      return null;
    }
  }
}