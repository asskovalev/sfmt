-module(sfmt_pt).
-export([parse_transform/2]).
-compile(export_all).

-define(FORMAT_CALL(Ln, Fmt, Str), {remote,Ln,{atom,_,Fmt},{string,_,Str}}).

-spec parse_transform(list(), list()) -> list().
parse_transform(Forms, _Options) ->
  F1 = sfmt_util:plain_transform(fun do_transform/1, Forms),
  F1.


do_transform(?FORMAT_CALL(Ln, b, Str)) -> make_ioformat(Ln, Str, binary);
do_transform(?FORMAT_CALL(Ln, s, Str)) -> make_ioformat(Ln, Str, list);
do_transform(?FORMAT_CALL(Ln, f, Str)) -> make_ioformat(Ln, Str, undefined);
do_transform(_)                        -> continue.


make_ioformat(Ln, Str, OutFmt) ->
  {Format, Args} = parse_format(Str),
  VarArgs = [parse_exprs(Ln, Arg) || Arg <- Args],
  Call = sfmt_util:make_call(Ln, io_lib, format, 
                   [sfmt_util:make_string(Ln,Format),
                    sfmt_util:make_list(Ln,VarArgs)]),
  case OutFmt of
    binary    -> sfmt_util:make_call(Ln, erlang, iolist_to_binary, [Call]);
    list      -> sfmt_util:make_call(Ln, lists, flatten, [Call]);
    undefined -> Call;
    _         -> throw({transform_error, bad_format, OutFmt})
  end.



parse_format(Str) ->
  case sfmt_parser:parse(Str) of
    {Format, Args} -> 
      {Format, Args};
    {_, Rest, {{line, _},Col}} ->
      throw({parse_error, Col, Str, Rest})
  end.

parse_exprs(Ln, Str_) ->
  Str = binary_to_list(<<Str_/binary, ".">>),
  case erl_scan:string(Str) of
    {ok, Tokens, _} -> 
      case erl_parse:parse_exprs(Tokens) of
        {ok, [Expr]} -> Expr;
        {ok, Exprs} -> sfmt_util:make_block(Ln, Exprs);
        ParseErr    -> throw(ParseErr)
      end;
    LexErr ->
      throw(LexErr)
  end.
