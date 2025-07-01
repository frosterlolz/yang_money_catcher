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
  TransactionCategoriesBloc(this._transactionsRepository) : super(const TransactionCategoriesState.processing(null)) {
    on<TransactionCategoriesEvent>(
      (event, emitter) => switch (event) {
        _Load() => _load(event, emitter),
      },
    );
  }

  final TransactionsRepository _transactionsRepository;

  Future<void> _load(_Load event, _Emitter emitter) async {
    emitter(TransactionCategoriesState.processing(state.categories));
    try {
      final categories = await _transactionsRepository.getTransactionCategories();
      emitter(TransactionCategoriesState.idle(UnmodifiableListView(categories)));
    } on Object catch (e, s) {
      emitter(TransactionCategoriesState.error(state.categories, error: e));
      onError(e, s);
    }
  }
}
