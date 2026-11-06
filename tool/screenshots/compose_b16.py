"""Compose screenshot sheets for DS-B16 (Settings Redesign in Stillwater Bloom)."""
import os
from PIL import Image, ImageDraw

def compose_pair(light_img_path, dark_img_path, out_path, title_prefix=""):
    light_img = Image.open(light_img_path).convert("RGB")
    dark_img = Image.open(dark_img_path).convert("RGB")
    w, h = light_img.size
    pad, head = 16, 32

    tiles = [
        (f"Light · {title_prefix}", light_img),
        (f"Dark · {title_prefix}", dark_img),
    ]

    sheet = Image.new("RGB", (2 * w + 3 * pad, h + head + 2 * pad), (28, 28, 28))
    draw = ImageDraw.Draw(sheet)
    for i, (label, img) in enumerate(tiles):
        x = pad + i * (w + pad)
        draw.text((x, pad), label, fill=(240, 240, 240))
        sheet.paste(img, (x, pad + head))

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    sheet.save(out_path, optimize=True)
    print("Wrote", out_path)

def main():
    repo = os.getcwd()
    goldens = os.path.join(repo, "tool", "screenshots", "goldens")
    out_dir = os.path.join(repo, "docs", "design-system", "screenshots", "ds-b16")

    compose_pair(
        os.path.join(goldens, "b16_more_hub_light.png"),
        os.path.join(goldens, "b16_more_hub_dark.png"),
        os.path.join(out_dir, "b16_more_hub.png"),
        "More Launcher Hub (Quick Toggles, Sand Vault Card, Module Launcher)",
    )

    compose_pair(
        os.path.join(goldens, "b16_settings_detail_light.png"),
        os.path.join(goldens, "b16_settings_detail_dark.png"),
        os.path.join(out_dir, "b16_settings_detail.png"),
        "Settings Page (Search Bar, Intent-Based Groupings)",
    )

    compose_pair(
        os.path.join(goldens, "b16_settings_search_light.png"),
        os.path.join(goldens, "b16_settings_search_dark.png"),
        os.path.join(out_dir, "b16_settings_search.png"),
        "Settings Search (Zero-Latency Keyword Filter)",
    )

if __name__ == "__main__":
    main()
