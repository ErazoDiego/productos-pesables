// ============================================================
// Pantalla: PantallaPrincipal
// Descripción: Pantalla inicial que muestra los 5 sectores
//              en formato de tarjetas con el conteo de productos
// ============================================================

import 'package:flutter/material.dart';
import '../services/almacenamiento_service.dart';
import '../services/exportacion_service.dart';
import '../constants/sectores.dart';
import '../widgets/dialogos.dart';
import 'detalle_sector_screen.dart';
import 'agregar_producto_screen.dart';

// Pantalla principal con las tarjetas de sectores
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AlmacenamientoService _almacenamiento = AlmacenamientoService();
  final ExportacionService _exportacion = ExportacionService();
  Map<String, int> _conteoPorSector = {}; // Cantidad de productos por sector
  bool _cargando = true;

  // Se ejecuta al iniciar la pantalla
  @override
  void initState() {
    super.initState();
    _cargarConteoSectores();
  }

  // Carga la cantidad de productos por sector
  Future<void> _cargarConteoSectores() async {
    setState(() => _cargando = true);
    final productos = await _almacenamiento.obtenerProductos();
    
    final conteo = <String, int>{};
    // Cuenta productos por sector
    for (final sector in Sectores.lista) {
      conteo[sector] = productos.where((p) => p.sector == sector).length;
    }
    
    setState(() {
      _conteoPorSector = conteo;
      _cargando = false;
    });
  }

  // Retorna el icono según el sector
  IconData _obtenerIconoSector(String sector) {
    switch (sector) {
      case 'Carnicería':
        return Icons.restaurant;
      case 'Verdulería':
        return Icons.eco;
      case 'Fiambrería':
        return Icons.lunch_dining;
      case 'Panadería':
        return Icons.bakery_dining;
      case 'Pescadería':
        return Icons.set_meal;
      case 'Platos':
        return Icons.dinner_dining;
      default:
        return Icons.category;
    }
  }

  // Retorna el color según el sector
  Color _obtenerColorSector(String sector) {
    switch (sector) {
      case 'Carnicería':
        return Colors.red;
      case 'Verdulería':
        return Colors.green;
      case 'Fiambrería':
        return Colors.orange;
      case 'Panadería':
        return Colors.brown;
      case 'Pescadería':
        return Colors.cyan;
      case 'Platos':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Navega a la pantalla de detalle del sector
  void _navegarADetalleSector(String sector) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleSectorScreen(
          sector: sector,
          color: _obtenerColorSector(sector),
        ),
      ),
    );

    // Si volvió con cambios, actualiza el conteo
    if (resultado == true) {
      _cargarConteoSectores();
    }
  }

  // Exporta productos a JSON y comparte
  Future<void> _exportarProductos() async {
    final rutaArchivo = await _exportacion.exportarProductos();
    
    if (!mounted) return;
    
    if (rutaArchivo == null) {
      mostrarSnackBar(context, 'No hay productos para exportar', esError: true);
      return;
    }

    await _exportacion.compartirArchivo(rutaArchivo);
    mostrarSnackBar(context, 'Archivo listo para compartir');
  }

  // Importa productos desde un archivo JSON
  Future<void> _importarProductos() async {
    final confirmacion = await mostrarDialogoConfirmacion(
      context,
      titulo: 'Importar productos',
      mensaje: 'Se agregarán los productos del archivo. Los productos existentes no se duplicarán.',
    );

    if (!confirmacion) return;

    final resultado = await _exportacion.seleccionarYImportar();
    
    if (!mounted) return;

    if (resultado == null) {
      return; // Usuario canceló
    } else if (resultado == -1) {
      mostrarSnackBar(context, 'Error al importar. Archivo inválido.', esError: true);
    } else if (resultado == 0) {
      mostrarSnackBar(context, 'No se agregaron productos (ya existen)', esError: true);
    } else {
      mostrarSnackBar(context, 'Se importaron $resultado producto(s)');
      _cargarConteoSectores();
    }
  }

  // Construye la interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con título y menú
      appBar: AppBar(
        title: const Text('Códigos de Balanza'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        // Menú de exportar/importar
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (opcion) {
              if (opcion == 'exportar') {
                _exportarProductos();
              } else if (opcion == 'importar') {
                _importarProductos();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'exportar',
                child: Row(
                  children: [
                    Icon(Icons.upload, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Exportar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'importar',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Importar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Contenido: Grid de sectores
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Selecciona un sector',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Grid de 2 columnas con los sectores
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: Sectores.lista.length,
                    itemBuilder: (context, indice) {
                      final sector = Sectores.lista[indice];
                      final conteo = _conteoPorSector[sector] ?? 0;
                      final color = _obtenerColorSector(sector);

                      return _SectorCard(
                        sector: sector,
                        conteo: conteo,
                        icono: _obtenerIconoSector(sector),
                        color: color,
                        onTap: () => _navegarADetalleSector(sector),
                      );
                    },
                  ),
                ),
              ],
            ),
      // Botón flotante para agregar producto
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarProductoScreen(),
            ),
          );
          if (resultado == true) {
            _cargarConteoSectores();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Tarjeta individual de cada sector
class _SectorCard extends StatelessWidget {
  final String sector;
  final int conteo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _SectorCard({
    required this.sector,
    required this.conteo,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono del sector
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              // Nombre del sector
              Text(
                sector,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Cantidad de productos
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$conteo prod.',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
