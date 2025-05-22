import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:tech_challenge_flutter/core/models/transaction.dart';
import 'package:tech_challenge_flutter/core/models/user_balance.dart';
import 'package:uuid/uuid.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  // Tam. máximo do arquivo
  static const int _maxImageSize = 500 * 1024; // 0.5MB em bytes

  // Salvar uma transação
  Future<void> saveTransaction(Map<String, Object> data) async {
    try {
      final user = _auth.currentUser;

      if (user == null) throw Exception('Usuário não autenticado');

      final String? documentId = data['id'] as String?;
      bool isEdit = documentId != null && documentId.isNotEmpty;

      double? oldValue;
      bool? oldIsIncome;

      if (isEdit) {
        final docSnapshot =
            await _firestore.collection('transactions').doc(documentId).get();
        if (docSnapshot.exists) {
          final oldData = docSnapshot.data()!;
          oldValue = (oldData['value'] as num).toDouble();
          oldIsIncome = oldData['isIncome'] as bool;
        }
      }

      // Processamento da imagem
      final String? imagePath = data['image'] as String?;
      if (imagePath != null && imagePath.isNotEmpty) {
        final String imagePath = data['image'] as String;

        if (imagePath.startsWith('http')) {
          data['image'] = imagePath;
        } else {
          final File imageFile = File(imagePath);

          // Verificar o tamanho do arquivo
          final int fileSize = await imageFile.length();
          if (fileSize > _maxImageSize) {
            throw Exception('A imagem deve ter no máximo 0.5MB');
          }

          // Fazer upload da imagem para o Firebase Storage
          final String imageUrl = await _uploadImage(imageFile);

          // Substituir o caminho da imagem local pela URL do Storage
          data['image'] = imageUrl;
        }
      } else {
        // Se não tiver imagem, definir como string vazia
        data['image'] = '';
      }

      // Gerenciamento da data
      if (data['date'] is DateTime) {
        data['date'] = Timestamp.fromDate(data['date'] as DateTime);
      }

      final isIncome = data['category'] == 'Entrada';
      final value = data['value'] as double;

      final transactionData = {
        'userId': user.uid,
        'description': data['description'],
        'value': data['value'],
        'category': data['category'],
        'date': data['date'],
        'image': data['image'],
        'isIncome': isIncome,
        'createdAt': Timestamp.now(),
      };

      if (isEdit) {
        // Editar o documento no Firestore
        await _firestore
            .collection('transactions')
            .doc(documentId)
            .update(transactionData);

        if (oldValue != null && oldIsIncome != null) {
          await _updateBalance(
            isIncome: isIncome,
            value: value,
            isEdit: true,
            oldValue: oldValue,
            oldIsIncome: oldIsIncome,
          );
        }
      } else {
        // Adicionar o documento no Firestore
        await _firestore.collection('transactions').add(transactionData);
        await _updateBalance(isIncome: isIncome, value: value);
      }
    } catch (e) {
      print('Erro ao salvar a transação: $e');
      throw e;
    }
  }

  // Atualizar o saldo do usuário
  Future<void> _updateBalance({
    required bool isIncome,
    required double value,
    bool isEdit = false,
    double? oldValue,
    bool? oldIsIncome,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final balanceRef = _firestore.collection('users').doc(user.uid);

    // Se é edição
    if (isEdit && oldValue != null && oldIsIncome != null) {
      if (oldIsIncome == isIncome) {
        // Continua sendo entrada ou saída
        if (isIncome) {
          await balanceRef.update({
            'balance': FieldValue.increment(value - oldValue),
            'totalIncome': FieldValue.increment(value - oldValue),
            'lastUpdated': DateTime.now(),
          });
        } else {
          await balanceRef.update({
            'balance': FieldValue.increment(oldValue - value),
            'totalExpenses': FieldValue.increment(value - oldValue),
            'lastUpdated': DateTime.now(),
          });
        }
      } else {
        // Mudou de entrada para saída ou vice-versa
        if (isIncome) {
          // Era saída, virou entrada
          await balanceRef.update({
            'balance': FieldValue.increment(oldValue + value),
            'totalExpenses': FieldValue.increment(-oldValue),
            'totalIncome': FieldValue.increment(value),
            'lastUpdated': DateTime.now(),
          });
        } else {
          // Era entrada, virou saída
          await balanceRef.update({
            'balance': FieldValue.increment(-(oldValue + value)),
            'totalIncome': FieldValue.increment(-oldValue),
            'totalExpenses': FieldValue.increment(value),
            'lastUpdated': DateTime.now(),
          });
        }
      }
    } else {
      // Se é criação
      if (isIncome) {
        await balanceRef.update({
          'balance': FieldValue.increment(value),
          'totalIncome': FieldValue.increment(value),
          'lastUpdated': DateTime.now(),
        });
      } else {
        await balanceRef.update({
          'balance': FieldValue.increment(-value),
          'totalExpenses': FieldValue.increment(value),
          'lastUpdated': DateTime.now(),
        });
      }
    }
  }

  // Carregar o saldo do usuário
  Future<UserBalance?> getBalance() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        return UserBalance.fromMap(docSnapshot.data()!);
      } else {
        return UserBalance(
          balance: 0.0,
          totalIncome: 0.0,
          totalExpenses: 0.0,
          email: user.email ?? '',
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      print('Erro ao carregar saldo: $e');
      return UserBalance(
        balance: 0.0,
        totalIncome: 0.0,
        totalExpenses: 0.0,
        email: '',
        lastUpdated: DateTime.now(),
      );
    }
  }

  // Upload de imagem para o Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    try {
      // Criar um nome único para o arquivo
      final String fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';

      // Referência para o arquivo no Firebase Storage
      final storageRef = _storage.ref().child('transaction_images/$fileName');

      // Iniciar o upload
      final uploadTask = storageRef.putFile(imageFile);

      // Aguardar o upload terminar e retornar a URL do arquivo
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      throw e;
    }
  }

  // Buscar todas as transações do usuário
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final querySnapshot =
          await _firestore
              .collection('transactions')
              .where('userId', isEqualTo: user.uid)
              .orderBy('date', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar transações: $e');
      throw e;
    }
  }

  // Excluir uma transação
  Future<void> deleteTransaction(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Buscar o documento para verificar se é do usuário atual e obter dados para atualizar o saldo
      final docSnapshot =
          await _firestore.collection('transactions').doc(id).get();

      if (!docSnapshot.exists) {
        throw Exception('Transação não encontrada');
      }

      final data = docSnapshot.data()!;

      // Verificar se a transação pertence ao usuário atual
      if (data['userId'] != user.uid) {
        throw Exception('Você não tem permissão para excluir esta transação');
      }

      // Determinar se era uma entrada ou saída
      final isIncome = data['category'] == 'Entrada';
      final value = (data['value'] as num).toDouble();

      // Se tiver uma imagem, excluir do Storage
      if (data['image'] != null && data['image'].toString().isNotEmpty) {
        try {
          // Extrair o nome do arquivo da URL
          final imageRef = _storage.refFromURL(data['image'].toString());
          await imageRef.delete();
        } catch (e) {
          print('Erro ao excluir imagem: $e');
          // Continuar o processo mesmo se falhar ao excluir a imagem
        }
      }

      // Excluir o documento do Firestore
      await _firestore.collection('transactions').doc(id).delete();

      // Atualizar o saldo (valor negativo para inverter a operação original)
      await _updateBalance(isIncome: !isIncome, value: value);
    } catch (e) {
      print('Erro ao excluir transação: $e');
      throw e;
    }
  }

  // Verificar se o usuário está autenticado
  bool get isUserAuthenticated => _auth.currentUser != null;
}
