"""Compose before/after screenshot comparisons for DS-B13 (Home Screen Header Redesign in Stillwater Bloom)."""
import os
from PIL import Image, ImageDraw

def main():
    repo = os.getcwd()
    goldens = os.path.join(repo, "tool", "screenshots", "goldens")
    out_dir = os.path.join(repo, "docs", "design-system", "screenshots", "ds-b13")
    os.makedirs(out_dir, exist_ok=True)

    b4_sheet = Image.open(os.path.join(repo, "docs", "design-system", "screenshots", "ds-b4", "home.png"))
    w, h = 390, 1640
    pad, head = 12, 28

    # In ds-b4/home.png: tile 1 was light, tile 3 was dark
    x_b4_light = pad + 1 * (w + pad)
    x_b4_dark = pad + 3 * (w + pad)
    y_content = pad + head

    before_light = b4_sheet.crop((x_b4_light, y_content, x_b4_light + w, y_content + h))
    before_dark = b4_sheet.crop((x_b4_dark, y_content, x_b4_dark + w, y_content + h))

    after_light = Image.open(os.path.join(goldens, "home_light.png")).convert("RGB")
    after_dark = Image.open(os.path.join(goldens, "home_dark.png")).convert("RGB")

    tiles = [
        ("light · before (fixed app bar, wordmark, shield)", before_light),
        ("light · after (calm greeting, privacy eye toggle)", after_light),
        ("dark · before (fixed app bar, wordmark, shield)", before_dark),
        ("dark · after (calm greeting, privacy eye toggle)", after_dark),
    ]

    sheet = Image.new("RGB", (4 * w + 5 * pad, h + head + 2 * pad), (40, 40, 40))
    draw = ImageDraw.Draw(sheet)
    for i, (label, img) in enumerate(tiles):
        x = pad + i * (w + pad)
        draw.text((x, pad), label, fill=(235, 235, 235))
        sheet.paste(img, (x, pad + head))

    out_path = os.path.join(out_dir, "home_header.png")
    sheet.save(out_path, optimize=True)
    print("Wrote comparison sheet to", out_path)

    # Also save a zoomed-in top-of-screen detail sheet (focusing on header + balance hero)
    h_crop = 540
    top_sheet = Image.new("RGB", (4 * w + 5 * pad, h_crop + head + 2 * pad), (40, 40, 40))
    top_draw = ImageDraw.Draw(top_sheet)
    for i, (label, img) in enumerate(tiles):
        x = pad + i * (w + pad)
        top_draw.text((x, pad), label, fill=(235, 235, 235))
        cropped = img.crop((0, 0, w, h_crop))
        top_sheet.paste(cropped, (x, pad + head))

    top_path = os.path.join(out_dir, "home_header_detail.png")
    top_sheet.save(top_path, optimize=True)
    print("Wrote detail comparison sheet to", top_path)

if __name__ == "__main__":
    main()
