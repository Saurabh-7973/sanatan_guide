// Direction A — "Sūtra"
// Maximum reading focus. Chrome recedes. Sanskrit dominates.
// A right-edge progress rail shows position in the chapter (verse 47 of 72).
// A left manuscript gutter carries the verse number in Devanagari numerals,
// treated as a printed colophon — the mark scripture editions actually use.
// The translation hangs below the Sanskrit separated only by a hair rule.
// Bottom chrome is a single tap-target: swipe navigates, a hint appears once.

function SutraScreen() {
  // Dark-only per request.
  const bg      = '#0F0F0F';
  const surface = '#1C1816';
  const text    = '#F0EBE5';
  const muted   = '#9B9390';
  const faint   = 'rgba(155,147,144,0.45)';
  const saff    = '#F4A830';
  const sansC   = '#E8D9C0';
  const rule    = 'rgba(232,168,48,0.18)';
  const hair    = 'rgba(240,235,229,0.10)';

  // verse 47 of 72 in chapter 2
  const chapterLen = 72;
  const pos = VERSE.verseNum;
  const railPct = (pos / chapterLen) * 100;

  // Split Sanskrit on danda/double-danda so each half-line breathes on its own row.
  // The ॥ and । become STRUCTURAL marks, displayed to the right of each pada.
  const padaSplit = splitPadas(VERSE.sanskrit);

  return (
    <div className="phone dark" style={{ background: bg, display: 'flex', flexDirection: 'column', color: text }}>

      {/* ── Minimal top bar: just a back chevron + a barely-there colophon ──── */}
      <div style={{
        display: 'flex', alignItems: 'center', height: 48, padding: '0 6px',
        flexShrink: 0,
      }}>
        <button style={sBtn}>{Icon.back(muted)}</button>
        <div style={{ flex: 1 }} />
        <button style={sBtn}>{Icon.bookmark(saff, true)}</button>
        <button style={sBtn}>{Icon.share(muted)}</button>
      </div>

      {/* ── Body: two-column grid (gutter | page) + right progress rail ─── */}
      <div className="scroll" style={{
        flex: 1, display: 'grid',
        gridTemplateColumns: '44px 1fr 18px',
        columnGap: 0,
        paddingTop: 8,
      }}>

        {/* ── Left manuscript gutter — verse number in Devanagari ─────── */}
        <div style={{
          paddingTop: 10, paddingLeft: 10,
          display: 'flex', flexDirection: 'column', alignItems: 'flex-start',
          gap: 6, position: 'sticky', top: 0, height: 'fit-content',
        }}>
          {/* vertical hair rule */}
          <div style={{
            position: 'absolute', right: 0, top: 6, bottom: -10000,
            width: 1, background: hair,
          }} />
          <div className="hin" style={{
            fontSize: 10, fontWeight: 700, color: saff, letterSpacing: 1.5,
            writingMode: 'vertical-rl', transform: 'rotate(180deg)',
            padding: '6px 0', textTransform: 'uppercase',
            fontFamily: 'var(--f-ui)',
          }}>
            Bhagavad Gītā
          </div>
          <div style={{ height: 14 }} />
          {/* Devanagari verse mark  "२।४७" */}
          <div style={{
            fontFamily: 'var(--f-sanskrit)', fontSize: 20, color: sansC,
            lineHeight: 1, letterSpacing: 0.5, opacity: 0.85,
          }}>२</div>
          <div style={{
            width: 14, height: 1, background: rule, marginLeft: 3,
          }} />
          <div style={{
            fontFamily: 'var(--f-sanskrit)', fontSize: 20, color: sansC,
            lineHeight: 1, letterSpacing: 0.5, opacity: 0.85,
          }}>
            ४७
          </div>
        </div>

        {/* ── Center: verse page ──────────────────────────────────────── */}
        <div style={{ padding: '4px 8px 120px 14px' }}>

          {/* Sanskrit — each pada on its own row, with the danda right-aligned */}
          <div style={{ marginTop: 18 }}>
            {padaSplit.map((p, i) => (
              <div key={i} style={{
                display: 'flex', alignItems: 'baseline', gap: 10,
                marginBottom: 6,
              }}>
                <div style={{
                  flex: 1,
                  fontFamily: 'var(--f-sanskrit)',
                  fontSize: 26,
                  lineHeight: 1.9,
                  color: sansC,
                  letterSpacing: 0.4,
                }}>
                  {p.text}
                </div>
                {p.danda && (
                  <div style={{
                    fontFamily: 'var(--f-sanskrit)', fontSize: 22, color: saff,
                    lineHeight: 1.9, opacity: 0.85, fontWeight: 400,
                  }}>
                    {p.danda}
                  </div>
                )}
              </div>
            ))}
          </div>

          {/* Hair rule between Sanskrit and translation — not a divider, a breath */}
          <div style={{
            margin: '28px 0 22px',
            display: 'flex', alignItems: 'center', gap: 10,
          }}>
            <div style={{ width: 18, height: 1, background: rule }} />
            <div style={{ fontFamily: 'var(--f-sanskrit)', fontSize: 12, color: saff, opacity: 0.7 }}>॥</div>
            <div style={{ flex: 1, height: 1, background: hair }} />
          </div>

          {/* English translation — a single generous paragraph */}
          <div style={{
            fontFamily: 'var(--f-english)',
            fontSize: 18,
            lineHeight: 1.7,
            color: text,
            textWrap: 'pretty',
          }}>
            {VERSE.english}
          </div>

          {/* After the translation, a discrete set of actions — no chips, no cards */}
          <div style={{
            marginTop: 28, display: 'flex', alignItems: 'center', gap: 14,
            fontFamily: 'var(--f-ui)', fontSize: 13,
            color: muted,
          }}>
            <ActionLink label="Pronunciation" color={saff} muted={muted} />
            <Dot color={faint} />
            <ActionLink label="Word by word" color={muted} muted={muted} />
            <Dot color={faint} />
            <ActionLink label="Ask guide" color={muted} muted={muted} />
          </div>
        </div>

        {/* ── Right: progress rail — position in chapter ──────────────── */}
        <div style={{
          position: 'sticky', top: 0, height: '100%',
          display: 'flex', flexDirection: 'column', alignItems: 'center',
          paddingTop: 14,
        }}>
          <div style={{
            fontFamily: 'var(--f-ui)', fontSize: 9, fontWeight: 600,
            letterSpacing: 1.5, color: muted, transform: 'rotate(-90deg)',
            transformOrigin: 'center', marginTop: 20, whiteSpace: 'nowrap',
          }}>
            CH · 2
          </div>
          <div style={{ height: 18 }} />
          <div style={{
            flex: 1, width: 2, minHeight: 200,
            background: hair, position: 'relative',
            borderRadius: 1,
          }}>
            <div style={{
              position: 'absolute', left: -3, top: `${railPct}%`,
              width: 8, height: 8, borderRadius: 8,
              background: saff, transform: 'translateY(-50%)',
              boxShadow: `0 0 0 3px ${bg}, 0 0 0 4px ${rule}`,
            }} />
          </div>
          <div style={{ padding: '10px 0', color: muted, fontFamily: 'var(--f-ui)', fontSize: 10, fontWeight: 600, letterSpacing: 1 }}>
            {pos}
            <div style={{ fontSize: 8, color: faint, textAlign: 'center', marginTop: 2 }}>·{chapterLen}</div>
          </div>
        </div>
      </div>

      {/* ── Floating nav lozenge — one thumb-reachable element ─────── */}
      <div style={{
        position: 'absolute', left: '50%', bottom: 22,
        transform: 'translateX(-50%)',
        display: 'flex', alignItems: 'center',
        background: 'rgba(28, 24, 22, 0.72)',
        backdropFilter: 'blur(20px) saturate(160%)',
        WebkitBackdropFilter: 'blur(20px) saturate(160%)',
        border: '1px solid rgba(240,235,229,0.08)',
        borderRadius: 999, padding: 4,
        boxShadow: '0 10px 30px rgba(0,0,0,0.45)',
        zIndex: 5,
      }}>
        <button style={{ ...lBtn, color: saff }}>{Icon.chevL(saff, 22)}</button>
        <div style={{
          fontFamily: 'var(--f-english)', fontStyle: 'italic',
          color: muted, padding: '0 14px', fontSize: 13, letterSpacing: 0.3,
        }}>
          swipe <span style={{ color: saff, fontStyle: 'normal' }}>·</span> or tap
        </div>
        <button style={{ ...lBtn, color: saff }}>{Icon.chevR(saff, 22)}</button>
      </div>
    </div>
  );
}

function Dot({ color }) {
  return <div style={{ width: 3, height: 3, borderRadius: 3, background: color }} />;
}

function ActionLink({ label, color }) {
  return (
    <span style={{ color, cursor: 'pointer' }}>{label}</span>
  );
}

// Split verse on । (single danda) and ॥ (double danda), keeping the danda as a
// separate field so we can render it as a structural mark rather than a glyph.
function splitPadas(sanskrit) {
  // First replace newlines with spaces — we'll re-break on the punctuation itself.
  const flat = sanskrit.replace(/\n/g, ' ').replace(/\s+/g, ' ').trim();
  const out = [];
  let buf = '';
  for (let i = 0; i < flat.length; i++) {
    const ch = flat[i];
    if (ch === '।' || ch === '॥') {
      // check for double-danda
      let d = ch;
      if (ch === '।' && flat[i + 1] === '।') { d = '॥'; i++; }
      out.push({ text: buf.trim(), danda: d });
      buf = '';
    } else {
      buf += ch;
    }
  }
  if (buf.trim()) out.push({ text: buf.trim(), danda: '' });
  return out;
}

const sBtn = {
  background: 'transparent', border: 0, padding: 10, cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  color: 'inherit',
};
const lBtn = {
  background: 'transparent', border: 0, padding: '8px 10px', cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  color: 'inherit',
};

Object.assign(window, { SutraScreen });
