# FinanceFlow_New_Design_System.md

**Design System Specification for FinanceFlow**
Version 1.0 · Derived exclusively from `FinanceFlow_PRD.md.txt` · Flutter + Material 3 · Android-first

---

## 1. Executive Design Direction

### 1.1 Design-System Name

**Stillwater** — the FinanceFlow design system.

The name answers the product name: FinanceFlow is about movement of money; Stillwater is about what that movement becomes when it is private, organized, and under control — a calm, clear body of water that belongs only to you. Deep enough to hold everything, still enough to see into.

### 1.2 One-Sentence Design Philosophy

> Stillwater makes private financial life feel calm, legible, and quietly confident — precision where money is counted, warmth where people are judged by none.

### 1.3 Product Personality

If FinanceFlow were a person, it would be a discreet, competent friend who keeps immaculate personal records, never gossips about your spending, explains things plainly, and only speaks up when it genuinely helps.

| Trait | Expresses as |
|---|---|
| Calm | Muted depths, generous whitespace, slow deliberate motion |
| Precise | Tabular numerals, hairline structure, exact figures (never “~₹12k” in balances) |
| Private | No “social” patterns, no sharing language, explicit on-device assurances |
| Personal | Warm paper neutrals, a serif display voice in quiet moments, first-person ownership language |
| Intelligent, not showy | AI appears as small warm sparks, never as a chatbot mascot |
| Non-judgmental | Overspending is reported as information, never as failure |

### 1.4 Visual Mood

A still pool at the edge of a warm shore: deep teal water, sun-warmed sand, a single marigold accent. Quiet, grounded, unhurried. The mood is “a private study with good light,” not “a trading terminal” and not “a candy-colored neobank.”

### 1.5 Emotional Goals

Every screen should leave the user feeling:

1. **In control** — I can see everything, change everything, delete everything.
2. **Safe** — my data is on my device; the app proves it repeatedly.
3. **Calm** — nothing flashes, shouts, or pressures me.
4. **Capable** — I understand my numbers without needing to be an expert.
5. **Respected** — the app never scolds me for spending.

### 1.6 Core Design Principles

| # | Principle | Meaning |
|---|---|---|
| P1 | **Clarity over decoration** | Every pixel earns its place with information or orientation. |
| P2 | **Privacy made visible** | On-device status, encryption, and AI boundaries are shown, not hidden in settings. |
| P3 | **Numbers are sacred** | Financial figures use exact values, tabular numerals, Indian digit grouping, and never ambiguous rounding in primary positions. |
| P4 | **Information, not judgment** | The system reports; the user decides. No shame language, no guilt colors, no punitive motion. |
| P5 | **AI on a leash** | AI suggestions are labeled, confidence-rated, explainable, and always one tap from being overridden. |
| P6 | **Offline as default state, not error state** | The full app works with zero connectivity; being offline is never styled as broken. |
| P7 | **Warm precision** | Warm neutrals and human voice around hard-edged, exact data. |
| P8 | **Dense when asked, calm by default** | Everyday users get comfort; power users can switch to dense mode. |

### 1.7 What Stillwater Intentionally Avoids

- Default Material blue/purple fintech palettes; neon gradients; “hacker green” terminal aesthetics.
- Mascots, coin characters, flying-money illustrations, gamification streaks and confetti.
- Red-shaming for overspending; fear-based security language (“DANGER!”, “ALERT!!!”).
- Chatbot faces, AI avatars, or AI branding on every screen.
- Dark patterns: no nagging, no guilt-tripping notifications, no hidden deletion.
- Cloud metaphors (clouds, sync circles implying servers) — FinanceFlow has no backend.
- Pure black or pure white large surfaces; both feel sterile and alarm-like.

### 1.8 How Stillwater Reflects Privacy-First and Local-First

- **Depth = privacy.** The primary color is deep water teal; sensitive zones (lock screen, security settings, encrypted backup) use the deepest ink variants — visually “deeper water,” more private.
- **The Boundary Line.** A single visual convention (Section 13): anything that stays on-device is styled calm and unmarked; anything that *can* leave the device (Gemini, Gmail OAuth, Drive backup) crosses an amber “boundary” treatment and always requires explicit consent.
- **No server language anywhere.** Copy never says “sync,” “upload,” or “cloud save” except when describing user-chosen external backup, which is always labeled *optional* and *yours*.
- **Offline is the hero state.** The dashboard carries a quiet “On-device” assurance rather than an offline warning.

---

## 2. User and Product Analysis

Analysis derived strictly from PRD Sections 1–3, 5–7, 16–17, 19–20, 23, 27.

### 2.1 Privacy-Conscious Individuals (Primary)

**PRD signals:** data never leaves device; zero infrastructure; no tracking; encrypted Isar DB; biometric/PIN lock; root detection; screenshot protection; ₹0 infrastructure; “0 bytes on servers.”

**Design implications:**

- Trust must be *demonstrated in the UI*, not promised in marketing: persistent on-device indicators, plain-language encryption notices, visible “nothing left your device” confirmations after AI-offline actions.
- Every permission (SMS, notifications, Gmail) needs a rationale-first request screen with explicit “what we read / what we never read” lists.
- Any external touchpoint (Google OAuth, Gemini, Drive/Dropbox/OneDrive/NAS) must look visually distinct (Boundary treatment) and be off by default.
- Deletion and export must be first-class, obvious, and reassuring — privacy users judge apps by how easily they can leave.

### 2.2 Finance Power Users (Secondary)

**PRD signals:** investments, loans, EMIs, multi-account, CSV/XLSX/OFX/QIF import, export formats, financial health score, tags, full-text search.

**Design implications:**

- A **Dense mode**: tighter rows (48dp), tabular-numeral tables, keyboard-friendly search, batch selection on transactions.
- Exact numbers everywhere; compact notations (₹1.2L) only inside chart axes, never in balances.
- Powerful global search with structured filters + natural language.
- Investments/loans modules use ledger-grade tables, not just cards.

### 2.3 Users Migrating from Axio / Walnut / Fold / Money Manager (Tertiary)

**PRD signals:** listed as tertiary targets; those apps are cloud-connected and notification-driven.

**Design implications:**

- Onboarding must answer “how is this different?” immediately: *your data stays here.*
- Feature parity cues: familiar constructs (category lists, budget bars, SMS detection) presented in calmer, more private packaging.
- CSV import is a migration path — treat it as a first-class guided flow, not an advanced utility.

### 2.4 Users Who Need Quick Transaction Entry

**PRD signals:** manual quick-add across expense/income/transfer/investment/loan/EMI/cash.

**Design implications:**

- Add-transaction must be reachable in ≤ 2 taps from anywhere (persistent FAB/sheet).
- Amount input is the hero control; category is one-thumb reachable; defaults are smart (today, last-used account).
- Save feedback is instant and quiet — no ceremony for a 5-second task.

### 2.5 Users Reviewing Long-Term Trends

**PRD signals:** daily/weekly/monthly/yearly trends, heatmaps, savings rate, merchant analysis.

**Design implications:**

- Charts must degrade gracefully from a 6-inch phone to a tablet.
- Time-range switching must preserve context (no full-screen reloads); animations must not replay tediously.
- Long ranges need summarizing sentences (“You saved 18% of income on average”) — numbers plus narrative.

### 2.6 Users Interacting with AI-Generated Insights

**PRD signals:** AI optional; smart categorization; merchant recognition; insights; forecasting; NL queries; rule-based offline first; Gemini fallback.

**Design implications:**

- AI content must be *visually distinguishable* from facts (transactions, balances) — warm marigold accent + confidence chips.
- Every AI output needs: source reasoning (explainability), one-tap correction, and an off switch nearby.
- When offline rule-based logic runs, label it “On-device rules” — this is a privacy *feature*, worth showing.

### 2.7 Users Managing Sensitive Financial Information

**PRD signals:** biometric lock, PIN, app lock, auto-lock, session timeout, encrypted backups, screenshot protection.

**Design implications:**

- Lock screen is the brand’s trust moment: deepest colors, minimal content, no data preview (no balances on notifications/widgets while locked).
- Amount blurring (“privacy blur”) when app is in recents or screenshot protection is on.
- Security toggles explain trade-offs in one sentence each.

### 2.8 Urgent vs. Informational Content

| Class | Examples | Treatment |
|---|---|---|
| **Urgent / actionable** | Upcoming EMI in 2 days, budget exceeded, unusual spend, subscription renewal tomorrow | Elevated surface, semantic color, appears in Alerts, optional local notification |
| **Informational** | Monthly trend, insight, health score movement, forecast | Calm surfaces, no color alarm, no notifications by default |

Rule: **only urgent items may use strong semantic color and elevation together.** Insights never shout.

### 2.9 Offline-First Implications

- No screen may contain an “offline error.” The offline state chip reads **“Offline — everything still works.”**
- Features that genuinely need network (Gemini, Gmail) show a calm “Needs internet” affordance with the local alternative offered first.
- Backup to external storage is phrased as *your storage*.

### 2.10 Indian Financial & Cultural Context

- INR everywhere; Indian digit grouping (₹1,23,456); lakh/crore awareness on axes.
- UPI, GPay/PhonePe/Paytm/BHIM, and major banks (HDFC, ICICI, SBI, Axis, Federal, Canara, Union) are first-class source visuals in onboarding and source badges.
- Category set includes EMI, Loans, Investments (PPF, NPS, FD, RD, Gold), Subscriptions — mirrors Indian household finance.
- Warmth palette (sand, marigold, clay) resonates locally without cliché; language supports Hindi/Indic scripts via fallback fonts and string externalization.
- Festival/seasonal spending spikes should be expected in trend copy (“Spending rose around Diwali week”) rather than flagged as anomalies.

### 2.11 Key Moments in the User Journey

1. **First trust moment** — permission requests and the “nothing leaves this phone” promise.
2. **First detection** — the first auto-captured transaction; magic + control together.
3. **First duplicate merge** — proof the system is careful.
4. **First budget warning** — the system must inform without scolding.
5. **First AI suggestion** — sets whether AI feels helpful or intrusive.
6. **First backup/restore** — tests trust in the privacy model end-to-end.

### 2.12 Avoiding Anxiety, Shame, and Judgment

- Overspend is described as information: “Food is ₹800 over budget this month” — never “You overspent!”
- No red banners on personal choices; expense color is warm clay, not alarm red.
- No streaks, no leaderboards, no “bad score” animations.
- Health score language focuses on *movable levers* (“Reducing subscriptions by ₹300 would raise your score by 4 points”).
- Users can hide balances (privacy blur) and hide specific accounts from dashboard totals.

---

## 3. Brand Identity

### 3.1 Brand Personality

**The Quiet Steward.** Competent, discreet, warm but not chatty, precise but not cold. Speaks like a trusted accountant who is also a considerate friend. Never a hype-man, never a scolder, never a salesperson.

### 3.2 Brand Voice Attributes

| Attribute | Do | Don’t |
|---|---|---|
| Plain | “You spent ₹4,230 on food this week.” | “Your gastronomic outflows increased!” |
| Calm | “Food budget will run out in ~8 days at this pace.” | “WARNING: Budget crisis ahead!” |
| Owning | “Your data stays on this device.” | “Data is securely handled by our systems.” |
| Honest about limits | “Low confidence — please confirm the category.” | Silently guessing wrong |
| Warm, sparingly | “Nice — Emergency Fund is 60% there.” | “AMAZING!!! You’re crushing it!!! 🔥” |

### 3.3 Tone Guidelines

- **Default tone:** neutral-warm, second person (“your”), present tense.
- **Money facts:** exact, unit always present (₹), Indian grouping.
- **Warnings:** factual + forward-looking + one suggested action. Never blame.
- **Success:** understated acknowledgment, at most one soft positive line; no confetti.
- **Errors:** what happened + what the user can do; never technical dumps on primary text.
- **AI:** always hedged appropriately to confidence; never “I” — the assistant speaks as “Suggestion” or “FinanceFlow suggests,” not as a persona.

### 3.4 Writing Style Rules

1. Sentence case for all UI text (not Title Case), except proper nouns and product names.
2. Numerals for all amounts: ₹5,000 not “five thousand rupees.”
3. Prefer active voice; the user acts, the app assists: “Merge duplicates” not “Duplicates will be merged.”
4. No exclamation marks in financial facts. At most one per celebratory empty-state.
5. No emoji in data UI; permitted only in onboarding illustrations’ alt text and never in amounts/alerts.
6. Time: relative for recent (“Today, 2:14 pm”), absolute for history (“12 Mar 2025”).
7. Avoid jargon: say “merge copies of the same payment,” not “deduplicate fingerprints,” except in power-user settings.

### 3.5 Microcopy Principles

- **One idea per string.** If a message has two ideas, split it into title + supporting line.
- **Action buttons restate the action**: “Merge,” “Keep both,” “Enable Gemini” — never “OK / Cancel” for consequential choices.
- **Privacy microcopy formula:** `[What] stays [where]` — “Transactions stay on this phone.”
- **Boundary microcopy formula:** `[What] goes to [whom], only when [condition]` — “This query goes to Gemini only while Gemini is enabled.”

### 3.6 Naming Recommendations

| Item | Recommendation |
|---|---|
| Design system | **Stillwater** |
| Token namespace | `ff` (e.g., `ff.color.primary`) |
| Flutter widget prefix | `Ff` (e.g., `FfBudgetCard`) |
| Icon set name | **Currents** |
| Type usage name | “Ledger numerals” for tabular figure contexts |
| Dark theme name | “Deep Water” |
| Light theme name | “Daylight” |
| Dense mode name | “Ledger view” |

### 3.7 Appropriate vs. Inappropriate Language — Examples

| Situation | ✅ Appropriate | ❌ Inappropriate |
|---|---|---|
| Budget exceeded | “Food is ₹800 over this month’s budget.” | “You blew your food budget 😬” |
| Low confidence AI | “Not sure about this one — is it Groceries?” | Auto-categorizing silently |
| Large expense | “₹18,500 paid to ABC Jewellers — larger than your usual Shopping spends.” | “ALERT: Massive spend detected!” |
| EMI due | “EMI of ₹6,200 due 3 Jun from HDFC ••4321.” | “Don’t forget to pay or penalties apply!” |
| Savings progress | “Vacation fund is 60% there. About ₹9,000 to go.” | “Only ₹9,000 stands between you and failure to travel.” |
| Health score dropped | “Your score moved 64 → 61, mostly from subscription load.” | “Your financial health is deteriorating.” |
| Offline | “Offline — everything still works on this device.” | “No internet connection. Some features unavailable.” |
| Data deletion | “Delete all FinanceFlow data from this phone? This cannot be undone. Backups you exported are not affected.” | “Are you sure? :-(” |

### 3.8 Communicating Warnings Without Blame or Fear

Formula: **Fact + Scope + Option.**

> “Transport is ₹1,200 over budget **(fact)**. This is mostly from three fuel payments this week **(scope)**. You can adjust the budget or review these payments **(option)**.”

- Never address the user’s character (“careless”), only the numbers.
- Offer the corrective action in the same surface as the warning.
- Warnings expire visually once addressed — no permanent red marks.

### 3.9 Communicating AI Confidence and Uncertainty

| Confidence | Chip label | Visual | Behavior |
|---|---|---|---|
| High (≥ 0.85 or exact rule match) | “High match” | Marigold dot, filled chip | Applied automatically, undoable |
| Medium (0.55–0.84) | “Suggested” | Marigold outline chip | Shown as suggestion; user confirms |
| Low (< 0.55) | “Needs review” | Neutral chip, amber dot | Never auto-applied; asks the user |

Always pair with a one-line reason: “Because: ‘Swiggy Instamart’ matched your Groceries list.”

---

## 4. Visual Concept

### 4.1 Central Metaphor: *Still Water on a Warm Shore*

FinanceFlow’s money-life is rendered as a calm, private pool:

- **Depth** = privacy. The deeper (darker teal) a surface, the more private its content. The lock screen is the deepest point.
- **Clarity** = legibility. The water is still, so you can see everything: crisp tabular numerals “on the surface.”
- **The shore** = warmth. Warm sand neutrals keep the experience human and personal, preventing clinical fintech coldness.
- **A marigold glint** = intelligence. AI moments appear as small warm reflections of light on water — present, pleasant, never the whole scene.
- **Ripples, not waves** = motion. Interactions produce gentle ripples; nothing splashes.

### 4.2 Why It Suits FinanceFlow

| Product truth | Metaphor answer |
|---|---|
| Data stays in one private place | A contained pool — no rivers flowing out to servers |
| Many noisy sources (SMS, notifications, email) settle into one truth | Turbulent inflow → still water |
| Calm, non-judgmental finance | Stillness; no storms over spending |
| Depth of power-user features | Depth gradient: surface (dashboard) → depths (ledger, imports, keys) |
| AI optional and gentle | Glints of light, switched on/off by the user |

### 4.3 Making Financial Data Approachable

- Numbers sit on warm, paper-like surfaces rather than cold white — data feels kept, not audited.
- Categories get soft tinted tiles (a 10–14% wash of their hue), so lists read as gentle mosaics, not spreadsheets.
- Charts use rounded, calm geometry (rounded bar caps, soft donut rings) with generous padding.
- Narrative one-liners accompany every major number, translating data into plain language.

### 4.4 Balancing Warmth and Precision

Stillwater splits the interface into two registers:

1. **The Warm Register** — surfaces, containers, illustrations, voice: sand neutrals, serif display moments, rounded corners, soft tints.
2. **The Precise Register** — numerals, tables, charts, inputs: tabular figures, hairline dividers, strict 4dp grid, exact amounts, minimal rounding on data marks.

Rule: **warmth frames precision; precision never gets decorated.** A budget bar may sit on a warm card, but its value text is exact, tabular, and unadorned.

### 4.5 Expressing Privacy, Control, Clarity, and Progress

- **Privacy:** depth gradient + Boundary Line (amber edge on anything that can leave the device) + “stays on this phone” microcopy.
- **Control:** every AI suggestion has an undo; every auto-detected item shows its source badge (SMS / notification / email / CSV); merge decisions are always user-visible.
- **Clarity:** one primary action per screen; consistent number formatting; semantic colors reserved for meaning, never decoration.
- **Progress:** fill-based metaphors (water rising toward a line) for goals and budgets — progress feels like accumulation, not a race.

---

## 5. Color System

Stillwater rejects default fintech blue. The palette is built from **deep water teal, warm shore sands, marigold light, terracotta clay, and indigo** — grounded, Indian-resonant, and emotionally calm.

### 5.1 Primary Palette — “Deepwater”

| Token | Name | Hex | HSL | Role |
|---|---|---|---|---|
| `colorPrimary` | Deepwater 600 | `#0E5F55` | 172°, 74%, 21% | Primary actions, links, active states, key highlights |
| `colorPrimaryDark` | Deepwater 800 | `#093F39` | 173°, 75%, 14% | Pressed states, dark-theme on-colors base |
| `colorPrimarySoft` | Deepwater 100 | `#D3EDE6` | 168°, 47%, 88% | Primary containers, selected chip fills |
| `colorOnPrimary` | White | `#FFFFFF` | — | Text/icons on primary |
| `colorOnPrimaryContainer` | Deepwater 900 | `#07423B` | 173°, 81%, 14% | Text on primary containers |

White on `#0E5F55` ≈ **7.2:1** contrast.

### 5.2 Secondary Palette — “Shore”

| Token | Name | Hex | HSL | Role |
|---|---|---|---|---|
| `colorSecondary` | Shore 600 | `#71624A` | 38°, 21%, 37% | Secondary actions, metadata emphasis |
| `colorSecondaryContainer` | Shore 150 | `#F0E6D2` | 41°, 47%, 88% | Warm containers, tag fills |
| `colorOnSecondaryContainer` | Shore 900 | `#4A3E2B` | 40°, 27%, 23% | Text on warm containers |

### 5.3 Tertiary / Accent — “Marigold” (also the AI accent)

| Token | Name | Hex | HSL | Role |
|---|---|---|---|---|
| `colorAccent` | Marigold 600 | `#9C6410` | 37°, 81%, 34% | AI accents, highlights, focus moments; text-safe amber |
| `colorAccentBright` | Marigold 450 | `#C98A1F` | 38°, 73%, 45% | Large glyphs, chart accents (not body text on light) |
| `colorAccentContainer` | Marigold 120 | `#FAE3BC` | 42°, 90%, 86% | AI insight card tint, suggestion chips |
| `colorOnAccentContainer` | Marigold 900 | `#5A3A06` | 39°, 87%, 19% | Text on AI containers |

Marigold is reserved. If a screen has more than three marigold elements, AI is being over-featured — reduce.

### 5.4 Neutral Palette — “Mist” (warm grey-greens)

| Token | Hex (Light) | Hex (Dark) | Usage |
|---|---|---|---|
| `neutral0` | `#FFFFFF` | `#0B1412` | Extremes (rarely used raw) |
| `neutral50` | `#F7F5EF` | `#101B19` | App background |
| `neutral100` | `#F2F0E8` | `#14201E` | Low containers |
| `neutral200` | `#EDEBE2` | `#182624` | Containers |
| `neutral300` | `#E7E5DC` | `#1D2D2A` | High containers |
| `neutral400` | `#D8D6CB` | `#2E3D39` | Hairlines, borders |
| `neutral500` | `#B9B7AB` | `#45544F` | Strong borders, disabled icons |
| `neutral600` | `#77857F` | `#7E8D86` | Tertiary text |
| `neutral700` | `#4E5B57` | `#A9B8B0` | Secondary text |
| `neutral900` | `#1B2422` | `#E6EDE8` | Primary text |

### 5.5 Surface Colors (Light / “Daylight”)

| Token | Hex | Purpose |
|---|---|---|
| `surfaceApp` | `#F7F5EF` | Root background (warm paper) |
| `surfaceDefault` | `#FDFDFB` | Cards, sheets |
| `surfaceContainerLow` | `#F2F0E8` | Inset areas, search field resting |
| `surfaceContainer` | `#EDEBE2` | Grouped backgrounds |
| `surfaceContainerHigh` | `#E7E5DC` | Pressed containers |
| `surfaceElevated` | `#FFFFFF` | Dialogs, popovers, FAB |
| `surfaceTintPrimary` | `#E7F3F0` | Selected/on states over primary tint |
| `surfaceSecurity` | `#E3EFE9` | Privacy/security panels |
| `surfaceAi` | `#FBF3E3` | AI insight surfaces |

### 5.6 Surface Colors (Dark / “Deep Water”)

| Token | Hex | Purpose |
|---|---|---|
| `surfaceApp` | `#0B1412` | Root background (ink water) |
| `surfaceDefault` | `#101B19` | Cards |
| `surfaceContainerLow` | `#14201E` | Insets |
| `surfaceContainer` | `#182624` | Groups |
| `surfaceContainerHigh` | `#1D2D2A` | Pressed |
| `surfaceElevated` | `#21332F` | Dialogs, sheets, FAB |
| `surfaceTintPrimary` | `#12332E` | Selected tints |
| `surfaceSecurity` | `#10241F` | Security panels |
| `surfaceAi` | `#201D12` | AI surfaces |

No pure black; dark surfaces carry a teal cast so depth feels like water, not void.

### 5.7 Border Colors

| Token | Light | Dark | Usage |
|---|---|---|---|
| `borderHairline` | `#E4E2D8` | `#22322E` | Card outlines, dividers |
| `borderDefault` | `#D8D6CB` | `#2E3D39` | Inputs, chips |
| `borderStrong` | `#B9B7AB` | `#45544F` | Focused-adjacent, emphasis |
| `borderFocus` | `#0E5F55` | `#7AD8C6` | 2dp focus ring |
| `borderBoundary` | `#C98A1F` | `#E9B366` | “May leave device” boundary (Section 13) |

### 5.8 Text Colors

| Token | Light | Dark | Usage |
|---|---|---|---|
| `textPrimary` | `#1B2422` | `#E6EDE8` | Headlines, amounts, body |
| `textSecondary` | `#4E5B57` | `#A9B8B0` | Supporting text |
| `textTertiary` | `#77857F` | `#7E8D86` | Captions, timestamps |
| `textDisabled` | `#A9B3AE` | `#56635E` | Disabled |
| `textOnPrimary` | `#FFFFFF` | `#063B33` | On primary fills (dark theme: dark text on light teal) |
| `textLink` | `#0E5F55` | `#7AD8C6` | Links (always underlined on hover/focus; icon-paired on mobile) |

### 5.9 Disabled, Focus, Overlay

| Token | Light | Dark | Usage |
|---|---|---|---|
| `fillDisabled` | `#ECEAE2` | `#1B2724` | Disabled control fill |
| `focusRing` | `#0E5F55` @ 100% (2dp) + 2dp offset | `#7AD8C6` | All focusable elements |
| `overlayScrim` | `#10201C` @ 48% | `#050B0A` @ 60% | Under sheets/dialogs |
| `overlayBlurTint` | `#F7F5EF` @ 92% | `#0B1412` @ 92% | Privacy blur over balances |

### 5.10 Semantic Colors

Deliberate choice: **negative financial states use warm clay/terracotta, not alarm red**; true `error` red-orange is reserved for system errors and destructive confirmation. Positive states use green with mandatory +/− and icon redundancy (see §16).

| Token | Light | Dark | Meaning |
|---|---|---|---|
| `colorPositive` | `#177A50` | `#6FD39B` | Success, confirmations, upward-good |
| `colorPositiveContainer` | `#D7EFE0` | `#143324` | Success banners |
| `colorNegative` | `#AE4E2E` | `#E59276` | Expense/downward financial state (clay, calm) |
| `colorNegativeContainer` | `#F7E2D8` | `#3A1F14` | Expense banners |
| `colorWarning` | `#9A6A00` | `#E5C069` | Caution: budgets near limit, renewals due |
| `colorWarningContainer` | `#F8ECC8` | `#362A0C` | Warning banners |
| `colorInfo` | `#3E6278` | `#9CC0D6` | Neutral information |
| `colorInfoContainer` | `#DCE8EF` | `#14252E` | Info banners |
| `colorError` | `#C23A22` | `#F2866F` | System errors, failed imports, destructive confirm |
| `colorErrorContainer` | `#FBDFD8` | `#41160B` | Error banners |

### 5.11 Financial-Specific Colors

| Token | Light | Dark | Meaning & usage |
|---|---|---|---|
| `finIncome` | `#177A50` | `#6FD39B` | Credits, salary, + amounts (with “+” glyph) |
| `finExpense` | `#AE4E2E` | `#E59276` | Debits, − amounts (with “−” glyph) |
| `finSavings` | `#0E7263` | `#62CBB5` | Goals, savings instruments |
| `finDebt` | `#6D4A78` | `#C79BD4` | Loans, EMI, credit-card dues, BNPL (plum: serious, not alarming) |
| `finInvestment` | `#4756A6` | `#A3B0EE` | Stocks, MF, FD, PPF, NPS, gold, crypto (indigo “Neel”) |
| `finTransfer` | `#5C7078` | `#9FB6BF` | Account-to-account movement (neutral slate) |
| `finBudgetBase` | `#0E5F55` | `#7AD8C6` | Budget bars under limit |
| `finBudgetNear` | `#9A6A00` | `#E5C069` | 80–100% used |
| `finBudgetOver` | `#AE4E2E` | `#E59276` | Over limit (with text, never color alone) |

### 5.12 AI-Related Colors

| Token | Light | Dark | Usage |
|---|---|---|---|
| `aiAccent` | `#9C6410` | `#E9B366` | AI glyphs, “Suggested” text |
| `aiContainer` | `#FAE3BC` | `#3B2C10` | AI chips, insight card tint (`surfaceAi`) |
| `aiShimmer` | `#F3E2C2` → `#FBF3E3` | `#2A2413` → `#201D12` | AI processing shimmer |
| `aiOff` | `#77857F` | `#7E8D86` | AI disabled states (grey marigold glyph) |

### 5.13 Privacy & Security Colors

| Token | Light | Dark | Usage |
|---|---|---|---|
| `secInk` | `#142B27` | `#081210` | Lock screen background, deepest private surfaces |
| `secVerified` | `#177A50` | `#6FD39B` | “Encrypted,” “Verified on-device” marks |
| `secBoundary` | `#C98A1F` | `#E9B366` | The Boundary Line for external services |
| `secSurface` | `#E3EFE9` | `#10241F` | Security panels |

### 5.14 Color Usage Rules

1. **Primary teal** is for action and selection, not for painting large data areas.
2. **Marigold** signals AI or special attention — maximum restraint; if everything glows, nothing does.
3. **Financial colors are used only for money meaning.** Never use `finExpense` clay for a generic “close” button.
4. Semantic colors always ship with an icon + text; color is never the sole carrier of meaning.
5. Containers use tinted neutrals, not saturated fills; saturation is reserved for data marks and small controls.
6. Dark theme is not an inverted light theme: shadows are removed, elevation = lighter surface + hairline, and data colors are lightened (see dark values above).
7. Charts pull from the financial palette first; categorical charts use the ordered series palette (§10.3).

### 5.15 Combinations to Avoid

| Avoid | Why | Use instead |
|---|---|---|
| `colorError` red for overspending | Feels like blame/alarm | `finBudgetOver` clay + factual copy |
| Marigold text on white | Fails contrast (~3.1:1) | `#9C6410` minimum, or marigold on `surfaceAi` |
| White text on `colorAccentBright` | Fails contrast | Dark `colorOnAccentContainer` |
| Green and clay adjacent without labels | Color-vision risk | Always add +/−, icons, or legends |
| Pure `#000000` / `#FFFFFF` large surfaces | Sterile, alarm-like | `surfaceApp` values |
| Red + green as the only difference | Deuteranopia risk | Add shape/position/labels (§16) |
| Tinted text below AA on tinted containers | Contrast failure | Use `on…Container` tokens |

### 5.16 Minimum Contrast Expectations

- Body text: **≥ 4.5:1** (WCAG AA).
- Large text (≥ 20sp bold / 24sp) and chart lines/bars: **≥ 3:1** against their surface.
- Interactive icons and control borders: **≥ 3:1**.
- Focus ring: **≥ 3:1** against adjacent colors.
- An “Increase contrast” accessibility toggle raises text colors one step darker/lighter and swaps hairlines to `borderStrong`.

---

## 6. Typography System

### 6.1 Font Families

| Role | Family | Rationale |
|---|---|---|
| **Primary UI** | **Manrope** (variable, 200–800) | Modern, warm geometric; excellent legibility at small sizes; feels personal, not corporate |
| **Numeric/table** | Manrope with tabular figures (`tnum`); fallback **Spline Sans Mono** for reference numbers, CSV previews, IDs | Aligned columns in ledgers and tables |
| **Display (optional)** | **Fraunces** (400–600, soft optical axis) | A warm, human serif used *only* for onboarding hero lines, empty-state titles, and the health-score narrative — the “personal” voice |
| **Indic fallback** | **Noto Sans Devanagari** (+ per-language Noto fallbacks) | Hindi and Indian-language strings; automatic fallback chain |

Flutter stack: `fontFamily: 'Manrope'`, `fontFamilyFallback: ['NotoSansDevanagari', 'Roboto']`. Display: `fontFamily: 'Fraunces'` only via `FfDisplayText`.

### 6.2 Numeric Treatment (“Ledger Numerals”)

- All amounts use **tabular figures**: `fontFeatureSettings: {'tnum': 1}`.
- Amounts always carry ₹; sign convention: income “+ ₹25,000”, expense “− ₹430”, transfer no sign with arrow glyph.
- **Indian digit grouping** via `Intl.NumberFormat('en_IN')`: ₹1,23,456. No decimals unless the transaction has paise; then exactly two (₹120.75).
- **Large balances** (hero): full precision with grouping (₹2,45,318), never abbreviated.
- **Compact values** only on chart axes and tight legends: ₹12k, ₹1.2L, ₹3.4Cr — with a tooltip showing the exact value.
- Negative amounts: minus sign + clay color + context icon; never parentheses-only.

### 6.3 Type Scale (Stillwater Tokens)

| Token | Size/Line | Weight | Tracking | Usage |
|---|---|---|---|---|
| `textDisplayLg` | 36/44 | 700 | −0.75% | Onboarding hero (Fraunces allowed) |
| `textDisplayMd` | 30/36 | 700 | −0.5% | Health score hero, year-in-review |
| `textHeadlineLg` | 26/32 | 700 | −0.4% | Dashboard greeting + total |
| `textHeadlineMd` | 22/28 | 700 | −0.3% | Screen titles |
| `textHeadlineSm` | 19/24 | 600 | −0.2% | Card/section titles |
| `textTitleLg` | 17/24 | 600 | 0% | Dialog/sheet titles |
| `textTitleMd` | 15/20 | 600 | 0% | List section headers |
| `textBodyLg` | 16/24 | 400 | 0% | Long-form, onboarding body |
| `textBodyMd` | 14/20 | 400 | +0.1% | Default body |
| `textBodySm` | 13/18 | 400 | +0.1% | Helper/supporting text |
| `textLabelXl` | 14/20 | 600 | +0.2% | Buttons |
| `textLabelLg` | 13/18 | 600 | +0.3% | Input labels, chips |
| `textLabelMd` | 12/16 | 500 | +0.4% | Captions, metadata |
| `textLabelSm` | 11/14 | 500 | +0.5% | Badges, source tags |
| `numBalanceHero` | 40/48 | 800 | −1% | Dashboard total balance (tabular) |
| `numBalanceLg` | 28/34 | 700 | −0.5% | Account/balance cards (tabular) |
| `numBalanceMd` | 20/26 | 700 | −0.25% | List amounts (tabular) |
| `numBalanceSm` | 15/20 | 600 | 0% | Inline amounts (tabular) |

### 6.4 Line Heights & Paragraphs

- Dense data rows: 1.15–1.3 line-height.
- Body copy: 1.45–1.5; max measure 66 characters.
- Never crop numerals: amount texts use vertical padding, not clipped line boxes.

### 6.5 Text Hierarchy Rules

1. One `headline` per screen; everything else steps down.
2. Amounts are always the most prominent numeric element on their card.
3. Metadata (time, source, account) is `textLabelMd` in `textTertiary` — never competes with the amount.
4. Section headers use `textTitleMd` uppercase **never**; sentence case only.

### 6.6 Truncation & Overflow

- Merchant names: end-truncate at 1 line in lists; full name in detail screen.
- Categories never truncate — wrap or shorten labels instead.
- Amounts **never truncate or wrap**; if space is short, reduce surrounding text, not the number.
- Long notes: 2-line clamp in list, expandable in detail.

### 6.7 Localization & Accessibility

- All strings externalized (ARB), `Intl` for `en-IN` default, Hindi (`hi`) second.
- Devanagari numerals remain Arabic (₹1,23,456) even in Hindi UI — standard Indian financial convention.
- Support system font scale up to **200%**: layouts must reflow; amounts may drop one scale step (hero 40→32) but never below 15sp.
- No text inside fixed-height images; charts get textual summaries for screen readers.
- Respect bold-text accessibility setting: weights shift +100.

---

## 7. Spacing, Sizing, and Layout

### 7.1 Base Unit & Spacing Tokens

Base unit: **4dp**. All spacing is a multiple of 4 (2dp allowed for hairline offsets only).

| Token | Value | Typical use |
|---|---|---|
| `space3Xs` | 2 | Hairline offsets, icon micro-gaps |
| `space2Xs` | 4 | Icon-to-text gaps |
| `spaceXs` | 8 | Chip padding-x, tight stacks |
| `spaceSm` | 12 | Inner component gaps |
| `spaceMd` | 16 | Card padding (compact), list row vertical |
| `spaceLg` | 20 | Screen margins, card padding (standard) |
| `spaceXl` | 24 | Section gaps within a screen |
| `space2Xl` | 32 | Between major sections |
| `space3Xl` | 40 | Hero padding, onboarding |
| `space4Xl` | 56 | Landing moments |

### 7.2 Layout Metrics

| Metric | Value |
|---|---|
| Screen horizontal margin (phone) | 20dp |
| Screen horizontal margin (tablet) | 32dp, content max width 840dp centered |
| Card inner padding | 16dp (dense) / 20dp (comfortable) |
| Card gap (vertical lists of cards) | 12dp |
| Section gap | 24dp |
| List row height (comfortable / dense) | 72dp / 56dp |
| Touch target minimum | **48 × 48dp** (visual control may be smaller with hit-area padding) |

### 7.3 Component Heights

| Component | Comfortable | Dense |
|---|---|---|
| Primary button | 48 | 40 |
| Secondary/tonal button | 44 | 36 |
| Text field | 56 | 48 |
| Amount input (hero) | 72 | 64 |
| Chip | 36 | 32 |
| Bottom nav bar | 80 (incl. inset) | — |
| Nav rail | full height, 80 wide | — |
| Transaction row | 72 | 56 |
| FAB (Add) | 56 circular | 56 |

### 7.4 Corner Radius Scale

| Token | Value | Usage |
|---|---|---|
| `radiusXs` | 4 | Tags, tiny badges |
| `radiusSm` | 8 | Icon tiles, small buttons |
| `radiusMd` | 12 | Inputs, standard buttons, chart cards |
| `radiusLg` | 16 | Cards, list containers |
| `radiusXl` | 24 | Dialogs, hero cards |
| `radius2Xl` | 28 | Bottom sheets (top corners), onboarding panels |
| `radiusFull` | 999 | Chips, avatar-like badges, toggles |

Buttons are **12dp, not pill** — a quiet signature that keeps Stillwater precise rather than bubbly; chips alone are pills.

### 7.5 Border Thickness

| Token | Value | Usage |
|---|---|---|
| `borderWidthHairline` | 0.75 | Dividers in lists |
| `borderWidthDefault` | 1 | Cards, inputs (resting) |
| `borderWidthStrong` | 1.5 | Selected containers |
| `borderWidthFocus` | 2 | Focus rings |
| `borderWidthBoundary` | 1.5 dashed 4-2 | External-service boundary (Section 13) |

### 7.6 Elevation & Shadows

Stillwater prefers **tonal layering + hairlines** over heavy shadows (truer to privacy: nothing “floats above” anything else theatrically).

| Token | Definition | Usage |
|---|---|---|
| `elevation0` | none | Flat content |
| `elevationCard` | hairline border + shadow `0 2 8 rgba(20,35,32,0.05)` | Cards at rest |
| `elevationRaised` | `0 6 16 rgba(20,35,32,0.09)` | FAB, pressed cards, pickers |
| `elevationOverlay` | `0 12 32 rgba(20,35,32,0.14)` + scrim | Sheets, dialogs, menus |
| Dark theme | shadows removed; elevation = surface step + hairline `borderHairline` | All elevated elements |

### 7.7 Responsive Breakpoints & Adaptive Navigation

| Breakpoint | Width | Navigation | Layout |
|---|---|---|---|
| `bpCompact` | < 600dp | Bottom navigation (4–5 destinations) | Single column, full-width cards |
| `bpMedium` | 600–839dp | Navigation rail + top bar | Single column, 840 max content |
| `bpExpanded` | 840–1199dp | Rail; two-pane where useful | Transactions list + detail split |
| `bpLarge` | ≥ 1200dp | Rail with labels | Two-pane + side insights panel |

Android-first: bottom nav on all phones; rail on tablets/foldables. iOS-compatible: same components; platform-adaptive scroll physics, back gesture, haptics; no platform-violating patterns.

### 7.8 Dense Mode (“Ledger View”) vs. Comfortable Mode

| Aspect | Comfortable (default) | Dense (opt-in setting) |
|---|---|---|
| Row height | 72 | 56 |
| Card padding | 20 | 16 |
| Section gap | 24 | 16 |
| Type step | Standard | Amounts drop one step; labels −1 step |
| Extras | Narrative one-liners on | Optional off; tables favored |

Toggle in Settings → Display; dense mode never reduces touch targets below 48dp.

---

## 8. Design Tokens

### 8.1 Token Architecture

Three layers:

1. **Reference tokens** (raw values): `ff.ref.color.teal600`, `ff.ref.space.16` — never used in components.
2. **System/semantic tokens**: `ff.color.primary`, `ff.space.md`, `ff.radius.lg` — used in components.
3. **Component tokens**: `ff.component.budgetCard.barHeight` — overrides scoped to one component.

### 8.2 Naming Convention

`ff.<group>.<role>[.variant][.state]` — e.g., `ff.color.fin.expense`, `ff.color.surface.elevated`, `ff.motion.duration.base`. Flutter constants mirror this: `FfTokens.colorFinExpense`, `FfTokens.spaceMd`.

### 8.3 Core Token Table (excerpt; full set in §18)

| Category | Tokens |
|---|---|
| Color | `colorPrimary`, `colorOnPrimary`, `colorPrimaryContainer`, `colorSecondary`, `colorAccent`, `surfaceApp`, `surfaceDefault`, `surfaceElevated`, `surfaceAi`, `surfaceSecurity`, `textPrimary`, `textSecondary`, `textTertiary`, `textDisabled`, `borderHairline`, `borderDefault`, `borderFocus`, `colorPositive`, `colorNegative`, `colorWarning`, `colorInfo`, `colorError`, `finIncome`, `finExpense`, `finSavings`, `finDebt`, `finInvestment`, `finTransfer`, `aiAccent`, `aiContainer`, `secInk`, `secBoundary`, `secVerified` |
| Typography | `textDisplayLg…textLabelSm`, `numBalanceHero…numBalanceSm`, `fontPrimary`, `fontDisplay`, `fontMonoData`, `fontIndicFallback` |
| Spacing | `space3Xs…space4Xl` |
| Radius | `radiusXs…radius2Xl`, `radiusFull` |
| Elevation | `elevation0`, `elevationCard`, `elevationRaised`, `elevationOverlay` |
| Borders | `borderWidthHairline…borderWidthBoundary` |
| Opacity | `opacityDisabled 0.38`, `opacityOverlay 0.48`, `opacityTint 0.12`, `opacityBlur 0.92` |
| Motion | `durationInstant 80`, `durationFast 160`, `durationBase 240`, `durationSlow 360`, `durationDeliberate 600`, `easeEmphasized`, `easeDecelerate`, `easeAccelerate`, `easeSpringGentle` |
| Breakpoints | `bpCompact`, `bpMedium`, `bpExpanded`, `bpLarge` |
| Component states | `stateHover`, `statePressed`, `stateSelected`, `stateDisabled`, `stateFocused`, `stateDragging` |

### 8.4 Mapping to Material 3

Stillwater is a **custom ColorScheme seeded into Material 3**, not the default seed-derived theme:

| M3 role | Stillwater token |
|---|---|
| `primary` / `onPrimary` | `colorPrimary` / `colorOnPrimary` |
| `primaryContainer` / `onPrimaryContainer` | `colorPrimaryContainer` / `colorOnPrimaryContainer` |
| `secondary`, `secondaryContainer` | Shore palette |
| `tertiary`, `tertiaryContainer` | Marigold palette |
| `surface`, `surfaceContainerLow/Default/High`, `surfaceBright` | Surface tokens §5.5–5.6 |
| `outline`, `outlineVariant` | `borderStrong`, `borderHairline` |
| `error`, `errorContainer` | Error tokens |
| `scrim` | `overlayScrim` |
| **Extensions** (`FfFinColors`, `FfAiColors`, `FfSecColors`) | Financial, AI, privacy palettes via `ThemeExtension` |

Typography maps to M3 `TextTheme` slots (display→`displayLarge`… label→`labelSmall`) with the extra `num*` styles exposed via `FfAmountText`. Shape scale maps to M3 `ShapeScale` (small=12, medium=16, large=24, extraLarge=28).

---

## 9. Component System

Format per component: **Purpose / Structure / Variants / States / Interaction / A11y / Responsive / Do–Don’t** (condensed).

### 9.1 App Shell

- **Purpose:** scaffold hosting navigation, top app bar, content, FAB, overlays.
- **Structure:** `surfaceApp` background; bottom nav (<600dp) or nav rail (≥600); persistent Add FAB (bottom-right, above nav, 16dp margin); global snackbar slot above nav.
- **Variants:** standard; locked (biometric gate replaces content); onboarding (no nav).
- **States:** normal, offline-chip visible, locked, modal-open (scrim).
- **Interaction:** destination switches use `durationSlow` fade-through; FAB morphs into Add-Transaction sheet.
- **A11y:** nav landmarks; FAB labeled “Add transaction”; locked shell exposes nothing to accessibility services except the unlock control.
- **Responsive:** nav adapts per §7.7; two-pane at ≥840.
- **Don’t:** place promotional or “upgrade” UI anywhere — the product has nothing to sell.

### 9.2 Top App Bar

- **Purpose:** screen identity, context actions, status.
- **Structure:** title (`textHeadlineMd`), optional leading back, trailing actions (max 2), optional status slot (on-device chip).
- **Variants:** small (56), medium (with collapsing subtitle), large (dashboard: greeting + hero balance).
- **States:** default, scrolled (gains `surfaceDefault` + hairline), contextual (multi-select: shows count + actions).
- **A11y:** heading semantics on title; actions have labels.
- **Don’t:** more than 2 trailing actions; never show balances in app bar on lock-capable state without blur.

### 9.3 Bottom Navigation

- **Purpose:** 4 primary destinations: **Home, Money (transactions), Plan (budgets/goals/subscriptions/loans), Insights (analytics + health)**.
- **Structure:** `surfaceDefault`, hairline top; items: 24 icon + `textLabelSm`; active = filled icon + `colorPrimary` label + pill indicator (`surfaceTintPrimary`).
- **States:** active/inactive; badge dot for alerts (max count “9+”).
- **Interaction:** tap = switch; retap = scroll to top. No swipe-between-tabs for critical flows.
- **A11y:** `selected` semantics; badges announced (“3 alerts”).
- **Don’t:** a 5th “AI” tab — AI is contextual, not a destination.

### 9.4 Navigation Rail

- Same 4 destinations + settings avatar at bottom; 80dp wide; labels at ≥1200dp; active indicator pill 56×32 `surfaceTintPrimary`.

### 9.5 Dashboard Cards (container pattern)

- **Purpose:** consistent card container used across dashboard.
- **Structure:** `surfaceDefault`, `radiusLg`, `elevationCard`, padding 20; header row (title + optional action), content, optional footer narrative line (`textBodySm`, `textSecondary`).
- **Variants:** standard, actionable (chevron + whole-card tap), emphasized (`surfaceTintPrimary` wash), alert (`colorWarningContainer` tint + icon).
- **States:** rest, pressed (scale 0.99 + `surfaceContainerHigh`), loading (skeleton), empty.
- **A11y:** actionable cards are single buttons with combined label.
- **Don’t:** nest cards in cards; more than one emphasized card per viewport.

### 9.6 Balance Card

- **Purpose:** show an account’s balance or the total.
- **Structure:** account name + masked number (`••4321`), balance `numBalanceLg`, optional delta chip, account-type icon tile.
- **Variants:** total (hero, `numBalanceHero`), per-account, hidden (privacy blur: “₹ ••••••” with eye toggle).
- **States:** rest, blurred, refreshing (local recompute shimmer — instant), hidden.
- **Interaction:** tap → account detail; eye toggle persists per session; long-press → quick hide-all.
- **A11y:** blurred values read as “Balance hidden” — never the actual number.
- **Don’t:** show balances in widgets/notifications while app-locked.

### 9.7 Transaction List Item

- **Purpose:** one transaction row — the most repeated component in the product.
- **Structure (left→right):** category icon tile (36×36, `radiusMd`, 12% category tint) → merchant/category name (`textTitleMd`) + sub-line (`textLabelMd`: time · account · source badge) → amount right-aligned (`numBalanceSm`, tabular; +`finIncome` / −`finExpense`) → optional status glyph (pending merge, AI-suggested dot).
- **Variants:** standard, income, transfer (arrow glyph, slate), AI-pending (marigold dot + “Suggested: Groceries”), duplicate-flagged (outline chip “Possible duplicate”).
- **States:** default, pressed, selected (multi-select check), swiped (edit/delete actions), merged (brief consolidation animation).
- **Interaction:** tap → detail; swipe-left → delete/edit; swipe-right → re-category shortcut; long-press → multi-select.
- **A11y:** combined label: “Swiggy, minus 430 rupees, Groceries, today 2:14 pm, via notification.” Source announced. Swipe actions also available in actions menu.
- **Responsive/dense:** 56dp row hides sub-line account, keeps time.
- **Don’t:** color-only expense/income signaling; more than one badge per row.

### 9.8 Transaction Detail Screen

- **Purpose:** full record + provenance + corrections.
- **Structure:** header (merchant, amount hero, date) → provenance card (“Captured from PhonePe notification · 2:14 pm · original text expandable”) → fields grid (category, account, payment method, tags, notes, location, attachments) → AI panel if suggested → actions (edit, split, delete, report-as-wrong).
- **Hierarchy:** amount > provenance > editable fields > danger zone.
- **States:** view, edit, duplicate-review mode (two records side-by-side + Merge/Keep both).
- **A11y:** provenance original text selectable; every field labeled.
- **Don’t:** bury the source — provenance is a trust feature, keep it visible.

### 9.9 Add Transaction Form

- **Purpose:** manual entry in ≤ 10 seconds.
- **Structure (bottom sheet):** amount input hero (auto-focused) → type segmented control (Expense/Income/Transfer) → category quick-row (last 6 + “More”) → account chip → date (defaults today) → note (optional) → Save bar (sticky).
- **Variants:** quick (sheet), full (screen, for investments/loans/EMI).
- **States:** empty, valid, invalid (amount), saving (button spinner 400ms max), saved (sheet closes + snackbar “Saved on this device”).
- **Interaction:** numeric keyboard with ₹; category auto-suggested by merchant if known (marigold dot).
- **A11y:** full labels; focus order amount→type→category→account→date→note→save.
- **Don’t:** make any field except amount mandatory.

### 9.10 Amount Input

- **Purpose:** money entry, error-proof.
- **Structure:** large ₹ prefix (static), digits `numBalanceHero`-scale, live Indian grouping as typed, helper line (balance hint for transfers).
- **States:** empty (placeholder “0”), typing, valid, invalid (0, exceeds reasonable cap warning ≥ ₹1,00,00,000 asks confirm), disabled.
- **Interaction:** custom numeric pad option for quick entry; paste supported with sanitization.
- **A11y:** announces grouped value on pause; error text linked via live region.
- **Don’t:** scientific notation; free-text currency ambiguity.

### 9.11 Currency Input

- INR-only by default (product scope). Multi-currency fields appear only in investment manual entry as optional “currency” selector disabled to ₹ in v1 with a clear “Only ₹ supported currently” helper. No currency flags or forex styling.

### 9.12 Category Selector

- **Purpose:** pick/change category.
- **Structure:** search box + grid of tiles (icon + label, 3–4 columns) + “Suggested” marigold row at top when AI/rules propose.
- **Variants:** picker (sheet), inline re-categorize (compact horizontal list).
- **States:** default, searching, suggested (with confidence chip), custom-category creation inline.
- **A11y:** icons always paired with text; grid navigable linearly.
- **Don’t:** icon-only mode anywhere.

### 9.13 Merchant Selector

- **Purpose:** normalize merchant (AMZN PAY → Amazon).
- **Structure:** autocomplete over local merchant DB; shows raw string + normalized suggestion with confidence; “Remember this mapping” checkbox (on by default for High).
- **States:** typing, suggested, learned (“You taught us: AMZN PAY = Amazon”), none.
- **A11y:** suggestion announced with confidence.

### 9.14 Account Selector

- **Purpose:** choose account/wallet/card/UPI.
- **Structure:** horizontal chip row (favorites) + full list sheet grouped by type (Bank, UPI, Card, Cash, Investment) with masked numbers and balances.
- **States:** default, hidden-account (excluded from totals, dimmed + “hidden” tag), add-new entry point.

### 9.15 Date Selector

- **Purpose:** date/time for transactions, goals, EMIs.
- **Structure:** M3 date picker restyled (radius, colors); quick chips: Today, Yesterday, This month; range mode for filters.
- **Rules:** default = today; future dates allowed only where meaningful (EMI, goals); always show weekday.

### 9.16 Filter Chips

- **Purpose:** filters in transaction list/analytics.
- **Structure:** pill, `radiusFull`, 36 height; resting `surfaceContainerLow` + `borderDefault`; selected `surfaceTintPrimary` + `colorPrimary` check.
- **States:** rest, selected, pressed, disabled; “Clear all” trailing chip when ≥1 active.
- **A11y:** announces “Filter applied: Food.”

### 9.17 Search Field

- **Purpose:** entry to global search.
- **Structure:** resting `surfaceContainerLow`, `radiusMd`, leading search icon, hint “Search merchant, amount, note…”; focus → `surfaceDefault` + `borderFocus`.
- **States:** rest, focused, typing (clear button), voice (future, PRD §25 — reserve slot only).

### 9.18 Global Search

- **Purpose:** search across merchant, amount, date, category, tags, notes, account (PRD §18).
- **Structure:** overlay under top bar; sections: Transactions (grouped by day), Categories, Merchants, Goals/Budgets; structured filter row (amount range, account, date).
- **States:** empty prompt (recent searches), results, no-results (with “Try: Amazon, ₹500…, last month”).
- **Interaction:** instant local results (full-text Isar); <50ms target; no spinner for local.

### 9.19 Natural-Language Search

- **Purpose:** “How much did I spend on coffee last month?”
- **Structure:** same field; recognized queries show a **query card**: parsed interpretation (“Food & Dining · Apr 1–30”) + result + “Edit query” link; if Gemini needed and enabled → boundary note; if offline → on-device rules answer or honest fallback (“I can search by filters offline — try filters”).
- **States:** parsed-ok, needs-clarification (two chips options), ai-off fallback, no-data.
- **A11y:** parsed interpretation is the accessible summary of results.

### 9.20 Budget Card

- **Purpose:** one budget’s status.
- **Structure:** title + category icon; spent/limit (`numBalanceSm` “₹3,240 / ₹5,000”); progress bar (8dp, `radiusFull` track `surfaceContainerHigh`); footer: remaining or daily allowance or projection line.
- **Variants:** ok (`finBudgetBase`), near (≥80%, `finBudgetNear`), over (`finBudgetOver` + factual line), forecast mode (“runs out in ~8 days”).
- **States:** rest, pressed→detail, editing (inline amount field).
- **A11y:** “Food budget: 3,240 of 5,000 used, 65 percent” — bar is decorative to AT.
- **Don’t:** alarm styling when over; no “!” iconography — use information tone.

### 9.21 Budget Progress Indicator

- Linear bar only (no gauges for budgets); height 8dp; cap rounded; animated fill `durationDeliberate`; over-limit shown as bar capped at 100% + small overflow tick with “+₹800” text — never a growing red bar of shame.

### 9.22 Savings Goal Card

- **Purpose:** track a goal (laptop, vacation, emergency fund).
- **Structure:** goal name + small user-chosen icon; saved/target; water-rise fill metaphor inside a rounded capsule (fill = `finSavings`, gentle wave edge static, not animated loop); target date + completion forecast line.
- **Variants:** active, completed (calm celebration: single ripple + “Completed on 12 Mar”), paused.
- **States:** rest, contributing (sheet with amount), forecast-updated chip.
- **A11y:** fill described textually; wave is decorative.

### 9.23 Subscription Card

- **Purpose:** recurring service status.
- **Structure:** service name + detected source chip; amount + cadence (“₹149/month”); next renewal date; monthly cost footer in list header (“₹1,240/month across 8”).
- **Variants:** active, due-soon (≤3 days, warning tint), detected-unconfirmed (“Looks like a subscription — confirm?”), cancelled.
- **Interaction:** swipe → mark cancelled; tap → history + renewal forecast.
- **Privacy:** detection explained (“Found 3 matching payments from the same merchant”).

### 9.24 Loan & EMI Card

- **Purpose:** one loan/EMI plan.
- **Structure:** loan name + institution; `finDebt` icon tile; EMI amount + next due; progress: paid/total with interest split line (“₹1,12,000 paid · ₹38,000 interest so far”); completion date.
- **Variants:** active, due-soon (urgent class §2.8), closed.
- **States:** rest, due-soon alert, detail (amortization table in dense mode).
- **A11y:** due date absolute; “in 3 days” supplementary.
- **Don’t:** fear language about missed payments; factual reminders only.

### 9.25 Investment Portfolio Card

- **Purpose:** portfolio summary + per-holding rows.
- **Structure:** total value `numBalanceLg`; absolute + % change with sign and `finInvestment`/`finExpense` by direction; allocation donut (max 6 slices); holdings list (name, units, value, P/L with sign).
- **Variants:** summary, holding detail (manual-first: user-entered buy price, quantity; price updates optional/manual in v1).
- **States:** rest, adding holding (form), stale-data note (“Values as entered by you on 2 Apr”).
- **Honesty rule:** since manual-first, never imply live market data; label user-entered values.

### 9.26 Financial Health Score

- **Purpose:** 0–100 composite (savings rate, debt ratio, budget discipline, emergency fund, subscription load, cash flow).
- **Structure:** hero number `textDisplayMd` inside a ring (ring fill = score arc, color = score band), band label (Steady/Building/Watchful), 3 biggest levers list (each with potential point impact), component breakdown in detail.
- **Score bands:** 0–39 Watchful (clay), 40–69 Building (marigold), 70–100 Steady (teal) — labels never judgmental.
- **States:** computed, insufficient data (show which inputs are missing), changed (delta chip “+3 since March”).
- **A11y:** full textual breakdown; ring decorative.
- **Don’t:** gamify; no streaks, no confetti, no score push notifications by default.

### 9.27 Charts

Component wrapper `FfChartCard`: title, range switcher, chart canvas, legend, one-line narrative, long-press tooltip mode. Detailed rules in §10.

### 9.28 Empty States

- **Purpose:** first-run and zero-data moments.
- **Structure:** small Stillwater illustration (≤120dp, line style §11), one Fraunces line (warm), one body line (what goes here), one primary action (add/import/enable source).
- **Rules:** never blame (“No transactions yet” not “You haven’t added anything!”); always offer the fastest next step.

### 9.29 Loading States

- Local-first means loads are usually <100ms: **no spinners under 300ms**. After 300ms: shimmer skeleton. Spinner only for Gmail fetch / Gemini / file import. All spinners are ripple-ring style (expanding circle stroke), 24dp, `colorPrimary`.

### 9.30 Skeleton Screens

- Neutral `surfaceContainerLow→High` shimmer (1.2s loop, `easeEmphasized`), exact geometry of the target component; no marigold shimmer except on AI cards.

### 9.31 Error States

- **Purpose:** something genuinely failed (import parse, backup write, permission lost).
- **Structure:** error icon (info-circle style, not skull/exclamation-heavy), what happened in one line, why if known, 1–2 actions (Retry / Choose file / Settings).
- **Rules:** `colorError` only on icon + action, never a full red screen; never expose stack traces in primary copy (“Details” expander for power users).

### 9.32 Offline States

- Not an error. A dismissible once-per-session chip in the app bar: **“Offline — everything still works.”** Network-dependent features show inline: “Needs internet · Gemini is optional — offline rules are active.”

### 9.33 Sync / Import States

- No “sync” concept (no server). Import states: queued → reading (file progress) → parsing (n of m rows) → review (preview table) → done (summary: “Imported 214 · skipped 12 duplicates · 2 need review”). Undo available for 10 seconds after import.

### 9.34 AI Insight Card

- **Purpose:** one AI/rules-generated insight or forecast.
- **Structure:** `surfaceAi` tint, marigold spark glyph (16dp) + “Insight” label; statement (`textBodyLg`); supporting detail expander (“Because…”); actions: Useful / Not useful / Dismiss; confidence chip.
- **Variants:** insight, forecast (includes horizon + confidence range), suggestion (includes Apply button).
- **States:** fresh, read, dismissed, ai-off placeholder (“Insights are off. On-device rules still categorize for you.”).
- **A11y:** announced as “AI suggestion” explicitly; never disguised as fact.
- **Don’t:** more than 2 insight cards per screen; no insight cards on lock or add flows.

### 9.35 AI Confidence Indicator

- Chip with dot: High (filled marigold), Suggested (outline), Needs review (neutral + amber dot). Always tappable → explanation sheet (inputs considered, rule or model used, whether on-device or Gemini).

### 9.36 Privacy & Security Notices

- **Purpose:** communicate on-device status and boundaries.
- **Structure:** shield-check glyph (`secVerified`) + statement on `surfaceSecurity`; for boundary items: dashed `secBoundary` border + “Leaves this device” line + Enable/Not now.
- **Rules:** notices are statements, not modals, unless consent is required; consent screens never pre-check boxes.

### 9.37 Confirmation Dialogs

- `radiusXl`, `surfaceElevated`, title (`textTitleLg`), body, max 2 actions: dismissive (text button) left, consequential (filled) right; destructive uses `colorError` fill and requires typed/long-press confirm for wipe-all. Never for trivial actions.

### 9.38 Bottom Sheets

- Top radius 28, drag handle 32×4 `borderStrong`, `elevationOverlay` + scrim; snap points at content, 60%, full; keyboard-aware for forms; swipe-down dismissible except mid-save.

### 9.39 Forms (general rules)

- One column on phones; labels above fields (`textLabelLg`); helper text `textBodySm`; inline validation on blur + on submit; error text with icon, `colorError`, never only border color; success = quiet check, not green floods.

### 9.40 Snackbars

- `surfaceElevated` inverted ink text; single line + optional action; 4s; above nav; used for confirmations (“Saved on this device”, “Merged 1 duplicate”, “Export ready”). Never for errors that need decisions (use inline).

### 9.41 Tooltips

- Long-press tooltips for icons and chart marks; `textBodySm` on `secInk` (light theme) / `surfaceElevated` (dark); max 2 lines.

### 9.42 Notifications & Alerts (in-app + local)

- **In-app Alerts inbox:** urgent class items only; grouped by day; each has action.
- **Local notifications:** opt-in per type (PRD §24 smart alerts); content follows §3 voice; amounts included only if lock-screen privacy setting allows, else “Open to view.”

### 9.43 Import & Export Flows

- **Import (CSV/XLSX/OFX/QIF):** pick file → column mapping screen (auto-guessed, editable, dense table preview) → review (counts: new/duplicate/uncertain) → finish summary with Undo. Boundary-free (file stays local).
- **Export (CSV/Excel/PDF/JSON):** choose scope (range, accounts, categories) → choose format → destination via system picker → confirm “Export saved to your storage.” Tax/yearly report templates use print-friendly neutral styling.

### 9.44 Backup & Restore Flows

- **Backup:** encrypted ZIP; choose destination (Drive/Dropbox/OneDrive/NAS/SSD) — all marked **optional, user-controlled, boundary-styled**; progress; completion shows passphrase/key handling status (“Protected with your app passphrase”).
- **Restore:** choose file → passphrase entry (masked) → preview counts → overwrite warning dialog (explicit, two-step) → done.
- **Rules:** backup never happens silently; every backup shows destination in plain words.

### 9.45 Biometric Lock Screen

- **Purpose:** gate the app; the deepest visual moment.
- **Structure:** `secInk` background (deepest teal-black), centered lock glyph animating to open (gentle ripple), prompt for biometric/PIN, fallback PIN pad (numeric, 48dp keys, no dot-animation overshoot).
- **Rules:** zero data visible; app preview blurred via `overlayBlurTint`; failure message neutral (“Try again” — no accusation); timeout escalations stated factually.

---

## 10. Data Visualization System

### 10.1 General Rules

- Clarity over decoration: no 3D, no gradients on marks, no drop shadows, no pictogram bars.
- Every chart ships with: title, range, one-line narrative, legend (or direct labels for ≤4 series), long-press tooltip, and a text summary for screen readers.
- Minimum chart height 160dp (phone), tap targets ≥44dp equivalent (Voronoi/nearest-point hit testing).
- Currency axes: compact (₹5k, ₹1.2L, ₹2Cr) with exact values in tooltips; never truncate data labels.
- Baselines: bars start at zero, always. Truncated axes forbidden (anti-misleading rule).
- Grid: max 4 horizontal lines, `borderHairline`, no vertical grids except time heatmaps.

### 10.2 Chart Specifications

| Chart | Type | Rules |
|---|---|---|
| Category breakdown | Donut (inner radius 0.62) or horizontal bars (default on narrow screens) | Max 6 slices + “Other”; direct labels ≥8% share; sorted descending |
| Income vs expense | Grouped bars by month or dual line | Income `finIncome`, expense `finExpense`; legend + sign labels; net line optional dashed |
| Savings rate | Line with soft area fill (fill opacity 12%) | % axis left, absolute savings tooltip; target line dashed `colorWarning` neutral |
| Spending trends (daily/weekly/monthly/yearly) | Bars (daily/weekly), line (monthly/yearly) | Anomaly dots only when >2σ, tap to explain; festival periods auto-annotated if detectable |
| Merchant analysis | Ranked horizontal bars | Top 10 + rest; show txn count under bar |
| Subscription analysis | Stacked bars by month + list | One color family (marigold shades) since single concept |
| Spending heatmaps | Calendar heatmap (week×day) | Sequential teal scale 5 steps; empty = `surfaceContainerLow`; legend “less→more” |
| Budget progress | Linear bars (§9.21) | Never pie charts for budgets |
| Health score | Ring arc (§9.26) | Single metric only |
| Investment allocation | Donut or treemap (tablet) | `finInvestment` hue variants + category colors; user-entered data timestamp shown |
| Profit & loss | Diverging bars from zero | + above zero `finIncome`, − below `finExpense`; zero line emphasized |
| Debt repayment | Stacked area: principal vs interest over time | Principal `finDebt`, interest `finDebt` at 45% opacity + labels |
| Forecasts | Dashed line projection from solid history | Solid = actual, dashed = forecast; confidence band at 15% opacity |
| Confidence ranges | Band around forecast | Always labeled with % (“likely range”) |

### 10.3 Categorical Series Palette (ordered, color-vision considered)

1. Deepwater `#0E5F55`
2. Marigold `#C98A1F`
3. Neel indigo `#4756A6`
4. Clay `#AE4E2E`
5. Damson `#6D4A78`
6. Grove `#177A50`
7. Slate `#5C7078`
8. Sand `#A08A5F`
Beyond 8 → “Other.” In dark theme, each lightened ~15% (e.g., Deepwater→`#4FB3A3`).

Rules: adjacent slices must differ in both hue and lightness; never place Grove and Clay adjacent without labels; “Enhanced color mode” (§16) swaps series 4 for a blue `#3E6FB0`.

### 10.4 Tooltips, Legends, Axes

- Tooltips: long-press/scrub; ink card with exact value, date, share %; dismiss on release.
- Legends: direct labels preferred; else horizontal legend below, max 2 rows, tap to isolate.
- Axes: `textLabelSm` `textTertiary`; month labels shortened (Jan, Feb); Indian fiscal awareness optional (Apr-start toggle in settings for power users).

### 10.5 Empty / Insufficient Data

- <7 data points: show list/table instead of chart with note “Trends appear after a week of data.”
- Empty: empty-state pattern (§9.28) with the single best next action.

### 10.6 Dark Theme Charts

- Plot background = card surface; grid `#22322E`; series lightened; white text labels at 87%; no shadows; tooltips `surfaceElevated`.

### 10.7 Avoiding Misleading Visualizations

- Zero baselines; consistent axis scales within a comparison; no dual-axis unless labeled explicitly; forecasts always visually separated from actuals; percentages show their denominator; “average” lines disclose the method (mean vs median) in detail.

---

## 11. Iconography and Illustration

### 11.1 Icon Set: “Currents”

- **Grid:** 24dp, 2dp padding, keylines.
- **Stroke:** 1.8dp uniform, rounded caps and joins; interior corner radius ≥2dp.
- **Geometry:** calm geometry — horizontals, gentle arcs, no sharp spikes; metaphor of flow and containment (pools, ripples, layers, shields).
- **Weights:** outline (default); filled (active nav, selected states).
- **Sizes:** 16 (inline badges), 20 (dense rows), 24 (default), 28 (nav), 32 (feature/empty-state).
- **Color:** inherits text color; semantic icons use semantic tokens; never multicolor icons.

### 11.2 Category Icons

- One glyph per default category (PRD §8), drawn in Currents style; each sits on a 36dp tile, `radiusMd`, 12% tint of its category color.
- Custom categories choose from the glyph library + tint; free image upload not in v1 (keeps visual coherence).
- Rule: category identity = glyph + tint, never glyph alone.

### 11.3 Financial Icons

- Income: downward-into-pool arrow (money arriving, not “up = good” stock metaphor); expense: outward ripple; transfer: two-way calm arrows; investment: layered growth lines; debt/EMI: stepped blocks; savings: vessel/jar with water line.

### 11.4 Security & Privacy Icons

- Shield-check (on-device verified), lock (locked), fingerprint (biometric), key-passphrase, eye-off (hidden balance), dashed-boundary square (external service). All use `sec*` colors; shield glyph reserved exclusively for privacy/security — never for marketing badges.

### 11.5 AI Icons

- A single **marigold spark** (four-point glint, soft concavity) — small, quiet, always ≤20dp in UI context. No robot faces, no brains, no “magic wands.” Disabled AI = same spark in `aiOff` grey with a slash-free treatment (dimmed, not crossed out — absence, not punishment).

### 11.6 Illustration Direction

- Minimal single-weight line drawings with at most two tints (ink + one Stillwater hue); subjects: still water, ripples, a single leaf, horizon lines, simple vessels.
- Personality: quiet, warm, adult. **Forbidden:** mascots, faces, coins with faces, rockets, piggy banks, exaggerated perspective, confetti.
- Empty states: ≤120dp illustration + Fraunces one-liner + one action.

---

## 12. Motion and Interaction Design

### 12.1 Motion Personality

**“Water responds; it never performs.”** Motion confirms state and hierarchy. It is short, soft-edged, and always interruptible. Nothing bounces more than once; nothing flashes.

### 12.2 Duration Tokens

| Token | ms | Use |
|---|---|---|
| `durationInstant` | 80 | Press feedback, toggles |
| `durationFast` | 160 | Chips, checkboxes, icon swaps |
| `durationBase` | 240 | Cards, list reorder, sheet snap |
| `durationSlow` | 360 | Page transitions, sheet full open |
| `durationDeliberate` | 600 | Progress fills, chart draw-in, health-score ring |
| `durationCeremony` | 900 | Goal completion ripple only |

### 12.3 Easing

| Token | Curve | Use |
|---|---|---|
| `easeEmphasized` | cubic-bezier(0.2, 0, 0, 1) | Default for entering elements |
| `easeDecelerate` | cubic-bezier(0, 0, 0, 1) | Expanding surfaces |
| `easeAccelerate` | cubic-bezier(0.3, 0, 1, 1) | Exiting elements |
| `easeSpringGentle` | spring(mass 1, stiffness 170, damping 26) | FAB morph, success ripple |

### 12.4 Specific Behaviors

| Moment | Behavior |
|---|---|
| Page transitions | Shared-axis horizontal (360ms); back = reverse; no zoom theatrics |
| Cards | Press: 0.99 scale + surface darken (80ms); release restores |
| List changes | Items fade+slide 8dp (160ms); duplicate merge = collapsing into twin (240ms) |
| Progress bars/rings | Fill with `durationDeliberate`, decelerate; value counts up only if <600ms total |
| Chart animations | Draw-in once per range change (600ms); subsequent filters = 160ms morph; never replay on scroll re-entry |
| Loading | Skeleton shimmer 1.2s loop; ripple spinner for >300ms waits |
| Success | Single soft ripple from action point + snackbar; no confetti |
| Error | Gentle horizontal settle (no violent shake); focus moves to problem |
| Import/detection | Per-batch progress; each detected transaction arrives with a small “settle” drop-in (120ms) in review list |
| AI processing | Marigold shimmer on AI card region only; if <400ms, no shimmer — just result fade |
| Offline | No motion change — offline must not feel degraded |

### 12.5 Reduced Motion

With system reduce-motion: transitions become 100ms crossfades; chart draw-in is skipped (final state instantly); shimmer replaced by static skeletons; ripples become opacity fades; goal completion = static check + text.

### 12.6 Haptics (Android-first)

| Event | Haptic |
|---|---|
| Toggle/chip select | `selectionClick` |
| Save transaction / confirm | `mediumImpact` once |
| Pull-to-dismiss threshold | `lightImpact` |
| Biometric success | `lightImpact` |
| Errors | none (visual carries it — no punitive buzz) |
| Budget-over alert | none by default; opt-in setting |

iOS: map to UIImpactFeedbackGenerator equivalents. Never haptic loops.

---

## 13. Privacy, Security, and Trust UX

### 13.1 The Two Visual Languages

1. **On-device calm** — default everywhere. Shield-check + “Stays on this phone” in `secVerified` green on `surfaceSecurity`. Used for: local storage, encryption at rest, offline rules, local backups, analytics, all core features.
2. **The Boundary** — anything that *may* transmit off-device gets: dashed amber `secBoundary` treatment, explicit statement of what goes where, and an explicit enable action. Applies to: Gmail OAuth, Gemini API, Drive/Dropbox/OneDrive backup, any future integration.

**Rule: no external service is ever enabled by default or pre-checked.**

### 13.2 Pattern Library

| Situation | Pattern |
|---|---|
| Local-only data | Quiet shield-check footer in Settings/Privacy; “0 bytes of your data on servers” line from PRD metrics, stated plainly |
| Encryption | “Encrypted on this device” with expandable detail (Isar encrypted collections, keystore-backed keys) — factual, no fear |
| Biometric/PIN enable | Explain benefit + fallback; enrollment flow never blocks emergency access to own data (recovery via passphrase) |
| Screenshot protection | Toggle with preview of what recents will show (blurred); on by default for lock-enabled users |
| Offline mode | Chip “Offline — everything still works”; AI section shows “On-device rules active” |
| Optional cloud backup | Boundary card listing destination options as *your storage*; each backup shows destination + date + “Encrypted before it leaves” |
| Google OAuth (Gmail) | Boundary consent sheet: exact scopes (“Read-only, only transaction emails”), search patterns shown (e.g., `from:hdfcbank`), “Never sends email content anywhere else”, revoke-anytime link |
| Gemini usage | Boundary + per-feature toggle; each Gemini-powered action shows a one-time inline note “Sent to Gemini for processing”; global kill-switch always in the AI panel |
| External integrations | Registry screen: every integration listed with status, data it touches, last used, disable button |
| Data import | “Files are read only on this device” note; imported rows carry source “CSV · filename” |
| Data export | Confirmation shows exactly what and where; export files user-named |
| Data deletion | Two-step; explicit list of what will be erased; backups you exported are unaffected — stated clearly |
| Permission requests (SMS/notifications) | Rationale-first screen → system prompt; denial gracefully degrades with manual/CSV paths offered |
| AI processing boundaries | Every AI output links to “How this was decided” (rule vs model, inputs used, on-device vs Gemini) |
| User consent | Never pre-checked; “Not now” equal visual weight to “Enable” |
| Uncertain detection | Low-confidence items land in “Needs review” — never silently recorded |
| Duplicate merge | Merge preview shows both originals + merged result; Merge / Keep both / Dismiss; merges undoable 30 days (audit list) |

### 13.3 Trust Micro-moments

- After first notification-captured transaction: “Detected on-device. Nothing was sent anywhere.”
- After backup: “Encrypted backup saved to your Drive folder. Only your passphrase can open it.”
- In About/Privacy: storage facts — “Transactions: 12,431 · stored on this phone · 0 on servers.”

---

## 14. AI Experience Guidelines

### 14.1 Positioning

AI in FinanceFlow is a **quiet assistant**: it files, notices, and forecasts; it never initiates conversations, never occupies a tab, and never blocks. Its home is a small spark, its manners are suggest-then-yield.

### 14.2 Layered Intelligence (PRD §16–17)

1. **Layer 0 — Deterministic rules** (always on, on-device): keyword classification, local merchant DB, user-taught mappings. Labeled “On-device rules.”
2. **Layer 1 — Gemini, per-feature opt-in** (needs internet): smart categorization fallback, merchant normalization, insights, forecasting, NL queries. Labeled with spark + boundary note on first use per feature.

### 14.3 Feature Behaviors

| Feature | Behavior |
|---|---|
| Smart categorization | High confidence → auto-apply + undo chip (10s) in list; Medium → suggestion chip on row; Low → Needs review queue |
| Merchant recognition | Suggest normalized name; “Remember mapping” on by default only for High; learned list editable in Settings |
| Financial insights | Generated ≤1 per day per area; insight card format; each has Because-expander + Useful/Not useful feedback that tunes local weights |
| Forecasting | Always with horizon + confidence band (“Food budget likely exhausted 18–22 May · Medium confidence”); never single-point doom dates |
| Natural language queries | Parse card → result → “Edit interpretation”; offline: filter-based parsing only, honestly labeled |
| Offline rule-based mode | Full categorization/search continue; insights that need model degrade to simple stats (“+22% vs last month” computable locally) |
| Gemini fallback | Only when feature enabled AND internet present AND local confidence insufficient; disclosed inline |

### 14.4 AI States

| State | Presentation |
|---|---|
| Loading | Marigold shimmer on the specific card; >3s → “Still thinking… You can continue — we’ll add it when ready” |
| Success | Result + confidence chip + reason; Apply/Dismiss where consequential |
| Failure (network) | “Couldn’t reach Gemini. On-device rules handled it instead.” + retry |
| Failure (other) | Honest “Insights unavailable right now” — no fake data, ever |
| AI off | Grey spark + what still works (“Categorization continues with on-device rules”) |

### 14.5 Confidence, Correction, Explainability

- Confidence tiers per §3.9; every AI output tappable → **Explanation sheet**: inputs considered, rule/model name, where processed (this device / Gemini), confidence.
- Correction flow: one tap to change category/merchant → system asks “Apply to future ‘Swiggy’ payments?” → learning confirmed with snackbar. Corrections are the primary training signal; the UI thanks with function, not flattery.
- **User approval before consequential changes:** AI never auto-merges duplicates, never auto-deletes, never moves money between accounts/categories of its own accord beyond the undoable High-confidence categorization.

### 14.6 Privacy Disclosure

First enablement of any Gemini feature shows a boundary consent sheet: what data is sent (e.g., “merchant name + amount + category, never your full statement”), that it is optional, and the off switch. A persistent “AI activity” log in Settings lists each external call with timestamp and payload summary.

---

## 15. Screen-Level Design Direction

Common scaffold: `surfaceApp`, 20dp margins, sections separated by 24dp, one primary action.

### 15.1 Onboarding

- **Hierarchy:** Fraunces hero line (value promise) → 3 Stillwater frames: (1) auto-capture sources you choose, (2) private by design (depth visual), (3) AI only when you ask.
- **Layout:** vertical pager, progress dots (not “3 of 5 steps” pressure language), Skip always visible.
- **Key rule:** the privacy promise appears on frame 1, not buried at the end.
- **States:** fresh, returning (restore backup entry point at bottom).

### 15.2 Permission Setup

- One screen per permission (Notifications → SMS → optional Gmail), each: what it enables, what it reads exactly, what it never reads, Continue / Not now (equal weight).
- Denied path: graceful card showing manual + CSV alternatives. Never a dead end.

### 15.3 Dashboard (Home)

- **Hierarchy:** greeting + total balance hero (privacy-blur toggle) → Today strip (spent/income) → Alerts (urgent only, max 3) → Budget status row (horizontal cards) → Insights (max 2 cards) → Upcoming (EMI/subscription) → Accounts glance.
- **Behavior:** pull-to-recalculate (local, instant); on-device chip in app bar; FAB persistent.
- **Empty state:** guided first-run (add manually / import CSV / enable a source).

### 15.4 Transactions

- **Hierarchy:** search field → filter chips (date, type, category, account) → day-grouped list with day totals (± net).
- **Behaviors:** swipe actions, multi-select (sum bar + export/merge/delete), dense toggle inline.
- **Needs-review section** pinned when non-empty (AI-pending, possible duplicates).

### 15.5 Transaction Detail

Per §9.8: amount hero → provenance → fields → AI panel → danger zone. Edit = inline sheet; save snackbar “Saved on this device.”

### 15.6 Add Transaction

Per §9.9 bottom sheet from FAB; full-screen variant for investment/loan/EMI with their extra fields (units, interest rate, tenure).

### 15.7 Budgets

- **Hierarchy:** month summary card (total budgeted vs spent, daily allowance) → budget cards list sorted by urgency (over → near → ok) → create budget action.
- **Detail:** history per month, projection line, edit limit, overspend handling choice (roll over / reset).

### 15.8 Savings Goals

- Capsule water-fill cards grid (1-col phone, 2-col tablet) → goal detail: contributions list, forecast date, add contribution (from transaction or manual), pause.
- Completed goals archive quietly with date.

### 15.9 Subscriptions

- **Hierarchy:** monthly total header → upcoming renewals (next 30 days strip) → active list → detected-unconfirmed section.
- Card actions: view history, mark cancelled, remind me before renewal (local notification opt-in).

### 15.10 Loans & EMIs

- **Hierarchy:** total monthly EMI header + next due (urgent if ≤3 days) → loan cards → add loan.
- **Detail:** amortization table (dense), interest-so-far, prepayment entry, completion forecast.

### 15.11 Investments

- **Hierarchy:** portfolio value + change → allocation donut → holdings list (grouped: Stocks, MF, FD/RD, PPF/NPS, Gold, Crypto, Real Estate) → add holding.
- Manual-first honesty banner: “Values are as you enter them — nothing leaves the app.”

### 15.12 Analytics (Insights)

- **Hierarchy:** time range switcher (sticky) → headline narrative card → chart cards in order: category breakdown, income vs expense, savings rate, trends, merchants, subscriptions, heatmap → health score card last (it is a summary, not the star).
- Each chart card independent with its own range memory.

### 15.13 Search

Per §9.18–9.19: single field, instant local results, NL parse card, structured filter fallback. Recent + saved searches.

### 15.14 AI Assistant / Query Experience

Not a chat screen. A **query surface** inside Search + insight cards elsewhere. If users ask conversationally, show parsed interpretation + answer + follow-up chips (max 3). Session transcript local-only, clearable.

### 15.15 Notifications (Alerts Inbox)

Urgent-class feed: large spend, budget exceeded, renewal, EMI due, goal milestones, income received. Each item: fact + action. Settings link to per-type opt-outs at top.

### 15.16 Backup & Restore

Per §9.44: destination cards (all boundary-styled, all optional), last backup info, auto-backup toggle (to user’s own storage only), restore flow with passphrase and overwrite protection.

### 15.17 Settings

Grouped: Display (theme, dense mode, contrast, balance visibility) · Data (import/export, storage facts, delete) · Sources (SMS/notifications/Gmail toggles + statuses) · AI & integrations (Gemini toggle, AI activity log, learned mappings) · Backup · About. Storage-facts footer on every relevant page.

### 15.18 Security & Privacy Settings

`surfaceSecurity` panel: app lock (biometric/PIN), auto-lock timing, screenshot protection, hide balances, permission audit (what can read what), encryption status (“Active — encrypted collections”), privacy statement. Every toggle has a one-line trade-off.

---

## 16. Accessibility and Inclusive Design

### 16.1 Contrast & Color Independence

- WCAG AA minimum everywhere (4.5:1 body, 3:1 large/UI); tokens pre-validated (§5.16); “Increase contrast” toggle available.
- Meaning never by color alone: +/− signs on amounts, icons on states, text on bars, patterns on forecast bands; “Enhanced color mode” swaps clay↔blue for red-green deficiencies.

### 16.2 Text Scaling & Layout

- Support 100–200% font scale: cards grow vertically, rows wrap to two-line variants, amounts drop max one step; never clip amounts.
- Respect bold-text setting; test Devanagari at large scales (taller glyphs).

### 16.3 Screen Readers (TalkBack/VoiceOver)

- Semantic labels for every component pattern (§9 per-component A11y lines are requirements, not suggestions).
- Amounts read naturally: “Minus four hundred thirty rupees.”
- Charts expose a **text summary** node first, then optional per-point exploration.
- Custom gestures (swipe actions) always duplicated in visible/AT action menus.
- Locked state exposes only unlock controls.

### 16.4 Touch, Motor, Input

- 48dp minimum targets; spacing between targets ≥8dp in dense mode.
- No gesture-only actions; no double-tap-only; long-press always has menu alternative.
- External keyboard/Switch: logical focus order, visible `borderFocus` ring, full functionality via focus + activate (Flutter `FocusNode` traversal audited per screen).

### 16.5 Cognitive Load & Financial Anxiety

- One primary action per screen; progressive disclosure for power features.
- No countdown pressure, no streaks, no guilt copy (§3.8, §2.12).
- Errors: calm, actionable, reversible (Undo where possible).
- Option to hide balances, hide accounts, and mute specific alert types.

### 16.6 Motion & Sensory

- Reduced-motion compliance (§12.5); no flashing >3 flashes/sec ever; haptics optional and minimal.

### 16.7 Localization & Indic Support

- All strings externalized; `en-IN` + `hi` in v1; Noto Sans Devanagari fallback verified; RTL reserved in token logic (margins via logical properties); currency fixed ₹ with Indian grouping; dates “12 Mar 2025” style; numbers never localized to devanagari numerals.

### 16.8 Error Prevention

- Destructive actions: confirm + delay + Undo; money edits show before→after; imports reviewable pre-commit; duplicate merges undoable.

---

## 17. Design-System Governance

### 17.1 Naming Conventions

- **Components:** `Ff<Noun>[<Qualifier>]` — `FfBudgetCard`, `FfAmountField`, `FfAiInsightCard`. One responsibility per widget; composition over configuration.
- **Tokens:** `ff.<group>.<role>.<variant>.<state>`; Dart constants `FfTokens.<group><Role><Variant>`.
- **Files:** `lib/core/theme/tokens/`, `lib/core/theme/stillwater/` (theme data), `lib/shared/widgets/ff/` (components).

### 17.2 Variant Rules

- Variants are closed sets declared up-front (e.g., Button: filled/tonal/text/destructive). New variant = design PR + rationale; no ad-hoc one-off styling in features.
- Component tokens (§8.1 layer 3) are the only sanctioned per-feature overrides.

### 17.3 Contribution & Deprecation

- Changes via PR: proposal (problem, options, tokens touched) → design review → tokens updated in single source → golden tests updated.
- Deprecation: `@Deprecated('Use FfX — removal in v2.4')`, minimum 2 minor releases grace, docs mark DEPRECATED with migration note.

### 17.4 Versioning

- SemVer: MAJOR token removals/renames; MINOR new tokens/components; PATCH fixes. Changelog mandatory; token diff published each release.

### 17.5 Documentation Requirements

Every component documents: purpose, anatomy, tokens used, states, a11y contract, do/don’t with screenshots (Daylight + Deep Water). Tokens documented with M3 mapping and contrast values.

### 17.6 Design-to-Dev Handoff

- Figma variables mirror the token file (§18) 1:1; naming identical.
- Handoff checklist: tokens referenced (no raw hex in features), states enumerated, a11y labels written, motion tokens specified by name.
- Flutter implementation guidance: theme via `ThemeData` + `ColorScheme` + `ThemeExtension<FfFinColors>/<FfAiColors>/<FfSecColors>`; text via `FfText`/`FfAmountText` wrappers enforcing tabular figures; components consume only `FfTokens`.

### 17.7 Testing Requirements

- Golden tests per component (both themes, comfortable + dense, 100% + 160% font scale).
- Contrast CI check on token changes (fails below §5.16).
- A11y audit per release: semantics scan + manual TalkBack pass on the 10 flows in §19.
- Visual regression threshold: 0.1% pixel diff triggers review.

---

## 18. Example Design Tokens

```yaml
# stillwater.tokens.yaml — FinanceFlow Stillwater Design System v1.0
meta: { prefix: ff, platform: flutter, m3: seeded-custom }

color:
  light:
    colorPrimary:            "#0E5F55"
    colorOnPrimary:          "#FFFFFF"
    colorPrimaryContainer:   "#D3EDE6"
    colorOnPrimaryContainer: "#07423B"
    colorSecondary:          "#71624A"
    colorSecondaryContainer: "#F0E6D2"
    colorAccent:             "#9C6410"   # Marigold / AI accent
    colorAccentContainer:    "#FAE3BC"
    surfaceApp:              "#F7F5EF"
    surfaceDefault:          "#FDFDFB"
    surfaceContainerLow:     "#F2F0E8"
    surfaceContainer:        "#EDEBE2"
    surfaceContainerHigh:    "#E7E5DC"
    surfaceElevated:         "#FFFFFF"
    surfaceAi:               "#FBF3E3"
    surfaceSecurity:         "#E3EFE9"
    textPrimary:             "#1B2422"
    textSecondary:           "#4E5B57"
    textTertiary:            "#77857F"
    textDisabled:            "#A9B3AE"
    borderHairline:          "#E4E2D8"
    borderDefault:           "#D8D6CB"
    borderStrong:            "#B9B7AB"
    borderFocus:             "#0E5F55"
    colorPositive:           "#177A50"
    colorPositiveContainer:  "#D7EFE0"
    colorNegative:           "#AE4E2E"
    colorNegativeContainer:  "#F7E2D8"
    colorWarning:            "#9A6A00"
    colorWarningContainer:   "#F8ECC8"
    colorInfo:               "#3E6278"
    colorInfoContainer:      "#DCE8EF"
    colorError:              "#C23A22"
    colorErrorContainer:     "#FBDFD8"
    finIncome:               "#177A50"
    finExpense:              "#AE4E2E"
    finSavings:              "#0E7263"
    finDebt:                 "#6D4A78"
    finInvestment:           "#4756A6"
    finTransfer:             "#5C7078"
    aiAccent:                "#9C6410"
    aiContainer:             "#FAE3BC"
    secInk:                  "#142B27"
    secVerified:             "#177A50"
    secBoundary:             "#C98A1F"
    overlayScrim:            "#10201C7A"
  dark:
    colorPrimary:            "#7AD8C6"
    colorOnPrimary:          "#063B33"
    colorPrimaryContainer:   "#0E4C43"
    colorOnPrimaryContainer: "#C6F0E6"
    colorSecondary:          "#D6C4A2"
    colorSecondaryContainer: "#43392A"
    colorAccent:             "#E9B366"
    colorAccentContainer:    "#3B2C10"
    surfaceApp:              "#0B1412"
    surfaceDefault:          "#101B19"
    surfaceContainerLow:     "#14201E"
    surfaceContainer:        "#182624"
    surfaceContainerHigh:    "#1D2D2A"
    surfaceElevated:         "#21332F"
    surfaceAi:               "#201D12"
    surfaceSecurity:         "#10241F"
    textPrimary:             "#E6EDE8"
    textSecondary:           "#A9B8B0"
    textTertiary:            "#7E8D86"
    textDisabled:            "#56635E"
    borderHairline:          "#22322E"
    borderDefault:           "#2E3D39"
    borderStrong:            "#45544F"
    borderFocus:             "#7AD8C6"
    colorPositive:           "#6FD39B"
    colorNegative:           "#E59276"
    colorWarning:            "#E5C069"
    colorInfo:               "#9CC0D6"
    colorError:              "#F2866F"
    finIncome:               "#6FD39B"
    finExpense:              "#E59276"
    finSavings:              "#62CBB5"
    finDebt:                 "#C79BD4"
    finInvestment:           "#A3B0EE"
    finTransfer:             "#9FB6BF"
    aiAccent:                "#E9B366"
    aiContainer:             "#3B2C10"
    secInk:                  "#081210"
    secVerified:             "#6FD39B"
    secBoundary:             "#E9B366"
    overlayScrim:            "#050B0A99"

typography:
  fontPrimary:  "Manrope"
  fontDisplay:  "Fraunces"
  fontMonoData: "Spline Sans Mono"
  fontIndicFallback: "NotoSansDevanagari"
  tabularFeatures: { tnum: 1 }
  scale:
    textDisplayLg:  { size: 36, line: 44, weight: 700, tracking: -0.75 }
    textDisplayMd:  { size: 30, line: 36, weight: 700, tracking: -0.50 }
    textHeadlineLg: { size: 26, line: 32, weight: 700, tracking: -0.40 }
    textHeadlineMd: { size: 22, line: 28, weight: 700, tracking: -0.30 }
    textHeadlineSm: { size: 19, line: 24, weight: 600, tracking: -0.20 }
    textTitleLg:    { size: 17, line: 24, weight: 600 }
    textTitleMd:    { size: 15, line: 20, weight: 600 }
    textBodyLg:     { size: 16, line: 24, weight: 400 }
    textBodyMd:     { size: 14, line: 20, weight: 400 }
    textBodySm:     { size: 13, line: 18, weight: 400 }
    textLabelXl:    { size: 14, line: 20, weight: 600 }
    textLabelLg:    { size: 13, line: 18, weight: 600 }
    textLabelMd:    { size: 12, line: 16, weight: 500 }
    textLabelSm:    { size: 11, line: 14, weight: 500 }
    numBalanceHero: { size: 40, line: 48, weight: 800, tracking: -1.0, tabular: true }
    numBalanceLg:   { size: 28, line: 34, weight: 700, tracking: -0.5, tabular: true }
    numBalanceMd:   { size: 20, line: 26, weight: 700, tabular: true }
    numBalanceSm:   { size: 15, line: 20, weight: 600, tabular: true }

space:   { 3xs: 2, 2xs: 4, xs: 8, sm: 12, md: 16, lg: 20, xl: 24, 2xl: 32, 3xl: 40, 4xl: 56 }
radius:  { xs: 4, sm: 8, md: 12, lg: 16, xl: 24, 2xl: 28, full: 999 }
borderWidth: { hairline: 0.75, default: 1, strong: 1.5, focus: 2 }
elevation:
  elevation0:       "none"
  elevationCard:    "0 2 8 rgba(20,35,32,0.05) + hairline"
  elevationRaised:  "0 6 16 rgba(20,35,32,0.09)"
  elevationOverlay: "0 12 32 rgba(20,35,32,0.14) + scrim"
opacity: { disabled: 0.38, overlay: 0.48, tint: 0.12, blur: 0.92 }
motion:
  durationInstant: 80
  durationFast: 160
  durationBase: 240
  durationSlow: 360
  durationDeliberate: 600
  easeEmphasized: "cubic-bezier(0.2,0,0,1)"
  easeDecelerate: "cubic-bezier(0,0,0,1)"
  easeAccelerate: "cubic-bezier(0.3,0,1,1)"
breakpoints: { compact: 0, medium: 600, expanded: 840, large: 1200 }

component:
  ffTransactionRow: { heightComfort: 72, heightDense: 56, iconTile: 36, iconTileRadius: 12 }
  ffBudgetBar:      { height: 8, radius: 999 }
  ffGoalCapsule:    { radius: 24, minHeight: 96 }
  ffAmountField:    { height: 72, prefix: "₹", grouping: "en_IN" }
  ffButton:         { heightPrimary: 48, heightSecondary: 44, radius: 12 }
  ffChip:           { height: 36, radius: 999 }
  ffSheet:          { topRadius: 28, handleSize: [32, 4] }
  ffHealthRing:     { thickness: 12, size: 160 }
  ffAiSpark:        { sizeUi: 16, sizeHero: 20, color: "aiAccent" }
```

---

## 19. Example User Flows

### 19.1 Newly Detected Transaction from a Notification

- **Trigger:** PhonePe notification “₹430 paid to Swiggy.”
- **Visual states:** listener parses on-device → transaction appears in Money list with settle drop-in (120ms); source badge “Notification · PhonePe”; category auto-applied “Food” (High match, marigold dot) with undo chip in snackbar: “Categorized as Food · Undo.”
- **Message:** snackbar “Saved on this device.”
- **User actions:** accept (do nothing), undo category, tap to open detail/provenance.
- **Feedback:** single `selectionClick`-level subtlety; no notification by default (opt-in setting).
- **Privacy:** processed entirely on-device; provenance shows raw notification text locally; nothing transmitted.

### 19.2 Possible Duplicate Detected

- **Trigger:** Same ₹430 Swiggy payment arrives via SMS 40s later.
- **Visual states:** fingerprint match flags; list shows one row with outline chip “Possible duplicate”; Needs-review section gains an item.
- **Message:** “Looks like the same payment captured twice (notification + SMS).”
- **User actions:** Merge (default suggestion) / Keep both / Dismiss. Merge preview shows both originals + merged result.
- **Feedback:** merge animation (collapse into twin, 240ms) + snackbar “Merged · Undo (30 days).”
- **Privacy:** matching computed locally; no external calls.

### 19.3 Food Budget Exceeded

- **Trigger:** Food spend crosses ₹5,000 limit.
- **Visual states:** budget card transitions to over state: bar capped at 100% + overflow tick “+₹800,” clay accent, factual footer: “Food is ₹800 over this month’s budget. Mostly dining (5 payments).” Alert inbox gains one item; optional local notification if user enabled budget alerts.
- **Message tone:** fact + scope + option (§3.8) — actions: “Adjust budget” / “Review payments.”
- **Feedback:** no punitive haptics/sound; no red flood.
- **Privacy:** local only; alert copy contains amounts only if lock-screen privacy setting permits.

### 19.4 AI-Generated Spending Insight

- **Trigger:** Morning local computation (rules) detects +22% food vs last month.
- **Visual states:** insight card on dashboard (`surfaceAi`, spark glyph): “You spent 22% more on food this month than last month.” Confidence chip “High match” (computed, not model-guessed); Because-expander: “₹6,120 vs ₹5,010 · 14 more dining payments.”
- **User actions:** Useful / Not useful / Dismiss / “See breakdown” → analytics deep link.
- **Feedback:** card fades in once; never re-animates on re-entry.
- **Privacy:** if Gemini is off, this insight still works (local stats). If Gemini were needed, boundary note + AI log entry would appear.

### 19.5 CSV Statement Import

- **Trigger:** user chooses Import → CSV file.
- **Visual states:** file picker → column mapping (auto-guessed columns with editable dropdowns + 5-row preview in mono data font) → review screen: “214 rows · 202 new · 12 duplicates will merge · 2 uncertain” with per-group expandable previews → Finish.
- **Message:** summary + “Imported from hdfc_march.csv · Undo (10s).”
- **User actions:** edit mapping, exclude rows, confirm, undo.
- **Feedback:** progress bar for parse; success snackbar; uncertain rows go to Needs review.
- **Privacy:** “Files are read only on this device” notice; source tag “CSV” on every imported row.

### 19.6 Using the App Offline

- **Trigger:** airplane mode / no network.
- **Visual states:** app bar shows dismissible chip “Offline — everything still works.” All core screens unchanged. Gemini-dependent surfaces show calm inline note: “Needs internet · On-device rules are active.”
- **User actions:** everything core: track, budget, search, analyze, export.
- **Feedback:** zero error styling; no spinners for local ops.
- **Privacy:** offline is the purest privacy state — the chip doubles as reassurance.

### 19.7 Enabling Optional Gemini Assistance

- **Trigger:** user taps an AI feature (e.g., NL query) while Gemini is off.
- **Visual states:** boundary consent sheet (dashed amber frame): what is sent (“merchant, amount, category — never full statements”), that it’s optional, per-feature toggle, “Not now” equal weight.
- **User actions:** Enable / Not now / Enable with limits (this query only).
- **Feedback:** on enable, spark brightens; AI activity log records each call with payload summary.
- **Privacy:** nothing changes until explicit consent; kill-switch always one tap away in AI panel; onboarding never pre-enables.

### 19.8 Restoring an Encrypted Backup

- **Trigger:** fresh install → “Restore from backup” or Settings → Restore.
- **Visual states:** choose file (Drive/Dropbox/local — boundary-styled sources) → passphrase entry (masked, with hint of key derivation facts, no fear language) → preview: “12,431 transactions · 6 accounts · 9 budgets” → overwrite warning dialog (two-step, explicit) → restore progress → done.
- **Message:** “Restored. Everything is encrypted on this device again.”
- **User actions:** enter passphrase, confirm overwrite, cancel anytime pre-commit.
- **Feedback:** deliberate progress (600ms+ steps), success ripple.
- **Privacy:** decryption happens on-device; wrong passphrase = neutral “That passphrase didn’t match. Try again.” — no lockout drama.

### 19.9 Adding an Investment Manually

- **Trigger:** FAB → Add → Investment (full-screen form).
- **Visual states:** fields: instrument type (Stocks/MF/FD/RD/PPF/NPS/Gold/Crypto/Real Estate), name, units, buy price, date, account, notes; live computed value preview (units × current price if user enters one) labeled “as entered by you.”
- **Message:** honesty note: “FinanceFlow doesn’t fetch market prices — values stay as you enter them.”
- **User actions:** save → portfolio card updates with `finInvestment` indigo allocation slice.
- **Feedback:** save snackbar “Saved on this device”; allocation donut morphs (160ms).
- **Privacy:** entirely local; export includes investments only if user selects scope.

### 19.10 Reviewing an Upcoming EMI

- **Trigger:** EMI ₹6,200 due in 3 days (Home Loan, HDFC ••4321).
- **Visual states:** Loans screen: card gains urgent treatment — elevated surface + warning tint + “Due in 3 days” chip; dashboard Upcoming strip shows it; optional local notification (if enabled) reads “EMI of ₹6,200 due 3 Jun from HDFC ••4321.”
- **User actions:** open detail → see amortization, interest paid, completion date; mark “paid” when the debit transaction is detected (auto-suggested link: “Matched this payment? Link to loan”).
- **Feedback:** linking payment to loan updates remaining principal with deliberate animation.
- **Privacy:** reminder content respects lock-screen privacy setting; all computation local.

---

## 20. Final Design Checklist

Use before shipping any screen.

**Identity & tone**
- [ ] Feels calm, personal, precise — not corporate, not gamified
- [ ] No mascots, confetti, streaks, or fear language
- [ ] Copy follows §3 voice: facts, options, no blame; sentence case; exact ₹ amounts

**Color**
- [ ] Only Stillwater tokens used (no raw hex)
- [ ] Financial colors used only for money meaning; +/− and icons accompany income/expense
- [ ] Marigold count ≤ 3 elements per screen; AI is not over-featured
- [ ] Contrast ≥ 4.5:1 body / 3:1 large text & UI; verified in both Daylight and Deep Water

**Typography**
- [ ] Amounts tabular, Indian-grouped, never truncated or abbreviated in primary positions
- [ ] One headline per screen; hierarchy steps respected
- [ ] Fraunces only in sanctioned display moments

**Layout & spacing**
- [ ] 4dp grid; 20dp margins; touch targets ≥ 48dp
- [ ] Correct radii scale (cards 16, buttons 12, chips pill, sheets 28)
- [ ] Comfortable/dense both tested; tablet ≥600 uses rail and max-width

**Components & states**
- [ ] Every component has rest/pressed/disabled/loading/error/empty states designed
- [ ] Skeletons for >300ms; no spinners for local instant ops
- [ ] Undo available for destructive/merge/import actions

**Data visualization**
- [ ] Zero baselines; exact values in tooltips; narratives present
- [ ] Series palette order respected; ≤6 slices + Other; color-blind redundancy

**Privacy & trust**
- [ ] On-device reassurances present where data is written/read
- [ ] Any external touchpoint carries the Boundary treatment + explicit consent; nothing pre-checked
- [ ] Lock/blur behaviors verified; no balances leak into locked surfaces

**AI**
- [ ] AI outputs labeled with confidence + reason; correction path one tap away
- [ ] AI-off experience fully functional via on-device rules
- [ ] No consequential change without user approval

**Accessibility**
- [ ] Semantics labels written and TalkBack-tested; charts have text summaries
- [ ] Works at 200% font scale; reduced-motion variant exists
- [ ] Hindi strings rendered and reviewed with Devanagari fallback

**Motion**
- [ ] Durations/easing from tokens only; success = ripple + snackbar; no loops or multi-bounces
- [ ] Haptics minimal and optional

**Offline & honesty**
- [ ] Screen works 100% offline; offline framed positively
- [ ] Manual/estimated data labeled as such; no implied live feeds

---

*Stillwater — FinanceFlow Design System v1.0. Your entire financial life, calm and clear, in water that belongs only to you.*