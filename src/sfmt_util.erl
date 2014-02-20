-module(sfmt_util).
-export([plain_transform/2]).
-export([make_call/4, make_list/2, make_var/2, make_string/2, make_block/2]).
-define(DUMMY_LINE, 9999).

-spec make_call(integer(), atom(), atom(), list()) -> tuple().
make_call(Ln, Mod, Fn, Args) ->
  {call,Ln, remote(Ln,Mod,Fn), Args}.

-spec make_string(integer(), string()) -> tuple().
make_string(Ln, Str) ->
  {string,Ln,Str}.

-spec make_list(integer(), list()) -> tuple().
make_list(Ln, List) ->
  lists:foldr(fun (It, Acc) -> 
      {cons, Ln, It, Acc}
    end, {nil, Ln}, List).

-spec make_var(integer(), list()|binary()|atom()) -> tuple().
make_var(Ln, Name) when is_list(Name)   -> make_var(Ln, list_to_atom(Name));
make_var(Ln, Name) when is_binary(Name) -> make_var(Ln, binary_to_atom(Name, latin1));
make_var(Ln, Name) when is_atom(Name)   -> {var, Ln, Name}.
  

remote(Ln, Mod, Fn) -> {remote,Ln,{atom,Ln,Mod},{atom,Ln,Fn}}.

-spec make_block(integer(), list()) -> tuple().
make_block(Ln, Exprs) when is_list(Exprs) -> {block, Ln, Exprs}.
  


%%%%%%%%%%%%%%%%%%%%%%
% piece of parse_trans
%%%%%%%%%%%%%%%%%%%%%%
-spec plain_transform(fun(), list()) -> list().
plain_transform(Fun, Forms) when is_function(Fun, 1), is_list(Forms) ->
  plain_transform1(Fun, Forms).

plain_transform1(_, []) ->
  [];

plain_transform1(Fun, [F|Fs]) when is_atom(element(1,F)) ->
  NewF = case Fun(F) of
    continue -> list_to_tuple(plain_transform1(Fun, tuple_to_list(F)));
    Other    -> Other
  end,
  [NewF | plain_transform1(Fun, Fs)];

plain_transform1(Fun, [L|Fs]) when is_list(L) ->
  [plain_transform1(Fun, L) | plain_transform1(Fun, Fs)];

plain_transform1(Fun, [F|Fs]) ->
  [F | plain_transform1(Fun, Fs)];

plain_transform1(_, F) ->
  F.

