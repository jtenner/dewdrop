# Struct constructor recovery

This note covers safe recovery when a planned struct constructor keeps its
target source name and object fields but loses its nominal declaration. The
current `facet_memory_string` failure is the `ProcessError` payload inside
`Result::Err`.

## Rule

Let `Struct(n)` be the set of linked physical struct types named `n`. Let
`Fields(e)` be the planned constructor fields. Let `≃` mean that source and
physical fields have a bijection by declaration or name. Carrier equality is
a separate emission obligation.

\[
\frac{
  \operatorname{name}(\operatorname{target}(e))=n
  \qquad
  \{T\in\operatorname{Struct}(n)\mid
       \operatorname{Fields}(e)\simeq\operatorname{Fields}(T)\}=\{T_0\}
}{
  \Gamma\vdash e:T_0
}
\quad\textsc{Recover-Struct}
\]

The singleton set is important. Zero matches means missing evidence. More than
one match means ambiguous evidence. Both cases keep the compiler error.

## Emission

If each source field emits the physical field carrier in physical field order:

\[
\forall i<k.\;\mathcal C(\tau_i)=\kappa_i
\Longrightarrow
\langle e,S\rangle\Downarrow
\langle I_0;\cdots;I_{k-1};\mathtt{struct.new}\;T_0,
S\cdot\mathtt{ref}\rangle.
\]

## Planning propagation

The selected physical struct type also supplies expected carriers to its
source field expressions before emission:

\[
\frac{
  \operatorname{SelectedType}(e)=T
  \qquad
  \operatorname{FieldMap}(T,f)=j
  \qquad
  \operatorname{StorageCarrier}(T,j)=\kappa
  \qquad
  \operatorname{SourceField}(e,f)=e_f
}{
  \operatorname{PlannedCarrier}(e_f)=\kappa
}
\quad\textsc{Constructor-Field-Propagation}
\]

The field map first accepts an exact field declaration. When lowering lost
that declaration, the already selected destination type makes its unique
field name a bounded fallback. The post-plan constructor assertion checks the
same physical storage again.

If the early body plan also lost `SelectedType(e)`, it calls the same unique
name-and-field recovery used by emission:

\[
\operatorname{SelectedType}(e)=\varnothing
\land
\operatorname{RecoverStruct}(e)=\{T\}
\Longrightarrow
\operatorname{PlanningType}(e)=T.
\]

## Status

- Checked: `self_host_linked_infer_constructor_type_index_by_target_name`
  checks target bounds, source-name bounds, name equality, a bijection of all
  field declarations or names, and uniqueness.
- Checked: scheduling rejects an unresolved field carrier and rejects a known
  carrier that differs from physical storage.
- Checked: body planning propagates selected physical field carriers into the
  matching source expressions before branch and local fixed-point steps.
- Test open: the A → B → C bootstrap has not yet needed this fallback.
- Open: the nominal declaration should remain present in the semantic plan.
