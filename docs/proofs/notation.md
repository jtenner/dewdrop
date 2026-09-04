# Notation

## Sets and maps

Let:

\[
\begin{aligned}
n &\in \mathsf{Name} \\
d &\in \mathsf{Decl} \\
e,a,q &\in \mathsf{Expr} \\
\tau &\in \mathsf{Type} \\
\kappa &\in \mathsf{Carrier}
  = \{\mathtt{i32},\mathtt{i64},\mathtt{f32},\mathtt{f64},
      \mathtt{v128},\mathtt{ref},\epsilon\}.
\end{aligned}
\]

The empty carrier \(\epsilon\) means that an expression leaves no WebAssembly
value on the stack.

Let the compiler environments be:

\[
\begin{aligned}
\Gamma &: \mathsf{Name} \rightharpoonup
  (\mathsf{Value}\;\tau + \mathsf{Namespace}), \\
\Delta &: \mathsf{Namespace}\times\mathsf{Name}
  \rightharpoonup \mathsf{Decl}, \\
\Sigma &: \mathsf{Decl} \rightharpoonup
  (\tau_1\times\cdots\times\tau_n\to\tau_r), \\
\Phi &: \mathsf{Expr} \rightharpoonup \mathsf{PhysicalFunction}, \\
\mathcal C &: \mathsf{Type}\to\mathsf{Carrier}.
\end{aligned}
\]

Plain English:

- \(\Gamma\) says if a name is a value or a namespace.
- \(\Delta\) selects a declaration from a namespace and member name.
- \(\Sigma\) gives the logical function type.
- \(\Phi\) gives the linked physical function.
- \(\mathcal C\) maps a Dew type to its WebAssembly stack carrier.

## Judgments

Typing:

\[
\Gamma;\Delta;\Sigma \vdash e : \tau
\]

Selection:

\[
\Gamma;\Delta \vdash q.n \Downarrow d
\]

Emission with an input and output stack:

\[
\Phi;\mathcal C \vdash
  \langle e,S\rangle \Downarrow \langle I,S'\rangle
\]

Here \(I\) is a WebAssembly instruction list. Stack append is written
\(S\cdot\kappa\). Instruction list append is written \(I_1;I_2\).

Preservation goal:

\[
\boxed{
\Gamma;\Delta;\Sigma\vdash e:\tau
\land
\operatorname{Certified}(e,\Phi,\mathcal C)
\Longrightarrow
\Phi;\mathcal C\vdash
\langle e,S\rangle\Downarrow
\langle I,S\cdot\mathcal C(\tau)\rangle
}
\]

For \(\mathcal C(\tau)=\epsilon\), the output stack is just \(S\).
