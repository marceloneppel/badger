part of badger.parser;

class BadgerGrammarDefinition extends GrammarDefinition {
  @override
  start() => (allowWhitespace(ref(declarations).optional()) &
          allowWhitespace(ref(statements).optional()))
      .end("expected end of program");

  statements() =>
      ref(statement).separatedBy(
          allowWhitespace(char(";") | char("\n").plus(),
                      lazy: char(";") | char("\n"), firstThenOptional: true) &
                  whitespace().star().optional() |
              failure("Expected a semicolon or a newline"),
          includeSeparators: false) |
      failure("Expected statements separated by a semicolon or a newline");

  statement() =>
      ref(
          token,
          ref(basicFunctionDefinition) |
              ref(functionDefinition) |
              ref(multipleAssign) |
              ref(accessAssignment) |
              ref(flatAssignment) |
              ref(variableDeclaration) |
              ref(ifStatement) |
              ref(whileStatement) |
              ref(breakStatement) |
              ref(forInStatement) |
              ref(returnStatement) |
              ref(switchStatement) |
              ref(tryCatchStatement) |
              ref(namespace) |
              ref(classBlock) |
              ref(expressionStatement)) |
      failure("Statement Expected");

  expressionStatement() => ref(expression);

  breakStatement() => ref(BREAK);

  booleanLiteral() => ref(TRUE) | ref(FALSE);

  nullLiteral() => ref(NULL);

  multipleAssign() =>
      ((string("let") | string("var")) &
              char("?").optional() &
              whitespace().star())
          .optional() &
      char("{") &
      whitespace().star() &
      ref(identifier)
          .separatedBy(allowWhitespace(ref(COMMA)), includeSeparators: false) &
      whitespace().star() &
      char("}") &
      whitespace().star() &
      ref(EQUALS) &
      whitespace().star() &
      ref(expression);

  variableDeclaration() =>
      (((ref(LET) | ref(VAR)) & char("?").optional()).flatten().optional() &
          whitespace().plus()) &
      ref(identifier) &
      allowWhitespace(ref(EQUALS)) &
      ref(expression);

  methodCall() =>
      (ref(identifier) | ref(access)) &
      char("(") &
      ref(arguments).optional() &
      char(")");

  simpleMethodCall() =>
      ref(identifier) & char("(") & ref(arguments).optional() & char(")");

  arguments() => ref(expression)
      .separatedBy(allowWhitespace(ref(COMMA)), includeSeparators: false);

  forInStatement() =>
      ref(FOR) &
      whitespace().plus() &
      ref(identifier) &
      whitespace().plus() &
      ref(IN) &
      whitespace().plus() &
      ref(expression) &
      ref(block);

  parens() => char("(") & ref(expression) & char(")");

  returnStatement() =>
      ref(RETURN) &
      (whitespace().star() & ref(expression) & whitespace().star());

  listDefinition() =>
      char("[") &
      whitespace().star() &
      ref(arguments) &
      whitespace().star() &
      char("]");

  ternaryOperator() =>
      ref(expressionItem) &
      whitespace().star() &
      char("?") &
      whitespace().star() &
      ref(expression) &
      whitespace().star() &
      char(":") &
      whitespace().star() &
      ref(expression);

  plusOperator() => ref(OPERATION, "+");

  minusOperator() => ref(OPERATION, "-");

  divideOperator() => ref(OPERATION, "/");

  divideIntOperator() => ref(OPERATION, "~/");

  multiplyOperator() => ref(OPERATION, "*");

  andOperator() => ref(OPERATION, "&&");

  orOperator() => ref(OPERATION, "||");

  bitwiseAndOperator() => ref(OPERATION, "&");

  bitwiseOrOperator() => ref(OPERATION, "|");

  lessThanOperator() => ref(OPERATION, "<");

  greaterThanOperator() => ref(OPERATION, ">");

  lessThanOrEqualOperator() => ref(OPERATION, "<=");

  greaterThanOrEqualOperator() => ref(OPERATION, ">=");

  bitShiftLeft() => ref(OPERATION, "<<");

  bitShiftRight() => ref(OPERATION, ">>");

  equalOperator() => ref(OPERATION, "==");

  notEqualOperator() => ref(OPERATION, "!=");

  inOperator() => ref(OPERATION, "in");

  insertOperator() => ref(OPERATION, "<-");

  OPERATION(String x) =>
      ref(expressionItem) &
      whitespace().star() &
      ref(token, x) &
      whitespace().star() &
      ref(expression);

  NEWLINE() => pattern('\n\r');

  singleLineComment() =>
      string('//') & any().starLazy(ref(NEWLINE)) & ref(NEWLINE).optional();

  declarations() => ref(declaration).separatedBy(char("\n"));

  declaration() => ref(token, ref(importDeclaration) | ref(featureDeclaration));

  featureDeclaration() =>
      ref(USING_FEATURE) & whitespace().plus() & ref(stringLiteral);

  importDeclaration() =>
      ref(IMPORT) &
      whitespace().star() &
      ref(stringLiteral) &
      (whitespace().plus() &
              ref(token, "as") &
              whitespace().plus() &
              ref(identifier))
          .optional();

  bracketAccess() =>
      ref(expressionItem) & char("[") & ref(expressionItem) & char("]");

  reference() => char("&") & ref(variableReference);

  tryCatchStatement() =>
      ref(token, "try") &
      whitespace().star() &
      ref(block) &
      whitespace().star() &
      ref(token, "catch") &
      whitespace().star() &
      char("(") &
      ref(identifier) &
      char(")") &
      whitespace().star() &
      ref(block);

  block() =>
      whitespace().star() &
      char("{") &
      whitespace().star() &
      ref(statements).optional() &
      whitespace().star() &
      char("}");

  functionDefinition() =>
      ref(FUNC).optional() &
      whitespace().star() &
      ref(identifier) &
      char("(") &
      ref(identifier)
          .separatedBy(whitespace().star() & char(",") & whitespace().star())
          .optional() &
      char(")") &
      ref(block);

  basicFunctionDefinition() =>
      ref(identifier) &
      char("(") &
      ref(identifier)
          .separatedBy(whitespace().star() & char(",") & whitespace().star())
          .optional() &
      char(")") &
      whitespace().star() &
      string("->") &
      whitespace().star() &
      ref(expression);

  emptyListDefinition() => string("[]");

  flatAssignment() =>
      ref(identifier) &
      whitespace().star() &
      ref(token, "=") &
      whitespace().star() &
      ref(expression);

  accessAssignment() =>
      ref(access) &
      whitespace().star() &
      string("=") &
      whitespace().star() &
      ref(expression);

  variableReference() => ref(identifier);

  expression() =>
      ref(operation) | ref(expressionItem) | failure("Expression Expected");

  operation() => ref(
      token,
      ref(inOperator) |
          ref(definedOperator) |
          ref(ternaryOperator) |
          ref(plusOperator) |
          ref(minusOperator) |
          ref(multiplyOperator) |
          ref(divideIntOperator) |
          ref(divideOperator) |
          ref(andOperator) |
          ref(orOperator) |
          ref(bitwiseAndOperator) |
          ref(bitwiseOrOperator) |
          ref(lessThanOperator) |
          ref(greaterThanOperator) |
          ref(greaterThanOrEqualOperator) |
          ref(lessThanOrEqualOperator) |
          ref(equalOperator) |
          ref(notEqualOperator) |
          ref(bitShiftLeft) |
          ref(bitShiftRight) |
          ref(negate) |
          ref(insertOperator) |
          failure("Operation Expected"));

  callable() => ref(
      token,
      ref(stringLiteral) |
          ref(simpleMethodCall) |
          ref(variableReference) |
          ref(parens));

  access() =>
      ref(callable) &
      char(".") &
      (ref(simpleMethodCall) | ref(identifier))
          .separatedBy(ref(DOT))
          .optional();

  expressionItem() => ref(
      token,
          ref(methodCall) |
          ref(reference) |
          ref(anonymousFunction) |
          ref(access) |
          ref(nullLiteral) |
          ref(nativeCode) |
          ref(rangeLiteral) |
          ref(mapDefinition) |
          ref(hexadecimalLiteral) |
          ref(doubleLiteral) |
          ref(integerLiteral) |
          ref(emptyListDefinition) |
          ref(listDefinition) |
          ref(stringLiteral) |
          ref(parens) |
          ref(booleanLiteral) |
          ref(variableReference) |
          ref(bracketAccess));

  negate() => char("!") & ref(expressionItem);

  definedOperator() => ref(identifier) & char("?");

  ifStatement() =>
      ref(IF) &
      whitespace().plus() &
      ref(expression) &
      whitespace().star() &
      ref(block) &
      (whitespace().star() & ref(ELSE) & ref(block)).optional();

  namespace() =>
      ref(token, "namespace") &
      whitespace().plus() &
      ref(identifier) &
      whitespace().star() &
      ref(block);

  classBlock() =>
      ref(token, "class") &
      whitespace().plus() &
      ref(identifier) &
      (char("(") &
              ref(identifier)
                  .separatedBy(
                      whitespace().star() & char(",") & whitespace().star())
                  .optional() &
              char(")"))
          .pick(1)
          .optional() &
      whitespace().plus() &
      (ref(token, "extends") & whitespace().plus() & ref(identifier))
          .optional() &
      whitespace().star() &
      ref(block);

  switchStatement() =>
      ref(SWITCH) &
      whitespace().plus() &
      ref(expression) &
      whitespace().plus() &
      char("{") &
      whitespace().plus() &
      (ref(caseStatement)).separatedBy(whitespace().star()).optional() &
      whitespace().plus() &
      char("}") &
      whitespace().star();

  caseStatement() =>
      ref(CASE) &
      whitespace().plus() &
      ref(expression) &
      whitespace().star() &
      ref(block);

  defaultStatement() => ref(DEFAULT) & whitespace().plus() & ref(block);

  simpleAnonymousFunction() =>
      char("(") &
      ref(identifier)
          .separatedBy(whitespace().star() & char(",") & whitespace().star())
          .optional() &
      whitespace().star() &
      string(") =>") &
      whitespace().star() &
      ref(expression);

  whileStatement() =>
      ref(WHILE) &
      whitespace().plus() &
      ref(expression) &
      whitespace().star() &
      ref(block);

  anonymousFunction() =>
      char("(") &
      ref(identifier).separatedBy(allowWhitespace(ref(COMMA))).optional() &
      allowWhitespace(char(")")) &
      allowWhitespace(char("-")) &
      allowWhitespace(char(">")) &
      ref(block);

  integerLiteral() => (pattern("-+").optional() & digit().plus()).flatten();

  rangeLiteral() => (ref(integerLiteral) &
      ref(DOT_DOT) &
      char("<").optional() &
      ref(integerLiteral) &
      (char(":") & ref(integerLiteral)).optional());

  hexadecimalLiteral() =>
      (string("0x") & (pattern("0-9A-Fa-f").plus().flatten()));

  doubleLiteral() =>
      (pattern("-+").optional() & digit().plus() & char(".") & digit().plus())
          .flatten();

  stringLiteral() =>
      char('"') & (ref(interpolation) | ref(character)).star() & char('"');

  mapDefinition() =>
      char("{") &
      whitespace().star() &
      ref(mapEntry)
          .separatedBy((char(",") | whitespace().star()).trim(),
              includeSeparators: false)
          .optional() &
      char(",").optional() &
      whitespace().star() &
      char("}");

  nativeCode() =>
      ref(THREE_BACKTICKS) &
      any().starLazy(ref(THREE_BACKTICKS)).flatten() &
      ref(THREE_BACKTICKS);

  mapEntry() =>
      ref(expressionItem) &
      whitespace().star() &
      (char(":") | string("->")) &
      whitespace().star() &
      ref(expression);

  interpolation() => string("\$(") & ref(expression) & char(")");

  character() => ref(unicodeEscape) | ref(characterEscape) | pattern('^"\\');

  unicodeEscape() => (string("\\u") & pattern("A-Fa-f0-9").times(4)).flatten();

  characterEscape() =>
      (string("\\") & pattern(_decodeTable.keys.join())).flatten();

  identifier() => ref(token, pattern("A-Za-z_").plus());

  EQUALS() => ref(token, "=");

  BREAK() => ref(token, "break");

  CASE() => ref(token, "case");

  ELSE() => ref(token, "else");

  TRUE() => ref(token, "true");

  FALSE() => ref(token, "false");

  FOR() => ref(token, "for");

  IF() => ref(token, "if");

  IN() => ref(token, "in");

  NULL() => ref(token, "null");

  SWITCH() => ref(token, "switch");

  VAR() => ref(token, "var");

  LET() => ref(token, "let");

  WHILE() => ref(token, "while");

  DEFAULT() => ref(token, "default");

  FUNC() => ref(token, "func");

  RETURN() => ref(token, "return");

  IMPORT() => ref(token, "import");

  USING_FEATURE() => ref(token, "using feature");

  COMMA() => ref(token, ",");

  SEMICOLON() => ref(token, ";");

  THREE_BACKTICKS() => ref(token, "```");

  DOT_DOT() => ref(token, "..");

  DOT() => ref(token, ".");

  HIDDEN() => ref(singleLineComment);

  Parser allowWhitespace(Parser input,
      {bool optional: true, Parser lazy, bool firstThenOptional: false}) {
    Parser ws;

    if (lazy != null) {
      if (optional) {
        ws = _WHITESPACE.starLazy(lazy);
      } else {
        ws = _WHITESPACE.plusLazy(lazy);
      }
    } else {
      if (optional) {
        ws = _WHITESPACE_OPTIONAL;
      } else {
        ws = _WHITESPACE_REQUIRED;
      }
    }

    if (firstThenOptional) {
      return ws & input & _WHITESPACE_OPTIONAL;
    } else {
      return ws & input & ws;
    }
  }

  static Parser _WHITESPACE = whitespace();
  Parser _WHITESPACE_OPTIONAL = _WHITESPACE.star().optional();
  Parser _WHITESPACE_REQUIRED = _WHITESPACE.plus();

  Parser token(input) {
    if (tokenCache[input] != null) {
      return tokenCache[input];
    }

    if (input is String) {
      input = input.length == 1 ? char(input) : string(input);
    } else if (input is Function) {
      input = ref(input);
    }

    if (input is! Parser && input is TrimmingParser) {
      throw new StateError("Invalid token parser: ${input}");
    }

    Parser parser = input;

    return tokenCache[input] = parser.token();
  }

  static Map<dynamic, Parser> tokenCache = {};
}

class BadgerGrammar extends GrammarParser {
  BadgerGrammar() : super(new BadgerGrammarDefinition());
}
