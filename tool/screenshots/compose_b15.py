"""Compose before/after screenshot comparisons for DS-B15 (Subscriptions in Stillwater Bloom)."""
import os
from PIL import Image, ImageDraw

def compose_shot(before_light, after_light, before_dark, after_dark, out_path, title=""):
    tiles = [
        ("light · before", Image.open(before_light).convert("RGB")),
        ("light · after", Image.open(after_light).convert("RGB")),
        ("dark · before", Image.open(before_dark).convert("RGB")),
        ("dark · after", Image.open(after_dark).convert("RGB")),
    ]
    w, h = tiles[0][1].size
    pad, head = 12, 28
    sheet = Image.new("RGB", (4 * w + 5 * pad, h + head + 2 * pad), (40, 40, 40))
    draw = ImageDraw.Draw(sheet)
    for i, (label, img) in enumerate(tiles):
        x = pad + i * (w + pad)
        draw.text((x, pad), label, fill=(235, 235, 235))
        sheet.paste(img, (x, pad + head))
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    sheet.save(out_path, optimize=True)
    print("Wrote", out_path)

def main():
    repo = os.getcwd()
    goldens = os.path.join(repo, "tool", "screenshots", "goldens")
    baseline = os.path.join(repo, "docs", "design-system", "screenshots", "ds-b15")
    out_dir = baseline

    # B15b: Add / edit sheet
    # B15c: Subscriptions list
    # B15d: Subscription detail
    scenarios = [
        ("b15_sheet_new", "compare_sheet_new.png"),
        ("b15_sheet_edit", "compare_sheet_edit.png"),
        ("b15_list_normal", "compare_list_normal.png"),
        ("b15_list_empty", "compare_list_empty.png"),
        ("b15_list_suggestions", "compare_list_suggestions.png"),
        ("b15_detail_active", "compare_detail_active.png"),
        ("b15_detail_paused", "compare_detail_paused.png"),
    ]

    for name, out_name in scenarios:
        bl = os.path.join(baseline, f"{name}_light.png")
        bd = os.path.join(baseline, f"{name}_dark.png")
        al = os.path.join(goldens, f"{name}_light.png")
        ad = os.path.join(goldens, f"{name}_dark.png")
        if os.path.exists(bl) and os.path.exists(al):
            compose_shot(bl, al, bd, ad, os.path.join(out_dir, out_name), title=name)

if __name__ == "__main__":
    main()
