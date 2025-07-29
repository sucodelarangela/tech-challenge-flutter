import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_flutter/domain/models/transaction.dart';
import 'package:tech_challenge_flutter/controllers/transaction_controller.dart';
import 'package:tech_challenge_flutter/widgets/adaptative_date_picker.dart';
import 'package:tech_challenge_flutter/screens/transactions/widgets/transaction_form_description_field.dart';
import 'package:tech_challenge_flutter/screens/transactions/widgets/transaction_form_value_field.dart';
import 'package:tech_challenge_flutter/screens/transactions/widgets/transaction_form_category_dropdown.dart';
import 'package:tech_challenge_flutter/screens/transactions/widgets/transaction_form_image_picker_preview.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _valueFocus = FocusNode();
  final _categoryFocus = FocusNode();

  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};

  File? _imageFile;
  String _imageUrl = '';
  bool _isImageFromNetwork = false;

  static const int _maxImageSize = 1 * 1024 * 1024;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is TransactionModel) {
        final transaction = args;
        _formData['id'] = transaction.id;
        _formData['description'] = transaction.description;
        _formData['value'] = transaction.value;
        _formData['category'] = transaction.category;
        _formData['image'] = transaction.image;
        _formData['date'] = transaction.date.toDate();
        _selectedDate = transaction.date.toDate();

        if (transaction.image.startsWith('http')) {
          _imageUrl = transaction.image;
          _isImageFromNetwork = true;
          _imageFile = null;
        } else if (transaction.image.isNotEmpty) {
          _imageFile = File(transaction.image);
          _isImageFromNetwork = false;
          _imageUrl = '';
        }
      }
    }
  }

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
        _isImageFromNetwork = false;
        _imageUrl = '';

        if (fileSize > _maxImageSize) {
          _showErrorDialog(
            'Arquivo muito grande',
            'A imagem selecionada excede o limite de 0.5MB. Por favor, escolha uma imagem menor.',
          );
          return;
        }

        setState(() {
          _imageFile = File(_pickedFile.path);
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

    try {
      if (_imageFile != null) {
        _formData['image'] = _imageFile!.path;
      }
      // Se for uma edição e tiver uma imagem da rede, mantemos a URL
      else if (_isImageFromNetwork && _imageUrl.isNotEmpty) {
        _formData['image'] = _imageUrl;
      }

      await Provider.of<TransactionController>(
        context,
        listen: false,
      ).saveTransaction(_formData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Transação salva com sucesso!')));

      Navigator.of(context).pop(true);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final appBarTitle = args != null ? 'Editar Transação' : 'Nova Transação';

    final isLoading = Provider.of<TransactionController>(context).isLoading;
    isLoading ? context.loaderOverlay.show() : context.loaderOverlay.hide();

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [IconButton(onPressed: _submitForm, icon: Icon(Icons.save))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TransactionFormDescriptionField(
                formData: _formData,
                valueFocus: _valueFocus,
              ),
              TransactionFormValueField(
                formData: _formData,
                valueFocus: _valueFocus,
              ),
              TransactionFormCategoryDropdown(
                formData: _formData,
                categoryFocus: _categoryFocus,
              ),
              AdaptativeDatePicker(
                selectedDate: _selectedDate,
                onDateChanged: (newDate) => _formData['date'] = newDate,
              ),
              TransactionFormImagePickerPreview(
                imageFile: _imageFile,
                imageUrl: _imageUrl,
                isImageFromNetwork: _isImageFromNetwork,
                pickImage: _pickImage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
