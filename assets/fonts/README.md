# Bundled fonts

FinanceFlow ships its fonts so text never depends on a network request and
release builds look the same as debug builds.

| Family | Files | Used for |
|---|---|---|
| Manrope | Regular 400, Medium 500, SemiBold 600, Bold 700, ExtraBold 800 | All UI text and amounts |
| Fraunces | SemiBold 600, Bold 700 | Display roles only (`displayLg`, `display`, `displaySm`) |

Source: the variable fonts in the Google Fonts repository, downloaded 2026-11-05:
- https://github.com/google/fonts/raw/main/ofl/manrope/Manrope%5Bwght%5D.ttf
- https://github.com/google/fonts/raw/main/ofl/fraunces/Fraunces%5BSOFT,WONK,opsz,wght%5D.ttf

Flutter does not map `FontWeight` onto a variable font's weight axis, so the
fixed weights were cut with fontTools using `tool/fonts/make_static_fonts.py`.
Fraunces is pinned to optical size 24, `SOFT` 0 and `WONK` 0, to match its display sizes with calm letterforms.

Licence: SIL Open Font License 1.1 (`Manrope-OFL.txt`, `Fraunces-OFL.txt`).
Neither font declares a Reserved Font Name, so the modified files keep their names.

To change weights, edit the script, re-run it on the variable fonts, and update
the `fonts:` section of `pubspec.yaml`.
