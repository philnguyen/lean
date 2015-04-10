/-
Copyright (c) 2015 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Module: hit.pushout
Authors: Floris van Doorn

Declaration of the pushout
-/

import .colimit

open colimit bool eq

namespace pushout
context

universe u
parameters {TL BL TR : Type.{u}} (f : TL → BL) (g : TL → TR)

  inductive pushout_ob :=
  | tl : pushout_ob
  | bl : pushout_ob
  | tr : pushout_ob

  open pushout_ob

  definition pushout_diag [reducible] : diagram :=
  diagram.mk pushout_ob
             bool
             (λi, pushout_ob.rec_on i TL BL TR)
             (λj, bool.rec_on j tl tl)
             (λj, bool.rec_on j bl tr)
             (λj, bool.rec_on j f  g)

  local notation `D` := pushout_diag
  -- open bool
  -- definition pushout_diag : diagram :=
  -- diagram.mk pushout_ob
  --            bool
  --            (λi, match i with | tl := TL | tr := TR | bl := BL end)
  --            (λj, match j with | tt := tl | ff := tl end)
  --            (λj, match j with | tt := bl | ff := tr end)
  --            (λj, match j with | tt := f  | ff := g  end)

  definition pushout := colimit pushout_diag -- TODO: define this in root namespace
  local attribute pushout_diag [instance]

  definition inl (x : BL) : pushout :=
  @ι _ _ x

  definition inr (x : TR) : pushout :=
  @ι _ _ x

  definition glue (x : TL) : inl (f x) = inr (g x) :=
  @cglue _ _ x ⬝ (@cglue _ _ x)⁻¹

  protected definition rec {P : pushout → Type} (Pinl : Π(x : BL), P (inl x))
    (Pinr : Π(x : TR), P (inr x)) (Pglue : Π(x : TL), glue x ▹ Pinl (f x) = Pinr (g x))
      (y : pushout) : P y :=
  begin
    fapply (@colimit.rec_on _ _ y),
    { intros [i, x], cases i,
       exact (@cglue _ _ x ▹ Pinl (f x)),
       apply Pinl,
       apply Pinr},
    { intros [j, x], cases j,
        exact idp,
      esimp [pushout_ob.cases_on, pushout_diag],
-- change (transport P (@cglue _ tt x) (Pinr (g x)) = transport P (coherence x) (Pinl (f x))),
      -- apply concat;rotate 1;apply (idpath (coherence x ▹ Pinl (f x))),
      -- apply concat;apply (ap (transport _ _));apply (idpath (Pinr (g x))),
      apply tr_eq_of_eq_inv_tr,
--      rewrite -{(transport (λ (x : pushout), P x) (inverse (coherence x)) (transport P (@cglue _ tt x) (Pinr (g x))))}tr_con,
      apply concat, rotate 1, apply tr_con,
      rewrite -Pglue}
  end

  protected definition rec_on [reducible] {P : pushout → Type} (y : pushout)
    (Pinl : Π(x : BL), P (inl x)) (Pinr : Π(x : TR), P (inr x))
    (Pglue : Π(x : TL), glue x ▹ Pinl (f x) = Pinr (g x)) : P y :=
  rec Pinl Pinr Pglue y

  --these definitions are needed until we have them definitionally
  definition rec_inl {P : pushout → Type} (Pinl : Π(x : BL), P (inl x))
    (Pinr : Π(x : TR), P (inr x)) (Pglue : Π(x : TL), glue x ▹ Pinl (f x) = Pinr (g x))
      (x : BL) : rec Pinl Pinr Pglue (inl x) = Pinl x :=
  @colimit.rec_incl _ _ _ _ _ _ --idp

  definition rec_inr {P : pushout → Type} (Pinl : Π(x : BL), P (inl x))
    (Pinr : Π(x : TR), P (inr x)) (Pglue : Π(x : TL), glue x ▹ Pinl (f x) = Pinr (g x))
      (x : TR) : rec Pinl Pinr Pglue (inr x) = Pinr x :=
  @colimit.rec_incl _ _ _ _ _ _ --idp

  protected definition elim {P : Type} (Pinl : BL → P) (Pinr : TR → P)
    (Pglue : Π(x : TL), Pinl (f x) = Pinr (g x)) (y : pushout) : P :=
  rec Pinl Pinr (λx, !tr_constant ⬝ Pglue x) y

  protected definition elim_on [reducible] {P : Type} (Pinl : BL → P) (y : pushout)
    (Pinr : TR → P) (Pglue : Π(x : TL), Pinl (f x) = Pinr (g x)) : P :=
  elim Pinl Pinr Pglue y

  definition rec_glue {P : pushout → Type} (Pinl : Π(x : BL), P (inl x))
    (Pinr : Π(x : TR), P (inr x)) (Pglue : Π(x : TL), glue x ▹ Pinl (f x) = Pinr (g x))
      (x : TL) : apD (rec Pinl Pinr Pglue) (glue x) = sorry ⬝ Pglue x ⬝ sorry :=
  sorry

  definition elim_glue {P : Type} (Pinl : BL → P) (Pinr : TR → P)
    (Pglue : Π(x : TL), Pinl (f x) = Pinr (g x)) (y : pushout) (x : TL)
    : ap (elim Pinl Pinr Pglue) (glue x) = sorry ⬝ Pglue x ⬝ sorry :=
  sorry


end

  open pushout equiv is_equiv unit

  namespace test
    definition unit_of_empty (u : empty) : unit := star

    example : pushout unit_of_empty unit_of_empty ≃ bool :=
    begin
      fapply equiv.MK,
      { intro x, fapply (pushout.rec_on _ _ x),
          intro u, exact ff,
          intro u, exact tt,
          intro c, cases c},
      { intro b, cases b,
          exact (inl _ _ ⋆),
          exact (inr _ _ ⋆)},
      { intro b, cases b, apply rec_inl, apply rec_inr},
      { intro x, fapply (pushout.rec_on _ _ x),
          intro u, cases u, rewrite [↑function.compose,↑pushout.rec_on,rec_inl],
          intro u, cases u, rewrite [↑function.compose,↑pushout.rec_on,rec_inr],
          intro c, cases c},
    end

  end test
end pushout
