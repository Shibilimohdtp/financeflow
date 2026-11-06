# FinanceFlow Brand Assets & Geometry Specifications

This directory contains the canonical vector geometry and brand identity assets for **FinanceFlow**, designed within the **Stillwater Bloom** visual language.

## 1. Geometry & Coordinate System

- **ViewBox**: `0 0 512 512`
- **Origin / Optical Center**: `(256, 256)`
- **Adaptive Icon Safe Zone**: Geometry is strictly confined within a circle of radius `r = 156` (diameter `312px`), corresponding to the canonical **66 dp safe zone** of Android's 108 dp adaptive canvas. No OEM launcher mask (Circle, Squircle, Rounded Square, Teardrop) will clip any part of the mark.
- **Stroke Weights**:
  - Outer Current Arc: `34px`
  - Inner Current Arc: `28px`
  - Caps: `round` (`StrokeCap.round`)
  - Joins: `round` (`StrokeJoin.round`)
- **Focal Spark Droplet**:
  - Center: `(256, 256)`
  - Radius: `24px` (diameter `48px`)

## 2. Palette Definitions (Bloom Primitives)

| Token / Element | Daylight (Light) | Deep Water (Dark) | Monochrome / Mask |
|---|---|---|---|
| **Canvas** | `#F3F2EC` (`lightCanvas`) | `#10120E` (`darkCanvas`) | Transparent |
| **Mark Stroke (Currents)** | `#1B1D17` (`lightInk`) | `#E4E4DC` (`darkInk`) | `#FFFFFF` |
| **Spark Droplet** | `#CBE94C` (`lightSpark`) | `#D5F057` (`darkSpark`) | `#FFFFFF` |
| **Plate Background (Launcher)** | `#F3F2EC` | `#10120E` | System Dynamic Monet |

## 3. Explored Directions (Under `directions/`)

1. **Direction 1: The Stillwater Ripple (Recommended)**
   - Files: `direction1_ripple_light.svg`, `direction1_ripple_dark.svg`, `direction1_ripple_mono.svg`
   - Concentric nested squircle arcs with fluid, breathing openings and a center radiant Lime Spark droplet.
   - Preserves instant recognition down to 24 dp in Android status bar notification alpha masks.
2. **Direction 2: The Continuous Ledger Ribbon**
   - Files: `direction2_ribbon_light.svg`, `direction2_ribbon_dark.svg`, `direction2_ribbon_mono.svg`
   - Architectural monogram "F" formed by a single continuous geometric path terminating in a lime spark.
3. **Direction 3: The Still Horizon**
   - Files: `direction3_horizon_light.svg`, `direction3_horizon_dark.svg`, `direction3_horizon_mono.svg`
   - Calm squircle water basin cradling local records with a serene waterline and buoyant morning spark.

## 4. Master SVGs & Propagation

Once the user confirms the preferred direction:
- The chosen SVG becomes `financeflow_mark.svg`, `financeflow_mark_adaptive_foreground.svg`, `financeflow_mark_monochrome.svg`, and `financeflow_notification_icon.svg`.
- The asset rasterizer (`tool/generate_brand_assets.py`) generates all multi-density platform assets without manual code drift.
