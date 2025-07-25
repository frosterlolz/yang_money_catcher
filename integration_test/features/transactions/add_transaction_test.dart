import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:yang_money_catcher/features/transactions/presentation/screens/transaction_screen.dart';
import 'package:yang_money_catcher/main.dart' as app;

import '../../utils/widget_tester_x.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      fail(details.exceptionAsString());
    };
  });

  group('Взаимодействия с транзакциями', () {
    testWidgets('Создание транзакции (Расход)', (WidgetTester tester) async {
      // === Подготовка и запуск ===

      app.main();
      await tester.asyncFinder(finder: () => find.byKey(const Key('fab_expense')));
      await tester.pumpAndSettle();
      final tilesCount = find.byType(ListTile).evaluate().length;
      expect(tilesCount, equals(0));

      // === Открытие экрана (ботомшит) добавления транзакции (расход) ===

      await tester.tap(find.byKey(const Key('fab_expense')));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionScreen), findsOneWidget);

      // === Заполнение полей ===

      // 🔽 Добираемся до "родительского" элемента (который и будет контекстом)
      final context = tester.firstElement(find.byType(TransactionScreen));
      final transactionBloc = context.read<TransactionBloc>();
      expect(transactionBloc.state, isA<TransactionState$Idle>());
      expect(transactionBloc.state.transaction, isNull);

      // 🔽 Открытие выбора счёта
      await tester.tap(find.byKey(const Key('account_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('account_item_0')));
      await tester.pumpAndSettle();

      // 🔽 Открытие выбора статьи
      await tester.tap(find.byKey(const Key('category_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transaction_category_0')));
      await tester.pumpAndSettle();

      // 🔽 Ждём появления поля суммы
      // 🔽 Проверка, что поле суммы доступно
      expect(find.byKey(const Key('amount_tile')), findsOneWidget);

      // 🔽 Открытие диалога суммы
      await tester.tap(find.byKey(const Key('amount_tile')));
      await tester.pumpAndSettle();

      // 🔽 Ввод суммы
      await tester.enterText(find.byKey(const Key('amount_input_field')), '100');
      await tester.pumpAndSettle();

      // 🔽 Подтверждение ввода
      await tester.tap(find.byKey(const Key('confirm_button')));
      await tester.pumpAndSettle();

      // 🔽 Выбор даты
      await tester.tap(find.byKey(const Key('date_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(context.l10n.ok));
      await tester.pumpAndSettle();

      // 🔽 Выбор времени
      await tester.tap(find.byKey(const Key('time_tile')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(context.l10n.ok));
      await tester.pumpAndSettle();

      // 🔽 Ввод комментария
      await tester.tap(find.byKey(const Key('comment_tile')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('TextConfirmDialog.textFormField')), 'Обед');
      await tester.tap(find.byKey(const Key('TextConfirmDialog.confirmButton')));
      await tester.pumpAndSettle();

      // 🔽 Нажатие кнопки сохранения
      await tester.tap(find.byKey(const Key('save_transaction_button')));
      await tester.pump(); // старт анимации

      // 🔽 Проверяем симптомы сосотояния загрузки
      expect(transactionBloc.state, isA<TransactionState$Processing>());
      expect(find.byType(TypedProgressIndicator), findsOneWidget);

      // 🔽 Ждём пока индикатор исчезнет (максимум 10 секунд)
      await tester.asyncFinder(finder: () => find.byType(TypedProgressIndicator), isEmptyFinder: true);

      // 🔽 После завершения — финальный settle
      await tester.pumpAndSettle();

      // 🔽 Проверка, что экран создания закрылся
      expect(find.byKey(const Key('create_transaction_screen')), findsNothing);

      // 🔽 Проверка: экран закрылся
      expect(find.byType(TransactionScreen), findsNothing);
      // 🔽 Проверка: появился тайл с total и тайл с транзакцией
      expect(find.byType(ListTile), findsAtLeastNWidgets(2));
    });
  });
}
