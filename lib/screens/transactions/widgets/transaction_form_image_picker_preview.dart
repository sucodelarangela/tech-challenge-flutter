import 'dart:io';

import 'package:flutter/material.dart';

class TransactionFormImagePickerPreview extends StatelessWidget {
  final File? imageFile;
  final String imageUrl;
  final bool isImageFromNetwork;
  final Future<void> Function() pickImage;

  const TransactionFormImagePickerPreview({
    required this.imageFile,
    required this.imageUrl,
    required this.isImageFromNetwork,
    required this.pickImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pickImage,
      child: Container(
        height: 300,
        width: 300,
        margin: EdgeInsets.only(top: 10, left: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child:
            imageFile != null
                // Exibir imagem local
                ? Image.file(imageFile!, fit: BoxFit.cover)
                : isImageFromNetwork && imageUrl.isNotEmpty
                ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Erro ao carregar imagem',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
                : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40),
                      SizedBox(height: 8),
                      Text('Adicionar imagem'),
                    ],
                  ),
                ),
      ),
    );
  }
}
