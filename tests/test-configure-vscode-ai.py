from __future__ import annotations

import json
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "bin" / "configure-vscode-ai"


class ConfigureVSCodeAITest(unittest.TestCase):
    def test_enables_agent_skills_without_replacing_existing_settings(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            settings = Path(directory) / "settings.json"
            settings.write_text(
                json.dumps({"editor.fontSize": 15, "chat.useAgentSkills": False})
                + "\n"
            )

            subprocess.run(
                [str(SCRIPT), "--settings", str(settings)],
                check=True,
                capture_output=True,
                text=True,
            )

            configured = json.loads(settings.read_text())
            self.assertEqual(configured["editor.fontSize"], 15)
            self.assertIs(configured["chat.useAgentSkills"], True)

    def test_keeps_a_backup_when_comments_would_be_lost(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            settings = Path(directory) / "settings.json"
            original = '{\n  // font\n  "editor.fontSize": 15,\n}\n'
            settings.write_text(original)

            subprocess.run([str(SCRIPT), "--settings", str(settings)], check=True, capture_output=True)

            self.assertEqual(json.loads(settings.read_text())["editor.fontSize"], 15)
            self.assertEqual((Path(directory) / "settings.json.bak").read_text(), original)

    def test_no_change_means_no_rewrite(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            settings = Path(directory) / "settings.json"
            subprocess.run([str(SCRIPT), "--settings", str(settings)], check=True, capture_output=True)
            first = settings.read_text()
            result = subprocess.run(
                [str(SCRIPT), "--settings", str(settings)], check=True, capture_output=True, text=True
            )
            self.assertIn("already configured", result.stdout)
            self.assertEqual(settings.read_text(), first)
            self.assertFalse((Path(directory) / "settings.json.bak").exists())


if __name__ == "__main__":
    unittest.main()
