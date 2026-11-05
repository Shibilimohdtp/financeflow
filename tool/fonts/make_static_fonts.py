# Cuts the bundled fixed-weight fonts from the Google Fonts variable fonts.
# Usage: python make_static_fonts.py <dir with the variable TTFs> <output dir>
# See assets/fonts/README.md.
# Cut fixed-weight TTFs from the Google Fonts variable fonts.
import sys
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

src, out = sys.argv[1], sys.argv[2]
jobs = [
    ("manrope_Manrope[wght].ttf", "Manrope", {400: "Regular", 500: "Medium", 600: "SemiBold", 700: "Bold", 800: "ExtraBold"}, {}),
    # Display roles are 24-36sp; pin optical size there, plain (non-"wonky") letterforms, no softening.
    ("fraunces_Fraunces[SOFT,WONK,opsz,wght].ttf", "Fraunces", {600: "SemiBold", 700: "Bold"}, {"opsz": 24, "SOFT": 0, "WONK": 0}),
]
for file, family, weights, fixed in jobs:
    for w, style in weights.items():
        f = TTFont(f"{src}/{file}")
        inst = instancer.instantiateVariableFont(f, {"wght": w, **fixed}, updateFontNames=not fixed)
        assert "fvar" not in inst
        path = f"{out}/{family}-{style}.ttf"
        inst.save(path)
        g = TTFont(path)
        print(path.split("/")[-1], g["OS/2"].usWeightClass, g["name"].getDebugName(1), g["name"].getDebugName(2), 0x20B9 in g.getBestCmap())
