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
    emitter(TransactionState.processing(isSameTransaction ? state.transaction : null, isOffline: state.isOffline));
    if (!isSameTransaction) {
      _updateTransactionChangesSubscription(event.id);
    }
    try {
      final transactionResultStream = _transactionsRepository.getTransaction(event.id);
      await for (final transactionResult in transactionResultStream) {
        switch (transactionResult.isOffline) {
          case true:
            emitter(TransactionState.processing(transactionResult.data, isOffline: transactionResult.isOffline));
          case false:
            emitter(TransactionState.idle(transactionResult.data, isOffline: transactionResult.isOffline));
        }
      }
      if (state.transaction != null) {
        emitter(TransactionState.idle(state.transaction, isOffline: state.isOffline));
      }
    } on Object catch (e, s) {
      emitter(TransactionState.error(state.transaction, isOffline: state.isOffline, error: e));
      onError(e, s);
    }
  }

  Future<void> _updateTransaction(_Update event, _Emitter emitter) async {
    emitter(TransactionState.processing(state.transaction, isOffline: state.isOffline));
    try {
      final transactionResultStream = switch (event.request) {
        final TransactionRequest$Create createRequest => _transactionsRepository.createTransaction(createRequest),
        final TransactionRequest$Update updateRequest => _transactionsRepository.updateTransaction(updateRequest),
      };
      await for (final transactionResult in transactionResultStream) {
        final isSameTransaction = state.transaction?.id == transactionResult.data.id;
        if (!isSameTransaction) {
          _updateTransactionChangesSubscription(transactionResult.data.id);
        }
        switch (transactionResult.isOffline) {
          case true:
            emitter(TransactionState.processing(transactionResult.data, isOffline: transactionResult.isOffline));
          case false:
            emitter(TransactionState.updated(transactionResult.data, isOffline: transactionResult.isOffline));
        }
      }
    } on Object catch (e, s) {
      emitter(TransactionState.error(state.transaction, isOffline: state.isOffline, error: e));
      onError(e, s);
    } finally {
      final currentTransaction = state.transaction;
      if (currentTransaction != null) {
        emitter(TransactionState.idle(currentTransaction, isOffline: state.isOffline));
      }
    }
  }

  Future<void> _deleteTransaction(_Delete event, _Emitter emitter) async {
    emitter(TransactionState.processing(state.transaction, isOffline: state.isOffline));
    try {
      final resultStream = _transactionsRepository.deleteTransaction(event.id);
      await for (final deleteResult in resultStream) {
        switch (deleteResult.isOffline) {
          case true:
            emitter(const TransactionState.processing(null, isOffline: true));
          case false:
            emitter(const TransactionState.updated(null, isOffline: false));
        }
      }
      await _transactionChangesSubscription?.cancel();
    } on Object catch (e, s) {
      emitter(TransactionState.error(state.transaction, isOffline: state.isOffline, error: e));
      onError(e, s);
    } finally {
      emitter(TransactionState.idle(state.transaction, isOffline: state.isOffline));
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
    emitter(TransactionState.idle(event.transaction, isOffline: event.transaction?.remoteId == null));
  }
}
