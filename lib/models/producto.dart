import 'dart:convert';

class Producto {
  final String nombre;
  final String sector;
  final String codigoPesable;

  Producto({
    required this.nombre,
    required this.sector,
    required this.codigoPesable,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'sector': sector,
        'codigoPesable': codigoPesable,
      };

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        nombre: json['nombre'] as String,
        sector: json['sector'] as String,
        codigoPesable: json['codigoPesable'] as String,
      );

  String toJsonString() => jsonEncode(toJson());

  factory Producto.fromJsonString(String jsonString) =>
      Producto.fromJson(jsonDecode(jsonString));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Producto &&
          runtimeType == other.runtimeType &&
          sector == other.sector &&
          codigoPesable == other.codigoPesable;

  @override
  int get hashCode => sector.hashCode ^ codigoPesable.hashCode;
}
