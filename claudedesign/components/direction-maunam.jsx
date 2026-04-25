// Direction C — "Maunam" (Silence)
// Contemplative / meditative. One verse fills the screen with breath-spacing.
// Every pada gets its own line, spaced so the eye naturally rests on each.
// The ॥ double-danda becomes a STRUCTURAL mark — a small bindu between padas,
// not a text glyph. Translation is hidden by default and revealed with a
// single upward drag on the "pull tab" at the bottom.
//
// Chrome is a pair of centered ornaments — one at top, one at bottom. Nothing
// else. The back chevron sits in the very corner, quiet. No cards, no chips.
//
// The top ornament contains the chapter · verse mark. The bottom ornament is
// the pull tab: when the reader is ready, they drag up and the translation
// rises into view beneath a thin saffron filament.

function MaunamScreen() {
  const bg      = '#0A0908';      // slightly deeper than surface to feel like a chamber
  const text    = '#F0EBE5';
  const muted   = '#8F867F';
  const faint   = 'rgba(143,134,127,0.4)';
  const saff    = '#F4A830';
  const saffDim = 'rgba(244,168,48,0.25)';
  const sansC   = '#E8D9C0';
  const hair    = 'rgba(240,235,229,0.06)';

  // Pre-split padas (half-verse lines). We drop the ॥ and render our own bindu.
  const padas = splitPadasForMaunam(VERSE.sanskrit);

  // "Translation revealed" state (pull-tab). Render in partially-open state
  // so the affordance is visible in screenshots.
  const translationOpen = 0; // 0 = closed; use a small peek to show what it is

  return (
    <div className="phone dark" style={{
      background: bg, display: 'flex', flexDirection: 'column',
      color: text, position: 'relative',
    }}>

      {/* Very faint vignette — like candlelight on stone */}
      <div style={{
        position: 'absolute', inset: 0,
        background: 'radial-gradient(ellipse at center, rgba(244,168,48,0.035) 0%, transparent 55%)',
        pointerEvents: 'none',
      }} />

      {/* ── Whisper-level top corners ──────────────────────────────── */}
      <div style={{
        display: 'flex', alignItems: 'center',
        padding: '6px 6px 0', flexShrink: 0, position: 'relative', zIndex: 2,
      }}>
        <button style={cornerBtn}>{Icon.back(muted)}</button>
        <div style={{ flex: 1 }} />
        <button style={cornerBtn}>{Icon.bookmark(saff, true)}</button>
      </div>

      {/* ── Top ornament: chapter·verse mark ───────────────────────── */}
      <div style={{
        display: 'flex', flexDirection: 'column', alignItems: 'center',
        marginTop: 14, marginBottom: 10,
        position: 'relative', zIndex: 2,
      }}>
        <TopBindu color={saff} />
        <div style={{
          fontFamily: 'var(--f-sanskrit)', fontSize: 15,
          color: saff, letterSpacing: 1, marginTop: 8, opacity: 0.85,
        }}>
          २ · ४७
        </div>
        <div style={{
          fontFamily: 'var(--f-ui)', fontSize: 9, fontWeight: 500,
          letterSpacing: 3, color: faint, textTransform: 'uppercase',
          marginTop: 5,
        }}>
          Bhagavad Gītā
        </div>
      </div>

      {/* ── The verse — centered, breath-paced ─────────────────────── */}
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        justifyContent: 'center', alignItems: 'center',
        padding: '0 24px',
        position: 'relative', zIndex: 2,
      }}>
        {padas.map((p, i) => (
          <React.Fragment key={i}>
            <div style={{
              fontFamily: 'var(--f-sanskrit)',
              fontSize: 23,
              lineHeight: 2.1,
              color: sansC,
              letterSpacing: 0.5,
              textAlign: 'center',
              textWrap: 'balance',
              maxWidth: 320,
            }}>
              {p}
            </div>
            {i < padas.length - 1 && <LineBindu color={saff} />}
          </React.Fragment>
        ))}
      </div>

      {/* ── Peek of translation (partially-revealed state) ───────── */}
      {/* Shown at ~12% so the screenshot communicates the affordance. */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        height: 96, pointerEvents: 'none', zIndex: 3,
      }}>
        {/* translucent sheet — rises on pull */}
        <div style={{
          position: 'absolute', inset: 0,
          background: `linear-gradient(to top, rgba(14,12,11,0.95) 50%, rgba(14,12,11,0.6) 80%, rgba(14,12,11,0) 100%)`,
        }} />

        {/* hairline saffron filament */}
        <div style={{
          position: 'absolute', left: 40, right: 40, bottom: 62,
          height: 1, background: `linear-gradient(to right, transparent, ${saffDim}, transparent)`,
        }} />

        {/* pull tab */}
        <div style={{
          position: 'absolute', left: '50%', bottom: 42,
          transform: 'translateX(-50%)',
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
        }}>
          <div style={{
            width: 32, height: 2.5, background: 'rgba(240,235,229,0.18)',
            borderRadius: 2,
          }} />
          <div style={{
            fontFamily: 'var(--f-english)', fontStyle: 'italic',
            fontSize: 12, color: muted, letterSpacing: 0.3,
          }}>
            pull up for meaning
          </div>
        </div>
      </div>

      {/* ── Bottom ornament: silence mark + prev/next taps ─────── */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 18px 22px', flexShrink: 0,
        position: 'relative', zIndex: 4,
      }}>
        <button style={{ ...cornerBtn, opacity: 0.55 }}>{Icon.chevL(muted, 20)}</button>
        <div style={{
          fontFamily: 'var(--f-sanskrit)', fontSize: 13, color: faint,
          letterSpacing: 2, display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <div style={{ width: 14, height: 1, background: faint, opacity: 0.5 }}/>
          <span style={{ opacity: 0.7 }}>मौनम्</span>
          <div style={{ width: 14, height: 1, background: faint, opacity: 0.5 }}/>
        </div>
        <button style={{ ...cornerBtn, opacity: 0.55 }}>{Icon.chevR(muted, 20)}</button>
      </div>
    </div>
  );
}

// Top ornament — a concentric bindu with two ruling lines flanking
function TopBindu({ color }) {
  return (
    <svg width="68" height="14" viewBox="0 0 68 14" fill="none" style={{ opacity: 0.8 }}>
      <path d="M0 7h24" stroke={color} strokeWidth="0.7" strokeLinecap="round" opacity="0.55" />
      <path d="M44 7h24" stroke={color} strokeWidth="0.7" strokeLinecap="round" opacity="0.55" />
      <circle cx="34" cy="7" r="4.5" stroke={color} strokeWidth="0.9" fill="none" />
      <circle cx="34" cy="7" r="1.4" fill={color} />
    </svg>
  );
}

// Between-line bindu: a tiny diamond + dot, small enough to feel like punctuation
function LineBindu({ color }) {
  return (
    <div style={{ padding: '14px 0', display: 'flex', justifyContent: 'center' }}>
      <svg width="6" height="6" viewBox="0 0 6 6" fill="none" style={{ opacity: 0.55 }}>
        <path d="M3 0.5l2.5 2.5-2.5 2.5-2.5-2.5z" stroke={color} strokeWidth="0.7" fill="none"/>
        <circle cx="3" cy="3" r="0.6" fill={color}/>
      </svg>
    </div>
  );
}

// For Maunam we drop the dandas entirely (we render our own bindu) and split
// on every single/double danda.
function splitPadasForMaunam(sanskrit) {
  return sanskrit
    .replace(/\n/g, ' ')
    .split(/।।|॥|।/)
    .map(s => s.trim())
    .filter(Boolean);
}

const cornerBtn = {
  background: 'transparent', border: 0, padding: 10, cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  color: 'inherit',
};

Object.assign(window, { MaunamScreen });
