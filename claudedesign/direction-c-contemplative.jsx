// Direction C — Meditative / Contemplative
// Philosophy: one verse, one breath. No chrome at all. The verse is centered
// vertically. Deep warm cream background, extreme air, controls hidden under taps.

const C_C = {
  cream: '#FDFAF6',
  warmCream: '#F5EFE4',    // slightly warmer, like old paper
  divider: '#E0D9CF',
  border: '#CCC5BB',
  textPrimary: '#1A1210',
  textSecondary: '#6B6360',
  saffron: '#E8820C',
  sanskrit: '#2D1B00',
  translit: '#5A3E28',
  warmGrey50: '#8A7968',
  warmGrey80: '#3A322B',
};

const FC_SANSKRIT = 'TiroDevanagari, "Noto Serif Devanagari", serif';
const FC_EN       = 'Lora, Georgia, serif';
const FC_UI       = 'Outfit, -apple-system, sans-serif';

function DirectionC() {
  return (
    <div style={{
      height: '100%', background: C_C.warmCream, color: C_C.textPrimary,
      display: 'flex', flexDirection: 'column', position: 'relative',
      fontFamily: FC_EN,
      // subtle paper texture feel via radial gradient vignette
      backgroundImage: 'radial-gradient(ellipse 80% 60% at 50% 40%, #FDFAF6 0%, #F5EFE4 70%, #ECE4D5 100%)',
    }}>
      {/* Floating minimal controls — fade in on tap */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '12px 14px 6px', opacity: 0.65,
      }}>
        <FadedIconC><path d="M19 12H5M12 19l-7-7 7-7"/></FadedIconC>
        <FadedIconC><path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z"/></FadedIconC>
      </div>

      {/* Everything else is centered, breath-like */}
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
        padding: '0 30px', textAlign: 'center',
      }}>
        {/* Tiny location mark — almost invisible */}
        <div style={{
          fontFamily: FC_UI, fontSize: 9.5, letterSpacing: 3, fontWeight: 500,
          color: C_C.warmGrey50, textTransform: 'uppercase', marginBottom: 36, opacity: 0.7,
        }}>
          Gītā &nbsp;·&nbsp; 2 &nbsp;·&nbsp; 47
        </div>

        {/* Sanskrit — airy, centered, huge line height */}
        <div style={{
          fontFamily: FC_SANSKRIT, fontSize: 22, lineHeight: 2.4,
          color: C_C.sanskrit, letterSpacing: 0.8, fontWeight: 400,
          marginBottom: 40,
        }}>
          कर्मण्येवाधिकारस्ते<br/>
          मा फलेषु कदाचन॥
        </div>

        {/* A single glyph ornament */}
        <div style={{
          width: 6, height: 6, borderRadius: '50%',
          background: C_C.saffron, opacity: 0.55, marginBottom: 32,
        }}/>

        {/* Translation — distilled, short. One sentence. */}
        <div style={{
          fontFamily: FC_EN, fontSize: 16, fontStyle: 'italic', lineHeight: 1.7,
          color: C_C.warmGrey80, maxWidth: 290,
          textWrap: 'pretty',
        }}>
          Your right is to action alone, never to its fruits.
        </div>
      </div>

      {/* Breath indicator / minute reading — contemplative flourish */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        gap: 8, padding: '0 0 14px',
        fontFamily: FC_UI, fontSize: 10, letterSpacing: 2, fontWeight: 500,
        color: C_C.warmGrey50, textTransform: 'uppercase', opacity: 0.8,
      }}>
        <div style={{ width: 20, height: 1, background: C_C.border }}/>
        <span>Breathe · Tap for more</span>
        <div style={{ width: 20, height: 1, background: C_C.border }}/>
      </div>

      {/* Bottom — edge arrows only. No background, no labels. */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '6px 18px 20px',
      }}>
        <FadedIconC size={22}><path d="M15 18l-6-6 6-6"/></FadedIconC>
        <div style={{
          fontFamily: FC_UI, fontSize: 10, letterSpacing: 1.5, color: C_C.warmGrey50,
          fontWeight: 500, opacity: 0.7,
        }}>47 / 72</div>
        <FadedIconC size={22}><path d="M9 18l6-6-6-6"/></FadedIconC>
      </div>
    </div>
  );
}

function FadedIconC({ children, size = 20 }) {
  return (
    <button style={{
      width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: 'none', border: 'none', padding: 0, cursor: 'pointer',
    }}>
      <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={C_C.warmGrey80}
        strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
        {children}
      </svg>
    </button>
  );
}

window.DirectionC = DirectionC;
