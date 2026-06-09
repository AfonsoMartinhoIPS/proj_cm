// lib/core/utils/logger.dart

import 'package:logger/logger.dart';

/// Logger global utilizado em toda a aplicação para debug e diagnóstico.
///
/// Configurado com um [PrettyPrinter] que limita o número de métodos exibidos
/// na stack trace de erros, mantém as linhas com no máximo 80 caracteres e
/// utiliza cores e emojis para melhor legibilidade no terminal.
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);