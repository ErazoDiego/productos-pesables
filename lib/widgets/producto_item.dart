import 'package:flutter/material.dart';
import '../models/producto.dart';

class ProductoItem extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEliminar;

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
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            producto.sector[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          producto.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${producto.sector} - Código: ${producto.codigoPesable}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onEliminar,
        ),
      ),
    );
  }
}
