import "dart:convert";
import "dart:io";

import "package:args/args.dart";
import "package:badger/compiler.dart";
import "package:badger/eval.dart";

Directory tmpDir;

main(List<String> args) async {
  var argp = new ArgParser();
  argp.addFlag("test", negatable: false, abbr: "t", help: "Runs the script in a testing environment.");

  argp.addOption("compile", abbr: "c", allowed: [
    "tiny-ast",
    "ast",
    "js",
    "badger",
    "snapshot",
    "dart"
  ], help: "Compiles Badger Code");

  argp.addOption("compiler-opt", abbr: "O", help: "Specifies a Compiler Option", allowMultiple: true);


  var opts = argp.parse(args);

  if (opts.rest.isEmpty) {
    print("Usage: badger [options] <script> [args]");
    print(argp.usage);
    exit(1);
  }

  var context = new Context();
  StandardLibrary.import(context);
  IOLibrary.import(context);

  if (opts["test"]) {
    TestingLibrary.import(context);
  }

  var argz = opts.rest.skip(1).toList();
  context.setVariable("args", argz);

  var p = opts.rest[0];

  if (p == "-") {
    var buff = new StringBuffer();
    stdin.lineMode = false;
    await for (var data in stdin) {
      buff.write(UTF8.decode(data));
    }
    stdin.lineMode = true;
    tmpDir = await Directory.systemTemp.createTemp("badger");
    var f = new File("${tmpDir.path}/script");
    await f.writeAsString(buff.toString());
    p = f.path;
  }

  var file = new File(p);

  if (!await file.exists()) {
    print("ERROR: Unable to find script file '${file.path}'");
    exit(1);
  }

  var env = new FileEnvironment(file);

  if (opts["compile"] != null) {
    var name = opts["compile"];
    CompilerTarget target;

    if (name == "ast") {
      target = new AstCompilerTarget();
    } else if (name == "js") {
      target = new JsCompilerTarget();
    } else if (name == "badger") {
      target = new BadgerCompilerTarget();
    } else if (name == "tiny-ast") {
      target = new TinyAstCompilerTarget();
    } else if (name == "snapshot") {
      target = new SnapshotCompilerTarget(env);
    } else if (name == "dart") {
      target = new DartCompilerTarget();
    } else {
      print("Unknown Compiler Target: ${name}");
      exit(1);
    }

    var o = opts["compiler-opt"];
    var optz = {};

    for (var i in o) {
      var split = i.split("=");

      if (split.length == 1) {
        optz[split[0]] = true;
      } else {
        var key = split[0];
        var value = split.skip(1).join("=");

        if (value == "true" || value == "false") {
          optz[key] = value == "true";
          continue;
        }

        try {
          value = num.parse(value);

          optz[key] = value;
        } catch (e) {
        }

        optz[key] = value;
      }
    }

    target.options = optz;

    target.options.putIfAbsent("isTestSuite", () => opts["test"]);

    var program = await env.parse();
    print(await target.compile(program));
    exit(0);
  }

  await env.eval(context);

  if (opts["test"] && !(context.meta["tests.ran"] == true)) {
    await context.run(() async {
      await context.invoke("runTests", []);
    });
  }

  if (tmpDir != null) {
    await tmpDir.delete(recursive: true);
  }
}
