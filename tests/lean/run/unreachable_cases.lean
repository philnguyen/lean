open nat prod

inductive ifin : ℕ → Type -- inductively defined fin-type
| fz : Π n, ifin (succ n)
| fs : Π {n}, ifin n → ifin (succ n)

open ifin

noncomputable definition foo {N : Type} : Π{n : ℕ}, N → ifin n → (N × ifin n)
| (succ k) n (fz .k) := sorry
| (succ k) n (fs x) := sorry

noncomputable definition bar {N : Type} : Π{n : ℕ}, (N × ifin n) → (N × ifin n)
| (succ k) (n, fz .k) := sorry
| (succ k) (n, fs x) := sorry

noncomputable definition bar2 {N : Type} : Π{n : ℕ}, (N × ifin n) → (N × ifin n)
| (succ k) (n, fz .k) := sorry
| (succ k) (n, fs x) := sorry
