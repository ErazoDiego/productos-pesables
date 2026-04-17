import 'package:flutter/material.dart';
import '../services/almacenamiento_service.dart';
import '../services/exportacion_service.dart';
import '../constants/sectores.dart';
import '../widgets/dialogos.dart';
import 'detalle_sector_screen.dart';
import 'agregar_producto_screen.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AlmacenamientoService _almacenamiento = AlmacenamientoService();
  final ExportacionService _exportacion = ExportacionService();
  Map<String, int> _conteoPorSector = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarConteoSectores();
  }

  Future<void> _cargarConteoSectores() async {
    setState(() => _cargando = true);
    final productos = await _almacenamiento.obtenerProductos();
    
    final conteo = <String, int>{};
    for (final sector in Sectores.lista) {
      conteo[sector] = productos.where((p) => p.sector == sector).length;
    }
    
    setState(() {
      _conteoPorSector = conteo;
      _cargando = false;
    });
  }

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
      case 'Platos':
        return Icons.dinner_dining;
      default:
        return Icons.category;
    }
  }

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
      case 'Platos':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

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

    if (resultado == true) {
      _cargarConteoSectores();
    }
  }

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
      return;
    } else if (resultado == -1) {
      mostrarSnackBar(context, 'Error al importar. Archivo inválido.', esError: true);
    } else if (resultado == 0) {
      mostrarSnackBar(context, 'No se agregaron productos (ya existen)', esError: true);
    } else {
      mostrarSnackBar(context, 'Se importaron $resultado producto(s)');
      _cargarConteoSectores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos Pesables'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
