class ProdutoModel {
  final int? idproduto;
  final String codigo;
  final String nome;
  final int quantidade;
  final String? validade;
  final String local;
  final int idtipo;
  final int idfornecedor;
  final String entrada;
  final String? nomeFornecedor; // campo complementar (join)
  final String? tipoProduto;

  ProdutoModel({
    this.idproduto,
    required this.codigo,
    required this.nome,
    required this.quantidade,
    required this.validade,
    required this.local,
    required this.idtipo,
    required this.idfornecedor,
    required this.entrada,
    this.nomeFornecedor,
    this.tipoProduto,
  });

  // ✅ Método para criar um Material a partir de um Map (do Supabase)
  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      idproduto: map['idproduto'] as int?,
      codigo: map['codigo'] as String,
      nome: map['nome'] as String,
      quantidade: (map['quantidade'] as num).toInt(),
      validade: map['validade'] as String?,
      local: map['local'] as String,
      idtipo: map['idtipo'] as int,
      idfornecedor: map['idfornecedor'] as int,
      entrada: map['entrada'] as String,
      nomeFornecedor: map['fornecedor']?['nome'] ?? map['fornecedor'],
      tipoProduto: map['tipo']?['tipo'] ?? map['tipo'],
    );
  }

  // ✅ Método para converter um Material para Map (para enviar ao Supabase)
  Map<String, dynamic> toMap() {
     final Map<String, dynamic> map = <String, dynamic> {
      'codigo': codigo,
      'nome': nome,
      'quantidade': quantidade,
      'local': local,
      'idtipo': idtipo,
      'idfornecedor': idfornecedor,
      'entrada': entrada,
    };

     if (idproduto != null) {
      map['idproduto'] = idproduto;
    }

    if (nomeFornecedor != null) {
      map['nomeFornecedor'] = nomeFornecedor;
    }

    if (tipoProduto != null) {
      map['tipoProduto'] = tipoProduto;
    }

    if (validade != null) {
      map['validade'] = validade;
    }

    return map;
  }

   ProdutoModel copyWith({
    int? idproduto,
    String? codigo,
    String? nome,
    int? quantidade,
    String? validade,
    String? local,
    int? idtipo,
    int? idfornecedor,
    String? entrada,
    String? nomeFornecedor,
    String? tipoProduto,
  }) {
    return ProdutoModel(
      idproduto: idproduto ?? this.idproduto,
      codigo: codigo ?? this.codigo,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      validade: validade ?? this.validade,
      local: local ?? this.local,
      idtipo: idtipo ?? this.idtipo,
      idfornecedor: idfornecedor ?? this.idfornecedor,
      entrada: entrada ?? this.entrada,
      nomeFornecedor: nomeFornecedor ?? this.nomeFornecedor,
      tipoProduto: tipoProduto ?? this.tipoProduto,
    );
  }
}
