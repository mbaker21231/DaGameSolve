import re
import nbformat
from pathlib import Path

source = Path("dagamesolve_description.ipynb")
output = Path("dagamesolve_paper.ipynb")

nb = nbformat.read(source, as_version=4)

# ------------------------------------------------------------
# Paper metadata
# ------------------------------------------------------------

nb.metadata["title"] = (
    "dagamesolve: A Package for Finding All Nash Equilibria "
    "in Sequences of Discrete-Action Games in Stata"
)

# LaTeX's \maketitle centers the title and author automatically.
# Include the affiliation immediately beneath the author's name.
nb.metadata["authors"] = [
    {
        "name": (
            r"Matthew J. Baker\\[0.25em]"
            r"\small Hunter College and the Graduate Center, CUNY"
        )
    }
]

nb.metadata["date"] = "Draft: October 2026"

# ------------------------------------------------------------
# Remove the old visible title/author block from the first cell.
# Keep the abstract, but make it unnumbered.
# ------------------------------------------------------------

first = nb.cells[0]

if first.cell_type == "markdown":
    match = re.search(r"^## Abstract\s*$", first.source, flags=re.MULTILINE)

    if match:
        abstract_text = first.source[match.end():].lstrip()
        first.source = "**Abstract.**  \n" + abstract_text

# ------------------------------------------------------------
# Clean section headings.
#
# Original notebook:
#     ## 3. Finite discrete-action games
#     ### 3.1 A two-action illustration of existence
#
# Paper notebook:
#     # Finite discrete-action games
#     ## A two-action illustration of existence
#
# LaTeX will supply the numbering automatically.
# ------------------------------------------------------------

heading_pattern = re.compile(
    r"^(#{2,6})\s+(?:\d+(?:\.\d+)*\.?\s+)?(.*)$"
)

for cell in nb.cells:

    if cell.cell_type != "markdown":
        continue

    new_lines = []

    for line in cell.source.splitlines():

        match = heading_pattern.match(line)

        if match:
            hashes = match.group(1)
            heading = match.group(2).strip()

            # Promote headings one level because the old Markdown H1 title
            # has been removed.
            new_hashes = "#" * (len(hashes) - 1)

            # These should appear as unnumbered paper sections.
            if heading in {
                "Digression on Complete Solution of Nonlinear Polynomial Systems",
                "References",
                "Appendix A: Installation and software environment",
            }:
                line = f"{new_hashes} {heading} {{.unnumbered}}"
            else:
                line = f"{new_hashes} {heading}"

        new_lines.append(line)

    cell.source = "\n".join(new_lines)

# ------------------------------------------------------------
# Write paper version
# ------------------------------------------------------------

nbformat.write(nb, output)

print(f"Created {output}")