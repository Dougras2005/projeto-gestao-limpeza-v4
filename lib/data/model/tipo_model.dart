class Tipo {
  final int? idtipo;
  final String tipo;

  Tipo({this.idtipo, required this.tipo});

  /// Converte um objeto `Tipo` para um `Map<String, dynamic>` (usado em inserts/updates)
  Map<String, dynamic> toMap() {
    return {
      if (idtipo != null) 'idtipo': idtipo,
      'tipo': tipo,
    };
  }

  /// Cria um objeto `Tipo` a partir de um mapa (usado ao ler do Supabase)
  factory Tipo.fromMap(Map<String, dynamic> map) {
    return Tipo(
      idtipo: map['idtipo'] as int?,
      tipo: map['tipo'] as String,
    );
  }
}
