"""An emitter cannot infer trait identity from method spelling or link order."""

import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class TraitCallPolicyTests(unittest.TestCase):
    def test_emitter_does_not_recover_missing_trait_targets(self):
        source = (ROOT / "self_host/compiler/starshine_module.dew").read_text()
        self.assertTrue("self_host_linked_trait_call_index(" not in source,
                        "missing trait targets must not select a same-named implementation")


if __name__ == "__main__":
    unittest.main()
