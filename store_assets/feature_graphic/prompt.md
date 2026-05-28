# Feature graphic — 1024 × 500

Play Store displays this at the top of your listing on web + above the
app preview on mobile. Single horizontal image. No app screenshots —
this is iconographic, not a screenshot collage.

## Constraint

- **Exact** 1024 × 500 px, PNG, RGB (no alpha).
- No text saying "Sanatan Guide" needed (Play overlays the app name).
- But a tagline or visual cue is fine.

## Prompt for image generation

Use one of: Nano Banana, GPT Image 1 (gpt-image-1), DALL-E 3, Midjourney.

### Primary prompt (paste verbatim)

```
A serene horizontal banner, 1024×500 aspect ratio, in the style of a
contemporary Indian heritage product: warm ivory cream background
(#F5EDE0), a single off-center mandala in saffron line-art (#C26A1A,
0.4 alpha) occupying about 30% of the right side, faint Sanskrit verse
text in Devanāgarī running in two slim parallel horizontal lines on
the left third — text is decorative, blurred and at 0.15 alpha (no
specific verse needed), Lora serif italic English subtitle "scripture,
in your pocket" in muted iron-red #8B3A1F at the lower-left, centred
vertically, with generous breathing space. No phone mockup. No app icon.
No people. No deities. Quiet, calm, scholarly mood — think a museum
catalog cover or a fine Indian publishing house imprint. Subtle paper
grain texture throughout. Composition is asymmetric: text/quote left,
mandala right, with negative space between.
```

### Style references (if the tool accepts them)

- Penguin Classics India imprint covers (the cream + ochre band style)
- Roli Books art-book covers
- Phaidon Press art monograph spines

### Variations to try

If the first generation is too busy:

```
…remove the mandala. Replace with a single thin saffron horizontal
brush stroke at 40% width crossing the lower-third. Otherwise identical.
```

If too sparse:

```
…add three thin vertical neem-leaf silhouettes on the right edge in
muted sage green #6B8E5A, very subtle (0.2 alpha).
```

## Negative prompts (avoid)

- AI-typical glow / neon / cyberpunk
- Faces, hands, deity iconography (cultural sensitivity)
- Lotus clichés in pink/magenta
- Stock-photo person meditating
- Phone in hand
- Cartoonish characters
- Text rendering — let Play overlay the title; don't bake "Sanatan
  Guide" into the graphic (LLM-image tools mangle that text anyway)

## After generation

1. Verify exactly 1024 × 500 — crop if needed via:
   `sips -c 500 1024 input.png --out output.png`
2. Check at thumbnail size (200×100). The mandala or stroke should still
   read; the Devanāgarī text won't, that's fine — it's texture.
3. Save as `feature_graphic.png` in this folder.

## Fallback

If image-gen output isn't usable in 3-4 tries: use a clean typographic
treatment instead — single Sanskrit aphorism rendered cleanly in Tiro
Devanāgarī font, saffron on cream, no illustration. The app name itself
becomes the brand. Open Figma → 1024×500 → set color #F5EDE0 → place
"सर्वं खल्विदं ब्रह्म" (Chāndogya 3.14.1) in 96pt Tiro Devanāgarī
saffron #C26A1A, centered → export. Done.
