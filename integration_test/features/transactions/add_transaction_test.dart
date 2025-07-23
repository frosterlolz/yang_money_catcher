import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yang_money_catcher/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Создание транзакции', (WidgetTester tester) async {
    // Запуск приложения
    app.main();
    await tester.pumpAndSettle();

    // 🔽 Здесь будет переход на экран создания транзакции
    await tester.tap(find.byKey(const Key('TransactionsScreen.isIncome = true floatingActionButton')));
    await tester.pumpAndSettle();

    // 🔽 Открытие выбора счёта
    await tester.tap(find.byKey(const Key('account_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account_0')));
    await tester.pumpAndSettle();

    // 🔽 Открытие выбора статьи
    await tester.tap(find.byKey(const Key('category_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category_0')));
    await tester.pumpAndSettle();

    // 🔽 Ждём появления поля суммы
    expect(find.byKey(const Key('amount_tile')), findsOneWidget);
    await tester.tap(find.byKey(const Key('amount_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('amount_100'))); // Пример
    await tester.pumpAndSettle();

    // 🔽 Выбор даты
    await tester.tap(find.byKey(const Key('date_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 🔽 Выбор времени
    await tester.tap(find.byKey(const Key('time_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 🔽 Ввод комментария
    await tester.tap(find.byKey(const Key('comment_tile')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('comment_input_field')), 'Обед');
    await tester.tap(find.byKey(const Key('comment_confirm_button')));
    await tester.pumpAndSettle();

    // 🔽 Нажатие кнопки сохранения
    await tester.tap(find.byKey(const Key('save_transaction_button')));
    await tester.pump(); // начинаем анимацию загрузки
    await tester.pump(const Duration(seconds: 1)); // подождем лоадер
    await tester.pumpAndSettle();

    // 🔽 Проверка: экран закрылся
    expect(find.byKey(const Key('create_transaction_screen')), findsNothing);
  });
}
