// Direction 1 — "Vellum"
// Treat the screen as an illuminated manuscript page: framed inner page,
// rubric section markers in saffron, a drop-initial on the English translation,
// folio label at foot. Reverent and still.

function VellumScreen({ dark = false }) {
  const isDark = dark;
  const pageBg = isDark ? '#14110F' : '#FBF6ED';     // subtle inner-page tone
  const scaffold = isDark ? 'var(--bg-dark)' : 'var(--cream)';
  const textC = isDark ? 'var(--text-on-dark)' : 'var(--text-primary)';
  const muted = isDark ? 'var(--text-secondary-on-dark)' : 'var(--text-secondary)';
  const saff = isDark ? 'var(--saffron-on-dark)' : 'var(--saffron)';
  const sansC = isDark ? 'var(--sanskrit-text-on-dark)' : 'var(--sanskrit-text)';
  const border = isDark ? 'var(--border-dark)' : 'var(--border)';
  const rule = isDark ? 'rgba(232,168,48,0.35)' : 'rgba(232,130,12,0.45)';

  return (
    <div className={`phone ${isDark ? 'dark' : 'light'}`} style={{ background: scaffold, display: 'flex', flexDirection: 'column' }}>
      {/* ── App bar ────────────────────────────────── */}
      <div style={{
        display: 'flex', alignItems: 'center', padding: '4px 4px 4px 4px',
        height: 52, flexShrink: 0, background: scaffold,
      }}>
        <button style={iconBtn}>{Icon.back(muted)}</button>
        <div style={{ flex: 1, textAlign: 'center', fontFamily: 'var(--f-ui)', fontSize: 12, fontWeight: 500, letterSpacing: 0.1, color: muted }}>
          {VERSE.label}
        </div>
        <button style={iconBtn}>{Icon.bookmark(saff, VERSE.isBookmarked)}</button>
        <button style={iconBtn}>{Icon.sparkles(muted)}</button>
        <button style={iconBtn}>{Icon.share(muted)}</button>
      </div>

      {/* ── The framed "page" ──────────────────────── */}
      <div className="scroll" style={{ flex: 1, padding: '4px 14px 0' }}>
        <div style={{
          background: pageBg,
          border: `1px solid ${border}`,
          borderRadius: 2,
          position: 'relative',
          padding: '28px 22px 20px',
          // Inner ruling — double fine line creates "vellum" framing
          boxShadow: `inset 0 0 0 1px ${isDark ? 'rgba(232,168,48,0.10)' : 'rgba(232,130,12,0.08)'},
                      inset 0 0 0 6px ${pageBg},
                      inset 0 0 0 7px ${rule}`,
          marginBottom: 16,
        }}>
          {/* Corner ornaments */}
          <CornerMark pos="tl" color={saff} />
          <CornerMark pos="tr" color={saff} />
          <CornerMark pos="bl" color={saff} />
          <CornerMark pos="br" color={saff} />

          {/* Rubric header: scripture name in caps w/ rule */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, justifyContent: 'center', marginBottom: 18, marginTop: 6 }}>
            <div style={{ flex: 1, height: 1, background: rule }} />
            <div style={{ fontFamily: 'var(--f-ui)', fontSize: 10, fontWeight: 700, letterSpacing: 3, color: saff, textTransform: 'uppercase' }}>
              {VERSE.scripture}
            </div>
            <div style={{ flex: 1, height: 1, background: rule }} />
          </div>

          {/* Chapter · Verse folio number in illuminated style */}
          <div style={{ textAlign: 'center', marginBottom: 20 }}>
            <div style={{ fontFamily: 'var(--f-english)', fontSize: 13, fontStyle: 'italic', color: muted, letterSpacing: 0.5 }}>
              adhyāya {VERSE.chapter} · śloka {VERSE.verseNum}
            </div>
          </div>

          {/* Sanskrit — centered, generous line-height, illuminated initial letter color */}
          <div style={{
            fontFamily: 'var(--f-sanskrit)',
            fontSize: 26,
            lineHeight: 2.0,
            color: sansC,
            textAlign: 'center',
            whiteSpace: 'pre-line',
            letterSpacing: 0.5,
            padding: '0 4px',
          }}>
            {VERSE.sanskrit}
          </div>

          {/* Ornament divider */}
          <div style={{ display: 'flex', justifyContent: 'center', margin: '18px 0 14px', color: saff }}>
            <Ornament color={saff} opacity={0.9} />
          </div>

          {/* Transliteration — italic, centered, muted */}
          <div style={{
            fontFamily: 'var(--f-english)', fontStyle: 'italic',
            fontSize: 14, lineHeight: 1.7,
            color: isDark ? '#B8A88E' : 'var(--translit-text)',
            textAlign: 'center',
            whiteSpace: 'pre-line',
            padding: '0 8px',
          }}>
            {VERSE.transliteration}
          </div>

          {/* Rubric marker ¶ for English */}
          <div style={{ marginTop: 24, display: 'flex', alignItems: 'baseline', gap: 10 }}>
            <span style={{ fontFamily: 'var(--f-english)', fontSize: 36, lineHeight: 1, color: saff, fontWeight: 600, fontStyle: 'italic' }}>
              {'\u00B6'}
            </span>
            <div style={{
              fontFamily: 'var(--f-english)', fontSize: 16, lineHeight: 1.65,
              color: textC,
            }}>
              <span style={{ fontSize: 40, float: 'left', lineHeight: 0.9, paddingRight: 6, paddingTop: 4, color: saff, fontWeight: 600, fontFamily: 'var(--f-english)' }}>Y</span>
              {VERSE.english.slice(1)}
            </div>
          </div>

          {/* Hindi section — small rubric */}
          <div style={{ marginTop: 20 }}>
            <div style={{ fontFamily: 'var(--f-ui)', fontSize: 10, fontWeight: 700, letterSpacing: 2, color: saff, textTransform: 'uppercase', marginBottom: 6 }}>
              हिंदी
            </div>
            <div style={{ fontFamily: 'var(--f-devanagari)', fontSize: 15, lineHeight: 1.7, color: textC }}>
              {VERSE.hindi}
            </div>
          </div>

          {/* Folio number at foot — "·  47  ·" */}
          <div style={{
            textAlign: 'center', marginTop: 26, paddingTop: 14,
            borderTop: `1px solid ${rule}`,
            fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 12,
            color: muted, letterSpacing: 2,
          }}>
            · BG ii · 47 ·
          </div>
        </div>

        {/* Word-by-word — collapsed rubric */}
        <VellumShelf title="Word by Word" saff={saff} muted={muted} border={border} textC={textC} open>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: 8 }}>
            {VERSE.wordMeanings.slice(0, 6).map((w, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'baseline', gap: 12, paddingBottom: 6, borderBottom: `1px dotted ${border}` }}>
                <span style={{ fontFamily: 'var(--f-sanskrit)', fontSize: 17, color: sansC, minWidth: 92 }}>{w.word}</span>
                <span style={{ fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 14, color: muted }}>{w.meaning}</span>
              </div>
            ))}
            <div style={{ fontFamily: 'var(--f-ui)', fontSize: 12, color: saff, textAlign: 'center', paddingTop: 4 }}>
              Show all 12 meanings
            </div>
          </div>
        </VellumShelf>

        {/* Notes — your reflection, styled as a marginalia */}
        <VellumShelf title="Your Marginalia" saff={saff} muted={muted} border={border} textC={textC} open>
          <div style={{
            fontFamily: 'var(--f-english)', fontStyle: 'italic',
            fontSize: 15, lineHeight: 1.7, color: textC,
            paddingLeft: 14, borderLeft: `2px solid ${saff}`,
          }}>
            {VERSE.note}
          </div>
        </VellumShelf>

        {/* AI ask */}
        <VellumShelf title="Ask the Guide" saff={saff} muted={muted} border={border} textC={textC}>
          <div style={{ fontFamily: 'var(--f-english)', fontSize: 14, color: muted, fontStyle: 'italic' }}>
            Tap to ask about context, meaning, or Sanskrit terms.
          </div>
        </VellumShelf>

        <div style={{ height: 24 }} />
      </div>

      {/* ── Bottom navigation ─────────────────────── */}
      <div style={{
        borderTop: `1px solid ${border}`, background: scaffold,
        padding: '6px 8px', display: 'flex', alignItems: 'center', gap: 4, flexShrink: 0,
      }}>
        <button style={{ ...navBtn, color: saff }}>{Icon.chevL(saff, 26)}</button>
        <div style={{ flex: 1, textAlign: 'center' }}>
          <div style={{ fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 13, color: muted }}>
            Verse 46 · <span style={{ color: textC, fontWeight: 600, fontStyle: 'normal' }}>47</span> · Verse 48
          </div>
        </div>
        <button style={navBtn}>{Icon.edit(muted)}</button>
        <button style={{ ...navBtn, color: saff }}>{Icon.chevR(saff, 26)}</button>
      </div>
    </div>
  );
}

function CornerMark({ pos, color }) {
  const base = { position: 'absolute', width: 10, height: 10, borderColor: color, borderStyle: 'solid' };
  const m = 10;
  const style = {
    tl: { top: m, left: m, borderWidth: '1px 0 0 1px' },
    tr: { top: m, right: m, borderWidth: '1px 1px 0 0' },
    bl: { bottom: m, left: m, borderWidth: '0 0 1px 1px' },
    br: { bottom: m, right: m, borderWidth: '0 1px 1px 0' },
  }[pos];
  return <div style={{ ...base, ...style, opacity: 0.55 }} />;
}

function VellumShelf({ title, children, saff, muted, border, textC, open = false }) {
  const [isOpen, setIsOpen] = React.useState(open);
  return (
    <div style={{
      marginBottom: 12,
      padding: '10px 14px 12px',
      borderTop: `1px solid ${border}`,
    }}>
      <div onClick={() => setIsOpen(!isOpen)} style={{
        display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer',
      }}>
        <span style={{ fontFamily: 'var(--f-ui)', fontSize: 10, fontWeight: 700, letterSpacing: 2.5, color: saff, textTransform: 'uppercase' }}>
          {title}
        </span>
        <div style={{ flex: 1, height: 1, background: border }} />
        <span style={{ color: muted, transform: `rotate(${isOpen ? 180 : 0}deg)`, transition: 'transform 0.2s' }}>
          {Icon.chevD(muted, 16)}
        </span>
      </div>
      {isOpen && <div style={{ marginTop: 12 }}>{children}</div>}
    </div>
  );
}

const iconBtn = {
  background: 'transparent', border: 0, padding: 10, cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  color: 'inherit',
};
const navBtn = {
  background: 'transparent', border: 0, padding: 10, cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  color: 'inherit',
};

Object.assign(window, { VellumScreen });
