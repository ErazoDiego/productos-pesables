// ============================================================
// Servicio: AlmacenamientoService
// Descripción: Maneja el guardado y lectura de productos
//              usando SharedPreferences (almacenamiento local)
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/producto.dart';

// Servicio para persistir productos en el dispositivo
class AlmacenamientoService {
  // Clave para guardar los datos en SharedPreferences
  static const String _claveProductos = 'productos_pesables';

  // Obtiene todos los productos guardados
  Future<List<Producto>> obtenerProductos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productosJson = prefs.getString(_claveProductos);

    // Si no hay datos, retorna lista vacía
    if (productosJson == null || productosJson.isEmpty) {
      return [];
    }

    // Decodifica el JSON y crea objetos Producto
    final List<dynamic> listaDecodificada = jsonDecode(productosJson);
    return listaDecodificada
        .map((json) => Producto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Guarda la lista completa de productos
  Future<bool> guardarProductos(List<Producto> productos) async {
    final prefs = await SharedPreferences.getInstance();
    // Convierte la lista a JSON y guarda
    final String productosJson =
        jsonEncode(productos.map((p) => p.toJson()).toList());
    return prefs.setString(_claveProductos, productosJson);
  }

  // Agrega un producto nuevo (valida duplicados)
  Future<bool> agregarProducto(Producto producto) async {
    final productos = await obtenerProductos();

    // Verifica si ya existe (mismo sector + código)
    if (productos.contains(producto)) {
      return false; // Producto duplicado
    }

    productos.add(producto);
    return guardarProductos(productos);
  }

  // Elimina un producto específico
  Future<bool> eliminarProducto(Producto producto) async {
    final productos = await obtenerProductos();
    // Busca y elimina por sector + código
    productos.removeWhere((p) =>
        p.sector == producto.sector && p.codigoPesable == producto.codigoPesable);
    return guardarProductos(productos);
  }

  // Elimina todos los productos
  Future<bool> eliminarTodosLosProductos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_claveProductos);
  }
}
