// Direction B — "Pīṭha"
// Study / reference tool. Mirrors the printed Gita-commentary stack:
//
//   1. Sanskrit (mūla)
//   2. Padaccheda  — word-by-word split  (toggled on/off inline below Sanskrit)
//   3. Anvaya / IAST — pronunciation / prose order
//   4. Anuvāda  — translation
//   5. Bhāṣya    — commentary (AI)
//
// A segmented rail at the top lets the reader choose which reference LAYERS
// are showing (multi-select, not single-select). The chosen layers reveal
// INLINE in their canonical positions — not in collapsed accordions at the
// bottom of the screen. This is how printed critical editions read.
//
// Left margin carries a manuscript-style colophon. Bottom bar is scholar's
// toolbar: prev/next, bookmark/note, ask.

function PithaScreen() {
  const bg        = '#0F0F0F';
  const surface   = '#1C1816';
  const elevated  = '#221E1B';
  const highest   = '#2A2520';
  const text      = '#F0EBE5';
  const muted     = '#9B9390';
  const faint     = 'rgba(155,147,144,0.55)';
  const saff      = '#F4A830';
  const saffDim   = 'rgba(244,168,48,0.55)';
  const saffBg    = 'rgba(232,130,12,0.12)';
  const sansC     = '#E8D9C0';
  const rule      = 'rgba(240,235,229,0.08)';
  const ruleStrong= 'rgba(240,235,229,0.14)';

  // Layer toggles — imitate the multi-select pattern of critical-edition layouts
  const [layers, setLayers] = React.useState({
    translit: false,     // pada paṭha / IAST pronunciation
    padaccheda: true,    // word-by-word
    anuvada: true,       // English translation  (always on by default)
    hindi: false,        // Hindi translation
    bhashya: false,      // AI commentary
  });
  const toggle = (k) => setLayers(s => ({ ...s, [k]: !s[k] }));

  return (
    <div className="phone dark" style={{ background: bg, display: 'flex', flexDirection: 'column', color: text }}>

      {/* ── Scholar top bar ──────────────────────────────────────────── */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 4,
        height: 48, padding: '0 6px', flexShrink: 0,
      }}>
        <button style={sBtn}>{Icon.back(muted)}</button>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <div style={{ fontFamily: 'var(--f-english)', fontSize: 13, color: text, letterSpacing: 0.2, fontWeight: 500 }}>
            Bhagavad Gītā  <span style={{ color: muted, fontWeight: 400 }}>2.47</span>
          </div>
          <div style={{ fontFamily: 'var(--f-ui)', fontSize: 9, color: muted, letterSpacing: 1.5, textTransform: 'uppercase', marginTop: 1 }}>
            Sāṅkhya Yoga
          </div>
        </div>
        <button style={sBtn}>{Icon.bookmark(saff, true)}</button>
        <button style={sBtn}>{Icon.share(muted)}</button>
      </div>

      {/* ── Layer rail — which reference strata are visible ──────────── */}
      <div style={{
        padding: '8px 12px 10px',
        flexShrink: 0,
        borderBottom: `1px solid ${rule}`,
      }}>
        <div style={{
          fontFamily: 'var(--f-ui)', fontSize: 9, fontWeight: 700,
          letterSpacing: 2, color: faint, textTransform: 'uppercase',
          marginBottom: 7, paddingLeft: 2,
        }}>
          Reference layers
        </div>
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          <LayerChip label="Pronunciation" active={layers.translit} onToggle={() => toggle('translit')}
            saff={saff} saffBg={saffBg} muted={muted} surface={highest} />
          <LayerChip label="Word by word" active={layers.padaccheda} onToggle={() => toggle('padaccheda')}
            saff={saff} saffBg={saffBg} muted={muted} surface={highest} />
          <LayerChip label="हिंदी" active={layers.hindi} onToggle={() => toggle('hindi')}
            saff={saff} saffBg={saffBg} muted={muted} surface={highest} />
          <LayerChip label="Commentary" active={layers.bhashya} onToggle={() => toggle('bhashya')}
            saff={saff} saffBg={saffBg} muted={muted} surface={highest} />
        </div>
      </div>

      {/* ── Page body — gutter + content grid ────────────────────────── */}
      <div className="scroll" style={{
        flex: 1, display: 'grid',
        gridTemplateColumns: '36px 1fr',
        paddingBottom: 90,
      }}>

        {/* Manuscript gutter — verse colophon */}
        <div style={{
          paddingTop: 22, paddingLeft: 10,
          borderRight: `1px solid ${rule}`,
          display: 'flex', flexDirection: 'column', alignItems: 'flex-start',
          gap: 10,
        }}>
          <div style={{
            fontFamily: 'var(--f-ui)', fontSize: 9, fontWeight: 700,
            letterSpacing: 1.5, color: saff,
          }}>
            BG
          </div>
          <div style={{
            width: 14, height: 1, background: rule,
          }} />
          <div style={{
            fontFamily: 'var(--f-english)', fontSize: 11, fontStyle: 'italic',
            color: muted, writingMode: 'vertical-rl', transform: 'rotate(180deg)',
            padding: '2px 0', letterSpacing: 0.5,
          }}>
            adhyāya 2
          </div>
          <div style={{
            fontFamily: 'var(--f-sanskrit)', fontSize: 18, color: sansC,
            lineHeight: 1, opacity: 0.9, marginTop: 4,
          }}>
            ४७
          </div>
        </div>

        <div style={{ padding: '20px 16px 8px' }}>

          {/* ── Layer 1: Sanskrit (mūla) ────────────────────────────── */}
          <SectionRubric label="मूल" sub="Sanskrit" saff={saff} muted={muted} rule={ruleStrong} first />
          <div style={{
            fontFamily: 'var(--f-sanskrit)',
            fontSize: 24,
            lineHeight: 2.0,
            color: sansC,
            letterSpacing: 0.5,
            marginTop: 6,
            whiteSpace: 'pre-line',
          }}>
            {VERSE.sanskrit}
          </div>

          {/* ── Layer 2: Pada pāṭha (IAST) — inline where it belongs ── */}
          {layers.translit && (
            <>
              <SectionRubric label="पदपाठ" sub="Pronunciation · IAST" saff={saff} muted={muted} rule={ruleStrong} />
              <div style={{
                fontFamily: 'var(--f-english)', fontStyle: 'italic',
                fontSize: 15, lineHeight: 1.75, color: muted,
                marginTop: 6, whiteSpace: 'pre-line',
              }}>
                {VERSE.transliteration}
              </div>
            </>
          )}

          {/* ── Layer 3: Padaccheda (word-by-word) ──────────────────── */}
          {layers.padaccheda && (
            <>
              <SectionRubric label="पदच्छेद" sub="Word by word" saff={saff} muted={muted} rule={ruleStrong} />
              <div style={{
                marginTop: 4,
                border: `1px solid ${rule}`,
                borderRadius: 4, padding: '6px 0',
                background: 'rgba(255,255,255,0.015)',
              }}>
                {VERSE.wordMeanings.map((w, i) => (
                  <div key={i} style={{
                    display: 'grid',
                    gridTemplateColumns: '120px 1fr',
                    gap: 14,
                    padding: '7px 12px',
                    borderTop: i ? `1px dotted ${rule}` : 'none',
                    alignItems: 'baseline',
                  }}>
                    <div style={{
                      fontFamily: 'var(--f-sanskrit)', fontSize: 15,
                      color: sansC, lineHeight: 1.4,
                    }}>
                      {w.word}
                    </div>
                    <div style={{
                      fontFamily: 'var(--f-english)', fontStyle: 'italic',
                      fontSize: 14, color: text, lineHeight: 1.4,
                    }}>
                      {w.meaning}
                    </div>
                  </div>
                ))}
              </div>
            </>
          )}

          {/* ── Layer 4: Anuvāda (translation) ───────────────────────── */}
          <SectionRubric label="अनुवाद" sub="Translation" saff={saff} muted={muted} rule={ruleStrong} />
          <div style={{
            fontFamily: 'var(--f-english)',
            fontSize: 16.5, lineHeight: 1.65,
            color: text, marginTop: 6,
            textWrap: 'pretty',
          }}>
            {VERSE.english}
          </div>

          {/* ── Layer 4b: Hindi ──────────────────────────────────────── */}
          {layers.hindi && (
            <>
              <SectionRubric label="हिन्दी" sub="Hindi" saff={saff} muted={muted} rule={ruleStrong} />
              <div style={{
                fontFamily: 'var(--f-devanagari)',
                fontSize: 16, lineHeight: 1.7, color: text,
                marginTop: 6,
              }}>
                {VERSE.hindi}
              </div>
            </>
          )}

          {/* ── Layer 5: Bhāṣya (commentary) ─────────────────────────── */}
          {layers.bhashya && (
            <>
              <SectionRubric label="भाष्य" sub="AI Commentary · Gemini" saff={saff} muted={muted} rule={ruleStrong} />
              <div style={{
                marginTop: 8,
                padding: '12px 14px',
                borderLeft: `2px solid ${saffDim}`,
                background: 'rgba(232,130,12,0.035)',
                borderRadius: '0 4px 4px 0',
              }}>
                <div style={{
                  fontFamily: 'var(--f-english)',
                  fontSize: 15, lineHeight: 1.65, color: text,
                  fontStyle: 'normal',
                }}>
                  Kṛṣṇa draws the foundational line between karma (action) and its
                  phala (fruit). Our domain is the first; the second is governed by
                  causes outside us. To act without grasping at outcomes is not
                  indifference — it is the purified action that yoga is.
                </div>
                <div style={{
                  marginTop: 8, fontFamily: 'var(--f-ui)', fontSize: 10,
                  color: faint, letterSpacing: 0.3,
                }}>
                  AI-generated · Refer to traditional commentaries for authority.
                </div>
              </div>
            </>
          )}

          {/* ── Cross-refs — a scholar's touch ──────────────────────── */}
          <SectionRubric label="सम्बन्ध" sub="Related verses" saff={saff} muted={muted} rule={ruleStrong} />
          <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 6 }}>
            <CrossRef code="BG 3.19" text="Perform your duty without attachment"
              muted={muted} saff={saff} text2={text} />
            <CrossRef code="BG 4.20" text="He who has renounced the fruits of action..."
              muted={muted} saff={saff} text2={text} />
            <CrossRef code="BG 18.11" text="Embodied beings cannot abandon action"
              muted={muted} saff={saff} text2={text} />
          </div>

          <div style={{ height: 24 }} />
        </div>
      </div>

      {/* ── Scholar's toolbar ─────────────────────────────────────────── */}
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: 'rgba(15,15,15,0.92)',
        backdropFilter: 'blur(16px)',
        WebkitBackdropFilter: 'blur(16px)',
        borderTop: `1px solid ${rule}`,
        display: 'flex', alignItems: 'center',
        padding: '6px 8px 14px',
        zIndex: 5,
      }}>
        <button style={{ ...sBtn, color: saff }}>{Icon.chevL(saff, 26)}</button>

        <div style={{ flex: 1, display: 'flex', justifyContent: 'center', gap: 18 }}>
          <ToolbarBtn icon={Icon.edit(muted)} label="Note" muted={muted} />
          <ToolbarBtn icon={Icon.sparkles(muted)} label="Ask" muted={muted} />
          <ToolbarBtn
            icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M7 4h10v16l-5-3-5 3V4z" stroke={muted} strokeWidth="1.7"/></svg>}
            label="4 refs" muted={muted}
          />
        </div>

        <button style={{ ...sBtn, color: saff }}>{Icon.chevR(saff, 26)}</button>
      </div>
    </div>
  );
}

function SectionRubric({ label, sub, saff, muted, rule, first = false }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      marginTop: first ? 6 : 22,
      marginBottom: 4,
    }}>
      <div className="hin" style={{
        fontFamily: 'var(--f-devanagari)', fontSize: 12, color: saff,
        fontWeight: 600, letterSpacing: 0.5,
      }}>
        {label}
      </div>
      <div style={{
        fontFamily: 'var(--f-ui)', fontSize: 9, fontWeight: 600,
        letterSpacing: 2, color: muted, textTransform: 'uppercase',
      }}>
        {sub}
      </div>
      <div style={{ flex: 1, height: 1, background: rule }} />
    </div>
  );
}

function LayerChip({ label, active, onToggle, saff, saffBg, muted, surface }) {
  return (
    <button onClick={onToggle} style={{
      fontFamily: 'var(--f-ui)', fontSize: 12, fontWeight: 500,
      padding: '6px 11px',
      background: active ? saffBg : 'transparent',
      border: `1px solid ${active ? 'rgba(244,168,48,0.45)' : 'rgba(240,235,229,0.12)'}`,
      borderRadius: 999,
      color: active ? saff : muted,
      cursor: 'pointer', letterSpacing: 0.1,
      display: 'flex', alignItems: 'center', gap: 6,
    }}>
      <svg width="10" height="10" viewBox="0 0 10 10" style={{ opacity: active ? 1 : 0.5 }}>
        {active
          ? <path d="M2 5l2 2 4-4" stroke={saff} strokeWidth="1.8" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
          : <circle cx="5" cy="5" r="3.5" stroke={muted} strokeWidth="1" fill="none"/>
        }
      </svg>
      {label}
    </button>
  );
}

function CrossRef({ code, text, muted, saff, text2 }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'baseline', gap: 10,
      padding: '6px 0',
    }}>
      <div style={{
        fontFamily: 'var(--f-ui)', fontSize: 11, fontWeight: 600,
        color: saff, letterSpacing: 0.5, minWidth: 56,
      }}>
        {code}
      </div>
      <div style={{
        fontFamily: 'var(--f-english)', fontStyle: 'italic',
        fontSize: 14, color: text2, lineHeight: 1.4,
      }}>
        {text}
      </div>
    </div>
  );
}

function ToolbarBtn({ icon, label, muted }) {
  return (
    <button style={{
      background: 'transparent', border: 0, cursor: 'pointer',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
      padding: '4px 10px', color: muted,
    }}>
      {icon}
      <span style={{
        fontFamily: 'var(--f-ui)', fontSize: 10,
        letterSpacing: 0.3, color: muted,
      }}>
        {label}
      </span>
    </button>
  );
}

Object.assign(window, { PithaScreen });
