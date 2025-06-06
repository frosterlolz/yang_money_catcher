import 'package:yang_money_catcher/core/utils/app_zone.dart';
import 'package:yang_money_catcher/features/app/di/app_runner.dart';

void main() => appZone((logger) => const AppRunner().initializeAndRun(logger));
