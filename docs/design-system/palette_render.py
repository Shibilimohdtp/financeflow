import json, sys, html

data = json.load(open(sys.argv[1]))
P, R = data["palettes"], data["results"]

def mock(c, mode_label):
    v = lambda k: "#" + c[k]
    rows = [("Salary", "Income", "+", "₹82,000", "income", "&#8595;"),
            ("Groceries", "Food", "−", "₹2,340", "expense", "&#8593;"),
            ("To savings", "Transfer", "", "₹10,000", "transfer", "&#8644;"),
            ("Home loan EMI", "Loan", "−", "₹18,450", "debt", "&#8593;")]
    rws = "".join(
        f'<div class="mrow"><span class="mic" style="background:{v(k+"C")};color:{v(k)}">{ic}</span>'
        f'<span class="mtx"><b style="color:{v("text")}">{t}</b><small style="color:{v("text3")}">{s}</small></span>'
        f'<span class="mamt" style="color:{v(k)}">{sign}{a}</span></div>'
        for t, s, sign, a, k, ic in rows)
    return f'''<div class="phone" style="background:{v("page")};color:{v("text")}">
  <div class="mtop"><span style="color:{v("text2")}">{mode_label}</span><span class="mchip" style="border-color:{v("control")};color:{v("text2")}">This month</span></div>
  <div class="mcard" style="background:{v("card")};border-color:{v("border")}">
    <small style="color:{v("text2")}">Spent this month</small>
    <div class="mbig">₹48,210</div>
    <div class="mpair"><span style="color:{v("income")}">+ ₹82,000 in</span><span style="color:{v("expense")}">− ₹48,210 out</span></div>
    <div class="mbar" style="background:{v("sunken")}"><i style="background:{v("primary")};width:58%"></i></div>
  </div>
  <div class="mcard mlist" style="background:{v("card")};border-color:{v("border")}">{rws}</div>
  <div class="mbtns"><span class="mbtn" style="background:{v("primary")};color:{v("onPrimary")}">Add transaction</span>
  <span class="mbtn ghost" style="background:{v("primaryC")};color:{v("onPrimaryC")}">Filter</span></div>
  <div class="msnack" style="background:{v("inverse")};color:{v("onInverse")}">2 deleted <b style="color:{v("inverseAction")}">UNDO</b></div>
</div>'''

SW = [("page", "Page"), ("card", "Card"), ("sunken", "Sunken"), ("text", "Text"), ("text2", "Text 2"),
      ("text3", "Text 3"), ("control", "Control border"), ("primary", "Primary"), ("primaryC", "Primary container"),
      ("accent", "Accent"), ("income", "Income"), ("expense", "Expense"), ("transfer", "Transfer"),
      ("savings", "Savings"), ("debt", "Debt"), ("investment", "Investment"), ("warning", "Warning"),
      ("error", "Error")]

def swatches(c):
    return "".join(f'<li><i style="background:#{c[k]}"></i><span>{n}</span><code>#{c[k]}</code></li>' for k, n in SW)

def checks(r):
    # Worst ratio per label across page/card/raised backgrounds.
    worst = {}
    for row in r["rows"]:
        w = worst.get(row["label"])
        if w is None or row["ratio"] < w["ratio"]:
            worst[row["label"]] = row
    trs = "".join(
        f'<tr><td>{html.escape(l)}</td><td class="num">{w["ratio"]:.2f}</td><td class="num">{w["min"]:.1f}</td>'
        f'<td><span class="pill {"ok" if w["ok"] else "bad"}">{"Pass" if w["ok"] else "Fail"}</span></td></tr>'
        for l, w in worst.items())
    cv = r["cvd"]
    cvd = "".join(f'<tr><td>{k.capitalize()}</td><td class="num">{v["incomeVsExpense"]}</td>'
                  f'<td>{v["closest"][1]} / {v["closest"][2]} ({v["closest"][0]})</td></tr>' for k, v in cv.items())
    return trs, cvd

sections = []
for name, p in P.items():
    modes = [("light", "Light"), ("dark", "Dark")] + ([("oled", "Pure black")] if name == "Lichen" else [])
    panels, details = [], []
    for key, label in modes:
        r = R[name][key]
        c = r["colors"]
        trs, cvd = checks(r)
        panels.append(f'<figure class="panel">{mock(c, label)}<ul class="sw">{swatches(c)}</ul></figure>')
        details.append(f'''<details><summary>{label}: {sum(1 for x in r["rows"] if x["ok"])}/{len(r["rows"])} contrast checks pass</summary>
<div class="tw"><table><thead><tr><th>Pair (worst background)</th><th class="num">Ratio</th><th class="num">Needs</th><th></th></tr></thead><tbody>{trs}</tbody></table></div>
<div class="tw"><table><thead><tr><th>Colour vision</th><th class="num">Income vs expense ΔE</th><th>Closest money pair (ΔE)</th></tr></thead><tbody>{cvd}</tbody></table></div></details>''')
    badge = '<span class="tag">Default</span>' if name == "Lichen" else ""
    sections.append(f'''<section class="pal" id="{name.lower()}">
<header><h2>{name} {badge}</h2><p>{html.escape(p["blurb"])}</p></header>
<div class="panels">{"".join(panels)}</div>
<div class="checks">{"".join(details)}</div></section>''')

page = f'''<title>FinanceFlow Palettes</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,600&family=Manrope:wght@400;600;700;800&display=swap">
<style>
/* Layout: one column of palettes; each shows light/dark phone mocks side by side with their swatches, contrast tables folded below. */
:root {{
  --bg:#F3F2EC; --surface:#FBFAF6; --fg:#23261E; --muted:#5A5E53; --line:#DCDBD0; --accent:#535B36;
  --ok:#1E6B45; --okbg:#DCEDE2; --bad:#A8432B; --badbg:#F8E2D9;
  --display:"Fraunces", Georgia, serif; --body:"Manrope", "Segoe UI", system-ui, sans-serif;
}}
@media (prefers-color-scheme: dark) {{ :root:not([data-theme="light"]) {{
  --bg:#121410; --surface:#1A1D17; --fg:#E8EBDF; --muted:#AEB3A4; --line:#30352A; --accent:#C4CC9B;
  --ok:#86D6A9; --okbg:#1E3A2C; --bad:#F7A285; --badbg:#4A2A1F; color-scheme:dark }} }}
:root[data-theme="dark"] {{
  --bg:#121410; --surface:#1A1D17; --fg:#E8EBDF; --muted:#AEB3A4; --line:#30352A; --accent:#C4CC9B;
  --ok:#86D6A9; --okbg:#1E3A2C; --bad:#F7A285; --badbg:#4A2A1F; color-scheme:dark }}
body {{ background:var(--bg); color:var(--fg); font-family:var(--body); line-height:1.5;
  padding-left:max(16px, env(safe-area-inset-left, 0px)); padding-right:max(16px, env(safe-area-inset-right, 0px)); }}
main {{ max-width:1180px; margin:0 auto; padding-block:40px 64px; display:grid; gap:48px; }}
h1 {{ font-family:var(--display); font-weight:600; font-size:clamp(28px, 4vw, 40px); margin:0; text-wrap:balance; }}
.intro p {{ max-width:68ch; color:var(--muted); margin:10px 0 0; }}
.intro ul {{ margin:14px 0 0; padding-left:20px; max-width:72ch; color:var(--muted); }}
.pal {{ display:grid; gap:18px; border-top:1px solid var(--line); padding-top:28px; }}
.pal h2 {{ font-family:var(--display); font-weight:600; font-size:26px; margin:0; display:flex; align-items:center; gap:10px; }}
.pal header p {{ margin:4px 0 0; color:var(--muted); }}
.tag {{ font-family:var(--body); font-size:11px; letter-spacing:.08em; text-transform:uppercase; border:1px solid var(--accent); color:var(--accent); border-radius:999px; padding:2px 9px; }}
.panels {{ display:grid; grid-template-columns:repeat(auto-fit, minmax(320px, 1fr)); gap:20px; }}
.panel {{ margin:0; display:grid; grid-template-columns:minmax(0, 1fr) 150px; gap:14px; background:var(--surface); border:1px solid var(--line); border-radius:14px; padding:14px; min-width:0; }}
.phone {{ border-radius:18px; padding:14px; display:grid; gap:10px; font-size:13px; min-width:0; }}
.mtop {{ display:flex; justify-content:space-between; align-items:center; font-weight:600; }}
.mchip {{ border:1px solid; border-radius:999px; padding:3px 10px; font-size:12px; }}
.mcard {{ border:1px solid; border-radius:14px; padding:12px; display:grid; gap:4px; }}
.mbig {{ font-size:26px; font-weight:800; letter-spacing:-.5px; font-variant-numeric:tabular-nums; }}
.mpair {{ display:flex; justify-content:space-between; gap:8px; font-weight:600; font-size:12px; font-variant-numeric:tabular-nums; flex-wrap:wrap; }}
.mbar {{ height:6px; border-radius:6px; overflow:hidden; margin-top:6px; }} .mbar i {{ display:block; height:100%; border-radius:6px; }}
.mlist {{ gap:10px; }}
.mrow {{ display:grid; grid-template-columns:30px minmax(0, 1fr) auto; gap:10px; align-items:center; }}
.mic {{ width:30px; height:30px; border-radius:9px; display:grid; place-items:center; font-weight:700; }}
.mtx {{ display:grid; min-width:0; }} .mtx b {{ font-weight:600; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }} .mtx small {{ font-size:11px; }}
.mamt {{ font-weight:700; font-variant-numeric:tabular-nums; }}
.mbtns {{ display:flex; gap:8px; }} .mbtn {{ flex:1; text-align:center; border-radius:12px; padding:10px 8px; font-weight:700; }}
.msnack {{ border-radius:10px; padding:9px 12px; display:flex; justify-content:space-between; }}
.sw {{ list-style:none; margin:0; padding:0; display:grid; gap:5px; font-size:11.5px; align-content:start; }}
.sw li {{ display:grid; grid-template-columns:16px minmax(0, 1fr); column-gap:7px; align-items:center; }}
.sw i {{ width:16px; height:16px; border-radius:4px; border:1px solid var(--line); grid-row:span 2; }}
.sw span {{ color:var(--fg); line-height:1.15; }} .sw code {{ color:var(--muted); font-size:10.5px; line-height:1.15; }}
details {{ background:var(--surface); border:1px solid var(--line); border-radius:12px; padding:10px 14px; }}
details + details {{ margin-top:8px; }}
summary {{ cursor:pointer; font-weight:600; }} summary:focus-visible {{ outline:2px solid var(--accent); outline-offset:3px; border-radius:4px; }}
.tw {{ overflow-x:auto; margin-top:10px; }}
table {{ border-collapse:collapse; width:100%; font-size:13px; }}
th, td {{ text-align:left; padding:5px 8px; border-bottom:1px solid var(--line); }} th {{ color:var(--muted); font-weight:600; }}
.num {{ text-align:right; font-variant-numeric:tabular-nums; }}
.pill {{ font-size:11px; font-weight:700; border-radius:999px; padding:1px 8px; }} .ok {{ color:var(--ok); background:var(--okbg); }} .bad {{ color:var(--bad); background:var(--badbg); }}
@media (max-width:520px) {{ .panel {{ grid-template-columns:1fr; }} .sw {{ grid-template-columns:repeat(2, minmax(0, 1fr)); }} }}
</style>
<main>
<div class="intro">
<h1>FinanceFlow palettes</h1>
<p>Proposed colour themes for the Stillwater design system, each shown on a sample Home card in light and dark. Every number below was computed from these exact colours: WCAG contrast for text (needs 4.5:1) and control borders/focus (needs 3:1), and a colour-blindness simulation for the money colours.</p>
<ul>
<li>Money colours are shared across palettes so income always looks like income. Sandstone is the one exception, explained in its own section.</li>
<li>Income vs expense is the only money pair that must survive colour blindness on colour alone (target ΔE ≥ 10). Transfer, savings, debt and investment always carry an icon and a label as well.</li>
<li>Lichen's expense colour moves from raspberry to brick. The old pair scored ΔE 5.8 for deuteranopia, which reads as nearly the same colour.</li>
</ul>
</div>
{"".join(sections)}
</main>'''
open(sys.argv[2], "w", encoding="utf-8").write(page)
print("ok", len(page))
