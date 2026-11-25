'use client';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Bell, LogOut, Menu, Search, X } from 'lucide-react';
import type { LucideIcon } from 'lucide-react';
import { ReactNode, useEffect, useMemo, useRef, useState } from 'react';
import Logo from '@/components/Logo';
import ThemeToggle from '@/components/ThemeToggle';
import { initials, setSession, type Role, type Session } from '@/lib/api';

export type NavItem = { key: string; label: string; icon: LucideIcon; badge?: number };
export type Notice = { icon: LucideIcon; text: string; sub: string };

const ROLE_LABEL: Record<Role, string> = { company: 'Company', investor: 'Investor', admin: 'Admin' };

export default function Shell({
  role, session, nav, view, title, crumb, notices, online, children,
}: {
  role: Role; session: Session; nav: NavItem[]; view: string; title: ReactNode; crumb: string; notices: Notice[]; online: boolean; children: ReactNode;
}) {
  const router = useRouter();
  const [notif, setNotif] = useState(false);
  const [unread, setUnread] = useState(true);
  const [cmd, setCmd] = useState(false);
  const [q, setQ] = useState('');
  const [sel, setSel] = useState(0);
  const navRef = useRef<HTMLElement>(null);
  const indRef = useRef<HTMLSpanElement>(null);
  const base = `/${role}`;
  const href = (k: string) => (k === 'overview' ? base : `${base}/${k}`);

  /* sliding nav indicator */
  useEffect(() => {
    const a = navRef.current?.querySelector<HTMLElement>('a.on');
    if (a && indRef.current) {
      indRef.current.style.transform = `translateY(${a.offsetTop}px)`;
      indRef.current.style.height = `${a.offsetHeight}px`;
      indRef.current.style.opacity = '1';
    } else if (indRef.current) indRef.current.style.opacity = '0';
    document.body.classList.remove('side-open');
  }, [view]);

  /* ⌘K */
  useEffect(() => {
    const k = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        setCmd((c) => !c);
      }
      if (e.key === 'Escape') {
        setCmd(false);
        setNotif(false);
      }
    };
    addEventListener('keydown', k);
    return () => removeEventListener('keydown', k);
  }, []);
  useEffect(() => {
    if (!notif) return;
    const close = (e: MouseEvent) => !(e.target as HTMLElement).closest('.notif-wrap') && setNotif(false);
    document.addEventListener('click', close);
    return () => document.removeEventListener('click', close);
  }, [notif]);

  const cmds = useMemo(() => {
    const all = [...nav.map((n) => ({ label: n.label, icon: n.icon, go: href(n.key), kind: 'Go to' })), { label: 'Back to website', icon: X, go: '/', kind: 'Site' }];
    return all.filter((c) => c.label.toLowerCase().includes(q.toLowerCase()));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q, nav]);

  const logout = () => {
    setSession(null);
    router.push('/login');
  };

  return (
    <div className="d-shell" style={{ ['--rc' as string]: 'var(--teal-d)' } as React.CSSProperties}>
      <aside className="d-side">
        <Logo href="/" className="logo" onDark />
        <span className="d-role">
          <b /> {ROLE_LABEL[role]} portal
        </span>
        <nav className="d-nav" ref={navRef}>
          <span className="d-ind" ref={indRef} />
          <span className="d-nav-label">Workspace</span>
          {nav.map((n) => (
            <Link key={n.key} href={href(n.key)} className={view === n.key ? 'on' : ''}>
              <n.icon size={18} strokeWidth={1.8} />
              {n.label}
              {!!n.badge && <span className="badge-n">{n.badge}</span>}
            </Link>
          ))}
        </nav>
        <div className="d-side-foot">
          <Link href={href('profile')} className="d-me-link">
            <span className="d-avatar">{initials(session.name)}</span>
            <span>
              <b style={{ fontSize: 14, fontWeight: 500 }}>{session.name}</b>
              <small>{online ? 'Connected' : 'Offline demo'}</small>
            </span>
          </Link>
          <button className="lnk" onClick={logout}>
            <LogOut size={16} /> Log out
          </button>
        </div>
      </aside>
      <div className="d-scrim" onClick={() => document.body.classList.remove('side-open')} />

      <main className="d-main">
        <header className="d-top">
          <button className="d-icon-btn d-burger" aria-label="Menu" onClick={() => document.body.classList.toggle('side-open')}>
            <Menu size={18} />
          </button>
          <div>
            <div className="d-crumb">{crumb}</div>
            <h1 className="d-title">{title}</h1>
          </div>
          <div className="d-top-r">
            <button className="d-search" onClick={() => setCmd(true)}>
              <Search size={16} />
              <span>Search</span>
              <kbd>⌘K</kbd>
            </button>
            <div className="notif-wrap" style={{ position: 'relative' }}>
              <button
                className="d-icon-btn"
                aria-label="Notifications"
                onClick={(e) => {
                  e.stopPropagation();
                  setNotif((n) => !n);
                  setUnread(false);
                }}
              >
                <Bell size={18} />
                {unread && notices.length > 0 && <span className="dot" />}
              </button>
              <div className={`d-notif${notif ? ' open' : ''}`}>
                <h5>Notifications</h5>
                {notices.length === 0 && <div className="empty">Nothing new</div>}
                {notices.map((n, i) => (
                  <div className="n" key={i}>
                    <span className="n-ic">
                      <n.icon size={16} />
                    </span>
                    <span>
                      {n.text}
                      <small>{n.sub}</small>
                    </span>
                  </div>
                ))}
              </div>
            </div>
            <ThemeToggle />
            <Link href={href('profile')} className="d-avatar" aria-label="Your profile" title="Your profile">
              {initials(session.name)}
            </Link>
          </div>
        </header>
        <div key={view} className="view on">
          {children}
        </div>
      </main>

      <div className={`d-ov${cmd ? ' open' : ''}`} onClick={(e) => e.target === e.currentTarget && setCmd(false)}>
        {cmd && (
          <div className="cmdk">
            <input
              autoFocus
              placeholder="Jump to…"
              value={q}
              onChange={(e) => {
                setQ(e.target.value);
                setSel(0);
              }}
              onKeyDown={(e) => {
                if (e.key === 'ArrowDown') setSel((s) => Math.min(s + 1, cmds.length - 1));
                if (e.key === 'ArrowUp') setSel((s) => Math.max(s - 1, 0));
                if (e.key === 'Enter' && cmds[sel]) {
                  router.push(cmds[sel].go);
                  setCmd(false);
                  setQ('');
                }
              }}
            />
            <ul>
              {cmds.map((c, i) => (
                <li
                  key={c.label}
                  className={i === sel ? 'sel' : ''}
                  onMouseEnter={() => setSel(i)}
                  onClick={() => {
                    router.push(c.go);
                    setCmd(false);
                    setQ('');
                  }}
                >
                  <c.icon size={16} /> {c.label}
                  <small>{c.kind}</small>
                </li>
              ))}
              {cmds.length === 0 && <li className="empty">No matches</li>}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
}

/** Modal with overlay; closes on overlay click and Escape. */
export function Modal({ open, onClose, wide, children }: { open: boolean; onClose: () => void; wide?: boolean; children: ReactNode }) {
  useEffect(() => {
    if (!open) return;
    const k = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    addEventListener('keydown', k);
    return () => removeEventListener('keydown', k);
  }, [open, onClose]);
  return (
    <div className={`d-ov${open ? ' open' : ''}`} onClick={(e) => e.target === e.currentTarget && onClose()}>
      <div className={`d-modal${wide ? ' wide' : ''}`} style={{ position: 'relative' }}>
        <button className="d-icon-btn m-close" aria-label="Close" onClick={onClose}>
          <X size={18} />
        </button>
        {open && children}
      </div>
    </div>
  );
}

export function Stat({ label, value, sub, icon: Icon }: { label: string; value: ReactNode; sub?: string; icon?: LucideIcon }) {
  return (
    <div className="d-card stat rv">
      <span className="lbl">
        {Icon && <Icon size={14} />} {label}
      </span>
      <span className="val">{value}</span>
      {sub && <span className="c-sub">{sub}</span>}
    </div>
  );
}

export function Toggle({ on, onChange, label }: { on: boolean; onChange: (v: boolean) => void; label?: string }) {
  return <button className={`tg${on ? ' on' : ''}`} aria-label={label} aria-pressed={on} onClick={() => onChange(!on)} />;
}
