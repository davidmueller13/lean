/-
Copyright (c) 2015 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Floris van Doorn

Ported from Coq HoTT
Theorems about fibers
-/

import .sigma .eq .pi .pointed

structure fiber {A B : Type} (f : A → B) (b : B) :=
  (point : A)
  (point_eq : f point = b)

open equiv sigma sigma.ops eq pi

namespace fiber
  variables {A B : Type} {f : A → B} {b : B}

  protected definition sigma_char [constructor]
    (f : A → B) (b : B) : fiber f b ≃ (Σ(a : A), f a = b) :=
  begin
  fapply equiv.MK,
    {intro x, exact ⟨point x, point_eq x⟩},
    {intro x, exact (fiber.mk x.1 x.2)},
    {intro x, cases x, apply idp},
    {intro x, cases x, apply idp},
  end

  definition fiber_eq_equiv (x y : fiber f b)
    : (x = y) ≃ (Σ(p : point x = point y), point_eq x = ap f p ⬝ point_eq y) :=
  begin
    apply equiv.trans,
      apply eq_equiv_fn_eq_of_equiv, apply fiber.sigma_char,
    apply equiv.trans,
      apply sigma_eq_equiv,
    apply sigma_equiv_sigma_id,
    intro p,
    apply pathover_eq_equiv_Fl,
  end

  definition fiber_eq {x y : fiber f b} (p : point x = point y)
    (q : point_eq x = ap f p ⬝ point_eq y) : x = y :=
  to_inv !fiber_eq_equiv ⟨p, q⟩

  open is_trunc
  definition fiber_pr1 (B : A → Type) (a : A) : fiber (pr1 : (Σa, B a) → A) a ≃ B a :=
  calc
    fiber pr1 a ≃ Σu, u.1 = a            : fiber.sigma_char
            ... ≃ Σa' (b : B a'), a' = a : sigma_assoc_equiv
            ... ≃ Σa' (p : a' = a), B a' : sigma_equiv_sigma_id (λa', !comm_equiv_nondep)
            ... ≃ Σu, B u.1              : sigma_assoc_equiv
            ... ≃ B a                    : !sigma_equiv_of_is_contr_left

  definition sigma_fiber_equiv (f : A → B) : (Σb, fiber f b) ≃ A :=
  calc
    (Σb, fiber f b) ≃ Σb a, f a = b : sigma_equiv_sigma_id (λb, !fiber.sigma_char)
                ... ≃ Σa b, f a = b : sigma_comm_equiv
                ... ≃ A             : sigma_equiv_of_is_contr_right

  definition is_pointed_fiber [instance] [constructor] (f : A → B) (a : A)
    : pointed (fiber f (f a)) :=
  pointed.mk (fiber.mk a idp)

  definition pointed_fiber [constructor] (f : A → B) (a : A) : Type* :=
  Pointed.mk (fiber.mk a (idpath (f a)))

end fiber

open unit is_trunc

namespace fiber

  definition fiber_star_equiv (A : Type) : fiber (λx : A, star) star ≃ A :=
  begin
    fapply equiv.MK,
    { intro f, cases f with a H, exact a },
    { intro a, apply fiber.mk a, reflexivity },
    { intro a, reflexivity },
    { intro f, cases f with a H, change fiber.mk a (refl star) = fiber.mk a H,
      rewrite [is_hset.elim H (refl star)] }
  end

end fiber

open function is_equiv

namespace fiber
  /- Theorem 4.7.6 -/
  variables {A : Type} {P Q : A → Type}
  variable (f : Πa, P a → Q a)

  /- Note that the map on total spaces/sigmas is just sigma_functor id -/
  definition fiber_total_equiv {a : A} (q : Q a)
    : fiber (sigma_functor id f) ⟨a , q⟩ ≃ fiber (f a) q :=
  calc
    fiber (sigma_functor id f) ⟨a , q⟩
          ≃ Σ(w : Σx, P x), ⟨w.1 , f w.1 w.2 ⟩ = ⟨a , q⟩
            : fiber.sigma_char
      ... ≃ Σ(x : A), Σ(p : P x), ⟨x , f x p⟩ = ⟨a , q⟩
            : sigma_assoc_equiv
      ... ≃ Σ(x : A), Σ(p : P x), Σ(H : x = a), f x p =[H] q
            :
            begin
              apply sigma_equiv_sigma_id, intro x,
              apply sigma_equiv_sigma_id, intro p,
              apply sigma_eq_equiv
            end
      ... ≃ Σ(x : A), Σ(H : x = a), Σ(p : P x), f x p =[H] q
            :
            begin
              apply sigma_equiv_sigma_id, intro x,
              apply sigma_comm_equiv
            end
      ... ≃ Σ(w : Σx, x = a), Σ(p : P w.1), f w.1 p =[w.2] q
            : sigma_assoc_equiv
      ... ≃ Σ(p : P (center (Σx, x=a)).1), f (center (Σx, x=a)).1 p =[(center (Σx, x=a)).2] q
            : sigma_equiv_of_is_contr_left
      ... ≃ Σ(p : P a), f a p =[idpath a] q
            : equiv_of_eq idp
      ... ≃ Σ(p : P a), f a p = q
            :
            begin
              apply sigma_equiv_sigma_id, intro p,
              apply pathover_idp
            end
      ... ≃ fiber (f a) q
            : fiber.sigma_char

end fiber
