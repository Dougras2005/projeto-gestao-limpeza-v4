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
  final String? tipoProduto;    // campo complementar (join)

  ProdutoModel({
    this.idproduto,
    required this.codigo,
    required this.nome,
    required this.quantidade,
    this.validade,
    required this.local,
    required this.idtipo,
    required this.idfornecedor,
    required this.entrada,
    this.nomeFornecedor,
    this.tipoProduto,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic> {
      'Codigo': codigo,
      'Nome': nome,
      'Quantidade': quantidade,
      'Validade': validade,
      'Local': local,
      'idtipo': idtipo,
      'idfornecedor': idfornecedor,
      'entrada': entrada,
    };

    if (idproduto != null) {
      map['idproduto'] = idproduto;
    }

    return map;
  }

  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      idproduto: map['idproduto'] as int?,
      codigo: map['Codigo'] ?? '',
      nome: map['Nome'] ?? '',
      quantidade: map['Quantidade'] is int
          ? map['Quantidade']
          : int.tryParse(map['Quantidade'].toString()) ?? 0,
      validade: map['Validade'],
      local: map['Local'] ?? '',
      idtipo: map['idtipo'] is int
          ? map['idtipo']
          : int.tryParse(map['idtipo'].toString()) ?? 0,
      idfornecedor: map['idfornecedor'] is int
          ? map['idfornecedor']
          : int.tryParse(map['idfornecedor'].toString()) ?? 0,
      entrada: map['entrada'] ?? '',
      nomeFornecedor: map['fornecedor']?['nome'] ?? map['fornecedor'],
      tipoProduto: map['tipo']?['tipo'] ?? map['tipo'],
    );
  }
}
