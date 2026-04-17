import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/producto.dart';
import 'almacenamiento_service.dart';

class ExportacionService {
  final AlmacenamientoService _almacenamiento = AlmacenamientoService();

  Future<String?> exportarProductos() async {
    try {
      final productos = await _almacenamiento.obtenerProductos();
      
      if (productos.isEmpty) {
        return null;
      }

      final directorio = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final archivo = File('${directorio.path}/productos_pesables_$timestamp.json');

      final Map<String, dynamic> datos = {
        'version': '1.0',
        'fechaExportacion': DateTime.now().toIso8601String(),
        'cantidad': productos.length,
        'productos': productos.map((p) => p.toJson()).toList(),
      };

      await archivo.writeAsString(jsonEncode(datos));
      return archivo.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> compartirArchivo(String rutaArchivo) async {
    await Share.shareXFiles(
      [XFile(rutaArchivo)],
      text: 'Backup de Códigos de Balanza',
    );
  }

  Future<int> importarProductos(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      final contenido = await archivo.readAsString();
      final datos = jsonDecode(contenido) as Map<String, dynamic>;

      final listaProductos = datos['productos'] as List<dynamic>;
      int agregados = 0;

      for (final item in listaProductos) {
        final producto = Producto.fromJson(item as Map<String, dynamic>);
        final exitoso = await _almacenamiento.agregarProducto(producto);
        if (exitoso) {
          agregados++;
        }
      }

      return agregados;
    } catch (e) {
      return -1;
    }
  }

  Future<int?> seleccionarYImportar() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (resultado != null && resultado.files.single.path != null) {
        return await importarProductos(resultado.files.single.path!);
      }
      return null;
    } catch (e) {
      return -1;
    }
  }
}
