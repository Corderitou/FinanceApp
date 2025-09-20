import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../data/models/transaction.dart' as model;
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../domain/usecases/add_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import '../../domain/usecases/transaction_form_validator.dart';
import './category_provider.dart'; // Import our new category provider

class TransactionFormState {
  final String amount;
  final int? selectedAccountId;
  final int? selectedCategoryId;
  final DateTime selectedDate;
  final String description;
  final String type;
  final String? amountError;
  final String? accountError;
  final String? categoryError;
  final String? dateError;
  final String? descriptionError;
  final List<Account> accounts;
  final List<Category> categories;
  final bool isLoading;
  final bool isSubmitting;
  final String? submitError;
  final bool submitSuccess;

  TransactionFormState({
    required this.amount,
    required this.selectedAccountId,
    required this.selectedCategoryId,
    required this.selectedDate,
    required this.description,
    required this.type,
    required this.amountError,
    required this.accountError,
    required this.categoryError,
    required this.dateError,
    required this.descriptionError,
    required this.accounts,
    required this.categories,
    required this.isLoading,
    required this.isSubmitting,
    required this.submitError,
    required this.submitSuccess,
  });

  TransactionFormState copyWith({
    String? amount,
    int? selectedAccountId,
    int? selectedCategoryId,
    DateTime? selectedDate,
    String? description,
    String? type,
    String? amountError,
    String? accountError,
    String? categoryError,
    String? dateError,
    String? descriptionError,
    List<Account>? accounts,
    List<Category>? categories,
    bool? isLoading,
    bool? isSubmitting,
    String? submitError,
    bool? submitSuccess,
  }) {
    return TransactionFormState(
      amount: amount ?? this.amount,
      selectedAccountId: selectedAccountId ?? this.selectedAccountId,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedDate: selectedDate ?? this.selectedDate,
      description: description ?? this.description,
      type: type ?? this.type,
      amountError: amountError ?? this.amountError,
      accountError: accountError ?? this.accountError,
      categoryError: categoryError ?? this.categoryError,
      dateError: dateError ?? this.dateError,
      descriptionError: descriptionError ?? this.descriptionError,
      accounts: accounts ?? this.accounts,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  static TransactionFormState initial() {
    return TransactionFormState(
      amount: '',
      selectedAccountId: null,
      selectedCategoryId: null,
      selectedDate: DateTime.now(),
      description: '',
      type: 'expense',
      amountError: null,
      accountError: null,
      categoryError: null,
      dateError: null,
      descriptionError: null,
      accounts: [],
      categories: [],
      isLoading: false,
      isSubmitting: false,
      submitError: null,
      submitSuccess: false,
    );
  }
}

class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;

  TransactionFormNotifier({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
  })  : _transactionRepository = transactionRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository,
        super(TransactionFormState.initial());

  void setAmount(String amount) {
    state = state.copyWith(
      amount: amount,
      amountError: amount.isEmpty ? 'El monto es requerido' : null,
    );
  }

  void setSelectedAccount(int? accountId) {
    state = state.copyWith(
      selectedAccountId: accountId,
      accountError: accountId == null ? 'La cuenta es requerida' : null,
    );
  }

  void setSelectedCategory(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      categoryError: categoryId == null ? 'La categoría es requerida' : null,
    );
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setType(String type) {
    state = state.copyWith(type: type);
  }

  Future<void> loadData(int userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final accounts = await _accountRepository.getAccountsByUser(userId);
      final categories = await _categoryRepository.getCategoriesByUser(userId);
      
      state = state.copyWith(
        accounts: accounts,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        submitError: 'Error al cargar datos: ${e.toString()}',
      );
    }
  }

  Future<bool> submitForm(int userId) async {
    print('=== PROVIDER: Iniciando submitForm ===');
    print('Usuario ID: $userId');
    print('Estado actual:');
    print('- Monto: ${state.amount}');
    print('- Cuenta: ${state.selectedAccountId}');
    print('- Categoría: ${state.selectedCategoryId}');
    print('- Tipo: ${state.type}');
    print('- Descripción: ${state.description}');
    print('- Fecha: ${state.selectedDate}');
    
    state = state.copyWith(isSubmitting: true, submitError: null);
    print('Estado actualizado a isSubmitting: true');
    
    // Validate form
    final isValid = _validateForm();
    print('Formulario válido: $isValid');
    if (!isValid) {
      state = state.copyWith(isSubmitting: false);
      print('Formulario inválido, retornando false');
      return false;
    }

    try {
      final amount = double.parse(state.amount);
      print('Monto parseado: $amount');
      
      final transaction = model.Transaction(
        userId: userId,
        accountId: state.selectedAccountId!,
        categoryId: state.selectedCategoryId!,
        amount: amount,
        type: state.type,
        description: state.description,
        date: state.selectedDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      print('Transacción creada: ${transaction.toString()}');

      final addTransactionUsecase = AddTransactionUseCase(
        transactionRepository: _transactionRepository,
        accountRepository: _accountRepository,
      );
      print('Ejecutando AddTransactionUseCase...');
      await addTransactionUsecase.execute(transaction);
      print('AddTransactionUseCase ejecutado exitosamente');

      state = state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
      );
      print('Estado actualizado: submitSuccess = true');
      
      return true;
    } catch (e, stackTrace) {
      print('ERROR EN submitForm: $e');
      print('STACK TRACE: $stackTrace');
      state = state.copyWith(
        isSubmitting: false,
        submitError: 'Error al guardar la transacción: ${e.toString()}',
      );
      return false;
    }
  }

  bool _validateForm() {
    print('=== VALIDANDO FORMULARIO ===');
    bool isValid = true;
    
    if (state.amount.isEmpty) {
      print('ERROR: Monto está vacío');
      state = state.copyWith(amountError: 'El monto es requerido');
      isValid = false;
    } else {
      try {
        double.parse(state.amount);
        print('Monto válido: ${state.amount}');
      } catch (e) {
        print('ERROR: Monto inválido - ${state.amount}');
        state = state.copyWith(amountError: 'Ingrese un monto válido');
        isValid = false;
      }
    }
    
    if (state.selectedAccountId == null) {
      print('ERROR: Cuenta no seleccionada');
      state = state.copyWith(accountError: 'La cuenta es requerida');
      isValid = false;
    } else {
      print('Cuenta seleccionada: ${state.selectedAccountId}');
    }
    
    if (state.selectedCategoryId == null) {
      print('ERROR: Categoría no seleccionada');
      state = state.copyWith(categoryError: 'La categoría es requerida');
      isValid = false;
    } else {
      print('Categoría seleccionada: ${state.selectedCategoryId}');
    }
    
    print('Formulario válido: $isValid');
    return isValid;
  }

  void resetForm() {
    state = TransactionFormState.initial();
  }
}

final transactionFormProvider = StateNotifierProvider<TransactionFormNotifier, TransactionFormState>((ref) {
  return TransactionFormNotifier(
    transactionRepository: TransactionRepository(),
    accountRepository: AccountRepository(),
    categoryRepository: CategoryRepository(),
  );
});