import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
      },
    );
  }

  final TransactionsRepository _transactionsRepository;

  Future<void> _loadTransactions(_Load event, _Emitter emitter) async {
    emitter(TransactionsState.processing(state.transactions));
    try {
      final transactions = await _transactionsRepository.getTransactions(
        accountId: event.accountId,
        startDate: event.range?.start,
        endDate: event.range?.end,
      );
      emitter(TransactionsState.idle(UnmodifiableListView(transactions)));
    } on Object catch (e, s) {
      emitter(TransactionsState.error(state.transactions, error: e));
      onError(e, s);
    }
  }
}
