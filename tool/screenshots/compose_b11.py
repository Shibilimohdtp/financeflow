"""Compose before/after screenshot comparisons for DS-B11 (Add/Edit Account Sheet in Stillwater Bloom)."""
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
    out_dir = os.path.join(repo, "docs", "design-system", "screenshots", "ds-b11")

    base_add_light = os.path.join(goldens, "b11_add_account_empty_light.png")
    base_add_dark = os.path.join(goldens, "b11_add_account_empty_dark.png")
    base_edit_light = os.path.join(goldens, "b11_edit_account_light.png")
    base_edit_dark = os.path.join(goldens, "b11_edit_account_dark.png")

    scenarios = [
        ("b11_sheet_empty", base_add_light, base_add_dark),
        ("b11_sheet_bank", base_add_light, base_add_dark),
        ("b11_sheet_card", base_add_light, base_add_dark),
        ("b11_sheet_upi", base_add_light, base_add_dark),
        ("b11_sheet_cash", base_add_light, base_add_dark),
        ("b11_sheet_error", base_add_light, base_add_dark),
        ("b11_sheet_duplicate", base_add_light, base_add_dark),
        ("b11_sheet_edit", base_edit_light, base_edit_dark),
        ("b11_sheet_keyboard", base_add_light, base_add_dark),
        ("b11_sheet_2x", base_add_light, base_add_dark),
        ("b11_sheet_hidden", base_edit_light, base_edit_dark),
    ]

    for name, bl, bd in scenarios:
        al = os.path.join(goldens, f"{name}_light.png")
        ad = os.path.join(goldens, f"{name}_dark.png")
        out_path = os.path.join(out_dir, f"{name}.png")
        compose_shot(bl, al, bd, ad, out_path, name)

if __name__ == "__main__":
    main()
