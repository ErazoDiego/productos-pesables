// ============================================================
// Modelo: Producto
// Descripción: Representa un producto pesable con sus datos
// ============================================================

import 'dart:convert';

// Modelo de datos para un producto
class Producto {
  // Campos obligatorios del producto
  final String nombre;        // Nombre del producto
  final String sector;        // Sector (Carnicería, Verdulería, etc.)
  final String codigoPesable; // Código numérico para la balanza

  Producto({
    required this.nombre,
    required this.sector,
    required this.codigoPesable,
  });

  // Convierte el producto a formato JSON (para guardar)
  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'sector': sector,
        'codigoPesable': codigoPesable,
      };

  // Crea un producto desde formato JSON (para leer)
  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        nombre: json['nombre'] as String,
        sector: json['sector'] as String,
        codigoPesable: json['codigoPesable'] as String,
      );

  // Convierte a string JSON
  String toJsonString() => jsonEncode(toJson());

  // Crea producto desde string JSON
  factory Producto.fromJsonString(String jsonString) =>
      Producto.fromJson(jsonDecode(jsonString));

  // Compara productos por sector + código pesable (evita duplicados)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Producto &&
          runtimeType == other.runtimeType &&
          sector == other.sector &&
          codigoPesable == other.codigoPesable;

  // Hash para comparar productos
  @override
  int get hashCode => sector.hashCode ^ codigoPesable.hashCode;
}
