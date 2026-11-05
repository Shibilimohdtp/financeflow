import json, sys

# Semantic roles per palette and mode. "Lichen" is today's palette with small fixes.
P = {
 "Lichen": {
  "blurb": "Current identity, refined. Lichen green, mushroom, mineral rose.",
  "light": dict(page="F5F4ED", card="FCFBF6", raised="FFFFFA", sunken="EEEDE4", tint="E9EDD9",
    text="23261E", text2="51564B", text3="676C60", border="DCDDD1", control="7B806F",
    primary="535B36", onPrimary="FCFCF5", primaryC="E3E8CB", onPrimaryC="282F16",
    accent="76546A", accentC="F1DFEA", onAccentC="422B3A",
    income="216843", incomeC="DDEDDD", expense="9F3D50", expenseC="F5DFE3",
    transfer="536474", transferC="E3E9EF", savings="326A70", savingsC="DDEDEE",
    debt="80523E", debtC="F0E3D9", investment="55569A", investmentC="E5E4F6",
    warning="795B12", warningC="F3E8C7", info="385F82", infoC="DFEAF5", error="AD3529", errorC="F9E0DA",
    inverse="2A2E24", onInverse="F1F3E8", inverseAction="C4CC9B"),
  "dark": dict(page="151812", card="1C2019", raised="262A21", sunken="11140F", tint="343D26",
    text="E8EBDF", text2="C0C5B6", text3="A3A997", border="353B2F", control="838B77",
    primary="C4CC9B", onPrimary="292F18", primaryC="3E4728", onPrimaryC="E6EBCF",
    accent="DFB6CD", accentC="533849", onAccentC="F7DEEC",
    income="8CD7A5", incomeC="243D2B", expense="F0A6B7", expenseC="472832",
    transfer="B4C5D7", transferC="303B48", savings="91CED1", savingsC="253D40",
    debt="DEB39A", debtC="443327", investment="BEC0F1", investmentC="32334F",
    warning="E8CA7C", warningC="43381B", info="A8CDEF", infoC="273B4D", error="FFA99A", errorC="502B24",
    inverse="E8EBDF", onInverse="1C2019", inverseAction="535B36"),
 },
 "Tide": {
  "blurb": "The original Stillwater spec: deep-water teal, shore sand, marigold.",
  "light": dict(page="F7F5EF", card="FDFDFB", raised="FFFFFF", sunken="F0EEE6", tint="E7F3F0",
    text="1B2422", text2="4A5753", text3="5E6B66", border="E1DFD5", control="7E8984",
    primary="0E5F55", onPrimary="FFFFFF", primaryC="D3EDE6", onPrimaryC="07423B",
    accent="8A5810", accentC="FAE3BC", onAccentC="5A3A06",
    income="177A50", incomeC="D7EFE0", expense="A8482A", expenseC="F7E2D8",
    transfer="56696F", transferC="E1E8EA", savings="0E6E61", savingsC="D5ECE7",
    debt="6D4A78", debtC="EDE2F0", investment="4756A6", investmentC="E2E5F5",
    warning="855B00", warningC="F8ECC8", info="3E6278", infoC="DCE8EF", error="B8361F", errorC="FBDFD8",
    inverse="142B27", onInverse="EEF4F1", inverseAction="7AD8C6"),
  "dark": dict(page="0B1412", card="111C1A", raised="1A2926", sunken="08100E", tint="12332E",
    text="E6EDE8", text2="B3C1BA", text3="8E9D96", border="22322E", control="6E7F78",
    primary="7AD8C6", onPrimary="063B33", primaryC="0F4A42", onPrimaryC="C9F2E8",
    accent="E9B366", accentC="3B2C10", onAccentC="FBE3BC",
    income="6FD39B", incomeC="143324", expense="E59276", expenseC="3A1F14",
    transfer="A4BAC2", transferC="1E2C31", savings="62CBB5", savingsC="0F332D",
    debt="C79BD4", debtC="2E2234", investment="A3B0EE", investmentC="20264A",
    warning="E5C069", warningC="362A0C", info="9CC0D6", infoC="14252E", error="F2866F", errorC="41160B",
    inverse="E6EDE8", onInverse="111C1A", inverseAction="0E5F55"),
 },
 "Sandstone": {
  "blurb": "Warm sand and fired terracotta, with a slate-blue accent.",
  "light": dict(page="F6F0E7", card="FCF9F4", raised="FFFFFF", sunken="EFE7DB", tint="F6E4DA",
    text="2B231D", text2="5B4F46", text3="6E6258", border="E6DCCF", control="8A7C70",
    primary="984527", onPrimary="FFFFFF", primaryC="F6DDD0", onPrimaryC="4A1F0E",
    accent="3F5F70", accentC="DDE8EE", onAccentC="1D3340",
    income="2F6B3A", incomeC="DCEBDA", expense="A3324A", expenseC="F6DDE2",
    transfer="58656F", transferC="E3E7EA", savings="1F6A6E", savingsC="D7EBEB",
    debt="74507A", debtC="EEE2EF", investment="4B57A0", investmentC="E3E5F5",
    warning="7A5A0E", warningC="F4E7C3", info="3B6180", infoC="DEE9F2", error="B0301F", errorC="FADDD5",
    inverse="2E2520", onInverse="F7EEE6", inverseAction="F0AE90"),
  "dark": dict(page="17120F", card="201A16", raised="2B231E", sunken="120E0B", tint="3A2519",
    text="F1E8E0", text2="CFC1B5", text3="AA9C90", border="3A302A", control="85766A",
    primary="F0AE90", onPrimary="4A1F0E", primaryC="6B3420", onPrimaryC="FFDCCD",
    accent="A9C8D8", accentC="2A4250", onAccentC="DCEBF3",
    income="8FD49A", incomeC="22371F", expense="F4A3B4", expenseC="4A2530",
    transfer="B4C2CE", transferC="2E363D", savings="8FD0D2", savingsC="1F3A3B",
    debt="DDB3E0", debtC="3D2A40", investment="BAC1F2", investmentC="2E3352",
    warning="E8C978", warningC="403416", info="A6CBEB", infoC="263A4A", error="FFA593", errorC="52241A",
    inverse="F1E8E0", onInverse="201A16", inverseAction="984527"),
 },
 "Graphite": {
  "blurb": "Quiet monochrome for people who want only the numbers in colour.",
  "light": dict(page="F2F3F4", card="FFFFFF", raised="FFFFFF", sunken="EBEDEF", tint="E4E7EA",
    text="16191C", text2="474D55", text3="5D646C", border="E0E3E6", control="858C94",
    primary="2B3036", onPrimary="FFFFFF", primaryC="E1E4E8", onPrimaryC="15191D",
    accent="4F5B6B", accentC="E3E7ED", onAccentC="222A35",
    income="1E6B45", incomeC="DBEDE2", expense="B02A3A", expenseC="F8DEE1",
    transfer="55616D", transferC="E3E7EB", savings="19676F", savingsC="D7EBED",
    debt="7A4B2E", debtC="F1E4DA", investment="4A4FA8", investmentC="E3E4F6",
    warning="7A5A00", warningC="F5EAC6", info="35607F", infoC="DDE8F1", error="B3261E", errorC="F9DEDB",
    inverse="22262B", onInverse="F1F3F5", inverseAction="C9D0D8"),
  "dark": dict(page="0F1012", card="18191C", raised="222428", sunken="0B0C0D", tint="2B2E33",
    text="ECEEF0", text2="B8BDC3", text3="959BA2", border="2C2F33", control="6E747B",
    primary="E6E8EB", onPrimary="16181B", primaryC="383B40", onPrimaryC="EEF0F2",
    accent="B9C3D0", accentC="333A44", onAccentC="E3E8EF",
    income="7FD3A0", incomeC="1B3326", expense="FF9AA6", expenseC="47222A",
    transfer="AFBCC8", transferC="2A3138", savings="86CFD6", savingsC="1B3538",
    debt="E2B395", debtC="3E2E24", investment="B7BCF5", investmentC="2C2F52",
    warning="EAC76E", warningC="3D3214", info="A2C8E8", infoC="223645", error="FFA096", errorC="4E201B",
    inverse="ECEEF0", onInverse="18191C", inverseAction="2B3036"),
 },
}

# One shared set of money colours for every palette, so income always looks
# like income. Income is cool green and expense warm brick: that pair stays
# apart under red-green colour blindness. Other money types rely on icon + label.
MONEY = {
 "light": dict(income="17694F", incomeC="D9EEE5", expense="A8432B", expenseC="F8E2D9",
               transfer="5B6570", transferC="E4E7EB", savings="1F6E7A", savingsC="D9ECEF",
               debt="74507A", debtC="EEE3EF", investment="4A55A3", investmentC="E3E5F5"),
 "dark": dict(income="86D6A9", incomeC="1E3A2C", expense="F7A285", expenseC="4A2A1F",
              transfer="B4C1CE", transferC="2C343D", savings="7FCFE0", savingsC="1C3940",
              debt="D9B0DC", debtC="3B2B3E", investment="B6BEF4", investmentC="2C3152"),
}
# Sandstone's brand is terracotta, so its expense moves to raspberry to stay
# distinct from the primary button, and income moves to olive so the pair
# still separates for red-green colour blindness.
SANDSTONE_EXPENSE = {"light": dict(income="3D6B22", incomeC="E3EDD7", expense="9E2C5E", expenseC="F7DDE8"),
                     "dark": dict(income="A6D47E", incomeC="2A3A1C", expense="F6A0BC", expenseC="4A2333")}
for _n, _p in P.items():
    for _m in ("light", "dark"):
        _p[_m].update(MONEY[_m])
        if _n == "Sandstone":
            _p[_m].update(SANDSTONE_EXPENSE[_m])
P["Tide"]["light"]["incomeC"] = "D9EEE5"

# Pure-black dark modifier, applied over any palette's dark mode.
OLED = dict(page="000000", card="0D0E0D", raised="171916", sunken="000000")

def lum(h):
    r, g, b = (int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
    f = lambda c: c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)

def cr(a, b):
    la, lb = sorted((lum(a), lum(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)

# Pairs: (fg, bg, minimum, label)
TEXT = 4.5; UI = 3.0
def pairs(m):
    out = []
    for bg in ("page", "card", "raised"):
        out += [("text", bg, TEXT, "Primary text"), ("text2", bg, TEXT, "Secondary text"),
                ("text3", bg, TEXT, "Tertiary text"), ("primary", bg, TEXT, "Primary as text/link"),
                ("accent", bg, TEXT, "Accent text")]
        for f in ("income", "expense", "transfer", "savings", "debt", "investment",
                  "warning", "info", "error"):
            out.append((f, bg, TEXT, f.capitalize() + " text"))
    out += [("control", "card", UI, "Control border (inputs, chips)"),
            ("control", "page", UI, "Control border on page"),
            ("primary", "card", UI, "Focus ring"),
            ("onPrimary", "primary", TEXT, "Text on primary button"),
            ("onPrimaryC", "primaryC", TEXT, "Text on primary container"),
            ("onAccentC", "accentC", TEXT, "Text on accent container"),
            ("text", "tint", TEXT, "Text on selected tint"),
            ("primary", "tint", TEXT, "Primary on selected tint"),
            ("onInverse", "inverse", TEXT, "Snackbar text"),
            ("inverseAction", "inverse", TEXT, "Snackbar action")]
    for f in ("income", "expense", "transfer", "savings", "debt", "investment",
              "warning", "info", "error"):
        out.append((f, f + "C", TEXT, f.capitalize() + " on its container"))
    return out

# Colour-vision simulation (Machado 2009, severity 1.0) in linear RGB.
CVD = {
 "deuteranopia": [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.011820, 0.042940, 0.968881]],
 "protanopia": [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]],
 "tritanopia": [[1.255528, -0.076749, -0.178779], [-0.078411, 0.930809, 0.147602], [0.004733, 0.691367, 0.303900]],
}
def lin(h):
    f = lambda c: c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    return [f(int(h[i:i+2], 16) / 255) for i in (0, 2, 4)]
def to_lab(rgb):
    x = 0.4124*rgb[0] + 0.3576*rgb[1] + 0.1805*rgb[2]
    y = 0.2126*rgb[0] + 0.7152*rgb[1] + 0.0722*rgb[2]
    z = 0.0193*rgb[0] + 0.1192*rgb[1] + 0.9505*rgb[2]
    def g(t): return t ** (1/3) if t > 216/24389 else (24389/27*t + 16) / 116
    fx, fy, fz = g(x/0.95047), g(y), g(z/1.08883)
    return (116*fy - 16, 500*(fx-fy), 200*(fy-fz))
def de(a, b):
    return sum((p - q) ** 2 for p, q in zip(a, b)) ** 0.5
def sim(h, m):
    c = lin(h)
    return [max(0, min(1, sum(m[i][j]*c[j] for j in range(3)))) for i in range(3)]
FIN = ("income", "expense", "transfer", "savings", "debt", "investment")

results = {}
failures = []
for name, p in P.items():
    results[name] = {}
    modes = [("light", p["light"]), ("dark", p["dark"])]
    if name == "Lichen":
        modes.append(("oled", {**p["dark"], **OLED}))
    for mode, m in modes:
        rows = []
        for fg, bg, mn, label in pairs(m):
            r = cr(m[fg], m[bg])
            rows.append(dict(fg=fg, bg=bg, label=label, ratio=round(r, 2), min=mn, ok=r >= mn))
            if r < mn:
                failures.append(f"{name}/{mode}: {label} {fg}#{m[fg]} on {bg}#{m[bg]} = {r:.2f} < {mn}")
        cvd = {}
        for kind, mat in CVD.items():
            worst = None
            for i, a in enumerate(FIN):
                for b in FIN[i+1:]:
                    d = de(to_lab(sim(m[a], mat)), to_lab(sim(m[b], mat)))
                    if worst is None or d < worst[0]:
                        worst = (round(d, 1), a, b)
            ie = round(de(to_lab(sim(m["income"], mat)), to_lab(sim(m["expense"], mat))), 1)
            cvd[kind] = dict(closest=worst, incomeVsExpense=ie)
        results[name][mode] = dict(colors=m, rows=rows, cvd=cvd)

json.dump(dict(palettes=P, results=results, oled=OLED), open(sys.argv[1], "w"), indent=1)
print("FAILURES:", len(failures))
for f in failures:
    print(" ", f)
for name in results:
    for mode, r in results[name].items():
        t3 = min(x["ratio"] for x in r["rows"] if x["fg"] == "text3")
        print(f"{name:10} {mode:5} min tertiary {t3:.2f}  CVD:",
              {k: (v["closest"], v["incomeVsExpense"]) for k, v in r["cvd"].items()})
