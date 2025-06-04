class Movimentacao {
  final int? idmovimentacao;
  final String? entradaData;
  final String? saidaData;
  final int? entrada;
  final int? saida;
  final int? idproduto;
  final int idusuario;

  Movimentacao({
    this.idmovimentacao,
    required this.entradaData,
    required this.saidaData,
    this.entrada,
    this.saida,
    required this.idproduto,
    required this.idusuario,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic> {
      'entrada': entrada,
      'saida': saida,
      'idproduto': idproduto,
      'idusuario': idusuario,
    };

     if (idmovimentacao != null) {
      map['idmovimentacao'] = idmovimentacao;
    }

    if (entradaData != null) {
      map['entrada_data'] = entradaData;
    }

      if (saidaData != null) {
      map['saida_data'] = saidaData;
    }

    return map;
  }

  factory Movimentacao.fromMap(Map<String, dynamic> map) {
    return Movimentacao(
      idmovimentacao: map['idmovimentacao'] as int?,
      entradaData: map['entrada_data'] as String,
      saidaData: map['saida_data'] as String,
      entrada: map['entrada'] != null ? map['entrada'] as int : null,
      saida: map['saida'] != null ? map['saida'] as int : null,
      idproduto: map['idproduto'] as int,
      idusuario: map['idusuario'] as int,
    );
  }
}
