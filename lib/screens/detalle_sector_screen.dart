// ============================================================
// Pantalla: DetalleSectorScreen
// Descripción: Muestra la lista de productos de un sector
//              específico con buscador y opción de eliminar
// ============================================================

import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/almacenamiento_service.dart';
import '../widgets/producto_item.dart';
import '../widgets/dialogos.dart';
import 'agregar_producto_screen.dart';

// Pantalla que lista los productos de un sector
class DetalleSectorScreen extends StatefulWidget {
  final String sector; // Sector a mostrar
  final Color color;    // Color del sector (para la barra)

  const DetalleSectorScreen({
    super.key,
    required this.sector,
    required this.color,
  });

  @override
  State<DetalleSectorScreen> createState() => _DetalleSectorScreenState();
}

class _DetalleSectorScreenState extends State<DetalleSectorScreen> {
  final AlmacenamientoService _almacenamiento = AlmacenamientoService();
  final TextEditingController _controladorBusqueda = TextEditingController();

  List<Producto> _productos = [];          // Todos los productos del sector
  List<Producto> _productosFiltrados = []; // Productos filtrados por búsqueda
  bool _cargando = true;

  // Se ejecuta al iniciar
  @override
  void initState() {
    super.initState();
    _cargarProductos();
    // Filtra cuando el usuario escribe en el buscador
    _controladorBusqueda.addListener(_filtrarProductos);
  }

  // Limpia el controlador al cerrar
  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  // Carga los productos del sector desde el almacenamiento
  Future<void> _cargarProductos() async {
    setState(() => _cargando = true);
    final todosProductos = await _almacenamiento.obtenerProductos();
    setState(() {
      // Filtra solo los productos de este sector
      _productos = todosProductos.where((p) => p.sector == widget.sector).toList();
      // Ordena alfabéticamente por nombre
      _productos.sort((a, b) => a.nombre.compareTo(b.nombre));
      _productosFiltrados = _productos;
      _cargando = false;
    });
  }

  // Filtra productos por nombre o código pesable
  void _filtrarProductos() {
    final texto = _controladorBusqueda.text.toLowerCase();
    setState(() {
      _productosFiltrados = _productos.where((producto) {
        return producto.nombre.toLowerCase().contains(texto) ||
            producto.codigoPesable.contains(texto);
      }).toList();
    });
  }

  // Elimina un producto individual
  Future<void> _eliminarProducto(Producto producto) async {
    final confirmacion = await mostrarDialogoConfirmacion(
      context,
      titulo: 'Eliminar producto',
      mensaje: '¿Estás seguro de eliminar "${producto.nombre}"?',
    );

    if (confirmacion) {
      final exitoso = await _almacenamiento.eliminarProducto(producto);
      if (exitoso) {
        await _cargarProductos();
        _filtrarProductos();
        if (mounted) {
          mostrarSnackBar(context, 'Producto eliminado');
          Navigator.pop(context, true); // Vuelve a la pantalla anterior
        }
      }
    }
  }

  // Elimina todos los productos del sector
  Future<void> _eliminarTodos() async {
    if (_productos.isEmpty) return;

    final confirmacion = await mostrarDialogoConfirmacion(
      context,
      titulo: 'Eliminar todos',
      mensaje: '¿Eliminar todos los productos de ${widget.sector}?',
    );

    if (confirmacion) {
      // Elimina cada producto
      for (final producto in _productos) {
        await _almacenamiento.eliminarProducto(producto);
      }
      await _cargarProductos();
      if (mounted) {
        mostrarSnackBar(context, 'Todos los productos eliminados');
        Navigator.pop(context, true);
      }
    }
  }

  // Navega a la pantalla de agregar producto (sector preseleccionado)
  void _navegarAAgregar() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarProductoScreen(sectorPreseleccionado: widget.sector),
      ),
    );

    if (resultado == true) {
      await _cargarProductos();
      _filtrarProductos();
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  // Construye la interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra con el nombre del sector
      appBar: AppBar(
        title: Text(widget.sector),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        // Botón para eliminar todos (si hay productos)
        actions: [
          if (_productos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Eliminar todos',
              onPressed: _eliminarTodos,
            ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controladorBusqueda,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o código...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Lista de productos
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _productosFiltrados.isEmpty
                    ? _mostrarEstadoVacio()
                    : ListView.builder(
                        itemCount: _productosFiltrados.length,
                        itemBuilder: (context, indice) {
                          final producto = _productosFiltrados[indice];
                          return ProductoItem(
                            producto: producto,
                            onEliminar: () => _eliminarProducto(producto),
                          );
                        },
                      ),
          ),
        ],
      ),
      // Botón flotante para agregar producto
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.color,
        onPressed: _navegarAAgregar,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Muestra mensaje cuando no hay productos
  Widget _mostrarEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _controladorBusqueda.text.isEmpty
                ? 'No hay productos en ${widget.sector}'
                : 'No se encontraron resultados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (_controladorBusqueda.text.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Toca + para agregar uno',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}
