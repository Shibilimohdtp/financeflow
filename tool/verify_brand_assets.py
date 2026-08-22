import os
from PIL import Image

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def verify():
    errors = []
    checked = 0

    def check_img(rel_path, expected_size):
        nonlocal checked
        full_path = os.path.join(ROOT_DIR, rel_path)
        if not os.path.exists(full_path):
            errors.append(f"Missing file: {rel_path}")
            return
        try:
            with Image.open(full_path) as img:
                checked += 1
                if isinstance(expected_size, int):
                    expected = (expected_size, expected_size)
                else:
                    expected = expected_size
                if img.size != expected:
                    errors.append(f"{rel_path}: expected size {expected}, got {img.size}")
        except Exception as e:
            errors.append(f"{rel_path}: failed to open ({e})")

    # Android Launcher Icons
    densities = [
        ("mipmap-mdpi", 48),
        ("mipmap-hdpi", 72),
        ("mipmap-xhdpi", 96),
        ("mipmap-xxhdpi", 144),
        ("mipmap-xxxhdpi", 192),
    ]
    for d, sz in densities:
        check_img(f"android/app/src/main/res/{d}/ic_launcher.png", sz)
        check_img(f"android/app/src/main/res/{d}/ic_launcher_round.png", sz)

    # Android Adaptive Foregrounds
    fg_densities = [
        ("drawable-mdpi", 108),
        ("drawable-hdpi", 162),
        ("drawable-xhdpi", 216),
        ("drawable-xxhdpi", 324),
        ("drawable-xxxhdpi", 432),
    ]
    for d, sz in fg_densities:
        check_img(f"android/app/src/main/res/{d}/ic_launcher_foreground.png", sz)

    # Android Notification Icons
    notif_densities = [
        ("drawable-mdpi", 24),
        ("drawable-hdpi", 36),
        ("drawable-xhdpi", 48),
        ("drawable-xxhdpi", 72),
        ("drawable-xxxhdpi", 96),
    ]
    for d, sz in notif_densities:
        check_img(f"android/app/src/main/res/{d}/ic_notification.png", sz)

    # iOS AppIcons
    ios_icons = [
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
    for fn, sz in ios_icons:
        check_img(f"ios/Runner/Assets.xcassets/AppIcon.appiconset/{fn}", sz)

    # Web & macOS
    check_img("web/favicon.png", 32)
    check_img("web/icons/Icon-192.png", 192)
    check_img("web/icons/Icon-512.png", 512)
    check_img("web/icons/Icon-maskable-192.png", 192)
    check_img("web/icons/Icon-maskable-512.png", 512)

    # Branding SVGs check
    svgs = [
        "assets/branding/financeflow_mark.svg",
        "assets/branding/financeflow_wordmark.svg",
        "assets/branding/financeflow_logo.svg",
        "assets/branding/financeflow_mark_light.svg",
        "assets/branding/financeflow_mark_dark.svg",
        "assets/branding/financeflow_mark_monochrome.svg",
        "assets/branding/financeflow_mark_transparent.svg",
        "assets/branding/financeflow_notification_icon.svg",
        "assets/branding/financeflow_mark_adaptive_foreground.svg",
        "assets/branding/financeflow_mark_adaptive_background.svg",
        "assets/branding/financeflow_app_icon.svg",
    ]
    for s in svgs:
        p = os.path.join(ROOT_DIR, s)
        if not os.path.exists(p) or os.path.getsize(p) == 0:
            errors.append(f"Missing or empty SVG: {s}")
        else:
            checked += 1

    print(f"Verified {checked} brand assets.")
    if errors:
        print("ERRORS FOUND:")
        for err in errors:
            print(f"  - {err}")
        return False
    else:
        print("ALL BRAND ASSETS ARE PRESENT, VALID, AND MATCH EXACT TARGET SPECIFICATIONS!")
        return True

if __name__ == "__main__":
    verify()
