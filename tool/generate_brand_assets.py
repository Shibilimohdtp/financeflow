"""
FinanceFlow Brand Assets Generator (Stillwater Bloom DS-B19)
Generates all multi-density and multi-platform icon & splash assets from the canonical
vector geometry via Flutter's vector rasterization engine, guaranteeing 100% mathematical
parity with the SVGs and in-app CustomPainters.
"""

import os
import subprocess
import sys

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def generate_assets():
    print("Generating FinanceFlow Stillwater Bloom brand assets...")
    cmd = ["flutter", "test", "tool/rasterize_brand_assets.dart"]
    result = subprocess.run(cmd, cwd=ROOT_DIR, capture_output=True, text=True)
    if result.returncode != 0:
        print("ERROR generating brand assets:")
        print(result.stdout)
        print(result.stderr)
        sys.exit(1)
    print("Successfully generated all brand assets from vector master geometry!")

if __name__ == "__main__":
    generate_assets()
