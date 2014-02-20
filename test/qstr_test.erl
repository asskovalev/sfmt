-module(qstr_test).
-include_lib("sfmt/include/sfmt.hrl").

-export([simple_test/0, expr_test/0]).

simple_test() ->
  A = 1,
  B = "2",
  C = '3',
  D = <<"4">>,
  E = {5, 5},
  
  Expected1 = io_lib:format("~p ~s ~p the ~pth ~p", [A,B,C,D,E]),
  Expected1 = f:"$A $~s{B} $C the ${D}th $E",
  
  Expected2 = lists:flatten(io_lib:format("~p ~s ~p the ~pth ~p", [A,B,C,D,E])),
  Expected2 = s:"$A $~s{B} $C the ${D}th $E",
  
  Expected3 = iolist_to_binary(io_lib:format("~p ~s ~p the ~pth ~p", [A,B,C,D,E])),
  Expected3 = b:"$A $~s{B} $C the ${D}th $E".


expr_test() -> 
  A = 5,
  
  Expected1 = io_lib:format("~p ~p", [A, A+2]),
  Expected1 = f:"$A ${A+2}",
  
  Expected2 = io_lib:format("~p", [lists:seq(0,A)]),
  Expected2 = f:"${lists:seq(0,A)}",
  
  Expected3 = io_lib:format("~p", [begin B = 1, lists:seq(B,A) end]),
  Expected3 = f:"${B = 1, lists:seq(B, A)}".
