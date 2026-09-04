'use strict';
const path = require('node:path');
const { runTests } = require('@vscode/test-electron');
const root = path.resolve(__dirname, '..');
runTests({
  extensionDevelopmentPath: root,
  extensionTestsPath: path.join(__dirname, 'host-suite.js'),
  ...(process.env.VSCODE_EXECUTABLE_PATH ? { vscodeExecutablePath: process.env.VSCODE_EXECUTABLE_PATH } : {}),
  launchArgs: [`--user-data-dir=${path.join(root, '.vscode-test/user-data')}`, `--extensions-dir=${path.join(root, '.vscode-test/extensions')}`, '--disable-extensions', '--disable-gpu', '--no-sandbox', '--skip-welcome', '--skip-release-notes'],
}).catch(error => { console.error(error); process.exitCode = 1; });
