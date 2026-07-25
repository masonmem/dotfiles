from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "bin" / "dotfiles-sync"


class DotfilesSyncTest(unittest.TestCase):
    def test_brew_bundle_keeps_progress_and_errors_visible(self) -> None:
        invocation = next(
            line
            for line in SCRIPT.read_text().splitlines()
            if "brew bundle --no-upgrade" in line and not line.lstrip().startswith("#")
        )

        self.assertNotIn("/dev/null", invocation)


if __name__ == "__main__":
    unittest.main()
