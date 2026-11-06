# Bundled fonts

FinanceFlow ships its fonts so text never depends on a network request and
release builds look the same as debug builds.

| Family | Files | Used for |
|---|---|---|
| Geist | Light 300, Regular 400, Medium 500, SemiBold 600 | All UI text, amounts and display roles (since DS-B2) |
| Manrope | Regular 400, Medium 500, SemiBold 600, Bold 700, ExtraBold 800 | Fallback for glyphs Geist lacks |

Source: the variable fonts in the Google Fonts repository (Manrope downloaded 2026-11-05):
- https://github.com/google/fonts/raw/main/ofl/manrope/Manrope%5Bwght%5D.ttf
- https://github.com/google/fonts/raw/main/ofl/geist/Geist%5Bwght%5D.ttf (downloaded 2026-11-06, Geist 1.800,
  SHA-256 `73894e0448cae90a92b6c2f8732b7bb9acb7b94c418bff559dad4a18e1de9659`; it has ₹ and tabular figures)

Flutter does not map `FontWeight` onto a variable font's weight axis, so the
fixed weights were cut with fontTools using `tool/fonts/make_static_fonts.py`.
Fraunces (display roles until DS-B2) was removed when the display roles moved to light Geist.

Licence: SIL Open Font License 1.1 (`Geist-OFL.txt`, `Manrope-OFL.txt`).
Neither font declares a Reserved Font Name, so the modified files keep their names.

To change weights, edit the script, re-run it on the variable fonts, and update
the `fonts:` section of `pubspec.yaml`.
