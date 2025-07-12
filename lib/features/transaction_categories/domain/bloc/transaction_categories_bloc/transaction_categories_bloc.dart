import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

part 'transaction_categories_event.dart';
part 'transaction_categories_state.dart';
part 'transaction_categories_bloc.freezed.dart';

typedef _Emitter = Emitter<TransactionCategoriesState>;

class TransactionCategoriesBloc extends Bloc<TransactionCategoriesEvent, TransactionCategoriesState> {
  TransactionCategoriesBloc(this._transactionsRepository)
      : super(const TransactionCategoriesState.processing(null, isOffline: true)) {
    on<TransactionCategoriesEvent>(
      (event, emitter) => switch (event) {
        _Load() => _load(event, emitter),
      },
    );
  }

  final TransactionsRepository _transactionsRepository;

  Future<void> _load(_Load event, _Emitter emitter) async {
    emitter(TransactionCategoriesState.processing(state.categories, isOffline: state.isOffline));
    try {
      final accountsStream = _transactionsRepository.getTransactionCategories();
      await for (final transactionCategoryResult in accountsStream) {
        final accounts = UnmodifiableListView(transactionCategoryResult.data);
        switch (transactionCategoryResult.isOffline) {
          case true:
            emitter(TransactionCategoriesState.processing(accounts, isOffline: true));
          case false:
            emitter(TransactionCategoriesState.idle(accounts, isOffline: false));
        }
      }
      if (state.categories != null) {
        emitter(TransactionCategoriesState.idle(state.categories!, isOffline: state.isOffline));
      }
    } on Object catch (e, s) {
      emitter(TransactionCategoriesState.error(state.categories, isOffline: state.isOffline, error: e));
      onError(e, s);
    }
  }
}
