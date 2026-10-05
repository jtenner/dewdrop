"""Focused command-line checks for the registry client."""

from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("bun"), "Bun is required for the registry client")
class DewRegistryCliTests(unittest.TestCase):
    def test_ipv6_loopback_allows_local_http(self):
        with tempfile.TemporaryDirectory(prefix="dew-registry-test-") as directory:
            process = subprocess.run(
                [
                    "bun",
                    "tools/dew-registry.mjs",
                    "whoami",
                    "--registry",
                    "http://[::1]",
                ],
                cwd=ROOT,
                env={**os.environ, "DEW_CONFIG_HOME": directory},
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=False,
            )
        self.assertEqual(process.returncode, 1)
        self.assertIn("not authenticated to http://[::1]", process.stderr)
        self.assertNotIn("registry must use HTTPS", process.stderr)


if __name__ == "__main__":
    unittest.main()
