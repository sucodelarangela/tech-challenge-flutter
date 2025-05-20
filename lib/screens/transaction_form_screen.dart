import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/core/providers/transaction_provider.dart';
import 'package:tech_challenge_flutter/widgets/adaptative_date_picker.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _valueFocus = FocusNode();
  final _categoryFocus = FocusNode();

  final ImagePicker _picker = ImagePicker();
  final DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};
  File _image = File('');

  bool _isLoading = false;
  static const int _maxImageSize = 1 * 1024 * 1024;

  // CLEANUP
  @override
  void dispose() {
    super.dispose();
    _valueFocus.dispose();
    _categoryFocus.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final _pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
      );
      if (_pickedFile != null) {
        final File selectedImage = File(_pickedFile.path);
        final int fileSize = await selectedImage.length();

        if (fileSize > _maxImageSize) {
          _showErrorDialog(
            'Arquivo muito grande',
            'A imagem selecionada excede o limite de 0.5MB. Por favor, escolha uma imagem menor.',
          );
          return;
        }

        setState(() {
          _image = File(_pickedFile.path);
        });
        _formData['image'] = _pickedFile.path;
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    _formKey.currentState?.save();

    if (!_formData.containsKey('date')) {
      _formData['date'] = _selectedDate;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).saveTransaction(_formData);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Transação salva com sucesso!')));
    } catch (e) {
      await showDialog<void>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text('Erro'),
              content: Text(
                'Ocorreu um erro ao salvar a transação.\n${e.toString()}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Ok'),
                ),
              ],
            ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Transação'),
        actions: [IconButton(onPressed: _submitForm, icon: Icon(Icons.save))],
      ),

      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _formData['description']?.toString(),
                        decoration: InputDecoration(labelText: 'Descrição'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_valueFocus);
                        },
                        onSaved:
                            (description) =>
                                _formData['description'] = description ?? '',
                        validator: (_description) {
                          final description = _description ?? '';
                          if (description.trim().isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (description.trim().length < 3) {
                            return 'Descrição precisa de, no mínimo, 3 caracteres';
                          }
                          return null;
                        },
                      ),

                      TextFormField(
                        initialValue: _formData['value']?.toString(),
                        decoration: InputDecoration(labelText: 'Valor'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        focusNode: _valueFocus,
                        onSaved:
                            (value) =>
                                _formData['value'] = double.parse(value ?? '0'),
                        validator: (_value) {
                          final valueString = _value ?? '';
                          final value = double.tryParse(valueString) ?? -1;
                          if (value <= 0) return 'Informe um preço válido';
                          return null;
                        },
                      ),

                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: 'Selecione uma categoria',
                        ),
                        focusNode: _categoryFocus,
                        items:
                            ['Entrada', 'Saída']
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt,
                                    child: Text(opt),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (category) =>
                                _formData['category'] = category ?? '',
                        validator: (category) {
                          if (category == null) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),

                      AdaptativeDatePicker(
                        selectedDate: _selectedDate,
                        onDateChanged: (newDate) => _formData['date'] = newDate,
                      ),

                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          height: 300,
                          width: 300,
                          margin: EdgeInsets.only(top: 10, left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child:
                              _image.path.isEmpty
                                  ? Center(child: Text('Adicionar imagem'))
                                  : Image.file(_image, fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
