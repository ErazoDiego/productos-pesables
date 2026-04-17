// ============================================================
// Servicio: ExportacionService
// Descripción: Maneja exportar e importar productos en formato JSON
//              Permite compartir datos entre dispositivos
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/producto.dart';
import 'almacenamiento_service.dart';

// Servicio para exportar e importar productos
class ExportacionService {
  final AlmacenamientoService _almacenamiento = AlmacenamientoService();

  // Exporta todos los productos a un archivo JSON
  // Retorna la ruta del archivo o null si no hay productos
  Future<String?> exportarProductos() async {
    try {
      final productos = await _almacenamiento.obtenerProductos();
      
      // Verifica si hay productos para exportar
      if (productos.isEmpty) {
        return null;
      }

      // Obtiene directorio temporal y crea nombre con fecha
      final directorio = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final archivo = File('${directorio.path}/codigos_balanza_$timestamp.json');

      // Estructura del archivo JSON con metadatos
      final Map<String, dynamic> datos = {
        'version': '1.0',
        'fechaExportacion': DateTime.now().toIso8601String(),
        'cantidad': productos.length,
        'productos': productos.map((p) => p.toJson()).toList(),
      };

      // Guarda el archivo
      await archivo.writeAsString(jsonEncode(datos));
      return archivo.path;
    } catch (e) {
      return null;
    }
  }

  // Comparte el archivo exportado por WhatsApp, email, etc.
  Future<void> compartirArchivo(String rutaArchivo) async {
    await Share.shareXFiles(
      [XFile(rutaArchivo)],
      text: 'Backup de Códigos de Balanza',
    );
  }

  // Importa productos desde un archivo JSON
  // Retorna la cantidad de productos agregados, -1 si hay error
  Future<int> importarProductos(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      final contenido = await archivo.readAsString();
      final datos = jsonDecode(contenido) as Map<String, dynamic>;

      // Obtiene la lista de productos del JSON
      final listaProductos = datos['productos'] as List<dynamic>;
      int agregados = 0;

      // Procesa cada producto (evita duplicados automáticamente)
      for (final item in listaProductos) {
        final producto = Producto.fromJson(item as Map<String, dynamic>);
        final exitoso = await _almacenamiento.agregarProducto(producto);
        if (exitoso) {
          agregados++;
        }
      }

      return agregados;
    } catch (e) {
      return -1; // Error en la importación
    }
  }

  // Abre el selector de archivos para elegir un JSON
  // Retorna null si cancela, -1 si hay error, o la cantidad de agregados
  Future<int?> seleccionarYImportar() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'], // Solo acepta archivos JSON
      );

      if (resultado != null && resultado.files.single.path != null) {
        return await importarProductos(resultado.files.single.path!);
      }
      return null; // Usuario canceló
    } catch (e) {
      return -1;
    }
  }
}
