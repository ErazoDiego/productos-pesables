// ============================================================
// Pantalla: AgregarProductoScreen
// Descripción: Formulario para agregar un nuevo producto
//              con validación de campos obligatorios
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';
import '../services/almacenamiento_service.dart';
import '../constants/sectores.dart';
import '../widgets/dialogos.dart';

// Pantalla de formulario para agregar productos
class AgregarProductoScreen extends StatefulWidget {
  // Si viene de un sector, ya lo preselecciona
  final String? sectorPreseleccionado;

  const AgregarProductoScreen({super.key, this.sectorPreseleccionado});

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorCodigo = TextEditingController();

  final AlmacenamientoService _almacenamiento = AlmacenamientoService();
  String? _sectorSeleccionado;
  bool _guardando = false; // Para mostrar indicador de carga

  // Inicializa con el sector preseleccionado si viene de un sector
  @override
  void initState() {
    super.initState();
    _sectorSeleccionado = widget.sectorPreseleccionado;
  }

  // Limpia los controladores al cerrar
  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorCodigo.dispose();
    super.dispose();
  }

  // Valida que el nombre no esté vacío
  String? _validarNombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El nombre no puede estar vacío';
    }
    return null;
  }

  // Valida que se haya seleccionado un sector
  String? _validarSector(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Selecciona un sector';
    }
    return null;
  }

  // Valida el código pesable: no vacío y solo números
  String? _validarCodigo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El código no puede estar vacío';
    }
    // Verifica que solo contenga dígitos
    if (!RegExp(r'^\d+$').hasMatch(valor)) {
      return 'Solo números permitidos';
    }
    return null;
  }

  // Guarda el producto en el almacenamiento
  Future<void> _guardarProducto() async {
    // Valida el formulario antes de guardar
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _guardando = true);

    // Crea el objeto producto
    final producto = Producto(
      nombre: _controladorNombre.text.trim(),
      sector: _sectorSeleccionado!,
      codigoPesable: _controladorCodigo.text.trim(),
    );

    // Intenta guardar (evita duplicados automáticamente)
    final exitoso = await _almacenamiento.agregarProducto(producto);

    setState(() => _guardando = false);

    if (!mounted) return;

    if (exitoso) {
      mostrarSnackBar(context, 'Producto guardado correctamente');
      Navigator.pop(context, true); // Vuelve indicando éxito
    } else {
      mostrarSnackBar(
        context,
        'Ya existe un producto con este sector y código',
        esError: true,
      );
    }
  }

  // Construye el formulario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo: Nombre del producto
              TextFormField(
                controller: _controladorNombre,
                decoration: InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                // Capitaliza cada palabra
                textCapitalization: TextCapitalization.words,
                validator: _validarNombre,
              ),
              const SizedBox(height: 20),
              
              // Campo: Sector (dropdown)
              DropdownButtonFormField<String>(
                value: _sectorSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Sector',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                // Lista de sectores fijos
                items: Sectores.lista.map((sector) {
                  return DropdownMenuItem(
                    value: sector,
                    child: Text(sector),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() => _sectorSeleccionado = valor);
                },
                validator: _validarSector,
              ),
              const SizedBox(height: 20),
              
              // Campo: Código pesable (solo números)
              TextFormField(
                controller: _controladorCodigo,
                decoration: InputDecoration(
                  labelText: 'Código pesable',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.numbers),
                ),
                // Teclado numérico
                keyboardType: TextInputType.number,
                // Solo permite dígitos
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: _validarCodigo,
              ),
              const SizedBox(height: 32),
              
              // Botón: Guardar
              ElevatedButton(
                onPressed: _guardando ? null : _guardarProducto,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 12),
              
              // Botón: Cancelar
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
