// Direction 3 — "Scroll"
// Vertical rhythm of a palm-leaf manuscript unfurled. The screen becomes a
// stack of horizontal bands. Each band = a "strip" (Sanskrit / IAST / English /
// Hindi / words / notes). Bands are separated by tiny bindu glyphs. A left
// side-rail shows dots — a scroll-map of which strips are present. Typographic,
// no cards.

function ScrollScreen({ dark = false }) {
  const isDark = dark;
  const scaffold = isDark ? 'var(--bg-dark)' : 'var(--cream)';
  const textC = isDark ? 'var(--text-on-dark)' : 'var(--text-primary)';
  const muted = isDark ? 'var(--text-secondary-on-dark)' : 'var(--text-secondary)';
  const saff = isDark ? 'var(--saffron-on-dark)' : 'var(--saffron)';
  const sansC = isDark ? 'var(--sanskrit-text-on-dark)' : 'var(--sanskrit-text)';
  const border = isDark ? 'var(--border-dark)' : 'var(--border)';
  const bandBorder = isDark ? 'rgba(232,168,48,0.20)' : 'rgba(232,130,12,0.18)';

  const strips = [
    { key: 'sanskrit', label: 'Sanskrit', active: true },
    { key: 'translit', label: 'IAST', active: true },
    { key: 'en', label: 'English', active: true },
    { key: 'hi', label: 'Hindi', active: true },
    { key: 'words', label: 'Words', active: true },
    { key: 'note', label: 'Note', active: true },
    { key: 'ai', label: 'Ask', active: false },
  ];

  return (
    <div className={`phone ${isDark ? 'dark' : 'light'}`} style={{ background: scaffold, display: 'flex', flexDirection: 'column' }}>
      {/* ── Top bar — minimal ──────────────────────── */}
      <div style={{ display: 'flex', alignItems: 'center', padding: '6px 6px', height: 48, flexShrink: 0 }}>
        <button style={iconBtn3}>{Icon.back(textC)}</button>
        <div style={{ flex: 1, textAlign: 'center' }}>
          <div style={{ fontFamily: 'var(--f-ui)', fontSize: 11, fontWeight: 700, letterSpacing: 2.5, color: saff, textTransform: 'uppercase' }}>
            Bhagavad Gita
          </div>
          <div style={{ fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 11, color: muted, marginTop: 1 }}>
            2 · 47
          </div>
        </div>
        <button style={iconBtn3}>{Icon.bookmark(saff, VERSE.isBookmarked)}</button>
      </div>

      <div className="scroll" style={{ flex: 1, display: 'flex' }}>
        {/* ── Left side-rail scroll map ───────────── */}
        <div style={{
          width: 34, flexShrink: 0,
          display: 'flex', flexDirection: 'column', alignItems: 'center',
          paddingTop: 24, gap: 0, position: 'relative',
        }}>
          {strips.map((s, i) => (
            <div key={s.key} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              flex: 1, minHeight: 62, justifyContent: 'flex-start',
              paddingTop: 14, position: 'relative',
            }}>
              <div style={{
                width: s.active ? 6 : 4, height: s.active ? 6 : 4,
                borderRadius: 999,
                background: s.active ? saff : border,
              }} />
              <div style={{
                transform: 'rotate(-90deg)', transformOrigin: 'center',
                position: 'absolute', top: 34, whiteSpace: 'nowrap',
                fontFamily: 'var(--f-ui)', fontSize: 9, fontWeight: 600, letterSpacing: 1.5,
                color: s.active ? textC : muted, opacity: s.active ? 0.65 : 0.35,
                textTransform: 'uppercase',
              }}>
                {s.label}
              </div>
              {i < strips.length - 1 && (
                <div style={{ width: 1, flex: 1, background: border, opacity: 0.5, marginTop: 4 }} />
              )}
            </div>
          ))}
        </div>

        {/* ── Bands column ────────────────────────── */}
        <div style={{ flex: 1, padding: '8px 18px 20px 0' }}>
          {/* Band: Scripture chip at top for context */}
          <Band top saff={saff} bandBorder={bandBorder}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '10px 2px 4px' }}>
              <span style={{ fontFamily: 'var(--f-ui)', fontSize: 10, fontWeight: 700, letterSpacing: 2, color: muted, textTransform: 'uppercase' }}>
                Chapter 2 · Karma Yoga
              </span>
              <div style={{ flex: 1 }} />
              <div style={{
                display: 'inline-flex', alignItems: 'center', gap: 4,
                padding: '3px 8px', borderRadius: 999,
                border: `1px solid ${border}`,
                fontFamily: 'var(--f-ui)', fontSize: 10, fontWeight: 500, color: muted,
              }}>
                {Icon.translate(muted)} Translation on
              </div>
            </div>
          </Band>

          {/* Sanskrit band — largest, feature */}
          <Band saff={saff} bandBorder={bandBorder} number="47">
            <div style={{
              fontFamily: 'var(--f-sanskrit)', fontSize: 26, lineHeight: 2.0, color: sansC,
              letterSpacing: 0.4, whiteSpace: 'pre-line', padding: '14px 0 10px',
            }}>
              {VERSE.sanskrit}
            </div>
          </Band>

          <BandDivider saff={saff} />

          {/* IAST band */}
          <Band saff={saff} bandBorder={bandBorder} label="iast">
            <div style={{
              fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 14, lineHeight: 1.7,
              color: isDark ? '#B8A88E' : 'var(--translit-text)',
              whiteSpace: 'pre-line', padding: '10px 0',
            }}>
              {VERSE.transliteration}
            </div>
          </Band>

          <BandDivider saff={saff} />

          {/* English band */}
          <Band saff={saff} bandBorder={bandBorder} label="english">
            <div style={{
              fontFamily: 'var(--f-english)', fontSize: 17, lineHeight: 1.65, color: textC,
              padding: '10px 0 8px', fontWeight: 400,
            }}>
              {VERSE.english}
            </div>
          </Band>

          {/* Hindi band */}
          <Band saff={saff} bandBorder={bandBorder} label="हिंदी">
            <div style={{
              fontFamily: 'var(--f-devanagari)', fontSize: 15, lineHeight: 1.75, color: textC,
              padding: '10px 0 14px',
            }}>
              {VERSE.hindi}
            </div>
          </Band>

          <BandDivider saff={saff} />

          {/* Words — single line list */}
          <Band saff={saff} bandBorder={bandBorder} label="words">
            <div style={{ padding: '10px 0 14px', display: 'flex', flexDirection: 'column', gap: 8 }}>
              {VERSE.wordMeanings.slice(0, 4).map((w, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
                  <span style={{ fontFamily: 'var(--f-sanskrit)', fontSize: 16, color: sansC, minWidth: 82 }}>{w.word}</span>
                  <span style={{ fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 13, color: muted }}>— {w.meaning}</span>
                </div>
              ))}
              <div style={{ fontFamily: 'var(--f-ui)', fontSize: 11, color: saff, fontWeight: 600, marginTop: 4 }}>
                + 8 more words
              </div>
            </div>
          </Band>

          <BandDivider saff={saff} />

          {/* Note band — editable-ish */}
          <Band saff={saff} bandBorder={bandBorder} label="your note">
            <div style={{
              padding: '10px 0 4px',
              display: 'flex', gap: 10, alignItems: 'flex-start',
            }}>
              <div style={{
                fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 15,
                lineHeight: 1.7, color: textC, flex: 1,
              }}>
                {VERSE.note}
              </div>
              <div style={{ color: saff, marginTop: 2 }}>{Icon.edit(saff)}</div>
            </div>
          </Band>

          <BandDivider saff={saff} />

          {/* Ask */}
          <div
            style={{
              marginTop: 10,
              padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 10,
              border: `1px dashed ${border}`, borderRadius: 12,
              color: muted,
            }}>
            {Icon.sparkles(saff)}
            <div style={{ fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 14, flex: 1 }}>
              Ask about context, meaning, Sanskrit terms…
            </div>
            {Icon.chevR(saff, 18)}
          </div>

          <div style={{ height: 20 }} />
        </div>
      </div>

      {/* ── Bottom nav — thin horizontal timeline ─────── */}
      <div style={{
        borderTop: `1px solid ${border}`,
        padding: '8px 12px', display: 'flex', alignItems: 'center', gap: 10, flexShrink: 0,
      }}>
        <button style={iconBtn3}>{Icon.chevL(saff, 22)}</button>

        {/* Progress ticks — visual scrubber of chapter */}
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 2, padding: '0 6px' }}>
          {Array.from({ length: 30 }).map((_, i) => {
            const cur = i === 14; // roughly verse 47 of 72 shown compressed
            return (
              <div key={i} style={{
                flex: 1, height: cur ? 10 : 4,
                borderRadius: 2,
                background: cur ? saff : (i < 14 ? border : (isDark ? '#2A2520' : '#ECE5DB')),
              }} />
            );
          })}
        </div>

        <button style={iconBtn3}>{Icon.edit(muted)}</button>
        <button style={iconBtn3}>{Icon.share(muted)}</button>
        <button style={iconBtn3}>{Icon.chevR(saff, 22)}</button>
      </div>
    </div>
  );
}

function Band({ children, label, number, top, saff, bandBorder }) {
  return (
    <div style={{ position: 'relative' }}>
      {label && (
        <div style={{
          position: 'absolute', top: 8, right: 0,
          fontFamily: 'var(--f-ui)', fontSize: 9, fontWeight: 600, letterSpacing: 2,
          textTransform: 'uppercase', color: saff, opacity: 0.65,
        }}>
          {label}
        </div>
      )}
      {number && (
        <div style={{
          position: 'absolute', top: 8, right: 0,
          fontFamily: 'var(--f-english)', fontSize: 11, fontStyle: 'italic',
          letterSpacing: 1, color: saff, opacity: 0.7,
        }}>
          {number}
        </div>
      )}
      {children}
    </div>
  );
}

function BandDivider({ saff }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '2px 0' }}>
      <div style={{ flex: 1, height: 1, background: 'currentColor', opacity: 0.08 }} />
      <Bindu color={saff} opacity={0.6} />
      <div style={{ flex: 1, height: 1, background: 'currentColor', opacity: 0.08 }} />
    </div>
  );
}

const iconBtn3 = {
  background: 'transparent', border: 0, padding: 8, cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  color: 'inherit',
};

Object.assign(window, { ScrollScreen });
