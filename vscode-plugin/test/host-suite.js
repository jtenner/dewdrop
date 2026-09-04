'use strict';
const assert = require('node:assert/strict');
const vscode = require('vscode');

async function run() {
  const extension = vscode.extensions.getExtension('dewdrop.dewdrop');
  assert.ok(extension, 'Dew extension must be installed in the test host');
  await extension.activate();
  const document = await vscode.workspace.openTextDocument({ language: 'dew', content: 'fn greeting(person: String) -> Unit {}\nlet result = gre\n// gre\nlet text = "gre\n' });
  await vscode.window.showTextDocument(document);
  const result = await vscode.commands.executeCommand('vscode.executeCompletionItemProvider', document.uri, new vscode.Position(1, 16));
  const item = result.items.find(item => item.label === 'greeting');
  assert.ok(item, 'completion must include a name from the file');
  assert.equal(item.range.start.character, 13);
  assert.equal(item.range.end.character, 16);
  for (const position of [new vscode.Position(2, 6), new vscode.Position(3, 15)]) {
    const hidden = await vscode.commands.executeCommand('vscode.executeCompletionItemProvider', document.uri, position);
    assert.ok(!hidden.items.some(item => item.label === 'greeting'), 'no name completion inside comments or strings');
  }
  const file = await vscode.workspace.openTextDocument(vscode.Uri.file(require('node:path').join(__dirname, '../examples/highlighting.dew')));
  assert.equal(file.languageId, 'dew', '.dew files must select Dew automatically');
  console.log('Dew extension host checks passed.');
}
module.exports = { run };
