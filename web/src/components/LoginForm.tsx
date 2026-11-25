'use client';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { ArrowRight, Building2, Shield, Smartphone, TrendingUp } from 'lucide-react';
import { useEffect, useState } from 'react';
import Halftone from '@/components/Halftone';
import Logo from '@/components/Logo';
import ThemeToggle from '@/components/ThemeToggle';
import { DEMO, getSession, login, setSession, type Role } from '@/lib/api';

const ROLES: { key: Role; label: string; icon: typeof Building2; blurb: string }[] = [
  { key: 'company', label: 'Company', icon: Building2, blurb: 'Post jobs, internships and paid tasks. Find talent by what they’ve built.' },
  { key: 'investor', label: 'Investor', icon: TrendingUp, blurb: 'Discover student startups, read full deal pages and back founders early.' },
  { key: 'admin', label: 'Admin', icon: Shield, blurb: 'Moderate content, verify users and manage quizzes and badges.' },
];

export default function LoginForm() {
  const router = useRouter();
  const qs = useSearchParams();
  const initial = (['company', 'investor', 'admin'] as Role[]).includes(qs.get('role') as Role) ? (qs.get('role') as Role) : 'company';
  const [role, setRole] = useState<Role>(initial);
  const [id, setId] = useState(DEMO[initial].id);
  const [pw, setPw] = useState('demo1234');
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    const s = getSession();
    if (s && !qs.get('role')) router.replace(`/${s.role}`);
  }, [qs, router]);

  const pick = (r: Role) => {
    setRole(r);
    setId(DEMO[r].id);
    setErr('');
  };
  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setErr('');
    try {
      const s = await login(role, id.trim());
      setSession(s);
      router.push(`/${role}`);
    } catch {
      setErr(`No ${role} account found for “${id}”.`);
      setBusy(false);
    }
  };
  const meta = ROLES.find((r) => r.key === role)!;

  return (
    <div className="auth2">
      <div className="auth2-art">
        <Halftone className="hero-dots" color="#ecebe6" />
        <Logo onDark />
        <div style={{ position: 'relative' }}>
          <h2>
            Welcome <em>back.</em>
          </h2>
          <p style={{ marginTop: 16 }}>{meta.blurb}</p>
        </div>
        <p className="mono" style={{ fontSize: 11 }}>MSW Community · Companies · Investors · Admin</p>
      </div>
      <form className="auth2-form" onSubmit={submit}>
        <div className="top">
          <Link href="/" className="back" style={{ color: 'var(--muted)', fontSize: 14 }}>
            Back to site
          </Link>
          <ThemeToggle />
        </div>
        <div>
          <h1>Log in</h1>
          <p className="sub">Choose how you use MSW Community.</p>
        </div>
        <div className="roles3" role="tablist">
          {ROLES.map((r) => (
            <button type="button" key={r.key} role="tab" aria-selected={role === r.key} className={role === r.key ? 'on' : ''} onClick={() => pick(r.key)}>
              <r.icon size={18} />
              {r.label}
            </button>
          ))}
        </div>
        <label>
          Account ID
          <input value={id} onChange={(e) => setId(e.target.value)} autoComplete="username" required />
        </label>
        <label>
          Password
          <input type="password" value={pw} onChange={(e) => setPw(e.target.value)} autoComplete="current-password" required />
        </label>
        {err && <p style={{ color: '#e5484d', fontSize: 14 }}>{err}</p>}
        <button className="go" disabled={busy}>
          {busy ? 'Signing in…' : `Continue as ${meta.label.toLowerCase()}`} <ArrowRight size={18} />
        </button>
        <p className="demo-hint">Demo accounts are pre-filled: lumen-labs, nikhil-varma, msw-admin.</p>
        <div className="student-note">
          <Smartphone size={22} />
          <div>
            <b>Student?</b>
            <p>Students use the MSW Community app.</p>
          </div>
          <Link href="/get-app">Get the app</Link>
        </div>
      </form>
    </div>
  );
}
