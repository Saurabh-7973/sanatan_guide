// Direction B — Study / Reference
// Philosophy: a critical edition in your hand. Sanskrit + transliteration + translation
// arranged like a printed commentary. Numbered pada-by-pada. Dense but ordered.

const C_B = {
  cream: '#FDFAF6',
  surface: '#F7F2EC',
  variant: '#EDE8E2',
  divider: '#E0D9CF',
  border: '#CCC5BB',
  borderFaint: 'rgba(204,197,187,0.4)',
  textPrimary: '#1A1210',
  textSecondary: '#6B6360',
  textHint: '#9E9A97',
  saffron: '#E8820C',
  saffronFaint: 'rgba(232,130,12,0.08)',
  saffronMuted: 'rgba(232,130,12,0.12)',
  sanskrit: '#2D1B00',
  translit: '#5A3E28',
  warmGrey10: '#F2EDE6',
  warmGrey50: '#8A7968',
  warmGrey80: '#3A322B',
};

const FB_SANSKRIT = 'TiroDevanagari, "Noto Serif Devanagari", serif';
const FB_DEV      = 'NotoSansDevanagari, "Noto Sans Devanagari", sans-serif';
const FB_EN       = 'Lora, Georgia, serif';
const FB_UI       = 'Outfit, -apple-system, sans-serif';

function DirectionB() {
  return (
    <div style={{
      height: '100%', background: C_B.cream, color: C_B.textPrimary,
      display: 'flex', flexDirection: 'column',
    }}>
      {/* App bar — keeps scripture context visible */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 6,
        padding: '8px 8px 8px 4px',
        borderBottom: `1px solid ${C_B.borderFaint}`,
      }}>
        <IconBtnB icon="back"/>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
          <div style={{
            fontFamily: FB_UI, fontSize: 10, letterSpacing: 1.5, fontWeight: 700,
            color: C_B.saffron, textTransform: 'uppercase',
          }}>Bhagavad Gītā</div>
          <div style={{
            fontFamily: FB_EN, fontSize: 14, fontWeight: 600, color: C_B.textPrimary,
            marginTop: 1,
          }}>Chapter 2 · Verse 47</div>
        </div>
        <IconBtnB icon="book"/>
        <IconBtnB icon="bookmark"/>
        <IconBtnB icon="share"/>
      </div>

      {/* Layer tabs — which layers of the text are visible */}
      <div style={{
        display: 'flex', gap: 6, padding: '10px 12px 8px',
        borderBottom: `1px solid ${C_B.borderFaint}`,
        background: C_B.cream,
      }}>
        <LayerChipB label="Sanskrit" active/>
        <LayerChipB label="IAST" active/>
        <LayerChipB label="Word-by-word" active/>
        <LayerChipB label="English" active/>
        <LayerChipB label="Hindi"/>
      </div>

      {/* Content */}
      <div style={{ flex: 1, overflow: 'auto' }}>
        {/* Sanskrit stanza — indent, with side number in margin */}
        <div style={{ display: 'flex', padding: '20px 16px 8px' }}>
          <div style={{
            width: 28, flexShrink: 0, paddingTop: 6,
            fontFamily: FB_UI, fontSize: 10, fontWeight: 600, letterSpacing: 0.5,
            color: C_B.warmGrey50, textAlign: 'right', paddingRight: 8,
          }}>2.47</div>
          <div style={{ flex: 1, fontFamily: FB_SANSKRIT, fontSize: 19, lineHeight: 1.95,
            color: C_B.sanskrit, letterSpacing: 0.3 }}>
            कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।<br/>
            मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥
          </div>
        </div>

        {/* Transliteration */}
        <div style={{ display: 'flex', padding: '0 16px 16px' }}>
          <div style={{ width: 28, flexShrink: 0 }}/>
          <div style={{ flex: 1, fontFamily: FB_EN, fontSize: 13.5, fontStyle: 'italic',
            lineHeight: 1.65, color: C_B.translit, letterSpacing: 0.3 }}>
            karmaṇy evādhikāras te mā phaleṣu kadācana /<br/>
            mā karmaphalahetur bhūr mā te saṅgo ’stv akarmaṇi //
          </div>
        </div>

        {/* Section: Word-by-word */}
        <SectionHeaderB label="Word by Word" n={8}/>
        <div style={{ padding: '4px 16px 12px', display: 'flex', flexDirection: 'column', gap: 0 }}>
          <WordRowB s="कर्मणि" t="karmaṇi" m="in action, in one's duty"/>
          <WordRowB s="एव" t="eva" m="only, alone"/>
          <WordRowB s="अधिकारः" t="adhikāraḥ" m="the right, authority"/>
          <WordRowB s="ते" t="te" m="of you, yours"/>
          <WordRowB s="मा फलेषु" t="mā phaleṣu" m="never in the fruits"/>
          <WordRowB s="कदाचन" t="kadācana" m="at any time, ever"/>
        </div>

        {/* Section: Translation */}
        <SectionHeaderB label="Translation"/>
        <div style={{ padding: '4px 16px 16px' }}>
          <div style={{
            fontFamily: FB_EN, fontSize: 16, lineHeight: 1.7,
            color: C_B.textPrimary,
          }}>
            You have the right to action alone, never to its fruits. Let not the fruits of action be your motive, nor let your attachment be to inaction.
          </div>
          <div style={{
            marginTop: 8, fontFamily: FB_UI, fontSize: 11, letterSpacing: 0.5,
            color: C_B.warmGrey50,
          }}>
            — after Radhakrishnan
          </div>
        </div>

        {/* Section: Commentary preview */}
        <SectionHeaderB label="Commentary"/>
        <div style={{ padding: '4px 16px 20px' }}>
          <div style={{
            padding: 14, background: C_B.surface, borderRadius: 8,
            borderLeft: `3px solid ${C_B.saffron}`,
          }}>
            <div style={{
              fontFamily: FB_UI, fontSize: 11, letterSpacing: 1, fontWeight: 700,
              color: C_B.saffron, textTransform: 'uppercase', marginBottom: 6,
            }}>Śaṅkara · Advaita</div>
            <div style={{
              fontFamily: FB_EN, fontSize: 14, lineHeight: 1.6,
              color: C_B.warmGrey80,
            }}>
              The verse teaches niṣkāma karma — action performed without selfish motive. The agent's authority extends only to the doing; outcomes belong to the order of dharma.
            </div>
          </div>
        </div>
      </div>

      {/* Bottom bar — thicker, pagination feel */}
      <div style={{
        display: 'flex', alignItems: 'stretch',
        borderTop: `1px solid ${C_B.divider}`, background: C_B.cream,
      }}>
        <NavBtnB dir="prev" num="46"/>
        <button style={{
          flex: 1, background: 'none', border: 'none',
          borderLeft: `1px solid ${C_B.borderFaint}`,
          borderRight: `1px solid ${C_B.borderFaint}`,
          padding: '10px 8px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          fontFamily: FB_UI, fontSize: 12, fontWeight: 500, color: C_B.warmGrey80,
          cursor: 'pointer',
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7M18.5 2.5a2.12 2.12 0 113 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
          Notes
        </button>
        <NavBtnB dir="next" num="48"/>
      </div>
    </div>
  );
}

function IconBtnB({ icon }) {
  const paths = {
    back:     <path d="M19 12H5M12 19l-7-7 7-7"/>,
    bookmark: <path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z"/>,
    share:    <><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="M8.59 13.51l6.83 3.98M15.41 6.51L8.59 10.49"/></>,
    book:     <><path d="M4 19.5A2.5 2.5 0 016.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z"/></>,
  };
  return (
    <button style={{
      width: 40, height: 40, display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: 'none', border: 'none', padding: 0, cursor: 'pointer',
    }}>
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={C_B.warmGrey80} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{paths[icon]}</svg>
    </button>
  );
}

function LayerChipB({ label, active }) {
  return (
    <div style={{
      padding: '5px 10px', borderRadius: 999,
      fontFamily: FB_UI, fontSize: 11.5, fontWeight: 500,
      background: active ? C_B.saffronMuted : 'transparent',
      color: active ? C_B.saffron : C_B.warmGrey50,
      border: `1px solid ${active ? 'transparent' : C_B.borderFaint}`,
      display: 'flex', alignItems: 'center', gap: 5,
    }}>
      {active && <span style={{ width: 5, height: 5, borderRadius: '50%', background: C_B.saffron }}/>}
      {label}
    </div>
  );
}

function SectionHeaderB({ label, n }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: '18px 16px 4px',
    }}>
      <div style={{
        fontFamily: FB_UI, fontSize: 10, fontWeight: 700, letterSpacing: 1.8,
        color: C_B.warmGrey50, textTransform: 'uppercase',
      }}>{label}</div>
      {n && (
        <div style={{
          padding: '1px 6px', background: C_B.warmGrey10, borderRadius: 999,
          fontFamily: FB_UI, fontSize: 10, fontWeight: 600, color: C_B.warmGrey50,
        }}>{n}</div>
      )}
      <div style={{ flex: 1, height: 1, background: C_B.borderFaint }}/>
    </div>
  );
}

function WordRowB({ s, t, m }) {
  return (
    <div style={{
      display: 'grid', gridTemplateColumns: '80px 90px 1fr',
      gap: 10, padding: '8px 0',
      borderBottom: `1px solid ${C_B.borderFaint}`,
      alignItems: 'baseline',
    }}>
      <div style={{ fontFamily: FB_SANSKRIT, fontSize: 15, color: C_B.sanskrit }}>{s}</div>
      <div style={{ fontFamily: FB_EN, fontSize: 12.5, fontStyle: 'italic', color: C_B.translit }}>{t}</div>
      <div style={{ fontFamily: FB_EN, fontSize: 13, color: C_B.warmGrey80, lineHeight: 1.45 }}>{m}</div>
    </div>
  );
}

function NavBtnB({ dir, num }) {
  const isPrev = dir === 'prev';
  return (
    <button style={{
      flex: 1, background: 'none', border: 'none', padding: '10px 14px',
      display: 'flex', alignItems: 'center', justifyContent: isPrev ? 'flex-start' : 'flex-end',
      gap: 8, cursor: 'pointer',
    }}>
      {isPrev && <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={C_B.saffron} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6"/></svg>}
      <div style={{ textAlign: isPrev ? 'left' : 'right' }}>
        <div style={{ fontFamily: FB_UI, fontSize: 9, letterSpacing: 1.5, color: C_B.warmGrey50, fontWeight: 600, textTransform: 'uppercase' }}>{isPrev ? 'Prev' : 'Next'}</div>
        <div style={{ fontFamily: FB_EN, fontSize: 14, fontWeight: 600, color: C_B.textPrimary, marginTop: 1 }}>2.{num}</div>
      </div>
      {!isPrev && <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={C_B.saffron} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 18l6-6-6-6"/></svg>}
    </button>
  );
}

window.DirectionB = DirectionB;
