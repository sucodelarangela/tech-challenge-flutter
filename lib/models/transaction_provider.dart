import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:tech_challenge_flutter/models/transaction.dart';
import 'package:tech_challenge_flutter/models/user_balance.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  // Tam. máximo do arquivo
  static const int _maxImageSize = 500 * 1024; // 0.5MB em bytes

  UserBalance? _userBalance;

  UserBalance? get userBalance => _userBalance;

  Future<void> saveTransaction(Map<String, Object> data) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Verificamos se temos uma imagem para upload
      if (data['image'] != null) {
        final String imagePath = data['image'] as String;
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
      } else {
        // Se não tiver imagem, definir como string vazia
        data['image'] = '';
      }

      // Converter o DateTime para Timestamp do Firestore
      if (data['date'] is DateTime) {
        data['date'] = Timestamp.fromDate(data['date'] as DateTime);
      }

      final isIncome = data['category'] == 'Entrada';
      final value = data['value'] as double;

      // Adicionar o documento no Firestore
      await _firestore.collection('transactions').add({
        'userId': user.uid,
        'description': data['description'],
        'value': data['value'],
        'category': data['category'],
        'date': data['date'],
        'image': data['image'],
        'isIncome': isIncome,
        'createdAt': Timestamp.now(),
      });

      await _updateBalance(isIncome, value);

      notifyListeners();
    } catch (e) {
      print('Erro ao salvar a transação: $e');
      throw e;
    }
  }

  Future<void> _updateBalance(bool isIncome, double value) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Referência para o documento de saldo do usuário
      final balanceRef = _firestore.collection('users').doc(user.uid);

      // Verificar se o documento já existe
      final docSnapshot = await balanceRef.get();

      if (docSnapshot.exists) {
        // Atualizar o saldo existente
        if (isIncome) {
          await balanceRef.update({
            'balance': FieldValue.increment(value),
            'totalIncome': FieldValue.increment(value),
          });
        } else {
          await balanceRef.update({
            'balance': FieldValue.increment(-value),
            'totalExpenses': FieldValue.increment(value),
          });
        }
      } else {
        // Criar um novo documento de saldo
        await balanceRef.set({
          'balance': isIncome ? value : -value,
          'totalIncome': isIncome ? value : 0,
          'totalExpenses': isIncome ? 0 : value,
          'email': user.email,
          'lastUpdated': Timestamp.now(),
        });
      }

      // Carregar os dados atualizados
      await loadBalance();
    } catch (e) {
      print('Erro ao atualizar saldo: $e');
      throw e;
    }
  }

  Future<void> loadBalance() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _userBalance = null;
        notifyListeners();
        return;
      }

      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        _userBalance = UserBalance.fromMap(docSnapshot.data()!);
      } else {
        _userBalance = UserBalance(
          balance: 0.0,
          totalIncome: 0.0,
          totalExpenses: 0.0,
          email: user.email ?? '',
          lastUpdated: DateTime.now(),
        );
      }

      notifyListeners();
    } catch (e) {
      print('Erro ao carregar saldo: $e');
      _userBalance = UserBalance(
        balance: 0.0,
        totalIncome: 0.0,
        totalExpenses: 0.0,
        email: '',
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }

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
      await _updateBalance(!isIncome, value);

      notifyListeners();
    } catch (e) {
      print('Erro ao excluir transação: $e');
      throw e;
    }
  }
}
