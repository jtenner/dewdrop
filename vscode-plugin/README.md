# Dewdrop for VS Code

This extension adds support for `.dew` files. It runs without the Dew compiler.

- Colors keywords, types, calls, numbers, comments, strings, byte strings, and `@` names.
- Supports `#|` text lines and string escapes.
- Adds bracket pairs, line comments, and two-space indentation.
- Offers keywords, built-in types, and names from the current file as you type. Use **Ctrl+Space** to show the list.
- Adds 17 snippets. Type `fn`, `pubfn`, `struct`, `enum`, `trait`, `impl`, `implfor`, `test`, `match`, `if`, `ifelse`, `open`, `import`, `let`, `letmut`, `using`, or `defer`. Select the snippet, then press **Tab** to move between fields.

## Install

From the repository root, with Node.js 22 or later and npm installed:

```sh
npm ci --prefix vscode-plugin
npm test --prefix vscode-plugin
npm run package --prefix vscode-plugin
code --install-extension vscode-plugin/dewdrop-1.0.0.vsix
```

Reload the VS Code window, then open a `.dew` file. The language in the status bar must be **Dew**. You can also install the VSIX with **Extensions: Install from VSIX** in the Command Palette.

The extension requires VS Code 1.85 or later. Node.js and npm are only needed to build and test the extension. The installed extension has no runtime package dependencies.

## Try it without installation

Open `vscode-plugin` as a folder in VS Code. Press **F5** and select **Run Dew extension**. A separate window opens with `examples/highlighting.dew`. This sample is for editor checks; its sample import does not refer to a real module.

## Completion limits

Name completion reads the current file. It does not check scope, types, imports, fields, or function arguments. A name can be offered outside its valid scope. This is a starting point for later compiler or language server support. No compiler command runs, and no workspace scan or network request is made by the extension.

Comments and strings are excluded from name suggestions. A changed file is read at its next completion request. Results are cached until its version changes and released when the file closes. Built-in word suggestions are off for Dew to avoid duplicate names and words from comments. You can change `editor.wordBasedSuggestions` in your own `[dew]` settings.

## Test and maintain

```sh
npm test --prefix vscode-plugin
npm run test:host --prefix vscode-plugin
```

The first command tests completion and uses VS Code's TextMate engine to test token colors. The second opens a separate test instance of VS Code and checks extension activation, file detection, completion ranges, and comment/string exclusions. It downloads VS Code on first use. Its profile and extensions are isolated under `vscode-plugin/.vscode-test`.

To use an existing VS Code executable on Linux:

```sh
VSCODE_EXECUTABLE_PATH=/usr/share/code/code npm run test:host --prefix vscode-plugin
```

For a Linux machine without a display, run the host command through `xvfb-run -a`.

- `syntaxes/dew.tmLanguage.json`: token colors.
- `language-configuration.json`: editor pairs, comments, and indentation.
- `snippets/dew.json`: snippets with tab stops.
- `src/completion.js`: completion data and cache, independent of VS Code.
- `src/extension.js`: VS Code provider registration.

Check language changes against `../src/tokenizer/tokens.mbt`, `../src/tokenizer/lexer.mbt`, and `../docs/spec.md`. Block comments are not part of the current tokenizer. Completion and color rules must not treat them as comments.

VS Code uses [TextMate grammars](https://code.visualstudio.com/api/language-extensions/syntax-highlight-guide) for token colors and a [completion provider](https://code.visualstudio.com/api/language-extensions/programmatic-language-features#show-code-completion-proposals) for suggestions.
