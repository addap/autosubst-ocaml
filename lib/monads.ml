(** This module contains own definitions for some monads *)
open Util

module M = Monadic
module L = Language
module AL = AssocList

module type MONAD_READER = sig
  type 'a t
  type r

  include M.Monad.MONAD
    with type 'a t := 'a t

  val ask : r t
  val asks : (r -> 'a) -> 'a t
end

module type MONAD_ERROR = sig
  type 'a t
  type e

  include M.Monad.MONAD
    with type 'a t := 'a t

  val error : e -> 'a t
end

(** A combination of reader and error *)
module type MONAD_RE = sig
  type 'a t
  (* as in Rws.MONAD_RWST I use these two types to include the Monad.MAKE_T signature so that I can have the Syntax signature in MONAD_RE. Then I can use the syntax when defining functions in the RE_Functions functor *)
  type 'a wrapped
  type 'a actual_t

  include MONAD_READER
    with type 'a t := 'a t
  include MONAD_ERROR
    with type 'a t := 'a t

  include M.Monad.APPLICATIVE_FUNCTIONS
    with type 'a applicative := 'a t
    with type 'a collection := 'a list

  include M.Monad.MONAD_FUNCTIONS
    with type 'a monad := 'a t
    with type 'a collection := 'a list

  include M.Monad.MAKE_T
    with type 'a t := 'a t
    with type 'a wrapped := 'a wrapped
    with type 'a actual_t := 'a actual_t
end

(** Some functions that were not in the monad library yet *)
module ExtraFunctionsList (MON: M.Monad.MONAD) = struct
  module Infix = M.Monad.MonadInfix(MON)
  module Fun = M.Monad.ApplicativeFunctionsList(MON)
  open Fun
  open Infix.Syntax
  open MON

  let m_guard mb l =
    let* b = mb in
    pure (guard b l)

  let a_split_map f a =
    let* bs = a_map f a in
    let (cs, ds) = List.split bs in
    pure (cs, ds)

  let map2 f a b =
    let* f' = map f a in
    map f' b

  let a_map2_exn f a b =
    sequence @@ List.map2 f a b

  let rec m_fold_left ~f ~init xs =
    match xs with
    | [] -> pure init
    | x :: xs ->
      let* init = f init x in
      m_fold_left ~f ~init xs

  let rec m_fold_right ~f ~init xs =
    match xs with
    | [] -> pure init
    | x :: xs ->
      let* result = m_fold_right ~f ~init xs in
      f x result

  let a_concat_map f xs =
    map List.concat @@ a_map f xs

  let m_guard cond m =
    if cond then m else pure []
end
