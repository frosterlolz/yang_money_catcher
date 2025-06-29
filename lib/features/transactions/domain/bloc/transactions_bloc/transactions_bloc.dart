import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
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
  StreamSubscription<TransactionChangeEntry>? _transactionChangesSubscription;

  Future<void> _loadTransactions(_Load event, _Emitter emitter) async {
    _updateTransactionChangesSubscription(event.range);
    emitter(TransactionsState.processing(state.transactions));
    try {
      final transactions = await _transactionsRepository.getTransactions(
        accountId: event.accountId,
        startDate: event.range?.start,
        endDate: event.range?.end,
      );
      debugPrint('transactions length: ${transactions.length}');
      debugPrint('other filtered: ${state.expensesFiltered(transactions).length}');
      emitter(TransactionsState.idle(UnmodifiableListView(transactions.toList())));
    } on Object catch (e, s) {
      emitter(TransactionsState.error(state.transactions, error: e));
      onError(e, s);
    }
  }

  void _updateTransaction(_Update event, _Emitter emitter) {
    final mutableTransactions = List<TransactionDetailEntity>.of(state.transactions ?? []);
    final newTransaction = event.transaction;
    if (mutableTransactions.isEmpty && newTransaction == null) return;
    final overlapIndex = mutableTransactions.indexWhere((transaction) => transaction.id == event.transactionId);
    // Удаляем транзакцию, если она найдена
    if (newTransaction == null && overlapIndex >= 0) {
      mutableTransactions.removeAt(overlapIndex);
      return emitter(TransactionsState.idle(UnmodifiableListView(mutableTransactions)));
    }
    // Нечего удалять, если транзакция не нашлась
    if (newTransaction == null) return;
    // Транзакция не найдена - добавляем
    if (overlapIndex == -1) {
      mutableTransactions.add(newTransaction);
      // Если транзакция с таким id уже есть, то заменяем ее
    } else {
      mutableTransactions[overlapIndex] = newTransaction;
    }
    emitter(TransactionsState.idle(UnmodifiableListView(mutableTransactions)));
  }

  void _updateTransactionChangesSubscription(DateTimeRange? dateTimeRange) {
    _transactionChangesSubscription?.cancel();
    _transactionChangesSubscription = _transactionsRepository
        .transactionChangesStream(startDate: dateTimeRange?.start, endDate: dateTimeRange?.end)
        .listen(
          (transactionChangeEntry) =>
              add(_Update(transactionId: transactionChangeEntry.key, transaction: transactionChangeEntry.value)),
        );
  }
}
