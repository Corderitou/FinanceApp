import '../../domain/entities/account.dart';
import '../../data/repositories/account_repository.dart';

class AddAccountUsecase {
  final AccountRepository _accountRepository;

  AddAccountUsecase(this._accountRepository);

  Future<int> execute(Account account) async {
    return await _accountRepository.insertAccount(account);
  }
}

class GetAccountsByUserUsecase {
  final AccountRepository _accountRepository;

  GetAccountsByUserUsecase(this._accountRepository);

  Future<List<Account>> execute(int userId) async {
    return await _accountRepository.getAccountsByUser(userId);
  }
}

class UpdateAccountUsecase {
  final AccountRepository _accountRepository;

  UpdateAccountUsecase(this._accountRepository);

  Future<int> execute(Account account) async {
    return await _accountRepository.updateAccount(account);
  }
}

class DeleteAccountUsecase {
  final AccountRepository _accountRepository;

  DeleteAccountUsecase(this._accountRepository);

  Future<int> execute(int accountId) async {
    return await _accountRepository.deleteAccount(accountId);
  }
}

class GetAccountByIdUsecase {
  final AccountRepository _accountRepository;

  GetAccountByIdUsecase(this._accountRepository);

  Future<Account?> execute(int id) async {
    return await _accountRepository.getAccountById(id);
  }
}

class UpdateAccountBalanceUsecase {
  final AccountRepository _accountRepository;

  UpdateAccountBalanceUsecase(this._accountRepository);

  Future<void> execute(int accountId, double newBalance) async {
    await _accountRepository.updateAccountBalance(accountId, newBalance);
  }
}