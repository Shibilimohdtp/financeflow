"""Compose screenshots for DS-B10 (Add/Edit Transaction in Stillwater Bloom)."""
import os
from PIL import Image, ImageDraw, ImageFont

def main():
    repo = os.getcwd()
    goldens = os.path.join(repo, "tool", "screenshots", "goldens")
    out_dir = os.path.join(repo, "docs", "design-system", "screenshots", "ds-b10")
    os.makedirs(out_dir, exist_ok=True)

    scenes = [
        ("Add Expense (Empty)", "b10_add_expense_empty"),
        ("Add Expense (Filled)", "b10_add_expense_filled"),
        ("Add Income (Hero Moss)", "b10_add_income"),
        ("Add Transfer (Hero Tide)", "b10_add_transfer"),
        ("Edit Transaction", "b10_edit_transaction"),
    ]

    sample = Image.open(os.path.join(goldens, "b10_add_expense_empty_light.png"))
    w, h = sample.size
    pad = 16
    header_h = 32

    # Master sheet: 5 columns x 2 rows (Light on top, Dark on bottom)
    total_w = 5 * w + 6 * pad
    total_h = 2 * (h + header_h) + 3 * pad

    master = Image.new("RGB", (total_w, total_h), (24, 26, 22))
    draw = ImageDraw.Draw(master)

    for col, (label, base_name) in enumerate(scenes):
        for row, mode in enumerate(["light", "dark"]):
            img_path = os.path.join(goldens, f"{base_name}_{mode}.png")
            if os.path.exists(img_path):
                img = Image.open(img_path).convert("RGB")
                x = pad + col * (w + pad)
                y = pad + row * (h + header_h + pad)
                draw.text((x + 8, y + 8), f"{label} · {mode.capitalize()}", fill=(220, 220, 215))
                master.paste(img, (x, y + header_h))

    out_master = os.path.join(out_dir, "add_edit_transaction.png")
    master.save(out_master, optimize=True)
    print("Wrote master sheet:", out_master)

    # Individual comparison sheets:
    for label, base_name in scenes:
        l_path = os.path.join(goldens, f"{base_name}_light.png")
        d_path = os.path.join(goldens, f"{base_name}_dark.png")
        if os.path.exists(l_path) and os.path.exists(d_path):
            l_img = Image.open(l_path).convert("RGB")
            d_img = Image.open(d_path).convert("RGB")
            comp_w = 2 * w + 3 * pad
            comp_h = h + header_h + 2 * pad
            comp = Image.new("RGB", (comp_w, comp_h), (24, 26, 22))
            cdraw = ImageDraw.Draw(comp)
            cdraw.text((pad + 8, pad + 8), f"{label} · Light", fill=(220, 220, 215))
            comp.paste(l_img, (pad, pad + header_h))
            cdraw.text((pad + w + pad + 8, pad + 8), f"{label} · Dark", fill=(220, 220, 215))
            comp.paste(d_img, (pad + w + pad, pad + header_h))
            out_comp = os.path.join(out_dir, f"{base_name}.png")
            comp.save(out_comp, optimize=True)
            print("Wrote scene sheet:", out_comp)

if __name__ == "__main__":
    main()
