// Direction 2 — "Sanctum"
// Architectural / temple-mandapa metaphor. Asymmetric layout:
//   ▸ Left gutter (48px): vertical scripture lineage + verse number stamp + action rail.
//   ▸ Main column: verse content as a single tall altar, scripture number acts as a "pillar capital".
//   ▸ Cards for translation / word-by-word / notes stack below like sanctum chambers.
// Hierarchy comes from typographic scale and an always-visible vertical saffron rule.

function SanctumScreen({ dark = false }) {
  const isDark = dark;
  const scaffold = isDark ? 'var(--bg-dark)' : 'var(--cream)';
  const surf = isDark ? 'var(--surface-dark)' : 'var(--surface)';
  const surfVar = isDark ? 'var(--surface-elevated)' : 'var(--surface-variant)';
  const textC = isDark ? 'var(--text-on-dark)' : 'var(--text-primary)';
  const muted = isDark ? 'var(--text-secondary-on-dark)' : 'var(--text-secondary)';
  const saff = isDark ? 'var(--saffron-on-dark)' : 'var(--saffron)';
  const sansC = isDark ? 'var(--sanskrit-text-on-dark)' : 'var(--sanskrit-text)';
  const border = isDark ? 'var(--border-dark)' : 'var(--border)';

  return (
    <div className={`phone ${isDark ? 'dark' : 'light'}`} style={{ background: scaffold, display: 'flex', flexDirection: 'column' }}>
      {/* ── App bar ─────────────────────────────────── */}
      <div style={{ display: 'flex', alignItems: 'center', padding: '6px 6px', height: 52, flexShrink: 0 }}>
        <button style={iconBtn2}>{Icon.back(textC)}</button>
        <div style={{ flex: 1 }} />
        <button style={iconBtn2}>{Icon.bookmark(saff, VERSE.isBookmarked)}</button>
        <button style={iconBtn2}>{Icon.share(muted)}</button>
      </div>

      {/* ── Main scroll ─────────────────────────────── */}
      <div className="scroll" style={{ flex: 1, display: 'flex', flexDirection: 'row' }}>
        {/* Left gutter — vertical rail */}
        <div style={{
          width: 48, flexShrink: 0,
          display: 'flex', flexDirection: 'column', alignItems: 'center',
          paddingTop: 16, paddingBottom: 16, gap: 12,
          position: 'relative',
        }}>
          {/* Saffron vertical rule */}
          <div style={{
            position: 'absolute', top: 12, bottom: 12, left: '50%',
            width: 1, background: `linear-gradient(to bottom, transparent, ${saff} 20%, ${saff} 80%, transparent)`,
            opacity: 0.5, transform: 'translateX(-0.5px)',
          }} />

          {/* Scripture code stamp */}
          <div style={{
            position: 'relative', width: 36, height: 36, borderRadius: 999,
            background: 'var(--saffron-faint)', border: `1px solid ${saff}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontFamily: 'var(--f-ui)', fontSize: 11, fontWeight: 700, letterSpacing: 1, color: saff,
            flexShrink: 0,
          }}>
            BG
          </div>

          {/* Rotated lineage */}
          <div style={{
            position: 'relative', flex: 1,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <div style={{
              transform: 'rotate(-90deg)', whiteSpace: 'nowrap',
              fontFamily: 'var(--f-ui)', fontSize: 10, fontWeight: 600, letterSpacing: 4,
              color: muted, textTransform: 'uppercase',
            }}>
              Śrīmad Bhagavad Gītā
            </div>
          </div>

          {/* Verse numeric stamp at bottom */}
          <div style={{
            position: 'relative', textAlign: 'center',
            fontFamily: 'var(--f-english)', color: saff,
            flexShrink: 0,
          }}>
            <div style={{ fontSize: 10, letterSpacing: 1, color: muted, fontFamily: 'var(--f-ui)', fontWeight: 500 }}>CH</div>
            <div style={{ fontSize: 20, fontWeight: 700, lineHeight: 1.1, color: textC, fontFamily: 'var(--f-english)' }}>2</div>
            <div style={{ fontSize: 10, letterSpacing: 1, color: muted, fontFamily: 'var(--f-ui)', fontWeight: 500, marginTop: 4 }}>V</div>
            <div style={{ fontSize: 26, fontWeight: 700, lineHeight: 1.1, color: saff, fontFamily: 'var(--f-english)' }}>47</div>
          </div>
        </div>

        {/* Right main column */}
        <div style={{ flex: 1, padding: '10px 18px 24px 4px' }}>
          {/* Small scripture chip */}
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            padding: '5px 10px', borderRadius: 8,
            background: 'var(--saffron-faint)',
            fontFamily: 'var(--f-ui)', fontSize: 11, fontWeight: 600, letterSpacing: 0.5,
            color: saff, marginBottom: 18,
          }}>
            <span style={{ width: 5, height: 5, borderRadius: 999, background: saff }} />
            Bhagavad Gita
          </div>

          {/* Sanskrit — left aligned, big */}
          <div style={{
            fontFamily: 'var(--f-sanskrit)',
            fontSize: 24, lineHeight: 2.0, color: sansC, letterSpacing: 0.4,
            whiteSpace: 'pre-line',
            marginBottom: 18,
          }}>
            {VERSE.sanskrit}
          </div>

          {/* Transliteration toggle + text */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
            <div style={{ height: 1, width: 20, background: border }} />
            <div style={{ fontFamily: 'var(--f-ui)', fontSize: 10, fontWeight: 700, letterSpacing: 2, color: muted, textTransform: 'uppercase' }}>
              Transliteration
            </div>
          </div>
          <div style={{
            fontFamily: 'var(--f-english)', fontStyle: 'italic',
            fontSize: 14, lineHeight: 1.7,
            color: isDark ? '#B8A88E' : 'var(--translit-text)',
            whiteSpace: 'pre-line',
            marginBottom: 22,
          }}>
            {VERSE.transliteration}
          </div>

          {/* Translation card */}
          <SanctumCard saff={saff} surf={surf} border={border} title="Translation" muted={muted}>
            <div style={{ fontFamily: 'var(--f-english)', fontSize: 16, lineHeight: 1.65, color: textC, marginBottom: 14 }}>
              {VERSE.english}
            </div>
            <div style={{ height: 1, background: border, margin: '2px 0 14px' }} />
            <div style={{ fontFamily: 'var(--f-ui)', fontSize: 10, fontWeight: 700, letterSpacing: 2, color: muted, textTransform: 'uppercase', marginBottom: 6 }}>
              Hindi
            </div>
            <div style={{ fontFamily: 'var(--f-devanagari)', fontSize: 15, lineHeight: 1.7, color: textC }}>
              {VERSE.hindi}
            </div>
          </SanctumCard>

          {/* Word-by-word card */}
          <SanctumCard saff={saff} surf={surf} border={border} title="Word by Word" muted={muted} collapsible>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {VERSE.wordMeanings.slice(0, 5).map((w, i) => (
                <div key={i} style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
                  <span style={{
                    fontFamily: 'var(--f-sanskrit)', fontSize: 17, color: sansC,
                    minWidth: 86,
                  }}>{w.word}</span>
                  <span style={{ color: muted, fontSize: 13 }}>·</span>
                  <span style={{ fontFamily: 'var(--f-english)', fontSize: 14, color: textC }}>{w.meaning}</span>
                </div>
              ))}
            </div>
          </SanctumCard>

          {/* Notes */}
          <SanctumCard saff={saff} surf={surf} border={border} title="Your Reflection" muted={muted}
            headerAction={<span style={{ color: saff, fontFamily: 'var(--f-ui)', fontSize: 11, fontWeight: 600 }}>Edit</span>}>
            <div style={{
              fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 15, lineHeight: 1.7, color: textC,
            }}>
              {VERSE.note}
            </div>
          </SanctumCard>

          {/* AI row */}
          <div style={{
            display: 'flex', alignItems: 'center', gap: 10,
            padding: '14px 14px', borderRadius: 12,
            background: 'var(--saffron-faint)',
            border: `1px solid var(--saffron-border)`,
            marginBottom: 16,
          }}>
            {Icon.sparkles(saff)}
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: 'var(--f-ui)', fontSize: 14, fontWeight: 600, color: textC }}>Ask the Guide</div>
              <div style={{ fontFamily: 'var(--f-english)', fontSize: 12, color: muted, marginTop: 2, fontStyle: 'italic' }}>
                Context, meaning, Sanskrit terms
              </div>
            </div>
            <div style={{ color: saff }}>{Icon.chevR(saff, 18)}</div>
          </div>
        </div>
      </div>

      {/* ── Bottom nav ─────────────────────────────── */}
      <div style={{
        borderTop: `1px solid ${border}`,
        padding: '8px 6px', display: 'flex', alignItems: 'center', flexShrink: 0,
      }}>
        <button style={{ ...iconBtn2, flex: 1, justifyContent: 'flex-start', gap: 4, paddingLeft: 12 }}>
          <span style={{ color: saff }}>{Icon.chevL(saff, 22)}</span>
          <span style={{ fontFamily: 'var(--f-ui)', fontSize: 13, color: muted }}>46</span>
        </button>
        <div style={{ fontFamily: 'var(--f-english)', fontStyle: 'italic', fontSize: 12, color: muted }}>
          swipe · 2 · 47
        </div>
        <button style={{ ...iconBtn2, flex: 1, justifyContent: 'flex-end', gap: 4, paddingRight: 12 }}>
          <span style={{ fontFamily: 'var(--f-ui)', fontSize: 13, color: muted }}>48</span>
          <span style={{ color: saff }}>{Icon.chevR(saff, 22)}</span>
        </button>
      </div>
    </div>
  );
}

function SanctumCard({ saff, surf, border, title, children, muted, collapsible = false, headerAction }) {
  const [open, setOpen] = React.useState(true);
  return (
    <div style={{
      background: surf, borderRadius: 16,
      padding: '14px 16px', marginBottom: 12,
      border: `1px solid ${border}`,
    }}>
      <div
        onClick={collapsible ? () => setOpen(!open) : undefined}
        style={{ display: 'flex', alignItems: 'center', marginBottom: open ? 12 : 0, cursor: collapsible ? 'pointer' : 'default' }}>
        <div style={{ width: 3, height: 14, background: saff, marginRight: 10, borderRadius: 2 }} />
        <span style={{ fontFamily: 'var(--f-ui)', fontSize: 11, fontWeight: 700, letterSpacing: 2, textTransform: 'uppercase', color: 'inherit' }}>
          {title}
        </span>
        <div style={{ flex: 1 }} />
        {headerAction}
        {collapsible && (
          <span style={{ color: muted, marginLeft: 8, transform: `rotate(${open ? 180 : 0}deg)`, transition: 'transform 0.2s' }}>
            {Icon.chevD(muted, 16)}
          </span>
        )}
      </div>
      {open && children}
    </div>
  );
}

const iconBtn2 = {
  background: 'transparent', border: 0, padding: 10, cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  color: 'inherit',
};

Object.assign(window, { SanctumScreen });
