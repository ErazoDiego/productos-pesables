// ============================================================
// Widget: ProductoItem
// Descripción: Tarjeta individual para mostrar un producto
//              en la lista de un sector
// ============================================================

import 'package:flutter/material.dart';
import '../models/producto.dart';

// Widget que muestra un producto en formato de lista
// Incluye: nombre, sector, código y botón de eliminar
class ProductoItem extends StatelessWidget {
  final Producto producto;    // Producto a mostrar
  final VoidCallback onEliminar; // Función al presionar eliminar

  const ProductoItem({
    super.key,
    required this.producto,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        // Avatar con la inicial del sector
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            producto.sector[0], // Primera letra del sector
            style: const TextStyle(color: Colors.white),
          ),
        ),
        // Nombre del producto
        title: Text(
          producto.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // Sector y código pesable
        subtitle: Text('${producto.sector} - Código: ${producto.codigoPesable}'),
        // Botón de eliminar
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onEliminar,
        ),
      ),
    );
  }
}
