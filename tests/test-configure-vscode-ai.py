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


if __name__ == "__main__":
    unittest.main()
