"""
Render docs/SRS.md to docs/AgroMaster-SRS.pdf.

    pip install markdown
    python scripts/build-srs-pdf.py

Printing is done by headless Edge or Chrome, so there is no LaTeX,
pandoc or wkhtmltopdf dependency.
"""

import pathlib
import re
import subprocess
import sys

import markdown

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "docs" / "SRS.md"
PDF = ROOT / "docs" / "AgroMaster-SRS.pdf"
HTML = ROOT / "docs" / ".srs-print.html"   # intermediate, deleted on success

# Edge ships with Windows; Chrome works identically where it does not.
BROWSERS = [
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    "/usr/bin/microsoft-edge",
    "/usr/bin/google-chrome",
    "/usr/bin/chromium",
]
BROWSER = next((b for b in BROWSERS if pathlib.Path(b).exists()), None)
if BROWSER is None:
    sys.exit("No Edge or Chrome found - one is needed to render the PDF.")

text = SRC.read_text(encoding="utf-8")

# The markdown title block becomes a proper cover page rather than body text.
text = re.sub(r"^# Software Requirements Specification\s*\n+", "", text, count=1)
text = re.sub(r"^## AgroMaster.*?\n+", "", text, count=1, flags=re.S | re.M)

meta_rows = ""
cover_table = re.search(r"\| \|\s*\|\n\|[-|\s]+\|\n((?:\|.*\|\n)+)", text)
if cover_table:
    for line in cover_table.group(1).strip().split("\n"):
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) >= 2:
            label = cells[0].replace("**", "")
            meta_rows += f'<tr><td class="k">{label}</td><td class="v">{cells[1]}</td></tr>'
    text = text[: cover_table.start()] + text[cover_table.end():]
text = text.lstrip("\n-\n ")

body = markdown.markdown(
    text,
    extensions=["tables", "fenced_code", "attr_list", "sane_lists"],
)


def slugify(match):
    """Give headings ids so the table-of-contents links resolve."""
    level, title = match.group(1), match.group(2)
    slug = re.sub(r"[^a-z0-9\s-]", "", re.sub(r"<[^>]+>", "", title).lower())
    slug = re.sub(r"\s+", "-", slug.strip())
    return f'<h{level} id="{slug}">{title}</h{level}>'


body = re.sub(r"<h([1-6])>(.*?)</h\1>", slugify, body, flags=re.S)

html = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>AgroMaster SRS</title>
<style>
  @page {{ size: A4; margin: 18mm 16mm 20mm 16mm; }}

  :root {{
    --ink:      #14181f;
    --muted:    #5b6472;
    --faint:    #8a93a1;
    --rule:     #d8dee7;
    --accent:   #16803c;
    --accent-bg:#f1f8f3;
    --code-bg:  #f5f7f9;
  }}

  * {{ box-sizing: border-box; }}

  body {{
    font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
    font-size: 10.2pt;
    line-height: 1.62;
    color: var(--ink);
    margin: 0;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }}

  /* ---------- cover ---------- */
  .cover {{
    height: 247mm;
    display: flex;
    flex-direction: column;
    justify-content: center;
    page-break-after: always;
  }}
  .cover .mark {{ font-size: 34pt; line-height: 1; margin-bottom: 26px; }}
  .cover h1 {{
    font-size: 30pt; font-weight: 700; letter-spacing: -0.8px;
    margin: 0 0 6px; border: none; padding: 0; color: var(--ink);
  }}
  .cover .sub {{ font-size: 13pt; color: var(--accent); font-weight: 600; margin-bottom: 4px; }}
  .cover .tag {{ font-size: 10.5pt; color: var(--muted); margin-bottom: 34px; }}
  .cover .bar {{ width: 64px; height: 3px; background: var(--accent); margin-bottom: 34px; }}
  .cover table {{ width: auto; border: none; margin: 0; font-size: 10pt; }}
  .cover td {{ border: none; padding: 5px 30px 5px 0; }}
  .cover td.k {{
    color: var(--faint); text-transform: uppercase;
    letter-spacing: 0.6px; font-size: 8.4pt; font-weight: 600;
  }}
  .cover td.v {{ font-weight: 600; }}

  /* ---------- headings ---------- */
  h1, h2, h3, h4 {{ page-break-after: avoid; break-after: avoid; }}

  h1 {{
    font-size: 17pt; font-weight: 700; letter-spacing: -0.3px;
    margin: 0 0 16px; padding-bottom: 8px;
    border-bottom: 2px solid var(--accent);
    page-break-before: always;
  }}
  h1:first-of-type {{ page-break-before: avoid; }}

  h2 {{ font-size: 13pt; font-weight: 700; margin: 26px 0 10px; }}
  h3 {{ font-size: 11pt; font-weight: 700; margin: 20px 0 8px; color: var(--muted); }}

  p {{ margin: 0 0 10px; }}

  /* ---------- tables ---------- */
  table {{
    width: 100%; border-collapse: collapse;
    margin: 12px 0 18px; font-size: 9.2pt;
    page-break-inside: avoid;
  }}
  th {{
    background: var(--accent-bg); font-weight: 700; text-align: left;
    padding: 7px 10px; border: 1px solid var(--rule);
    font-size: 8.8pt; text-transform: uppercase; letter-spacing: 0.4px;
  }}
  td {{ padding: 6px 10px; border: 1px solid var(--rule); vertical-align: top; }}
  tr:nth-child(even) td {{ background: #fafbfc; }}

  /* ---------- code ---------- */
  pre {{
    background: var(--code-bg);
    border: 1px solid var(--rule);
    border-left: 3px solid var(--accent);
    border-radius: 3px; padding: 11px 13px;
    font-family: "Cascadia Mono", Consolas, monospace;
    font-size: 8.4pt; line-height: 1.5;
    page-break-inside: avoid;
    white-space: pre-wrap; word-wrap: break-word;
  }}
  code {{
    font-family: "Cascadia Mono", Consolas, monospace;
    font-size: 8.8pt; background: var(--code-bg);
    padding: 1px 4px; border-radius: 3px;
  }}
  pre code {{ background: none; padding: 0; font-size: inherit; }}

  /* ---------- misc ---------- */
  ul, ol {{ margin: 0 0 12px; padding-left: 20px; }}
  li {{ margin-bottom: 4px; }}

  blockquote {{
    border-left: 3px solid var(--accent);
    background: var(--accent-bg);
    margin: 12px 0; padding: 9px 14px; color: var(--muted);
  }}
  blockquote p {{ margin: 0; }}

  hr {{ border: none; border-top: 1px solid var(--rule); margin: 22px 0; }}

  a {{ color: var(--accent); text-decoration: none; }}
  strong {{ font-weight: 700; }}
  em {{ color: var(--muted); }}
</style></head>
<body>

<div class="cover">
  <div class="mark">&#127807;</div>
  <div class="sub">AgroMaster</div>
  <h1>Software Requirements Specification</h1>
  <div class="tag">Smart Farm Management Platform for Sri Lankan Farmers</div>
  <div class="bar"></div>
  <table>{meta_rows}</table>
</div>

{body}
</body></html>
"""

HTML.write_text(html, encoding="utf-8")

PDF.parent.mkdir(parents=True, exist_ok=True)
PDF.unlink(missing_ok=True)

result = subprocess.run(
    [
        BROWSER,
        "--headless",
        "--disable-gpu",
        "--no-sandbox",
        "--no-pdf-header-footer",
        f"--print-to-pdf={PDF}",
        HTML.as_uri(),
    ],
    capture_output=True,
    text=True,
    timeout=180,
)

if PDF.exists():
    HTML.unlink(missing_ok=True)
    print(f"PDF written: {PDF.relative_to(ROOT)}  ({PDF.stat().st_size:,} bytes)")
else:
    HTML.unlink(missing_ok=True)
    print("PDF generation failed.")
    print(result.stdout[-1500:])
    print(result.stderr[-1500:])
    sys.exit(1)
