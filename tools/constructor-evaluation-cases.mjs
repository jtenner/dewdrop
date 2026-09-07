import assert from "node:assert/strict";

export function checkConstructorEvaluations(main) {
  for (let test = 0; test < 9; test++) {
    assert.equal(main(test), 1, `constructor evaluation case ${test}`);
  }
  return 9;
}
