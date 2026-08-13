import 'package:task_cli/src/cli/cli_app.dart';

Future<void> main(List<String> arguments) async {
  final app = CliApp();
  await app.run(arguments);
}
