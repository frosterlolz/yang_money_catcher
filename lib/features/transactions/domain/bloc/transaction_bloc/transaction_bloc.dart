import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';
part 'transaction_bloc.freezed.dart';

typedef _Emitter = Emitter<TransactionState>;

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc(super.initialState, {required TransactionsRepository transactionsRepository})
      : _transactionsRepository = transactionsRepository {
    on<TransactionEvent>(
      (event, emitter) => switch (event) {
        _Load() => _loadTransaction(event, emitter),
        _Update() => _updateTransaction(event, emitter),
        _Delete() => _deleteTransaction(event, emitter),
        _InternalUpdate() => _internalTransactionUpdate(event, emitter),
      },
    );
    if (state.transaction != null) {
      _updateTransactionChangesSubscription(state.transaction!.id);
    }
  }

  final TransactionsRepository _transactionsRepository;
  StreamSubscription<TransactionDetailEntity?>? _transactionChangesSubscription;

  @override
  Future<void> close() {
    _transactionChangesSubscription?.cancel();
    return super.close();
  }

  Future<void> _loadTransaction(_Load event, _Emitter emitter) async {
    final isSameTransaction = state.transaction?.id == event.id;
    emitter(TransactionState.processing(isSameTransaction ? state.transaction : null));
    if (!isSameTransaction) {
      _updateTransactionChangesSubscription(event.id);
    }
    try {
      final transaction = await _transactionsRepository.getTransaction(event.id);
      emitter(TransactionState.idle(transaction));
    } on Object catch (e, s) {
      emitter(TransactionState.error(state.transaction, error: e));
      onError(e, s);
    }
  }

  Future<void> _updateTransaction(_Update event, _Emitter emitter) async {
    emitter(TransactionState.processing(state.transaction));
    try {
      switch (event.request) {
        case final TransactionRequest$Create createRequest:
          final transaction = await _transactionsRepository.createTransaction(createRequest);
          final updatedTransactionDetails = await _transactionsRepository.getTransaction(transaction.id);
          emitter(TransactionState.updated(updatedTransactionDetails));
        case final TransactionRequest$Update updateRequest:
          final transaction = await _transactionsRepository.updateTransaction(updateRequest);
          emitter(TransactionState.updated(transaction));
      }
    } on Object catch (e, s) {
      emitter(TransactionState.error(state.transaction, error: e));
      onError(e, s);
    } finally {
      final currentTransaction = state.transaction;
      if (currentTransaction != null) {
        emitter(TransactionState.idle(currentTransaction));
      }
    }
  }

  Future<void> _deleteTransaction(_Delete event, _Emitter emitter) async {
    emitter(TransactionState.processing(state.transaction));
    try {
      await _transactionsRepository.deleteTransaction(event.id);
      emitter(TransactionState.updated(state.transaction));
    } on Object catch (e, s) {
      emitter(TransactionState.error(state.transaction, error: e));
      onError(e, s);
    } finally {
      emitter(TransactionState.idle(state.transaction));
    }
  }

  void _updateTransactionChangesSubscription(int transactionId) {
    _transactionChangesSubscription?.cancel();
    _transactionChangesSubscription = _transactionsRepository.transactionChanges(transactionId).listen(
          (transaction) => add(
            _InternalUpdate(transaction),
          ),
        );
  }

  void _internalTransactionUpdate(_InternalUpdate event, _Emitter emitter) {
    emitter(TransactionState.idle(event.transaction));
  }
}
