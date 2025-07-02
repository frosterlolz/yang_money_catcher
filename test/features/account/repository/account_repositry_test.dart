// TODO(frosterlolz): исправить тесты после появления локального хранилища
// import 'package:flutter_test/flutter_test.dart';
// import 'package:yang_money_catcher/features/account/data/repository/mock_account_repository.dart';
// import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_storage.dart';
// import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
// import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
//
// void main() {
//   late MockAccountRepository repository;
//   late AccountsLocalStorage storage;
//
//   setUp(() {
//     storage = ;
//     repository = MockAccountRepository(storage);
//   });
//
//   test('Создание нового аккаунта', () async {
//     final account = await repository.createAccount(
//       const AccountRequest$Create(name: 'My Account', balance: '1000', currency: Currency.rub),
//     );
//
//     expect(account.name, equals('My Account'));
//     expect(account.balance, equals('1000'));
//   });
//
//   test('Получение списка аккаунтов', () async {
//     await repository.createAccount(const AccountRequest$Create(name: 'A', balance: '500', currency: Currency.rub));
//     await repository.createAccount(const AccountRequest$Create(name: 'B', balance: '1500', currency: Currency.rub));
//
//     final accounts = await repository.getAccounts();
//
//     expect(accounts.length, equals(2));
//   });
//
//   test('Обновление аккаунта', () async {
//     final created = await repository.createAccount(
//       const AccountRequest$Create(name: 'Old', balance: '100', currency: Currency.rub),
//     );
//
//     final updated = await repository.updateAccount(
//       AccountRequest$Update(id: created.id, name: 'New', balance: '200', currency: Currency.rub),
//     );
//
//     expect(updated.name, equals('New'));
//   });
//
//   test('Получение деталей аккаунта', () async {
//     final created = await repository.createAccount(
//       const AccountRequest$Create(name: 'DetailTest', balance: '200', currency: Currency.rub),
//     );
//
//     final detail = await repository.getAccountDetail(created.id);
//
//     expect(detail.name, equals('DetailTest'));
//   });
//
//   test('Получение истории аккаунта', () async {
//     final created = await repository.createAccount(
//       const AccountRequest$Create(name: 'HistoryTest', balance: '300', currency: Currency.rub),
//     );
//
//     final history = await repository.getAccountHistory(created.id);
//
//     expect(history.accountId, equals(created.id));
//   });
// }
