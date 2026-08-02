#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."
moon run --target native src/swar_parity_gen
node tools/swar-parity/parity.mjs
