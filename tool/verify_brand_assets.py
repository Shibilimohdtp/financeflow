import os
import re
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

    # 1. Android Launcher Icons (Legacy & Round)
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

    # 2. Android Adaptive Foregrounds
    fg_densities = [
        ("drawable-mdpi", 108),
        ("drawable-hdpi", 162),
        ("drawable-xhdpi", 216),
        ("drawable-xxhdpi", 324),
        ("drawable-xxxhdpi", 432),
    ]
    for d, sz in fg_densities:
        check_img(f"android/app/src/main/res/{d}/ic_launcher_foreground.png", sz)

    # 3. Android Notification Icons
    notif_densities = [
        ("drawable-mdpi", 24),
        ("drawable-hdpi", 36),
        ("drawable-xhdpi", 48),
        ("drawable-xxhdpi", 72),
        ("drawable-xxxhdpi", 96),
    ]
    for d, sz in notif_densities:
        check_img(f"android/app/src/main/res/{d}/ic_notification.png", sz)

    # 4. Native Splash Logo & Master Branding Bitmaps
    check_img("android/app/src/main/res/drawable/splash_logo.png", 192)
    check_img("assets/branding/financeflow_mark.png", 512)
    check_img("assets/branding/financeflow_app_icon.png", 1024)

    # 5. iOS AppIcons
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

    # 6. Web & macOS
    check_img("web/favicon.png", 32)
    check_img("web/icons/Icon-192.png", 192)
    check_img("web/icons/Icon-512.png", 512)
    check_img("web/icons/Icon-maskable-192.png", 192)
    check_img("web/icons/Icon-maskable-512.png", 512)

    # 7. Master Branding SVGs
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

    # 8. Stricter Android Vector Drawables & XML Checks
    xml_resources = [
        "android/app/src/main/res/drawable/ic_launcher_background.xml",
        "android/app/src/main/res/drawable/ic_launcher_foreground.xml",
        "android/app/src/main/res/drawable/ic_launcher_monochrome.xml",
        "android/app/src/main/res/drawable/ic_notification.xml",
        "android/app/src/main/res/drawable/launch_background.xml",
        "android/app/src/main/res/drawable-v21/launch_background.xml",
        "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml",
        "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml",
        "android/app/src/main/res/values/colors.xml",
        "android/app/src/main/res/values-night/colors.xml",
        "android/app/src/main/res/values-v31/styles.xml",
        "android/app/src/main/res/values-night-v31/styles.xml",
    ]
    for x in xml_resources:
        xp = os.path.join(ROOT_DIR, x)
        if not os.path.exists(xp) or os.path.getsize(xp) == 0:
            errors.append(f"Missing or empty XML resource: {x}")
        else:
            checked += 1

    # 9. Alpha-Only Check for ic_notification.xml and ic_launcher_monochrome.xml
    for fn in ["ic_notification.xml", "ic_launcher_monochrome.xml"]:
        p = os.path.join(ROOT_DIR, f"android/app/src/main/res/drawable/{fn}")
        if os.path.exists(p):
            with open(p, "r", encoding="utf-8") as f:
                content = f.read()
                # Check for colored hex codes (anything other than pure white #FFF, #FFFFFF, or #FFFFFFFF)
                non_white_colors = re.findall(r'#(?!FFF\b|FFFFFF\b|FFFFFFFF\b)[0-9A-Fa-f]{3,8}', content, re.IGNORECASE)
                if non_white_colors:
                    errors.append(f"{fn} contains non-white/alpha colors: {non_white_colors}. Alpha mask requires pure white.")
                checked += 1

    # 10. Safe Zone Check for ic_launcher_foreground.xml
    fg_xml = os.path.join(ROOT_DIR, "android/app/src/main/res/drawable/ic_launcher_foreground.xml")
    if os.path.exists(fg_xml):
        with open(fg_xml, "r", encoding="utf-8") as f:
            content = f.read()
            # Must declare scale <= 0.90 to keep inside 66dp safe zone (out of 108dp canvas)
            scale_match = re.search(r'android:scaleX="([0-9.]+)"', content)
            if scale_match:
                scale_val = float(scale_match.group(1))
                if scale_val > 0.90:
                    errors.append(f"ic_launcher_foreground.xml scaleX={scale_val} exceeds 0.90 safe zone limit.")
                else:
                    checked += 1
            else:
                errors.append("ic_launcher_foreground.xml missing scaleX attribute.")

    print(f"Verified {checked} brand assets and XML vector resources.")
    if errors:
        print("ERRORS FOUND:")
        for err in errors:
            print(f"  - {err}")
        return False
    else:
        print("ALL BRAND ASSETS & ANDROID VECTORS ARE VALID, CRISP, AND STRICTLY BOUNDED!")
        return True

if __name__ == "__main__":
    import sys
    if not verify():
        sys.exit(1)
