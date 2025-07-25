// data/transaction_dao.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:tech_challenge_flutter/domain/models/transaction.dart';
import 'package:tech_challenge_flutter/domain/models/user_balance.dart';
import 'package:uuid/uuid.dart';

class TransactionDao {
  static const int _maxImageSize = 500 * 1024; // 0.5MB em bytes
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  // Cache em memória (mantido do código original)
  final List<TransactionModel> _transactionsCache = [];
  bool _transactionsLoaded = false;
  UserBalance? _balanceCache;
  bool _balanceLoaded = false;

  bool get isUserAuthenticated => _auth.currentUser != null;

  // ✅ Buscar transações (baseado no seu código original)
  Future<List<TransactionModel>> getTransactions({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _transactionsLoaded) {
      return _transactionsCache;
    }

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

      _transactionsCache
        ..clear()
        ..addAll(
          querySnapshot.docs.map(
            (doc) => TransactionModel.fromMap(doc.data(), doc.id),
          ),
        );

      _transactionsLoaded = true;
      return _transactionsCache;
    } catch (e) {
      print('Erro ao buscar transações: $e');
      throw e;
    }
  }

  // ✅ Buscar saldo (baseado no seu código original)
  Future<UserBalance?> getBalance({bool forceRefresh = false}) async {
    if (!forceRefresh && _balanceLoaded && _balanceCache != null) {
      return _balanceCache;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        _balanceCache = UserBalance.fromMap(docSnapshot.data()!);
      } else {
        _balanceCache = UserBalance(
          balance: 0.0,
          totalIncome: 0.0,
          totalExpenses: 0.0,
          email: user.email ?? '',
          lastUpdated: DateTime.now(),
        );
      }

      _balanceLoaded = true;
      return _balanceCache;
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

  // ✅ Salvar transação (baseado no seu código original)
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

      // Upload de imagem se necessário
      final String? imagePath = data['image'] as String?;
      if (imagePath != null && imagePath.isNotEmpty) {
        if (imagePath.startsWith('http')) {
          data['image'] = imagePath;
        } else {
          final File imageFile = File(imagePath);
          final int fileSize = await imageFile.length();
          if (fileSize > _maxImageSize) {
            throw Exception('A imagem deve ter no máximo 0.5MB');
          }
          final String imageUrl = await _uploadImage(imageFile);
          data['image'] = imageUrl;
        }
      } else {
        data['image'] = '';
      }

      // Converter DateTime para Timestamp
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
        await _firestore.collection('transactions').add(transactionData);
        await _updateBalance(isIncome: isIncome, value: value);
      }

      // Invalida cache após alteração
      _transactionsLoaded = false;
      _balanceLoaded = false;
    } catch (e) {
      print('Erro ao salvar a transação: $e');
      throw e;
    }
  }

  // ✅ Deletar transação (baseado no seu código original)
  Future<void> deleteTransaction(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final docSnapshot =
          await _firestore.collection('transactions').doc(id).get();

      if (!docSnapshot.exists) {
        throw Exception('Transação não encontrada');
      }

      final data = docSnapshot.data()!;

      if (data['userId'] != user.uid) {
        throw Exception('Você não tem permissão para excluir esta transação');
      }

      final isIncome = data['category'] == 'Entrada';
      final value = (data['value'] as num).toDouble();

      // Excluir imagem se existir
      if (data['image'] != null && data['image'].toString().isNotEmpty) {
        try {
          final imageRef = _storage.refFromURL(data['image'].toString());
          await imageRef.delete();
        } catch (e) {
          print('Erro ao excluir imagem: $e');
        }
      }

      await _firestore.collection('transactions').doc(id).delete();
      await _updateBalance(isIncome: isIncome, value: value, isDelete: true);

      // Invalida cache após exclusão
      _transactionsLoaded = false;
      _balanceLoaded = false;
    } catch (e) {
      print('Erro ao excluir transação: $e');
      throw e;
    }
  }

  // ✅ Upload de imagem (baseado no seu código original)
  Future<String> _uploadImage(File imageFile) async {
    try {
      final String fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';
      final storageRef = _storage.ref().child('transaction_images/$fileName');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      throw e;
    }
  }

  // ✅ Atualizar saldo (baseado no seu código original)
  Future<void> _updateBalance({
    required bool isIncome,
    required double value,
    bool isEdit = false,
    bool isDelete = false,
    double? oldValue,
    bool? oldIsIncome,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final balanceRef = _firestore.collection('users').doc(user.uid);

    if (isDelete) {
      if (isIncome) {
        await balanceRef.update({
          'balance': FieldValue.increment(-value),
          'totalIncome': FieldValue.increment(-value),
          'lastUpdated': DateTime.now(),
        });
      } else {
        await balanceRef.update({
          'balance': FieldValue.increment(value),
          'totalExpenses': FieldValue.increment(-value),
          'lastUpdated': DateTime.now(),
        });
      }
      _balanceLoaded = false;
      return;
    }

    if (isEdit && oldValue != null && oldIsIncome != null) {
      if (oldIsIncome == isIncome) {
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
        if (isIncome) {
          await balanceRef.update({
            'balance': FieldValue.increment(oldValue + value),
            'totalExpenses': FieldValue.increment(-oldValue),
            'totalIncome': FieldValue.increment(value),
            'lastUpdated': DateTime.now(),
          });
        } else {
          await balanceRef.update({
            'balance': FieldValue.increment(-(oldValue + value)),
            'totalIncome': FieldValue.increment(-oldValue),
            'totalExpenses': FieldValue.increment(value),
            'lastUpdated': DateTime.now(),
          });
        }
      }
    } else {
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

    _balanceLoaded = false;
  }
}
