// PhoneShell.jsx — minimal Android phone bezel themed to Sanatan Guide.
// Provides status bar (warm), gesture pill, and a per-frame light/dark toggle handle.

const PHONE_W = 412;
const PHONE_H = 892;

function StatusBar({ dark, time = '7:41' }) {
  const c = dark ? window.TOKENS.C.textOnDark : window.TOKENS.C.textPrimary;
  return (
    <div style={{
      height: 36, display: 'flex', alignItems: 'center',
      justifyContent: 'space-between', padding: '0 18px',
      position: 'relative',
      fontFamily: '"Outfit", sans-serif',
      flexShrink: 0,
    }}>
      <span style={{ fontSize: 14, fontWeight: 500, color: c }}>{time}</span>
      <div style={{
        position: 'absolute', left: '50%', top: 6, transform: 'translateX(-50%)',
        width: 22, height: 22, borderRadius: 100, background: '#1a1a1a',
      }} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        {/* signal */}
        <svg width="14" height="14" viewBox="0 0 16 16">
          <rect x="1" y="11" width="2.5" height="4" rx="0.5" fill={c}/>
          <rect x="5" y="8" width="2.5" height="7" rx="0.5" fill={c}/>
          <rect x="9" y="5" width="2.5" height="10" rx="0.5" fill={c}/>
          <rect x="13" y="2" width="2.5" height="13" rx="0.5" fill={c}/>
        </svg>
        {/* wifi */}
        <svg width="14" height="14" viewBox="0 0 16 16">
          <path d="M8 12.5a1.2 1.2 0 100 2.4 1.2 1.2 0 000-2.4zM3.4 8.7l1.7 1.6a4.2 4.2 0 015.8 0l1.7-1.6a6.6 6.6 0 00-9.2 0zM.7 5.9l1.7 1.6a8.4 8.4 0 0111.2 0l1.7-1.6A10.8 10.8 0 00.7 5.9z" fill={c}/>
        </svg>
        {/* battery */}
        <svg width="22" height="12" viewBox="0 0 22 12">
          <rect x="0.5" y="0.5" width="18" height="11" rx="2.5" fill="none" stroke={c} strokeOpacity="0.7"/>
          <rect x="2" y="2" width="15" height="8" rx="1" fill={c}/>
          <rect x="19.5" y="3.5" width="2" height="5" rx="0.8" fill={c} fillOpacity="0.7"/>
        </svg>
      </div>
    </div>
  );
}

function GestureBar({ dark }) {
  return (
    <div style={{ height: 22, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
      <div style={{
        width: 124, height: 4, borderRadius: 2,
        background: dark ? '#fff' : '#1a1a1a', opacity: 0.5,
      }} />
    </div>
  );
}

function ModeToggle({ dark, onToggle }) {
  return (
    <button
      onClick={onToggle}
      style={{
        position: 'absolute', top: -34, right: 0,
        height: 26, padding: '0 10px',
        borderRadius: 999,
        border: '1px solid rgba(255,255,255,0.18)',
        background: 'rgba(255,255,255,0.06)',
        color: '#cfcfcf',
        fontFamily: '"Outfit", sans-serif',
        fontSize: 11, fontWeight: 500, letterSpacing: '0.6px',
        textTransform: 'uppercase',
        cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6,
      }}
    >
      <span style={{
        width: 8, height: 8, borderRadius: 999,
        background: dark ? '#F4A830' : '#FDFAF6',
      }} />
      {dark ? 'Dark' : 'Light'}
    </button>
  );
}

function PhoneShell({ children, dark, onToggle, bg }) {
  const bezel = '#0b0b0b';
  return (
    <div style={{ position: 'relative', width: PHONE_W, paddingTop: 0 }}>
      <ModeToggle dark={dark} onToggle={onToggle} />
      <div style={{
        width: PHONE_W, height: PHONE_H,
        borderRadius: 44, padding: 8,
        background: bezel,
        boxShadow: '0 40px 80px rgba(0,0,0,0.35), 0 4px 8px rgba(0,0,0,0.4)',
        boxSizing: 'border-box',
      }}>
        <div style={{
          width: '100%', height: '100%',
          borderRadius: 36, overflow: 'hidden',
          background: bg,
          display: 'flex', flexDirection: 'column',
          position: 'relative',
        }}>
          <StatusBar dark={dark} />
          <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
            {children}
          </div>
          <GestureBar dark={dark} />
        </div>
      </div>
    </div>
  );
}

window.PhoneShell = PhoneShell;
window.PHONE_W = PHONE_W;
window.PHONE_H = PHONE_H;
