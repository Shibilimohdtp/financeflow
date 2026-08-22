"""
FinanceFlow Brand Assets Generator
Generates all multi-density and multi-platform icon & splash assets from the Stillwater design system.
Uses 4x supersampled rendering for ultra-crisp antialiasing.
"""

import math
import os
from PIL import Image, ImageDraw

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Color definitions
COLOR_DEEPWATER_600 = (14, 95, 85, 255)       # #0E5F55
COLOR_DEEPWATER_800 = (9, 63, 57, 255)        # #093F39
COLOR_DEEPWATER_DARK = (11, 20, 18, 255)      # #0B1412
COLOR_SHORE_SAND = (247, 245, 239, 255)       # #F7F5EF
COLOR_MIST_WHITE = (255, 255, 255, 255)
COLOR_MIST_SOFT = (211, 237, 230, 255)        # #D3EDE6
COLOR_MARIGOLD = (201, 138, 31, 255)          # #C98A1F
COLOR_MARIGOLD_LIGHT = (233, 179, 102, 255)   # #E9B366
COLOR_TRANSPARENT = (0, 0, 0, 0)

def draw_arc_with_caps(draw, cx, cy, radius, start_deg, end_deg, width, color, step=0.5):
    """Draw a smooth circular arc with rounded end caps."""
    half_w = width / 2.0
    # Draw arc segment as thick polyline or series of connected circles
    points = []
    curr = start_deg
    while curr <= end_deg:
        rad = math.radians(curr)
        x = cx + radius * math.cos(rad)
        y = cy + radius * math.sin(rad)
        points.append((x, y))
        curr += step
    
    # Draw line segments
    for i in range(len(points) - 1):
        x0, y0 = points[i]
        x1, y1 = points[i+1]
        draw.line([(x0, y0), (x1, y1)], fill=color, width=int(width))
    
    # Draw rounded end caps
    for pt in [points[0], points[-1]]:
        draw.ellipse([pt[0] - half_w, pt[1] - half_w, pt[0] + half_w, pt[1] + half_w], fill=color)

def render_stillwater_mark(
    size=1024,
    bg_color=COLOR_DEEPWATER_600,
    fg_color=COLOR_MIST_WHITE,
    accent_color=COLOR_MARIGOLD_LIGHT,
    is_round=False,
    corner_radius=0,
    padding_factor=0.22,
    monochrome=False,
    is_adaptive_fg=False
):
    """
    Renders the Stillwater Mark at specified size using 4x supersampling.
    """
    scale = 4
    canvas_size = size * scale
    img = Image.new("RGBA", (canvas_size, canvas_size), COLOR_TRANSPARENT)
    draw = ImageDraw.Draw(img)

    cx = canvas_size / 2.0
    cy = canvas_size / 2.0

    # Background
    if bg_color != COLOR_TRANSPARENT:
        if is_round:
            draw.ellipse([0, 0, canvas_size - 1, canvas_size - 1], fill=bg_color)
        elif corner_radius > 0:
            cr = corner_radius * scale
            draw.rounded_rectangle([0, 0, canvas_size - 1, canvas_size - 1], radius=cr, fill=bg_color)
        else:
            draw.rectangle([0, 0, canvas_size - 1, canvas_size - 1], fill=bg_color)

    # Calculate mark dimensions
    if is_adaptive_fg:
        # Fits inside 288/432 safe zone (66.6% safe diameter)
        eff_size = canvas_size * 0.52
    else:
        eff_size = canvas_size * (1.0 - padding_factor * 2)

    s = eff_size / 512.0 # 512 is reference viewBox

    # Outer arc
    # Center (256, 256) in ref coordinates -> radius ~188, from angle 115 deg to 395 deg (270 deg span)
    draw_arc_with_caps(
        draw,
        cx=cx,
        cy=cy,
        radius=188 * s,
        start_deg=-250, # ~110 deg to 380 deg
        end_deg=65,
        width=40 * s,
        color=fg_color
    )

    # Inner arc (F-geometry flow)
    # Center (256, 256) in ref coordinates -> radius ~120, from -180 deg to 55 deg
    draw_arc_with_caps(
        draw,
        cx=cx,
        cy=cy,
        radius=120 * s,
        start_deg=-180,
        end_deg=55,
        width=34 * s,
        color=fg_color
    )

    # Horizon arc
    # Center (256, 280) -> radius ~68, from -200 deg to -30 deg
    draw_arc_with_caps(
        draw,
        cx=cx,
        cy=cy + (24 * s),
        radius=68 * s,
        start_deg=-170,
        end_deg=-10,
        width=26 * s,
        color=fg_color
    )

    # Central Spark / Droplet
    dot_x = cx
    dot_y = cy - (54 * s)
    dot_r = 28 * s
    spark_col = fg_color if monochrome else accent_color
    draw.ellipse([dot_x - dot_r, dot_y - dot_r, dot_x + dot_r, dot_y + dot_r], fill=spark_col)

    # Downsample 4x with high-quality Lanczos filter
    final_img = img.resize((size, size), Image.Resampling.LANCZOS)
    return final_img

def render_notification_icon(size=96):
    """
    Renders pure monochrome white notification icon on transparent background.
    """
    scale = 4
    canvas_size = size * scale
    img = Image.new("RGBA", (canvas_size, canvas_size), COLOR_TRANSPARENT)
    draw = ImageDraw.Draw(img)

    cx = canvas_size / 2.0
    cy = canvas_size / 2.0
    s = (canvas_size * 0.80) / 512.0

    # Outer arc
    draw_arc_with_caps(
        draw,
        cx=cx,
        cy=cy,
        radius=188 * s,
        start_deg=-250,
        end_deg=65,
        width=44 * s,
        color=COLOR_MIST_WHITE
    )

    # Inner arc
    draw_arc_with_caps(
        draw,
        cx=cx,
        cy=cy,
        radius=120 * s,
        start_deg=-180,
        end_deg=55,
        width=38 * s,
        color=COLOR_MIST_WHITE
    )

    # Horizon arc
    draw_arc_with_caps(
        draw,
        cx=cx,
        cy=cy + (24 * s),
        radius=68 * s,
        start_deg=-170,
        end_deg=-10,
        width=30 * s,
        color=COLOR_MIST_WHITE
    )

    # Spark
    dot_x = cx
    dot_y = cy - (54 * s)
    dot_r = 30 * s
    draw.ellipse([dot_x - dot_r, dot_y - dot_r, dot_x + dot_r, dot_y + dot_r], fill=COLOR_MIST_WHITE)

    return img.resize((size, size), Image.Resampling.LANCZOS)

def ensure_dir(path):
    os.makedirs(path, exist_ok=True)

def generate_all_assets():
    print("Generating FinanceFlow Stillwater Brand Assets...")

    # 1. Android Mipmaps
    android_res = os.path.join(ROOT_DIR, "android", "app", "src", "main", "res")
    android_densities = {
        "mipmap-mdpi": (48, 108),
        "mipmap-hdpi": (72, 162),
        "mipmap-xhdpi": (96, 216),
        "mipmap-xxhdpi": (144, 324),
        "mipmap-xxxhdpi": (192, 432),
    }

    for folder, (icon_size, adaptive_size) in android_densities.items():
        folder_path = os.path.join(android_res, folder)
        ensure_dir(folder_path)

        # Standard launcher icon (squircle/rounded)
        icon_img = render_stillwater_mark(
            size=icon_size,
            bg_color=COLOR_DEEPWATER_600,
            fg_color=COLOR_MIST_WHITE,
            accent_color=COLOR_MARIGOLD_LIGHT,
            corner_radius=int(icon_size * 0.22)
        )
        icon_img.save(os.path.join(folder_path, "ic_launcher.png"), "PNG")

        # Round launcher icon
        round_img = render_stillwater_mark(
            size=icon_size,
            bg_color=COLOR_DEEPWATER_600,
            fg_color=COLOR_MIST_WHITE,
            accent_color=COLOR_MARIGOLD_LIGHT,
            is_round=True
        )
        round_img.save(os.path.join(folder_path, "ic_launcher_round.png"), "PNG")

    # 2. Android Adaptive Foreground & Background Drawables
    drawable_densities = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432,
    }

    for folder, size in drawable_densities.items():
        folder_path = os.path.join(android_res, folder)
        ensure_dir(folder_path)

        # Foreground layer (transparent bg, centered within safe zone)
        fg_img = render_stillwater_mark(
            size=size,
            bg_color=COLOR_TRANSPARENT,
            fg_color=COLOR_MIST_WHITE,
            accent_color=COLOR_MARIGOLD_LIGHT,
            is_adaptive_fg=True
        )
        fg_img.save(os.path.join(folder_path, "ic_launcher_foreground.png"), "PNG")

    # 3. Android Notification Icons
    notif_densities = {
        "drawable-mdpi": 24,
        "drawable-hdpi": 36,
        "drawable-xhdpi": 48,
        "drawable-xxhdpi": 72,
        "drawable-xxxhdpi": 96,
    }

    for folder, size in notif_densities.items():
        folder_path = os.path.join(android_res, folder)
        ensure_dir(folder_path)

        notif_img = render_notification_icon(size=size)
        notif_img.save(os.path.join(folder_path, "ic_notification.png"), "PNG")

    # 4. Splash Screen Bitmap Assets
    drawable_dir = os.path.join(android_res, "drawable")
    ensure_dir(drawable_dir)
    splash_mark = render_stillwater_mark(
        size=192,
        bg_color=COLOR_TRANSPARENT,
        fg_color=COLOR_DEEPWATER_600,
        accent_color=COLOR_MARIGOLD,
        padding_factor=0.1
    )
    splash_mark.save(os.path.join(drawable_dir, "splash_logo.png"), "PNG")

    # 5. iOS Assets (AppIcon.appiconset)
    ios_icons = os.path.join(ROOT_DIR, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    ensure_dir(ios_icons)

    ios_sizes = [
        ("Icon-App-20x20@1x.png", 20),
        ("Icon-App-20x20@2x.png", 40),
        ("Icon-App-20x20@3x.png", 60),
        ("Icon-App-29x29@1x.png", 29),
        ("Icon-App-29x29@2x.png", 58),
        ("Icon-App-29x29@3x.png", 87),
        ("Icon-App-40x40@1x.png", 40),
        ("Icon-App-40x40@2x.png", 80),
        ("Icon-App-40x40@3x.png", 120),
        ("Icon-App-60x60@2x.png", 120),
        ("Icon-App-60x60@3x.png", 180),
        ("Icon-App-76x76@1x.png", 76),
        ("Icon-App-76x76@2x.png", 152),
        ("Icon-App-83.5x83.5@2x.png", 167),
        ("Icon-App-1024x1024@1x.png", 1024),
    ]

    for filename, px in ios_sizes:
        ios_img = render_stillwater_mark(
            size=px,
            bg_color=COLOR_DEEPWATER_600,
            fg_color=COLOR_MIST_WHITE,
            accent_color=COLOR_MARIGOLD_LIGHT,
            corner_radius=0 # iOS applies its own squircle mask
        )
        ios_img.save(os.path.join(ios_icons, filename), "PNG")

    # iOS LaunchImage
    ios_launch = os.path.join(ROOT_DIR, "ios", "Runner", "Assets.xcassets", "LaunchImage.imageset")
    ensure_dir(ios_launch)
    for name, sz in [("LaunchImage.png", 128), ("LaunchImage@2x.png", 256), ("LaunchImage@3x.png", 384)]:
        li = render_stillwater_mark(
            size=sz,
            bg_color=COLOR_TRANSPARENT,
            fg_color=COLOR_DEEPWATER_600,
            accent_color=COLOR_MARIGOLD
        )
        li.save(os.path.join(ios_launch, name), "PNG")

    # 6. Web Assets
    web_dir = os.path.join(ROOT_DIR, "web")
    web_icons = os.path.join(web_dir, "icons")
    ensure_dir(web_icons)

    # Favicon 32x32
    fav = render_stillwater_mark(
        size=32,
        bg_color=COLOR_DEEPWATER_600,
        fg_color=COLOR_MIST_WHITE,
        accent_color=COLOR_MARIGOLD_LIGHT,
        corner_radius=6
    )
    fav.save(os.path.join(web_dir, "favicon.png"), "PNG")

    # Web PWA Icons
    for sz, name in [
        (192, "Icon-192.png"),
        (512, "Icon-512.png"),
        (192, "Icon-maskable-192.png"),
        (512, "Icon-maskable-512.png")
    ]:
        pwa_img = render_stillwater_mark(
            size=sz,
            bg_color=COLOR_DEEPWATER_600,
            fg_color=COLOR_MIST_WHITE,
            accent_color=COLOR_MARIGOLD_LIGHT,
            corner_radius=int(sz * 0.22) if "maskable" not in name else 0
        )
        pwa_img.save(os.path.join(web_icons, name), "PNG")

    # 7. MacOS AppIcons
    macos_icons = os.path.join(ROOT_DIR, "macos", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    ensure_dir(macos_icons)
    macos_sizes = [
        ("app_icon_16.png", 16),
        ("app_icon_32.png", 32),
        ("app_icon_64.png", 64),
        ("app_icon_128.png", 128),
        ("app_icon_256.png", 256),
        ("app_icon_512.png", 512),
        ("app_icon_1024.png", 1024),
    ]
    for filename, px in macos_sizes:
        mac_img = render_stillwater_mark(
            size=px,
            bg_color=COLOR_DEEPWATER_600,
            fg_color=COLOR_MIST_WHITE,
            accent_color=COLOR_MARIGOLD_LIGHT,
            corner_radius=int(px * 0.22)
        )
        mac_img.save(os.path.join(macos_icons, filename), "PNG")

    # 8. Windows App Icon (.ico multi-res)
    win_res = os.path.join(ROOT_DIR, "windows", "runner", "resources")
    ensure_dir(win_res)
    ico_sizes = [16, 32, 48, 64, 128, 256]
    ico_images = [
        render_stillwater_mark(
            size=s,
            bg_color=COLOR_DEEPWATER_600,
            fg_color=COLOR_MIST_WHITE,
            accent_color=COLOR_MARIGOLD_LIGHT,
            corner_radius=int(s * 0.22)
        ) for s in ico_sizes
    ]
    ico_images[0].save(
        os.path.join(win_res, "app_icon.ico"),
        format="ICO",
        sizes=[(s, s) for s in ico_sizes],
        append_images=ico_images[1:]
    )

    # 9. Clean exports to assets/branding/ and assets/icons/
    branding_dir = os.path.join(ROOT_DIR, "assets", "branding")
    ensure_dir(branding_dir)
    master_png = render_stillwater_mark(
        size=1024,
        bg_color=COLOR_DEEPWATER_600,
        fg_color=COLOR_MIST_WHITE,
        accent_color=COLOR_MARIGOLD_LIGHT,
        corner_radius=224
    )
    master_png.save(os.path.join(branding_dir, "financeflow_app_icon.png"), "PNG")

    mark_trans = render_stillwater_mark(
        size=512,
        bg_color=COLOR_TRANSPARENT,
        fg_color=COLOR_DEEPWATER_600,
        accent_color=COLOR_MARIGOLD
    )
    mark_trans.save(os.path.join(branding_dir, "financeflow_mark.png"), "PNG")

    print("All FinanceFlow Brand Assets generated successfully!")

if __name__ == "__main__":
    generate_all_assets()
