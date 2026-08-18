# Dewdrop website

This folder is a complete static Astro project for the Dewdrop landing page.

## Commands

Run these commands from `docs/website`:

```sh
npm install
npm run dev
npm run build
npm run preview
```

`npm run build` runs Astro's type and content checks before it creates `dist/`.

## Syntax highlighting

Dew code is highlighted at build time with Shiki. The custom Dew TextMate grammar is in `src/utils/dewdrop-highlight.ts`. It covers the implemented keyword set, declarations, built-in and nominal types, literals, comments, namespace aliases, calls, and operators.

## Typography

The site uses a 16 px base size for reading text and a 14 px base size for code. Small labels use 12 px or more. Keep new text at these minimum sizes so that the site stays easy to read.

## Compiler-backed homepage examples

The homepage has two source-to-Wasm examples:

- `examples/direct-struct.dew` maps a Dew struct to a Wasm GC struct.
- `examples/option-result.dew` maps `Option<I32>` and `Result<I32, I32>` to tagged Wasm GC structs.

Each example has the raw compiler WAT and a `.annotated.wat` file. The page shows the annotated file. Annotations add names and comments only. Parsing and printing an annotated file must produce the raw WAT exactly.

From the repository root, verify or refresh the struct output with:

```sh
tools/dew build docs/website/examples/direct-struct.dew -o /tmp/dewdrop-website-example.wasm
wasm-tools validate --features gc /tmp/dewdrop-website-example.wasm
wasm-tools strip /tmp/dewdrop-website-example.wasm -o /tmp/dewdrop-website-example-stripped.wasm
wasm-tools print /tmp/dewdrop-website-example-stripped.wasm -o /tmp/dewdrop-website-example.wat
cmp docs/website/examples/direct-struct.wat /tmp/dewdrop-website-example.wat
```

Use the same steps for `option-result.dew`. The strip step removes Dew custom metadata sections. It does not rewrite the module's types, functions, exports, or instructions.

Verify that the annotations do not change the WAT:

```sh
wasm-tools parse docs/website/examples/direct-struct.annotated.wat -o /tmp/direct-struct-annotated.wasm
wasm-tools print /tmp/direct-struct-annotated.wasm -o /tmp/direct-struct-annotated.wat
cmp docs/website/examples/direct-struct.wat /tmp/direct-struct-annotated.wat

wasm-tools parse docs/website/examples/option-result.annotated.wat -o /tmp/option-result-annotated.wasm
wasm-tools print /tmp/option-result-annotated.wasm -o /tmp/option-result-annotated.wat
cmp docs/website/examples/option-result.wat /tmp/option-result-annotated.wat
```
