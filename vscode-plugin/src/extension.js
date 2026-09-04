'use strict';
const vscode = require('vscode');
const { complete, createCache, prefixAt, inText } = require('./completion');

function activate(context) {
  const cache = createCache();
  context.subscriptions.push(
    vscode.languages.registerCompletionItemProvider({ language: 'dew' }, {
      provideCompletionItems(document, position, token) {
        const line = document.lineAt(position.line).text.slice(0, position.character);
        if (token.isCancellationRequested || inText(line)) return [];
        const range = new vscode.Range(position.line, position.character - prefixAt(line).length, position.line, position.character);
        return complete(cache.get(document), line).map(entry => {
          const item = new vscode.CompletionItem(entry.label, vscode.CompletionItemKind[entry.kind]);
          item.detail = entry.detail;
          item.range = range;
          return item;
        });
      },
    }, '@'),
    vscode.workspace.onDidCloseTextDocument(document => cache.delete(document)),
    { dispose: () => cache.clear() },
  );
}

module.exports = { activate };
