"""Sphinx directive that converts box-drawing text to SVG with svgbob.

Usage in MyST:

    ```{svgbob}
    +-----+
    | box |
    +-----+
    ```

The svgbob CLI must be on PATH. Stroke color is currentColor, so the SVG follows
the theme text color.
"""

import shutil
import subprocess

from docutils import nodes
from docutils.parsers.rst import Directive

# Readthedocs installs as 'svgbob_cli'; Nix installs as 'svgbob'
SVGBOB = shutil.which("svgbob_cli") or shutil.which("svgbob")


class SvgbobDirective(Directive):
    has_content = True

    def run(self):
        if SVGBOB is None:
            error = self.state_machine.reporter.error(
                "svgbob not found on PATH",
                line=self.lineno,
            )
            return [error]
        source = "\n".join(self.content)
        result = subprocess.run(
            [
                SVGBOB,
                "--background",
                "transparent",
                "--stroke-color",
                "currentColor",
            ],
            input=source,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            error = self.state_machine.reporter.error(
                f"svgbob failed: {result.stderr}",
                line=self.lineno,
            )
            return [error]
        return [nodes.raw("", result.stdout, format="html")]


def setup(app):
    app.add_directive("svgbob", SvgbobDirective)
    return {"parallel_read_safe": True, "parallel_write_safe": True}
