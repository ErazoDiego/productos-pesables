// ============================================================
// App: Códigos de Balanza
// Descripción: App para gestionar códigos de productos pesables
// Autor: DAE
// Versión: 1.0.0
// ============================================================

import 'package:flutter/material.dart';
import 'screens/pantalla_principal.dart';

// Punto de entrada principal de la aplicación
void main() {
  runApp(const ProductosPesablesApp());
}

// Widget principal de la aplicación
// Configura el tema general y la pantalla inicial
class ProductosPesablesApp extends StatelessWidget {
  const ProductosPesablesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Códigos de Balanza',
      debugShowCheckedModeBanner: false,
      
      // Tema de la aplicación con Material Design 3
      theme: ThemeData(
        // Color principal azul
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        
        // Estilo del AppBar
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        
        // Estilo de las tarjetas
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Estilo de los campos de texto
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      
      // Pantalla inicial: PantallaPrincipal
      home: const PantallaPrincipal(),
    );
  }
}
