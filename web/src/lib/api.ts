'use client';
import { useCallback, useEffect, useState } from 'react';
import seed from './seed.json';

/* eslint-disable @typescript-eslint/no-explicit-any */
export type Role = 'company' | 'investor' | 'admin';
export type Person = { id: string; name: string; role: string; [k: string]: any };
export type Post = { id: number; author: Person; body: string; title?: string; src?: string; url?: string; time: string; likes: number; comments: { id: number; author: Person; text: string; time: string }[]; hidden?: boolean; pinned?: boolean; [k: string]: any };
export type Opp = { id: number; title: string; company: string; internship: boolean; work_mode: string; location: string; pay: string; duration: string; start_date: string; apply_by: string; openings: number; experience: string; skills: string[]; eligibility: string[]; about: string; responsibilities: string[]; perks: string[]; applicants: number; views?: number; live: boolean; [k: string]: any };
export type Submission = { id: number; student: Person; repo: string; demo: string; notes: string; shots: number[]; status: string };
export type Task = { id: number; title: string; company: string; reward: number; days: number; level: number; stack: string[]; repo: string; description: string; deliverables: string[]; acceptance: string[]; submissions: Submission[]; [k: string]: any };
export type Idea = { id: number; name: string; pitch: string; sector: string; stage: string; founders: [string, string, string][]; problem: string; solution: string; users: number; growth: number; revenue: string; market: string; model: string; ask: number; equity: number; raised: number; min_ticket: number; use_of_funds: [string, number][]; milestones: string[]; spark: number[]; decision: 'backed' | 'passed' | null; my_cheque: number };
export type Data = { me: Person; users: Person[]; posts: Post[]; events: any[]; opportunities: Opp[]; tasks: Task[]; ideas: Idea[]; announcements: any[] };
export type AdminUser = { id: string; name: string; role: string; status: string; is_admin: number };

export const API = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

/* ---------- session (demo auth: the backend trusts X-User) ---------- */
export type Session = { id: string; name: string; role: Role };
export const DEMO: Record<Role, Session> = {
  company: { id: 'lumen-labs', name: 'Lumen Labs', role: 'company' },
  investor: { id: 'nikhil-varma', name: 'Nikhil Varma', role: 'investor' },
  admin: { id: 'msw-admin', name: 'MSW Admin', role: 'admin' },
};
const KEY = 'msw-session';
export function getSession(): Session | null {
  try {
    return JSON.parse(localStorage.getItem(KEY) || 'null');
  } catch {
    return null;
  }
}
export function setSession(s: Session | null) {
  try {
    if (s) localStorage.setItem(KEY, JSON.stringify(s));
    else localStorage.removeItem(KEY);
  } catch {}
}

/* ---------- http ---------- */
async function call<T = any>(uid: string, method: string, path: string, body?: unknown): Promise<T> {
  const r = await fetch(API + path, {
    method,
    headers: { 'Content-Type': 'application/json', 'X-User': uid },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  if (!r.ok) throw new Error(`${r.status}`);
  return r.json();
}

export async function login(role: Role, userId: string): Promise<Session> {
  try {
    const r = await call<{ user: { id: string; name: string; role: string } }>(userId, 'POST', '/auth/login', { user_id: userId, role });
    if (r.user.role !== role && r.user.role !== 'admin') throw new Error('role');
    return { id: r.user.id, name: r.user.name, role };
  } catch (e) {
    if ((e as Error).message === 'role') throw e;
    if (userId === DEMO[role].id) return DEMO[role]; // offline demo
    throw e;
  }
}

/* ---------- offline fallback built from seed.json ---------- */
function offline(s: Session): Data {
  const d = JSON.parse(JSON.stringify(seed)) as any;
  const me = { id: s.id, name: s.name, role: s.role };
  const ids = (xs: any[]) => xs.map((x, i) => ({ id: i + 1, ...x }));
  let cid = 1, sid = 1;
  return {
    me,
    users: [me, ...d.users],
    posts: ids(d.posts).map((p: any) => ({ ...p, comments: (p.comments || []).map((c: any) => ({ id: cid++, ...c })), hidden: false, pinned: false })),
    events: ids(d.events),
    opportunities: ids(d.opportunities).map((o: any) => ({ applicants: 0, live: true, ...o })),
    tasks: ids(d.tasks).map((t: any) => ({ ...t, submissions: (t.submissions || []).map((x: any) => ({ id: sid++, ...x })) })),
    ideas: ids(d.ideas).map((x: any) => ({ decision: null, my_cheque: 0, ...x })),
    announcements: ids(d.announcements),
  };
}

/** Loads everything the portal needs. Mutations go to the backend and are mirrored locally,
 *  so the UI also works offline (changes then live only in this tab). */
export function usePortal(role: Role) {
  const [session, setS] = useState<Session | null>(null);
  const [data, setData] = useState<Data | null>(null);
  const [online, setOnline] = useState(false);
  const [admin, setAdmin] = useState<{ stats: any; users: AdminUser[] } | null>(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let s = getSession();
    if (!s || s.role !== role) s = null;
    setS(s);
    setReady(true);
    if (!s) return;
    const sess = s;
    (async () => {
      try {
        const d = await call<Data>(sess.id, 'GET', '/bootstrap');
        setData(d);
        setOnline(true);
        if (role === 'admin') {
          const [stats, users] = await Promise.all([call(sess.id, 'GET', '/admin/stats'), call<AdminUser[]>(sess.id, 'GET', '/admin/users')]);
          setAdmin({ stats, users });
        }
      } catch {
        const d = offline(sess);
        setData(d);
        setOnline(false);
        if (role === 'admin') {
          const users: AdminUser[] = [
            ...Object.values(DEMO).map((u) => ({ id: u.id, name: u.name, role: u.role, status: 'Verified', is_admin: u.role === 'admin' ? 1 : 0 })),
            ...d.users.filter((u) => u.role === 'student').map((u) => ({ id: u.id, name: u.name, role: u.role, status: 'Pending', is_admin: 0 })),
          ];
          setAdmin({ stats: { users_by_role: { company: 3, investor: 1, admin: 1, student: d.users.length - 1 }, posts: d.posts.length, comments: d.posts.reduce((a, p) => a + p.comments.length, 0), events: d.events.length, opportunities: d.opportunities.length, applications: 0, tasks: d.tasks.length, submissions: d.tasks.reduce((a, t) => a + t.submissions.length, 0), ideas: d.ideas.length, committed_lakh: 0 }, users });
        }
      }
    })();
  }, [role]);

  /** Run an API call (ignored when offline) and apply the same change locally. */
  const act = useCallback(
    async (method: string, path: string, body: unknown, local: (d: Data) => Data): Promise<any> => {
      let res: any = null;
      if (online && session) {
        try {
          res = await call(session.id, method, path, body);
        } catch {
          return null;
        }
      }
      setData((d) => (d ? local(d) : d));
      return res ?? { ok: true };
    },
    [online, session],
  );

  const actAdmin = useCallback(
    async (method: string, path: string, body: unknown, local: (u: AdminUser[]) => AdminUser[]) => {
      if (online && session) {
        try {
          await call(session.id, method, path, body);
        } catch {
          return false;
        }
      }
      setAdmin((a) => (a ? { ...a, users: local(a.users) } : a));
      return true;
    },
    [online, session],
  );

  const applications = useCallback(
    async (oid: number): Promise<{ user_id: string; name: string; link: string; note: string; status?: string }[]> => {
      if (!online || !session) return [];
      try {
        return await call(session.id, 'GET', `/opportunities/${oid}/applications`);
      } catch {
        return [];
      }
    },
    [online, session],
  );

  return { ready, session, data, online, admin, act, actAdmin, applications, setData };
}

export const initials = (n: string) =>
  n
    .split(/\s+/)
    .map((w) => w[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();

export const lakh = (n: number) => `₹${n % 1 === 0 ? n.toFixed(0) : n.toFixed(1)}L`;
