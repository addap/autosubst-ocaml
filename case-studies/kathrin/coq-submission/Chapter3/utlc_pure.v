Require Export unscoped.
Require Export header_extensible.
Inductive tm : Type :=
  | var_tm : forall _ : nat, tm
  | app : forall _ : tm, forall _ : tm, tm
  | lam : forall _ : tm, tm.
Lemma congr_app {s0 : tm} {s1 : tm} {t0 : tm} {t1 : tm} (H0 : eq s0 t0)
  (H1 : eq s1 t1) : eq (app s0 s1) (app t0 t1).
Proof.
exact (eq_trans (eq_trans eq_refl (ap (fun x => app x s1) H0))
                (ap (fun x => app t0 x) H1)).
Qed.
Lemma congr_lam {s0 : tm} {t0 : tm} (H0 : eq s0 t0) : eq (lam s0) (lam t0).
Proof.
exact (eq_trans eq_refl (ap (fun x => lam x) H0)).
Qed.
Definition upRen_tm_tm (xi : forall _ : nat, nat) : forall _ : nat, nat :=
  up_ren xi.
Fixpoint ren_tm (xi_tm : forall _ : nat, nat) (s : tm) : tm :=
  match s with
  | var_tm s0 => var_tm (xi_tm s0)
  | app s0 s1 => app (ren_tm xi_tm s0) (ren_tm xi_tm s1)
  | lam s0 => lam (ren_tm (upRen_tm_tm xi_tm) s0)
  end.
Definition up_tm_tm (sigma : forall _ : nat, tm) : forall _ : nat, tm :=
  scons (var_tm var_zero) (funcomp (ren_tm shift) sigma).
Fixpoint subst_tm (sigma_tm : forall _ : nat, tm) (s : tm) : tm :=
  match s with
  | var_tm s0 => sigma_tm s0
  | app s0 s1 => app (subst_tm sigma_tm s0) (subst_tm sigma_tm s1)
  | lam s0 => lam (subst_tm (up_tm_tm sigma_tm) s0)
  end.
Definition upId_tm_tm (sigma : forall _ : nat, tm)
  (Eq : forall x, eq (sigma x) (var_tm x)) :
  forall x, eq (up_tm_tm sigma x) (var_tm x) :=
  fun n =>
  match n with
  | S n' => ap (ren_tm shift) (Eq n')
  | O => eq_refl
  end.
Fixpoint idSubst_tm (sigma_tm : forall _ : nat, tm)
(Eq_tm : forall x, eq (sigma_tm x) (var_tm x)) (s : tm) :
eq (subst_tm sigma_tm s) s :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (idSubst_tm sigma_tm Eq_tm s0) (idSubst_tm sigma_tm Eq_tm s1)
  | lam s0 =>
      congr_lam (idSubst_tm (up_tm_tm sigma_tm) (upId_tm_tm _ Eq_tm) s0)
  end.
Definition upExtRen_tm_tm (xi : forall _ : nat, nat)
  (zeta : forall _ : nat, nat) (Eq : forall x, eq (xi x) (zeta x)) :
  forall x, eq (upRen_tm_tm xi x) (upRen_tm_tm zeta x) :=
  fun n => match n with
           | S n' => ap shift (Eq n')
           | O => eq_refl
           end.
Fixpoint extRen_tm (xi_tm : forall _ : nat, nat)
(zeta_tm : forall _ : nat, nat) (Eq_tm : forall x, eq (xi_tm x) (zeta_tm x))
(s : tm) : eq (ren_tm xi_tm s) (ren_tm zeta_tm s) :=
  match s with
  | var_tm s0 => ap var_tm (Eq_tm s0)
  | app s0 s1 =>
      congr_app (extRen_tm xi_tm zeta_tm Eq_tm s0)
        (extRen_tm xi_tm zeta_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (extRen_tm (upRen_tm_tm xi_tm) (upRen_tm_tm zeta_tm)
           (upExtRen_tm_tm _ _ Eq_tm) s0)
  end.
Definition upExt_tm_tm (sigma : forall _ : nat, tm)
  (tau : forall _ : nat, tm) (Eq : forall x, eq (sigma x) (tau x)) :
  forall x, eq (up_tm_tm sigma x) (up_tm_tm tau x) :=
  fun n =>
  match n with
  | S n' => ap (ren_tm shift) (Eq n')
  | O => eq_refl
  end.
Fixpoint ext_tm (sigma_tm : forall _ : nat, tm) (tau_tm : forall _ : nat, tm)
(Eq_tm : forall x, eq (sigma_tm x) (tau_tm x)) (s : tm) :
eq (subst_tm sigma_tm s) (subst_tm tau_tm s) :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (ext_tm sigma_tm tau_tm Eq_tm s0)
        (ext_tm sigma_tm tau_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (ext_tm (up_tm_tm sigma_tm) (up_tm_tm tau_tm) (upExt_tm_tm _ _ Eq_tm)
           s0)
  end.
Definition up_ren_ren_tm_tm (xi : forall _ : nat, nat)
  (zeta : forall _ : nat, nat) (rho : forall _ : nat, nat)
  (Eq : forall x, eq (funcomp zeta xi x) (rho x)) :
  forall x,
  eq (funcomp (upRen_tm_tm zeta) (upRen_tm_tm xi) x) (upRen_tm_tm rho x) :=
  up_ren_ren xi zeta rho Eq.
Fixpoint compRenRen_tm (xi_tm : forall _ : nat, nat)
(zeta_tm : forall _ : nat, nat) (rho_tm : forall _ : nat, nat)
(Eq_tm : forall x, eq (funcomp zeta_tm xi_tm x) (rho_tm x)) (s : tm) :
eq (ren_tm zeta_tm (ren_tm xi_tm s)) (ren_tm rho_tm s) :=
  match s with
  | var_tm s0 => ap var_tm (Eq_tm s0)
  | app s0 s1 =>
      congr_app (compRenRen_tm xi_tm zeta_tm rho_tm Eq_tm s0)
        (compRenRen_tm xi_tm zeta_tm rho_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (compRenRen_tm (upRen_tm_tm xi_tm) (upRen_tm_tm zeta_tm)
           (upRen_tm_tm rho_tm) (up_ren_ren _ _ _ Eq_tm) s0)
  end.
Definition up_ren_subst_tm_tm (xi : forall _ : nat, nat)
  (tau : forall _ : nat, tm) (theta : forall _ : nat, tm)
  (Eq : forall x, eq (funcomp tau xi x) (theta x)) :
  forall x, eq (funcomp (up_tm_tm tau) (upRen_tm_tm xi) x) (up_tm_tm theta x) :=
  fun n =>
  match n with
  | S n' => ap (ren_tm shift) (Eq n')
  | O => eq_refl
  end.
Fixpoint compRenSubst_tm (xi_tm : forall _ : nat, nat)
(tau_tm : forall _ : nat, tm) (theta_tm : forall _ : nat, tm)
(Eq_tm : forall x, eq (funcomp tau_tm xi_tm x) (theta_tm x)) (s : tm) :
eq (subst_tm tau_tm (ren_tm xi_tm s)) (subst_tm theta_tm s) :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (compRenSubst_tm xi_tm tau_tm theta_tm Eq_tm s0)
        (compRenSubst_tm xi_tm tau_tm theta_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (compRenSubst_tm (upRen_tm_tm xi_tm) (up_tm_tm tau_tm)
           (up_tm_tm theta_tm) (up_ren_subst_tm_tm _ _ _ Eq_tm) s0)
  end.
Definition up_subst_ren_tm_tm (sigma : forall _ : nat, tm)
  (zeta_tm : forall _ : nat, nat) (theta : forall _ : nat, tm)
  (Eq : forall x, eq (funcomp (ren_tm zeta_tm) sigma x) (theta x)) :
  forall x,
  eq (funcomp (ren_tm (upRen_tm_tm zeta_tm)) (up_tm_tm sigma) x)
    (up_tm_tm theta x) :=
  fun n =>
  match n with
  | S n' =>
      eq_trans
        (compRenRen_tm shift (upRen_tm_tm zeta_tm) (funcomp shift zeta_tm)
           (fun x => eq_refl) (sigma n'))
        (eq_trans
           (eq_sym
              (compRenRen_tm zeta_tm shift (funcomp shift zeta_tm)
                 (fun x => eq_refl) (sigma n'))) (ap (ren_tm shift) (Eq n')))
  | O => eq_refl
  end.
Fixpoint compSubstRen_tm (sigma_tm : forall _ : nat, tm)
(zeta_tm : forall _ : nat, nat) (theta_tm : forall _ : nat, tm)
(Eq_tm : forall x, eq (funcomp (ren_tm zeta_tm) sigma_tm x) (theta_tm x))
(s : tm) : eq (ren_tm zeta_tm (subst_tm sigma_tm s)) (subst_tm theta_tm s) :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (compSubstRen_tm sigma_tm zeta_tm theta_tm Eq_tm s0)
        (compSubstRen_tm sigma_tm zeta_tm theta_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (compSubstRen_tm (up_tm_tm sigma_tm) (upRen_tm_tm zeta_tm)
           (up_tm_tm theta_tm) (up_subst_ren_tm_tm _ _ _ Eq_tm) s0)
  end.
Definition up_subst_subst_tm_tm (sigma : forall _ : nat, tm)
  (tau_tm : forall _ : nat, tm) (theta : forall _ : nat, tm)
  (Eq : forall x, eq (funcomp (subst_tm tau_tm) sigma x) (theta x)) :
  forall x,
  eq (funcomp (subst_tm (up_tm_tm tau_tm)) (up_tm_tm sigma) x)
    (up_tm_tm theta x) :=
  fun n =>
  match n with
  | S n' =>
      eq_trans
        (compRenSubst_tm shift (up_tm_tm tau_tm)
           (funcomp (up_tm_tm tau_tm) shift) (fun x => eq_refl) (sigma n'))
        (eq_trans
           (eq_sym
              (compSubstRen_tm tau_tm shift (funcomp (ren_tm shift) tau_tm)
                 (fun x => eq_refl) (sigma n'))) (ap (ren_tm shift) (Eq n')))
  | O => eq_refl
  end.
Fixpoint compSubstSubst_tm (sigma_tm : forall _ : nat, tm)
(tau_tm : forall _ : nat, tm) (theta_tm : forall _ : nat, tm)
(Eq_tm : forall x, eq (funcomp (subst_tm tau_tm) sigma_tm x) (theta_tm x))
(s : tm) : eq (subst_tm tau_tm (subst_tm sigma_tm s)) (subst_tm theta_tm s)
:=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (compSubstSubst_tm sigma_tm tau_tm theta_tm Eq_tm s0)
        (compSubstSubst_tm sigma_tm tau_tm theta_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (compSubstSubst_tm (up_tm_tm sigma_tm) (up_tm_tm tau_tm)
           (up_tm_tm theta_tm) (up_subst_subst_tm_tm _ _ _ Eq_tm) s0)
  end.
Definition rinstInst_up_tm_tm (xi : forall _ : nat, nat)
  (sigma : forall _ : nat, tm)
  (Eq : forall x, eq (funcomp var_tm xi x) (sigma x)) :
  forall x, eq (funcomp var_tm (upRen_tm_tm xi) x) (up_tm_tm sigma x) :=
  fun n =>
  match n with
  | S n' => ap (ren_tm shift) (Eq n')
  | O => eq_refl
  end.
Fixpoint rinst_inst_tm (xi_tm : forall _ : nat, nat)
(sigma_tm : forall _ : nat, tm)
(Eq_tm : forall x, eq (funcomp var_tm xi_tm x) (sigma_tm x)) (s : tm) :
eq (ren_tm xi_tm s) (subst_tm sigma_tm s) :=
  match s with
  | var_tm s0 => Eq_tm s0
  | app s0 s1 =>
      congr_app (rinst_inst_tm xi_tm sigma_tm Eq_tm s0)
        (rinst_inst_tm xi_tm sigma_tm Eq_tm s1)
  | lam s0 =>
      congr_lam
        (rinst_inst_tm (upRen_tm_tm xi_tm) (up_tm_tm sigma_tm)
           (rinstInst_up_tm_tm _ _ Eq_tm) s0)
  end.
Lemma rinstInst_tm (xi_tm : forall _ : nat, nat) :
  eq (ren_tm xi_tm) (subst_tm (funcomp var_tm xi_tm)).
Proof.
exact (FunctionalExtensionality.functional_extensionality _ _
                (fun x => rinst_inst_tm xi_tm _ (fun n => eq_refl) x)).
Qed.
Lemma instId_tm : eq (subst_tm var_tm) id.
Proof.
exact (FunctionalExtensionality.functional_extensionality _ _
                (fun x => idSubst_tm var_tm (fun n => eq_refl) (id x))).
Qed.
Lemma rinstId_tm : eq (@ren_tm id) id.
Proof.
exact (eq_trans (rinstInst_tm (id _)) instId_tm).
Qed.
Lemma varL_tm (sigma_tm : forall _ : nat, tm) :
  eq (funcomp (subst_tm sigma_tm) var_tm) sigma_tm.
Proof.
exact (FunctionalExtensionality.functional_extensionality _ _
                (fun x => eq_refl)).
Qed.
Lemma varLRen_tm (xi_tm : forall _ : nat, nat) :
  eq (funcomp (ren_tm xi_tm) var_tm) (funcomp var_tm xi_tm).
Proof.
exact (FunctionalExtensionality.functional_extensionality _ _
                (fun x => eq_refl)).
Qed.
Lemma renRen_tm (xi_tm : forall _ : nat, nat) (zeta_tm : forall _ : nat, nat)
  (s : tm) :
  eq (ren_tm zeta_tm (ren_tm xi_tm s)) (ren_tm (funcomp zeta_tm xi_tm) s).
Proof.
exact (compRenRen_tm xi_tm zeta_tm _ (fun n => eq_refl) s).
Qed.
Lemma renRen'_tm (xi_tm : forall _ : nat, nat)
  (zeta_tm : forall _ : nat, nat) :
  eq (funcomp (ren_tm zeta_tm) (ren_tm xi_tm))
    (ren_tm (funcomp zeta_tm xi_tm)).
Proof.
exact (FunctionalExtensionality.functional_extensionality _ _
                (fun n => renRen_tm xi_tm zeta_tm n)).
Qed.
Lemma compRen_tm (sigma_tm : forall _ : nat, tm)
  (zeta_tm : forall _ : nat, nat) (s : tm) :
  eq (ren_tm zeta_tm (subst_tm sigma_tm s))
    (subst_tm (funcomp (ren_tm zeta_tm) sigma_tm) s).
Proof.
exact (compSubstRen_tm sigma_tm zeta_tm _ (fun n => eq_refl) s).
Qed.
Lemma compRen'_tm (sigma_tm : forall _ : nat, tm)
  (zeta_tm : forall _ : nat, nat) :
  eq (funcomp (ren_tm zeta_tm) (subst_tm sigma_tm))
    (subst_tm (funcomp (ren_tm zeta_tm) sigma_tm)).
Proof.
exact (FunctionalExtensionality.functional_extensionality _ _
                (fun n => compRen_tm sigma_tm zeta_tm n)).
Qed.
Lemma renComp_tm (xi_tm : forall _ : nat, nat) (tau_tm : forall _ : nat, tm)
  (s : tm) :
  eq (subst_tm tau_tm (ren_tm xi_tm s)) (subst_tm (funcomp tau_tm xi_tm) s).
Proof.
exact (compRenSubst_tm xi_tm tau_tm _ (fun n => eq_refl) s).
Qed.
Lemma renComp'_tm (xi_tm : forall _ : nat, nat) (tau_tm : forall _ : nat, tm)
  :
  eq (funcomp (subst_tm tau_tm) (ren_tm xi_tm))
    (subst_tm (funcomp tau_tm xi_tm)).
Proof.
exact (FunctionalExtensionality.functional_extensionality _ _
                (fun n => renComp_tm xi_tm tau_tm n)).
Qed.
Lemma compComp_tm (sigma_tm : forall _ : nat, tm)
  (tau_tm : forall _ : nat, tm) (s : tm) :
  eq (subst_tm tau_tm (subst_tm sigma_tm s))
    (subst_tm (funcomp (subst_tm tau_tm) sigma_tm) s).
Proof.
exact (compSubstSubst_tm sigma_tm tau_tm _ (fun n => eq_refl) s).
Qed.
Lemma compComp'_tm (sigma_tm : forall _ : nat, tm)
  (tau_tm : forall _ : nat, tm) :
  eq (funcomp (subst_tm tau_tm) (subst_tm sigma_tm))
    (subst_tm (funcomp (subst_tm tau_tm) sigma_tm)).
Proof.
exact (FunctionalExtensionality.functional_extensionality _ _
                (fun n => compComp_tm sigma_tm tau_tm n)).
Qed.


Global Instance Subst_tm   : Subst1 (( nat ) -> tm ) (tm ) (tm ) := @subst_tm   .

Global Instance Ren_tm   : Ren1 (( nat ) -> nat) (tm ) (tm ) := @ren_tm   .

Global Instance VarInstance_tm  : Var (nat) (tm ) := @var_tm  .

Notation "x '__tm'" := (var_tm x) (at level 5, format "x __tm") : subst_scope.

Notation "x '__tm'" := (@ids (_) (_) VarInstance_tm x) (at level 5, only printing, format "x __tm") : subst_scope.

Notation "'var'" := (var_tm) (only printing, at level 1) : subst_scope.

Class Up_tm X Y := up_tm : ( X ) -> Y.

Notation "↑__tm" := (up_tm) (only printing) : subst_scope.

Notation "↑__tm" := (up_tm_tm) (only printing) : subst_scope.

Global Instance Up_tm_tm   : Up_tm (_) (_) := @up_tm_tm   .

Notation "s [ sigmatm ]" := (subst_tm sigmatm s) (at level 7, left associativity, only printing) : subst_scope.

Notation "[ sigmatm ]" := (subst_tm sigmatm) (at level 1, left associativity, only printing) : fscope.

Notation "s ⟨ xitm ⟩" := (ren_tm xitm s) (at level 7, left associativity, only printing) : subst_scope.

Notation "⟨ xitm ⟩" := (ren_tm xitm) (at level 1, left associativity, only printing) : fscope.

Ltac auto_unfold := repeat unfold subst1,  subst2,  Subst1,  Subst2,  ids,  ren1,  ren2,  Ren1,  Ren2,  Subst_tm,  Ren_tm,  VarInstance_tm.

Tactic Notation "auto_unfold" "in" "*" := repeat unfold subst1,  subst2,  Subst1,  Subst2,  ids,  ren1,  ren2,  Ren1,  Ren2,  Subst_tm,  Ren_tm,  VarInstance_tm in *.

Ltac asimpl' := repeat first [progress rewrite ?instId_tm| progress rewrite ?compComp_tm| progress rewrite ?compComp'_tm| progress rewrite ?rinstId_tm| progress rewrite ?compRen_tm| progress rewrite ?compRen'_tm| progress rewrite ?renComp_tm| progress rewrite ?renComp'_tm| progress rewrite ?renRen_tm| progress rewrite ?renRen'_tm| progress rewrite ?varL_tm| progress rewrite ?varLRen_tm| progress (unfold up_ren, upRen_tm_tm, up_tm_tm)| progress (cbn [subst_tm ren_tm])| fsimpl].

Ltac asimpl := repeat try unfold_funcomp; auto_unfold in *; asimpl'; repeat try unfold_funcomp.

Tactic Notation "asimpl" "in" hyp(J) := revert J; asimpl; intros J.

Tactic Notation "auto_case" := auto_case (asimpl; cbn; eauto).

Tactic Notation "asimpl" "in" "*" := auto_unfold in *; repeat first [progress rewrite ?instId_tm in *| progress rewrite ?compComp_tm in *| progress rewrite ?compComp'_tm in *| progress rewrite ?rinstId_tm in *| progress rewrite ?compRen_tm in *| progress rewrite ?compRen'_tm in *| progress rewrite ?renComp_tm in *| progress rewrite ?renComp'_tm in *| progress rewrite ?renRen_tm in *| progress rewrite ?renRen'_tm in *| progress rewrite ?varL_tm in *| progress rewrite ?varLRen_tm in *| progress (unfold up_ren, upRen_tm_tm, up_tm_tm in *)| progress (cbn [subst_tm ren_tm] in *)| fsimpl in *].

Ltac substify := auto_unfold; try repeat (erewrite rinstInst_tm).

Ltac renamify := auto_unfold; try repeat (erewrite <- rinstInst_tm).
