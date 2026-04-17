import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/producto.dart';

class AlmacenamientoService {
  static const String _claveProductos = 'productos_pesables';

  Future<List<Producto>> obtenerProductos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productosJson = prefs.getString(_claveProductos);

    if (productosJson == null || productosJson.isEmpty) {
      return [];
    }

    final List<dynamic> listaDecodificada = jsonDecode(productosJson);
    return listaDecodificada
        .map((json) => Producto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<bool> guardarProductos(List<Producto> productos) async {
    final prefs = await SharedPreferences.getInstance();
    final String productosJson =
        jsonEncode(productos.map((p) => p.toJson()).toList());
    return prefs.setString(_claveProductos, productosJson);
  }

  Future<bool> agregarProducto(Producto producto) async {
    final productos = await obtenerProductos();

    if (productos.contains(producto)) {
      return false;
    }

    productos.add(producto);
    return guardarProductos(productos);
  }

  Future<bool> eliminarProducto(Producto producto) async {
    final productos = await obtenerProductos();
    productos.removeWhere((p) =>
        p.sector == producto.sector && p.codigoPesable == producto.codigoPesable);
    return guardarProductos(productos);
  }

  Future<bool> eliminarTodosLosProductos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_claveProductos);
  }
}
