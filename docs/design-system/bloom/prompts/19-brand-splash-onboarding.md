# Prompt: New logo and app icon, splash, notification icon and onboarding (DS-B19)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead brand designer, product designer and Flutter/Android engineer for **FinanceFlow** (Flutter,
Riverpod, Isar; fully local, privacy-first, no backend). The app uses one design system, **Stillwater**, in its
**Bloom** visual language, and almost every screen is now in Bloom. The one thing that still looks like the old
"Lichen Ledger" era is the **identity**: the logo, the app icon, the splash, the notification icon and the first
screens a new user sees. Your job is a single, coherent piece of work:

1. **Design a brand-new FinanceFlow logo and app icon, built entirely as SVG** (hand-authored vector geometry, no
   raster tracing, no stock art, no AI-generated bitmaps, no fetched fonts or network), and **replace the old logo
   everywhere it appears**: launcher icon (legacy, round, adaptive, themed monochrome), native splash, Flutter splash and
   loading screens, the in-app mark and wordmark (onboarding, lock screen, More screen footer, error and startup
   screens), the notification icon, and the other platform icons.
2. **Fix the notification icon.** Today a pushed notification shows a plain circle blob in the phone's status bar
   instead of our mark. Make the real, recognisable mark appear as the small icon.
3. **Redesign the splash** (native and Flutter side, as one continuous moment).
4. **Redesign both onboarding experiences**: the first-run walk-through (`onboarding_screen.dart`) and the permission
   rationale screens (SMS and notification access).

**This must be a creative redesign, not a re-skin.** A recoloured version of the current mark, or the same four
centred-icon pages with new fonts, is the wrong outcome and will be rejected. The logo should be something the owner
is proud to see on a home screen; the onboarding should make a first-time user feel *calm, in control and private*
within ten seconds. Use Bloom's vocabulary (aurora canvas, hero card, squircles, light oversized numerals, ink pills
with one lime accent, ring and dot-matrix viz) with our own signature, never copied from the reference imagery or from
any bank, wallet or fintech logo.

## Read first, in this order (binding)

1. `AGENTS.md`: the **backup gate** (an icon change means installing a new APK on a real device: ask me for a verified
   encrypted backup first, then `adb install -r` only, never `adb uninstall`, `pm clear` or `flutter install`) and the
   **Android standalone-startup gate** (splash and manifest changes are exactly what it covers).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, **`03-components.md` in full**,
   `04-screen-recipes.md` (pattern G, secure or onboarding, and pattern A), `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows. Also `docs/features/FinanceFlow_Design_System.md`
   and the brand mentions in `docs/design-system/00-audit-and-proposal.md`.
4. The golden screens and the newest slice screenshots under `docs/design-system/screenshots/` (`ds-b4` Home, `ds-b6`,
   `ds-b9*`, `ds-b10` to `ds-b17*`, whichever exist). The new identity must sit naturally next to them.
5. **The identity today** (read all of it before designing anything):
   - `assets/branding/`: `financeflow_mark.svg`, `financeflow_logo.svg`, `financeflow_wordmark.svg`,
     `financeflow_app_icon.svg/.png`, `financeflow_mark_adaptive_foreground.svg` / `_background.svg`,
     `financeflow_mark_monochrome.svg`, `financeflow_mark_light/dark/transparent.svg`, `financeflow_notification_icon.svg`.
     The current mark is rings plus a small rose "spark" dot in the old Lichen palette (`#535B36`, `#76546A`).
   - `tool/generate_brand_assets.py` (426 lines, **Pillow primitives that redraw the mark by hand**, not an SVG
     rasteriser, so the SVGs and the PNGs can drift) and `tool/verify_brand_assets.py` (checks sizes only).
   - `lib/shared/widgets/financeflow_mark.dart` (271): `FinanceFlowMark` (a `CustomPaint` with variants
     auto / daylight / deepWater / monochrome / security that read `StillwaterColors` statics), `FinanceFlowWordmark`,
     `FinanceFlowLogo`. There is no SVG package in `pubspec.yaml`.
   - Where the widgets are used: `lib/app/app.dart` (loading and error screens), `lib/main.dart` (the
     `StartupReady` screen with "Preparing your local data…"), `lib/features/onboarding/onboarding_screen.dart`,
     `lib/features/security/lock_screen.dart` (monochrome variant), `lib/features/settings/more_screen.dart` (the About
     footer `FinanceFlowLogo`), `lib/features/settings/branding_preview_screen.dart` (developer tool that previews the
     brand assets; reachable from More, settings detail and the developer tools card).
   - Android: `android/app/src/main/res/` has `mipmap-*/ic_launcher*.png` (legacy and round), `mipmap-anydpi-v26/ic_launcher.xml`
     and `ic_launcher_round.xml` (adaptive; **no `<monochrome>` layer yet**), `drawable-*/ic_launcher_foreground.png`,
     `drawable/ic_launcher_background.xml`, `drawable/ic_notification.xml` (a vector) and `drawable-*/ic_notification.png`,
     `drawable/splash_logo.png`, `drawable/launch_background.xml` and `drawable-v21/launch_background.xml`,
     `values/colors.xml` and `values-night/colors.xml` (still the old Lichen hexes, e.g. `splash_background #F5F4ED`),
     `values/styles.xml` and `values-night/styles.xml` (`LaunchTheme`, `NormalTheme`; no Android 12 splash attributes),
     and `AndroidManifest.xml` (`android:icon`, `android:roundIcon`, label "FinanceFlow"; do not change the application
     id or label).
   - Other platforms: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` and `LaunchImage.imageset`, `web/` (`favicon.png`,
     `icons/*`, `manifest.json`), `windows/runner/resources/app_icon.ico`.
6. **The notification bug, with the likely cause** (confirm it before you fix it):
   `lib/services/notifications/local_notification_service.dart` initialises Android with
   `AndroidInitializationSettings('@mipmap/ic_launcher')`, and the per-notification `AndroidNotificationDetails` do not
   set an `icon`. Android draws a status-bar small icon as an **alpha mask**, so a full-colour launcher icon becomes a
   solid circle or blob. The correct source is a **monochrome, transparent-background drawable** (white shapes, alpha
   only, no gradients, no background plate), referenced as `@drawable/ic_notification`, with the brand accent set as the
   notification `color`. A drawable referenced **only by a string name** can also be **removed by resource shrinking in a
   release build**, so check `android/app/build.gradle*` for `shrinkResources` / `minifyEnabled` and add
   `res/raw/keep.xml` if needed. Also check every place that builds a notification
   (`lib/services/notifications/`, the SMS and notification-listener Kotlin classes under
   `android/app/src/main/kotlin/`) so no path falls back to the launcher icon.
7. The first-run screens: `lib/features/onboarding/onboarding_screen.dart` (233: a `PageView` of four pages, each a
   circle with a Material icon (the first uses the mark), a privacy badge, title, subtitle, body, page dots, "Skip"
   and "Continue / Get Started"), and `lib/features/ingestion/permissions/sms_permission_screen.dart` (273) and
   `notification_permission_screen.dart` (234) (privacy rationale, supported banks or app selection; reached from
   Settings and More today, tests in `test/widget/permission_rationale_widget_test.dart`). Completion is stored by
   `settingsControllerProvider.notifier.setOnboardingCompleted(true)` and routed in `lib/app/app.dart` (onboarding, then
   lock, then the shell). Tests: `test/widget/onboarding_widget_test.dart`, `test/widget_test.dart`,
   `test/integration/core_e2e_journey_test.dart`, `test/integration/isar_startup_test.dart`.

## Coordination (check before anything else)

- `git status`, `git log --oneline -10`, and the CHANGELOG **In flight** table. If another row touches a file you need,
  stop and ask me.
- **Settings (DS-B16) and Lock (DS-B17) chats** may touch `more_screen.dart`, `settings_detail_screen.dart`,
  `branding_preview_screen.dart` and `lock_screen.dart`. You change only the logo widget call sites in them (a
  few lines), after re-reading the file, and tell me. The two permission rationale screens are also launched from
  Settings: if DS-B16 has claimed their visuals in the In flight table, stop and ask me which chat owns them.
- **Do not edit** `lib/features/dashboard/`, `lib/features/budgets/`, `lib/features/transactions/`,
  `lib/features/alerts/`, `lib/features/ingestion/` except the two permission screens above, nor any data, repository or
  provider code. Notification **content, channels, scheduling and payloads stay unchanged**; you change only the icon,
  colour and large icon the notifications present.
- You may add shared components to `lib/shared/widgets/` (test + component-sheet screenshot + `03-components.md`).
- In `05-screen-status.md` and `CHANGELOG.md` change only your own rows, re-reading each file right before you edit.

## Design directions (starting points; improve them and justify what you change)

### The logo and app icon (the creative centrepiece)

- **Brief.** FinanceFlow is calm, private, local and clear: "still water for your financial life", a soft, tactile,
  squircle-and-aurora look with one lime spark. The mark must be **ownable** (no rupee sign, coin, wallet, shield with a
  padlock, bar-chart or graph-arrow clichés), **simple enough to survive at 24 dp** as a one-colour silhouette, and
  **calm**, not corporate. It should hint at flow, a ledger or the letter F, a bloom or ripple, and privacy, without
  drawing any of them literally. Avoid a look that resembles another well-known app.
- **Deliver three genuinely different directions** as a contact sheet first (each as clean SVG, shown at 192 / 96 / 48 /
  24 px, in light, dark and as a one-colour silhouette, on the launcher shapes circle, squircle, rounded square and
  teardrop, and as Android's themed monochrome icon), recommend one with reasons, and **stop for my choice before
  propagating anything**. Sketch ideas to start from, and improve on them: (a) a **bloom/ripple** built from overlapping
  squircle or circle arcs with the lime spark at the centre; (b) a **monogram F** formed from one continuous flowing
  ribbon; (c) a **still-water drop** or horizon with a spark. Design the wordmark with the logo (Geist is the UI face;
  a custom-drawn wordmark in SVG paths is allowed if it is legible and does not need a font at runtime).
- **Build rules.** One canonical geometry (viewBox, grid, stroke widths, corner radii, optical alignment) documented in a
  short `assets/branding/README.md`. SVG with plain paths, gradients limited to simple linear/radial ones that rasterise
  identically, no filters, no masks that Android vector drawables cannot express, no embedded raster, no external
  references. Colours come from the Bloom primitives (`lib/theme/palettes/bloom_primitives.dart`: ink, canvas
  `#F3F2EC` / `#10120E`, moss, lime spark); check contrast of the mark against its plate in light and dark.
- **Asset set to produce from the master SVGs** (the full set below must exist, named consistently):
  mark (colour, light, dark, one-colour, transparent), wordmark, horizontal and stacked lockups, app icon (full-bleed
  1024 master), adaptive foreground and background (mark inside the **66 dp safe zone** of the 108 dp canvas, so no
  launcher mask clips it), **themed monochrome** layer, notification small icon, splash mark, Play-store 512 icon.

### One source of truth for the assets

- Today the PNGs are redrawn by Pillow code and can disagree with the SVGs. Replace that with a **generator that
  rasterises the master SVGs** (check what is already installed: a Python SVG library, `resvg`, Inkscape or ImageMagick,
  or render through headless Chrome or a Flutter test golden; **ask me before installing anything** and do not add a
  runtime dependency to the app without approval). Prefer **Android vector drawables** (`<vector>` XML converted from
  the same path data) for the adaptive foreground, monochrome layer and notification icon, and PNG only where Android
  needs bitmaps (legacy `mipmap-*`, splash on API < 31). Update `tool/verify_brand_assets.py` to also check that
  every referenced resource exists, that the notification and monochrome layers are alpha-only, and that the adaptive
  foreground stays inside the safe zone.
- In Flutter, `FinanceFlowMark` must draw **the same geometry** as the SVG master. Either generate a Dart `Path`
  from the SVG path data with a small checked-in script (preferred, no runtime dependency), or propose `flutter_svg`
  to me with the size cost. Colours via `context.ff` tokens, not `StillwaterColors`; keep the variants the call sites
  use (`monochrome` on the lock screen, `auto`, `daylight`, `deepWater`) or migrate them in the same commit.

### Notification icon (must visibly work)

- Set the small icon to the new monochrome `@drawable/ic_notification` in `AndroidInitializationSettings` **and** in
  every `AndroidNotificationDetails` (channels may need the same), set the accent `color` from the brand, and consider
  a `largeIcon` of the full-colour mark only if it looks good in the shade and costs nothing at startup (no network, no
  async work before the first frame).
- Add the `keep.xml` / shrinker protection if the release build removes the drawable. Add a unit test that pins the icon
  resource name and a check in `verify_brand_assets.py`; confirm in the **release** APK that the drawable is present
  (`apkanalyzer` or `aapt dump resources`, whichever exists).
- State exactly how you will verify it on a device (post a test notification from the alerts settings, look at the
  status bar, the shade and the lock screen, in light and dark, on a Samsung-style One UI if available). Until I
  confirm on my phone, say plainly that it is unverified.

### Splash: one continuous moment

- **Native splash** (the window background before Flutter draws): Android 12+ system splash configured in a
  `values-v31` theme (`windowSplashScreenBackground`, `windowSplashScreenAnimatedIcon` as a vector, icon background,
  night variants) and the pre-12 `launch_background.xml` using the same colours and the same mark position, so there is
  no jump between native splash and the first Flutter frame. Background colours come from the Bloom canvas for light and
  dark, not the old Lichen hexes.
- **Flutter splash** (`StartupReady` in `lib/main.dart`, and the `loading` / `error` screens in `lib/app/app.dart`):
  the same mark in the same place on the aurora canvas, a calm status line, and a recoverable error state that keeps
  today's wording and Retry behaviour ("Your data has not been changed", never a wipe). One short, one-time entrance
  motion at most (mark draws in or the spark settles), disabled by reduced effects, **never a minimum display time**:
  the splash leaves the moment the app is ready. Replace the stock `CircularProgressIndicator` with a Bloom loader.
- **Hard rule from `AGENTS.md`**: `main()` stays synchronous through `runApp`; no database, plugin, network or
  asset-decoding work before the first frame; large images are not decoded on the startup path. Use fixed, privacy-safe
  startup milestones only.

### Onboarding walk-through (pattern G on `FfAurora`)

Today: four near-identical pages (a circle, a Material icon, a badge, three lines of text). Make it a short, beautiful
story that earns trust:

- **A hero visual per page, built from our own shapes**, not icons in circles: (1) the new mark assembling from its
  parts on the aurora with the promise "Still water for your financial life"; (2) a phone silhouette holding a ledger
  with a clear seal and the words "Stays on this device", no arrows leaving it; (3) PIN dots and a fingerprint tile that
  fill in as the page settles ("Locked, if you want it"); (4) three quiet promises as a stack of small cards ("No
  account", "No servers", "Works offline"). Page transitions use parallax or a shared mark that travels between pages,
  respecting reduced effects.
- **Controls**: a pill progress indicator (`FfPillBar`, `FfDotMatrix` or a custom pill row, not four dots), an ink
  `FfButton` "Continue" that becomes a spark "Get started" on the last page, a quiet "Skip" with a 48 dp target, swipe and
  button both work, and screen-reader order is logical. Safe areas and 2× text must not overflow (test it), small
  phones and landscape must not clip.
- **Honest copy.** Verify every claim against the code before you keep it: "encrypted", "0 bytes on servers", "zero
  data collection", "100% offline", "device hardware security", "no tracking". Rewrite anything the code cannot
  prove (for example, if the database is not encrypted at rest, do not say it is) and tell me what you changed and why.
  Keep copy short, calm and free of jargon.
- **Optional last-step idea (ask me, do not build without approval):** a skippable "Set up in a minute" card offering
  *Add my first account*, *Turn on app lock* and *Detect bank messages*, each only navigating to the existing flow after
  onboarding and never requesting an OS permission by itself.

### Permission rationale screens (SMS and notifications)

- Treat them as the second half of onboarding: a clear hero (the mark with a small lock or message glyph), a three-part
  explanation (**What we read**, **What we never do**, **How to turn it off**), the supported banks or app selection as
  tactile tiles with search where the list is long, and one honest primary button. The screens still only *request* a
  permission when the user taps that button, and the existing permission, settings and selection logic stays
  untouched. The privacy claims follow the same verification rule as above.

## Hard constraints

- **Behaviour and data unchanged.** No change to onboarding completion, lock routing, notification channels, content,
  scheduling or payloads, permissions logic, or any stored value. **No Isar schema, generated-file or provider-bootstrap
  changes** (backup gate: stop and ask me). Do not change the application id, the app label or the signing config.
- **Privacy**: no network, no remote fonts or images, no analytics, no logging of financial data. Brand assets are
  bundled and static.
- Only shared `Ff*` components and tokens in Dart. No raw colours, sizes, radii, durations, `TextStyle(`, `Colors.*`;
  remove the `StillwaterColors` reads from `financeflow_mark.dart`. Native XML colours come from the Bloom primitives
  and are documented in `colors.xml`. Buttons via `FfButton`; amounts (none expected) via `FfAmountText`.
- Accessibility: 48 dp targets, contrast ratchet green, meaningful semantics on the mark ("FinanceFlow") and the
  onboarding pages, no information carried by motion alone, 2× text without overflow (test it), reduced effects, light
  and dark.
- Performance and size: no continuous animation, no blur beyond the hero rules, nothing heavy on the startup path.
  Report the debug and release APK size change.
- Keep texts and keys that `onboarding_widget_test.dart`, `permission_rationale_widget_test.dart` and the startup tests
  rely on, or update the tests in the same commit and say why. `test/widget_test.dart` and
  `test/integration/isar_startup_test.dart` must stay green.
- Split any file you push over ~500 lines. Format only the files you touched; never `dart format lib`. Commit only your
  own paths. Windows 11, PowerShell and Git Bash.

## Slices (one commit each; each updates `05-screen-status.md` and `CHANGELOG.md`)

- **B19a Logo design**: three directions as SVG, the contact sheet, the chosen master SVG set and
  `assets/branding/README.md`. **Pause for my choice before anything else.**
- **B19b Asset pipeline and Android resources**: the SVG-driven generator and verifier, regenerated launcher (legacy,
  round, adaptive, **themed monochrome**), Play-store icon, native splash resources with night variants, the notification
  drawables, and `colors.xml` from the Bloom primitives.
- **B19c Notification icon**: wiring in the notification service (initialisation and every details object), accent
  colour, shrinker protection, the test, and the release-APK check.
- **B19d In-app brand**: `FinanceFlowMark`, wordmark and lockups redrawn from the master geometry, token colours, all
  call sites (lock screen, More footer, error screens, branding preview), component test and sheet screenshot.
- **B19e Splash**: Android 12+ and pre-12 native splash, Flutter `StartupReady` / loading / error screens, hand-over
  without a jump. **Pause for my review** (with screenshots of the native and Flutter frames side by side).
- **B19f Onboarding walk-through**, then **B19g Permission rationale screens**.
- **B19h Other platforms and polish**: iOS AppIcon and LaunchImage, web favicon/icons/manifest, Windows `.ico`
  (verify only Android; say so), states matrix, docs, `03-components.md`, brand section in the design-system docs.

**Pause for my review after B19a, B19e and B19f** with the screenshots.

## Verification

- `flutter analyze` clean; the full test suite green; `dart run tool/design_system_audit.dart --shared` numbers not up;
  `python tool/verify_brand_assets.py` green with the stricter checks.
- Golden screenshots through `tool/screenshots/compare.py`: the contact sheets, the mark in every variant, the
  splash/loading/error screens, each onboarding page, both permission screens, light and dark, 1× and 2× text, saved
  under `docs/design-system/screenshots/ds-b19*/`. A rendering of the icon on circle, squircle and themed-monochrome
  masks, and of the notification icon at 24 dp on a light and a dark status bar.
- New tests: onboarding flow (continue, skip, last page completes once, back/swipe), semantics order, 2× text, reduced
  effects, the mark painter (size, variants, no overflow), the notification icon resource name, and the splash
  error/retry state.
- **Startup gate** (because this touches the manifest, resources and the bootstrap screens): `flutter build apk --debug`
  and `flutter build apk --release` (retry a Gradle loopback/JDK error with `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=.`
  for that build only), then, with a device connected and **no `flutter run` attached**,
  `./tool/verify_debug_startup.ps1 -Serial <serial>`, a USB-unplugged cold launch, and a check that the app reaches
  onboarding, lock or home, not just the first frame.
- **Device install only after the backup gate**: ask me to create and verify an encrypted FinanceFlow backup and keep
  the file and passphrase, wait for my explicit confirmation, then `adb install -r` only. Changing the icon never needs
  a data wipe; if a launcher still shows the old icon, say it is the launcher's cache and suggest a restart, never a
  reinstall. Never test with my real data.
- Say plainly what you could not verify (device status bar rendering, OEM launcher masks, Android 12+ splash animation on
  hardware, themed icons, grain, performance).

## Start

Do steps 0–1 of `06-workflow.md` only. Read everything above, run the coordination checks, take the baseline
(`flutter analyze`, the onboarding, permission and startup tests, the audit, screenshots of the current logo in every
place it appears, the current notification icon on a rendered status bar, and the current native and Flutter splash),
then return:

1. A map of the identity today: every file and place that shows or defines the logo, icon, splash or notification icon,
   how the notification small icon is chosen and why it renders as a circle, what release shrinking does to it, and
   what each onboarding and permission screen shows.
2. Your three logo directions (described, with the reasoning and your recommendation), the asset pipeline plan, the
   splash plan (native and Flutter hand-over), the onboarding story page by page, and the redesign of the two permission
   screens, each with its empty, error, 2× text and reduced-effects states. Offer an alternative for your riskiest idea
   (the travelling mark across onboarding pages, or the Android 12 animated splash icon) and recommend one.
3. Shared components to add, copy changes (with the claim-by-claim honesty check), anything that needs new storage or a
   new dependency, risks, and questions.

Wait for my approval before building anything.
