import 'package:flutter/material.dart';
import 'screens/pantalla_principal.dart';

void main() {
  runApp(const ProductosPesablesApp());
}

class ProductosPesablesApp extends StatelessWidget {
  const ProductosPesablesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Códigos de Balanza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
      home: const PantallaPrincipal(),
    );
  }
}
