import 'package:logger/logger.dart';

/// AppLogger provides a centralized way to log messages with various log levels,
/// using the `logger` package for pretty output and enhanced readability.
class AppLogger {
  // Logger instance with PrettyPrinter for better formatting of log messages
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount:
          0, // Number of stack trace method calls to display (0 = none)
      errorMethodCount:
          5, // Stack trace method calls for error logs (default = 5)
      lineLength: 80, // Max length of each log line (80 characters)
      colors: true, // Enables color coding for logs (e.g., error is red)
      printEmojis: true, // Adds emojis to log messages (e.g., 🔥 for error)
    ),
  );

  /// Logs a message at the debug level, used for development and debugging.
  static void debug(String message) {
    _logger.d(message);
  }

  /// Logs a message at the info level, used for general information logging.
  static void info(String message) {
    _logger.i(message);
  }

  /// Logs a message at the warning level, used for warnings that are not critical.
  static void warning(String message) {
    _logger.w(message);
  }

  /// Logs a message at the error level, used for handling error messages.
  static void error(String message) {
    _logger.e(message);
  }

  /// Logs a message at the fatal level, indicating a severe issue that needs immediate attention.
  static void fatal(String message) {
    _logger.f(message);
  }
}
