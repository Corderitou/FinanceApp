import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../../data/models/account.dart';
import '../../data/repositories/account_repository.dart';

class AccountState {
  final List<Account> accounts;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  AccountState({
    required this.accounts,
    required this.isLoading,
    this.error,
    required this.isSubmitting,
  });

  AccountState copyWith({
    List<Account>? accounts,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return AccountState(
      accounts: accounts ?? this.accounts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  static AccountState initial() {
    return AccountState(
      accounts: [],
      isLoading: false,
      isSubmitting: false,
    );
  }
}

class AccountNotifier extends StateNotifier<AccountState> {
  final AccountRepository _accountRepository;

  AccountNotifier({required AccountRepository accountRepository})
      : _accountRepository = accountRepository,
        super(AccountState.initial());

  Future<void> loadAccounts(int userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final accounts = await _accountRepository.getAccountsByUser(userId);
      state = state.copyWith(
        accounts: accounts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar las cuentas: ${e.toString()}',
      );
    }
  }

  Future<bool> createAccount(Account account) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _accountRepository.insertAccount(account);
      
      // Reload accounts
      await loadAccounts(account.userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al crear la cuenta: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateAccount(Account account) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _accountRepository.updateAccount(account);
      
      // Reload accounts
      await loadAccounts(account.userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al actualizar la cuenta: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteAccount(int accountId, int userId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _accountRepository.deleteAccount(accountId);
      
      // Reload accounts
      await loadAccounts(userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al eliminar la cuenta: ${e.toString()}',
      );
      return false;
    }
  }
}

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  // This will be overridden when the provider is created with a repository
  throw UnimplementedError();
});