import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/producto.dart';
import '../services/almacenamiento_service.dart';
import '../constants/sectores.dart';
import '../widgets/dialogos.dart';

class AgregarProductoScreen extends StatefulWidget {
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
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _sectorSeleccionado = widget.sectorPreseleccionado;
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorCodigo.dispose();
    super.dispose();
  }

  String? _validarNombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El nombre no puede estar vacío';
    }
    return null;
  }

  String? _validarSector(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Selecciona un sector';
    }
    return null;
  }

  String? _validarCodigo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El código no puede estar vacío';
    }
    if (!RegExp(r'^\d+$').hasMatch(valor)) {
      return 'Solo números permitidos';
    }
    return null;
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _guardando = true);

    final producto = Producto(
      nombre: _controladorNombre.text.trim(),
      sector: _sectorSeleccionado!,
      codigoPesable: _controladorCodigo.text.trim(),
    );

    final exitoso = await _almacenamiento.agregarProducto(producto);

    setState(() => _guardando = false);

    if (!mounted) return;

    if (exitoso) {
      mostrarSnackBar(context, 'Producto guardado correctamente');
      Navigator.pop(context, true);
    } else {
      mostrarSnackBar(
        context,
        'Ya existe un producto con este sector y código',
        esError: true,
      );
    }
  }

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
              TextFormField(
                controller: _controladorNombre,
                decoration: InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.label_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: _validarNombre,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _sectorSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Sector',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
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
              TextFormField(
                controller: _controladorCodigo,
                decoration: InputDecoration(
                  labelText: 'Código pesable',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: _validarCodigo,
              ),
              const SizedBox(height: 32),
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
