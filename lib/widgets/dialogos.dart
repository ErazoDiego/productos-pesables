// ============================================================
// Widgets: Diálogos y notificaciones
// Descripción: Funciones reutilizables para mostrar mensajes
// ============================================================

import 'package:flutter/material.dart';

// Muestra un diálogo de confirmación con dos opciones
// Retorna true si el usuario confirma, false si cancela
Future<bool> mostrarDialogoConfirmacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return resultado ?? false;
}

// Muestra una barra de notificación en la parte inferior
// Si esError=true muestra color rojo, sino verde
void mostrarSnackBar(BuildContext context, String mensaje, {bool esError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: esError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}
