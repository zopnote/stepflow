import 'dart:async';

import 'package:stepflow/core.dart';

@Deprecated("Everything relating to the standard output "
    "will be removed from stepflow in the next major update."
    "The features have been extracted into the Dart package natrix "
    "and have undergone a general overhaul.")
class LogColor {
  const LogColor(this.value);
  final String value;
  static const String reset = '\x1B[0m';

  static const LogColor black = LogColor("\x1B[30m");
  static const LogColor red = LogColor("\x1B[31m");
  static const LogColor green = LogColor("\x1B[32m");
  static const LogColor yellow = LogColor("\x1B[33m");
  static const LogColor blue = LogColor("\x1B[34m");
  static const LogColor magenta = LogColor("\x1B[35m");
  static const LogColor cyan = LogColor("\x1B[36m");
  static const LogColor white = LogColor("\x1B[37m");

  static String blacked(String msg) => "$black$msg$reset";
  static String redid(String msg) => "$red$msg$reset";
  static String greened(String msg) => "$green$msg$reset";
  static String yellowed(String msg) => "$yellow$msg$reset";
  static String blued(String msg) => "$blue$msg$reset";
  static String magentaed(String msg) => "$magenta$msg$reset";
  static String cyanid(String msg) => "$cyan$msg$reset";
  static String whited(String msg) => "$white$msg$reset";

  static const LogColor gray = LogColor("\x1B[90m");
  static const LogColor brightRed = LogColor("\x1B[91m");
  static const LogColor brightGreen = LogColor("\x1B[92m");
  static const LogColor brightYellow = LogColor("\x1B[93m");
  static const LogColor brightBlue = LogColor("\x1B[94m");
  static const LogColor brightMagenta = LogColor("\x1B[95m");
  static const LogColor brightCyan = LogColor("\x1B[96m");
  static const LogColor brightWhite = LogColor("\x1B[97m");

  static String grayed(String msg) => "$gray$msg$reset";
  static String brightRedid(String msg) => "$brightRed$msg$reset";
  static String brightGreened(String msg) => "$brightGreen$msg$reset";
  static String brightYellowed(String msg) => "$brightYellow$msg$reset";
  static String brightBlued(String msg) => "$brightBlue$msg$reset";
  static String brightMagentaed(String msg) => "$brightMagenta$msg$reset";
  static String brightCyanid(String msg) => "$brightCyan$msg$reset";
  static String brightWhited(String msg) => "$brightWhite$msg$reset";

  static const LogColor backgroundBlack = LogColor("\x1B[40m");
  static const LogColor backgroundRed = LogColor("\x1B[41m");
  static const LogColor backgroundGreen = LogColor("\x1B[42m");
  static const LogColor backgroundYellow = LogColor("\x1B[43m");
  static const LogColor backgroundBlue = LogColor("\x1B[44m");
  static const LogColor backgroundMagenta = LogColor("\x1B[45m");
  static const LogColor backgroundCyan = LogColor("\x1B[46m");
  static const LogColor backgroundWhite = LogColor("\x1B[47m");

  static String backgroundBlacked(String msg) => "$backgroundBlack$msg$reset";
  static String backgroundRedid(String msg) => "$backgroundRed$msg$reset";
  static String backgroundGreened(String msg) => "$backgroundGreen$msg$reset";
  static String backgroundYellowed(String msg) => "$backgroundYellow$msg$reset";
  static String backgroundBlued(String msg) => "$backgroundBlue$msg$reset";
  static String backgroundMagentaed(String msg) =>
      "$backgroundMagenta$msg$reset";
  static String backgroundCyanid(String msg) => "$backgroundCyan$msg$reset";
  static String backgroundWhited(String msg) => "$backgroundWhite$msg$reset";

  static const LogColor bold = LogColor("\x1B[1");
  static const LogColor italic = LogColor("\x1B[3");
  static const LogColor underline = LogColor("\x1B[4");

  static String bolded(String msg) => "$bold$msg$reset";
  static String italiced(String msg) => "$italic$msg$reset";
  static String underlined(String msg) => "$underline$msg$reset";

  @override
  String toString() => value;
}

@Deprecated("Everything relating to the standard output "
    "will be removed from stepflow in the next major update."
    "The features have been extracted into the Dart package natrix "
    "and have undergone a general overhaul.")
class LogASCIIContext extends Step {
  final String text;
  final LogColor color;
  final Level level;

  const LogASCIIContext(
    this.text, {
    this.color = LogColor.white,
    this.level = Level.normal,
  });

  @override
  FutureOr<Step?> execute(
    FlowController controller, [
    FutureOr<Step?> Function()? candidate,
  ]) {
    controller.context.send(Response("$color$text${LogColor.reset}", level));
    return (candidate ?? () => null)();
  }
}
