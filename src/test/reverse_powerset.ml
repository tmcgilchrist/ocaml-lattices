open! Core
open Lattices
open QCheck

module L : LCheck.LATTICE = struct
  module L_1 =
    Powerset.Make_reverse
      (Bool)
      (struct
        let bottom = Set.add (Set.singleton (module Bool) false) true
      end)

  include L_1
  include Lcheck_helper.Make (L_1)

  let bot = bottom

  let equal x y = leq x y && leq y x

  let name = "powerset lattice"

  let arb_elem =
    let gen =
      Gen.(
        frequency
          [
            (1, return (Set.empty (module L_1.Elt)));
            (1, return (Set.singleton (module L_1.Elt) false));
            (1, return (Set.singleton (module L_1.Elt) true));
            (1, return bottom);
          ])
    in
    make gen ~print:to_string

  let arb_elem_le e =
    let gen =
      match e with
      | e when equal e bot -> Gen.return bottom
      | e ->
          Gen.(
            let x = Set.choose_exn e in
            let _, _, s = Set.split e x in
            return s)
    in
    make gen ~print:to_string

  let equiv_pair =
    let a = map (fun a -> (a, a)) arb_elem in
    set_print (fun (a, a') -> "(" ^ to_string a ^ ";" ^ to_string a' ^ ")") a
end

module LTests = LCheck.GenericTests (L)
module LTestsTop = LCheck.GenericTopTests (L)

let () =
  Alcotest.run "reverse powerset lattice"
    [
      ("properties", List.map ~f:QCheck_alcotest.to_alcotest LTests.suite);
      ("top properties", List.map ~f:QCheck_alcotest.to_alcotest LTestsTop.suite);
    ]
