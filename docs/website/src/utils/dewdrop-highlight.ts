import {
  createHighlighter,
  type LanguageRegistration,
  type ThemeRegistrationRaw,
} from "shiki";

const dewLanguage: LanguageRegistration = {
  name: "dew",
  scopeName: "source.dew",
  patterns: [
    { include: "#comments" },
    { include: "#strings" },
    { include: "#numbers" },
    {
      match: "\\b(fn)(\\s+)([\\p{L}_][\\p{L}\\p{N}_]*)",
      captures: {
        1: { name: "keyword.declaration.function.dew" },
        3: { name: "entity.name.function.dew" },
      },
    },
    {
      match: "\\b(struct|enum|trait|type)(\\s+)([\\p{L}_][\\p{L}\\p{N}_]*)",
      captures: {
        1: { name: "keyword.declaration.type.dew" },
        3: { name: "entity.name.type.dew" },
      },
    },
    {
      match: "\\b(pub|builtin|foreign|impl|for|let|mut|if|else|match|while|loop|return|break|continue|as|in|where|open|import|export|package|test|derive|using|defer)\\b",
      name: "keyword.control.dew",
    },
    {
      match: "\\b(true|false)\\b",
      name: "constant.language.dew",
    },
    {
      match: "\\b(Unit|Bool|String|StringView|Bytes|I8|I16|I32|I64|U8|U16|U32|U64|F32|F64|Option|Result|Array|FixedArray)\\b",
      name: "support.type.builtin.dew",
    },
    {
      match: "\\b[A-Z][\\p{L}\\p{N}_]*\\b",
      name: "entity.name.type.dew",
    },
    {
      match: "@[\\p{L}_][\\p{L}\\p{N}_]*",
      name: "variable.other.namespace.dew",
    },
    {
      match: "(?<![.:])\\b[\\p{L}_][\\p{L}\\p{N}_]*(?=\\s*\\()",
      name: "entity.name.function.call.dew",
    },
    {
      match: "::|->|=>|\\.\\.\\.|\\*\\*|==|!=|<=|>=|<<|>>|&&|\\|\\||[+\\-*/%^=!&|<>]",
      name: "keyword.operator.dew",
    },
  ],
  repository: {
    comments: {
      patterns: [{ begin: "//", end: "$", name: "comment.line.double-slash.dew" }],
    },
    strings: {
      patterns: [
        {
          begin: "b?\"",
          beginCaptures: { 0: { name: "punctuation.definition.string.begin.dew" } },
          end: "\"",
          endCaptures: { 0: { name: "punctuation.definition.string.end.dew" } },
          name: "string.quoted.double.dew",
          patterns: [
            {
              match: "\\\\(?:[\\\\\"nrt0bf]|x[0-9A-Fa-f]{2})",
              name: "constant.character.escape.dew",
            },
          ],
        },
      ],
    },
    numbers: {
      patterns: [
        {
          match: "(?<![\\p{L}\\p{N}_])(?:\\d[\\d_]*\\.[\\d_]+(?:[eE][+-]?[\\d_]+)?(?:F|f32|f64)?|\\.\\d[\\d_]*(?:[eE][+-]?[\\d_]+)?(?:F|f32|f64)?|\\d[\\d_]*(?:i8|i16|i32|i64|u8|u16|u32|u64|U|L|UL)?)(?![\\p{L}\\p{N}_])",
          name: "constant.numeric.dew",
        },
      ],
    },
  },
};

const dewTheme: ThemeRegistrationRaw = {
  name: "dewdrop-night",
  type: "dark",
  colors: {
    "editor.background": "#090a0d",
    "editor.foreground": "#c7cbd3",
  },
  settings: [
    { settings: { foreground: "#c7cbd3", background: "#090a0d" } },
    { scope: ["comment"], settings: { foreground: "#777c86", fontStyle: "italic" } },
    { scope: ["keyword", "storage"], settings: { foreground: "#ff4f87" } },
    { scope: ["string"], settings: { foreground: "#27d6a8" } },
    { scope: ["constant.numeric", "constant.language"], settings: { foreground: "#e7b45c" } },
    { scope: ["entity.name.type", "support.type"], settings: { foreground: "#4b91ff" } },
    { scope: ["entity.name.function"], settings: { foreground: "#eef1f6" } },
    { scope: ["variable.other.namespace"], settings: { foreground: "#a78bfa" } },
    { scope: ["constant.character.escape"], settings: { foreground: "#78e6ca" } },
  ],
};

const highlighter = createHighlighter({
  themes: [dewTheme],
  langs: [dewLanguage, "wasm"],
});

export type CodeLanguage = "dew" | "wasm";

export async function highlightCode(
  code: string,
  language: CodeLanguage = "dew",
): Promise<string> {
  const instance = await highlighter;
  return instance.codeToHtml(code.trim(), {
    lang: language,
    theme: "dewdrop-night",
  });
}
