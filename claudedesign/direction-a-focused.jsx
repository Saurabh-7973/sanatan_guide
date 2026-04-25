// Direction A — Focused Reader
// Philosophy: everything recedes. The verse dominates. Chrome is hair-thin,
// navigation is edge-docked, no cards. The page becomes a manuscript leaf.

const C_A = {
  cream: '#FDFAF6',
  surface: '#F7F2EC',
  variant: '#EDE8E2',
  divider: '#E0D9CF',
  border: '#CCC5BB',
  textPrimary: '#1A1210',
  textSecondary: '#6B6360',
  textHint: '#9E9A97',
  saffron: '#E8820C',
  sanskrit: '#2D1B00',
  translit: '#5A3E28',
  warmGrey50: '#8A7968',
  warmGrey80: '#3A322B',
};

const FONT_SANSKRIT = 'TiroDevanagari, "Noto Serif Devanagari", serif';
const FONT_DEV      = 'NotoSansDevanagari, "Noto Sans Devanagari", sans-serif';
const FONT_EN       = 'Lora, Georgia, serif';
const FONT_UI       = 'Outfit, -apple-system, sans-serif';

function DirectionA() {
  return (
    <div style={{
      height: '100%', background: C_A.cream, color: C_A.textPrimary,
      display: 'flex', flexDirection: 'column',
      fontFamily: FONT_EN,
    }}>
      {/* Top bar — ultra minimal, just hairline actions */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '10px 12px 6px',
      }}>
        <IconBtnA>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={C_A.warmGrey80} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
        </IconBtnA>
        {/* Center: just the verse locator — no scripture label competing */}
        <div style={{
          fontFamily: FONT_UI, fontSize: 11, letterSpacing: 1.5, fontWeight: 600,
          color: C_A.warmGrey50, textTransform: 'uppercase',
        }}>
          BG · 2 · 47
        </div>
        <div style={{ display: 'flex', gap: 4 }}>
          <IconBtnA>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={C_A.warmGrey80} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z"/></svg>
          </IconBtnA>
          <IconBtnA>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={C_A.warmGrey80} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="M8.59 13.51l6.83 3.98M15.41 6.51L8.59 10.49"/></svg>
          </IconBtnA>
        </div>
      </div>

      {/* Content */}
      <div style={{ flex: 1, overflow: 'auto', padding: '14px 28px 24px' }}>
        {/* Location crumb — editorial, not chip */}
        <div style={{
          fontFamily: FONT_UI, fontSize: 11, letterSpacing: 2, fontWeight: 600,
          color: C_A.saffron, textTransform: 'uppercase',
          textAlign: 'center', marginBottom: 2,
        }}>
          Bhagavad Gītā
        </div>
        <div style={{
          fontFamily: FONT_EN, fontSize: 13, fontStyle: 'italic',
          color: C_A.warmGrey50, textAlign: 'center', marginBottom: 32,
        }}>
          Chapter 2 · Sānkhya-yoga · Verse 47
        </div>

        {/* Sanskrit — the star. Left-aligned like a manuscript. */}
        <div style={{
          fontFamily: FONT_SANSKRIT, fontSize: 26, lineHeight: 2.0,
          color: C_A.sanskrit, letterSpacing: 0.4, fontWeight: 400,
          marginBottom: 20,
        }}>
          कर्मण्येवाधिकारस्ते<br/>
          मा फलेषु कदाचन।<br/>
          मा कर्मफलहेतुर्भूर्<br/>
          मा ते सङ्गोऽस्त्वकर्मणि॥
        </div>

        {/* Verse marker — the traditional marginal number */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          marginBottom: 28,
        }}>
          <div style={{ height: 1, background: C_A.divider, flex: 1 }}/>
          <div style={{
            fontFamily: FONT_SANSKRIT, fontSize: 15, color: C_A.warmGrey50,
          }}>॥ २.४७ ॥</div>
          <div style={{ height: 1, background: C_A.divider, flex: 1 }}/>
        </div>

        {/* Translation — quiet, subordinate */}
        <div style={{
          fontFamily: FONT_EN, fontSize: 16, lineHeight: 1.7,
          color: C_A.textPrimary,
        }}>
          You have the right to action alone, never to its fruits. Let not the fruits of action be your motive, nor let your attachment be to inaction.
        </div>

        {/* Tiny inline affordance — tap to expand */}
        <button style={{
          marginTop: 28, background: 'none', border: 'none', padding: 0,
          fontFamily: FONT_UI, fontSize: 12, fontWeight: 500, letterSpacing: 0.5,
          color: C_A.saffron, display: 'flex', alignItems: 'center', gap: 6,
          cursor: 'pointer',
        }}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M6 9l6 6 6-6"/></svg>
          Transliteration · Word meanings · Hindi
        </button>
      </div>

      {/* Bottom — edge-docked, no background panel. Just floats. */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '10px 18px 18px',
      }}>
        <EdgeNavA dir="prev" label="2.46"/>
        <button style={{
          background: C_A.cream, border: `1px solid ${C_A.border}`,
          borderRadius: 999, padding: '8px 14px',
          fontFamily: FONT_UI, fontSize: 12, fontWeight: 500,
          color: C_A.warmGrey80, display: 'flex', alignItems: 'center', gap: 6,
        }}>
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7M18.5 2.5a2.12 2.12 0 113 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
          Note
        </button>
        <EdgeNavA dir="next" label="2.48"/>
      </div>
    </div>
  );
}

function IconBtnA({ children }) {
  return (
    <button style={{
      width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: 'none', border: 'none', padding: 0, cursor: 'pointer',
    }}>{children}</button>
  );
}

function EdgeNavA({ dir, label }) {
  const isPrev = dir === 'prev';
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 6,
      fontFamily: FONT_UI, fontSize: 12, color: C_A.warmGrey50,
      flexDirection: isPrev ? 'row' : 'row-reverse',
    }}>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={C_A.saffron} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
        {isPrev ? <path d="M15 18l-6-6 6-6"/> : <path d="M9 18l6-6-6-6"/>}
      </svg>
      <span>{label}</span>
    </div>
  );
}

window.DirectionA = DirectionA;
