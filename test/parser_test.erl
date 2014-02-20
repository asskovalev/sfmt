-module(parser_test).
-compile(export_all).

extract_parts_test() ->
  {"test string", []} = sfmt_parser:parse("test string"),
	{"~p", [<<"Var">>]} = sfmt_parser:parse("$Var"),
	{"~p", [<<"Var">>]} = sfmt_parser:parse("${Var}"),
  {"~pst", [<<"Var">>]} = sfmt_parser:parse("${Var}st"),
  {"~s", [<<"Var">>]} = sfmt_parser:parse("$~s{Var}"),
  {"the ~snd ~p", [<<"Var">>, <<"Var2">>]} 
    = sfmt_parser:parse("the $~s{Var}nd $Var2"),
  {"~p aa~p ~pst ~s", [<<"Var">>, <<"Var2">>, <<"Var3">>, <<"Var4">>]} 
    = sfmt_parser:parse("$Var aa${Var2} ${Var3}st $~s{Var4}").
