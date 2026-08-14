"""Sphinx directive that converts box-drawing text to SVG with svgbob.

Usage in MyST:

    ```{svgbob}
    +-----+
    | box |
    +-----+
    ```

The svgbob CLI must be on PATH. Stroke color is currentColor, so
the SVG follows the theme text color.
"""

import subprocess

from docutils import nodes
from docutils.parsers.rst import Directive


class SvgbobDirective(Directive):
    has_content = True

    def run(self):
        source = "\n".join(self.content)
        result = subprocess.run(
            [
                "svgbob",
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
