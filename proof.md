# Dewdrop Type Proof

For all $n$ integer literals, their type is $I32$.

$$
{
  \ \ 
  \over
  \ \ Γ ⊢ n : {I32}\ \  
}
$$

For $true$ and $false$, their type is $Bool$.

$$
{
  \ \ 
  \over
  \ \ Γ ⊢ true : {Bool},\ \ Γ ⊢ false : {Bool}\ \
}
$$

For any variable $x$ of type $τ$ that exists in the environment $Γ$, the type of $x$ is $τ$.

$$
{
  \ \ x : τ ∈ Γ\ \ 
  \over
  \ \ Γ ⊢ x : τ\ \ 
}
$$

Expressions can be bound.

$$
{
\ \ Γ ⊢ e : τ,\ \{Γ,\ x : τ\} ⊢ e' : τ'​\ \ 
\over
\ \ Γ ⊢\ (let\ x=e\ ; e'):τ'
}  
$$

Since integers can only be $I32$ for now, the following proof need not apply, but will be used in the future, assuming it's possible for multiple integer types to exist.

$$
\ \ \ \
\over
\ \ Γ ⊢ I8 : Int(signed,\ 8),\ U8 : Int(unsigned,\ 8),\ \dots,\ U64 : Int(unsigned,\ 64)\ \ 
$$

An integer type that can hold the data of two given integer types is defined with the following pseudo-code function:

```haskell
τ_{max} (t1, t2) :: Type

τ_{max} Int(s0, n0) Int(s1, n1) = Int(s || s', max(n0, n1)) 
```

The type proof:

$$
\ \ \{\ τ_0 : Int(s_0,\ n_0),\ τ_1 : Int(s_1,\ n_1)\ \}\ \epsilon\ Γ\ \ 
\over
\ \ Γ ⊢ τ_{max}(τ_0,\ τ_1) : Int(s_0\ \vee \ s_1,\ max(n_0,\ n_1))\ \ 
$$



For all integer binary operations $\circ$ such that...

$$
\{+,\ -,\ *,\ /\}\ \ \epsilon \ \ \circ
$$

... then it holds true that


$$
{
  \ \ Γ ⊢ e_0 : τ_0,\  Γ ⊢ e_1 : τ_1\ \ \{\ τ_0,\ τ_1\ \}\ \epsilon\ Integer \ \ 
  \over
  \ \ Γ ⊢\ e_0 \circ e_1 : τ_{max}(τ_0,\ τ_1)\ \ 
}\ \ 
\circ \epsilon\ \{+,\ -,\ *,\ /\}
$$


For $when$ expressions, the type of the $else$ expression must be the same as the type of the arms if it exists.

$$
{
  { \{\ cond_{0..n} : Bool,\ e_{0..n} : τ,\ e_{else} : τ \ \} }\ \epsilon\ \Gamma
  \over
  \ \ Γ ⊢ when\ \{\ cond_0 \rightarrow e_0,\ cond_1 \rightarrow e_1,\ \dots,\ cond_n \rightarrow e_n \ \}\ else\ e_{else}: τ\ \
} 
$$

For equality comparisons:

$$
\ \ Γ ⊢ e_0 : τ_0,\ Γ ⊢ e_1 : τ_1\ \ 
\over
\ \ Γ ⊢ e_​0 == e_​1 : Bool\ \ 
$$

For all functions declarations $fn$:

TODO: Add predicates for function declarations.

$$
{
  
  \over
  \ \ Γ ⊢ fn\ \ (e_0,\ e_1,\ \dots\ e_n) \rightarrow e_{return}: (τ_0,\ τ_1,\ \dots\ τ_n) \rightarrow\ τ_{return}\ \
}
$$
