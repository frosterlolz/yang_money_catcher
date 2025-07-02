import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';
part 'transactions_bloc.freezed.dart';

typedef _Emitter = Emitter<TransactionsState>;

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc(this._transactionsRepository) : super(const TransactionsState.processing(null)) {
    on<TransactionsEvent>(
      (event, emitter) => switch (event) {
        _Load() => _loadTransactions(event, emitter),
        _Update() => _updateTransaction(event, emitter),
      },
    );
  }

  final TransactionsRepository _transactionsRepository;
  StreamSubscription<List<TransactionDetailEntity>>? _transactionsListChangesSubscription;

  @override
  Future<void> close() {
    _transactionsListChangesSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadTransactions(_Load event, _Emitter emitter) async {
    _updateTransactionChangesSubscription(event.filters);
    emitter(TransactionsState.processing(state.transactions));
    try {
      final transactions = await _transactionsRepository.getTransactions(event.filters);
      emitter(TransactionsState.idle(UnmodifiableListView(transactions.toList())));
    } on Object catch (e, s) {
      emitter(TransactionsState.error(state.transactions, error: e));
      onError(e, s);
    }
  }

  void _updateTransaction(_Update event, _Emitter emitter) {
    emitter(TransactionsState.idle(UnmodifiableListView(event.transactions.toList())));
  }

  void _updateTransactionChangesSubscription(TransactionFilters filters) {
    _transactionsListChangesSubscription?.cancel();
    _transactionsListChangesSubscription = _transactionsRepository.transactionsListChanges(filters).listen(
          (transactions) => add(_Update(transactions)),
        );
  }
}
