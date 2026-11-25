'use client';
import { useParams } from 'next/navigation';
import { Award, BarChart3, Brain, Briefcase, CalendarDays, ClipboardList, FileText, LayoutDashboard, MessageSquare, Plus, Shield, Trash2, UserRound, Users } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { useToast } from '@/components/Toast';
import { initials, type AdminUser, type Data, usePortal } from '@/lib/api';
import Gate from './Gate';
import Profile from './Profile';
import Shell, { Modal, Stat, Toggle, type NavItem } from './Shell';

type P = ReturnType<typeof usePortal>;

export default function AdminPortal() {
  const p = usePortal('admin');
  const params = useParams<{ view?: string[] }>();
  const view = params.view?.[0] ?? 'overview';
  if (!p.ready || !p.session) return <Gate role="admin" ready={p.ready} />;
  if (!p.data || !p.admin) return <Gate role="admin" ready loading />;
  const d = p.data, users = p.admin.users;
  const pending = users.filter((u) => u.status !== 'Verified' && u.status !== 'Suspended');
  const nav: NavItem[] = [
    { key: 'overview', label: 'Overview', icon: LayoutDashboard },
    { key: 'content', label: 'Content', icon: FileText },
    { key: 'listings', label: 'Listings', icon: Briefcase },
    { key: 'users', label: 'Users', icon: Users, badge: pending.length || undefined },
    { key: 'quizzes', label: 'Quizzes & badges', icon: Award },
    { key: 'profile', label: 'Profile', icon: UserRound },
  ];
  const titles: Record<string, [string, React.ReactNode]> = {
    overview: ['Admin', <>Platform <em>overview</em></>],
    content: ['Moderation', <>Posts & <em>comments</em></>],
    listings: ['Moderation', <>Jobs, tasks & <em>events</em></>],
    users: ['People', <>All <em>users</em></>],
    quizzes: ['Learning', <>Quizzes & <em>badges</em></>],
    profile: ['Account', <>Admin <em>profile</em></>],
  };
  const [crumb, title] = titles[view] ?? titles.overview;
  const notices = pending.slice(0, 4).map((u) => ({ icon: Shield, text: `${u.name} is waiting for verification`, sub: u.role }));

  return (
    <Shell role="admin" session={p.session} nav={nav} view={view} title={title} crumb={crumb} notices={notices} online={p.online}>
      {view === 'overview' && <Overview stats={p.admin.stats} d={d} users={users} />}
      {view === 'content' && <Content d={d} p={p} />}
      {view === 'listings' && <Listings d={d} p={p} />}
      {view === 'users' && <UsersView users={users} p={p} me={p.session.id} />}
      {view === 'quizzes' && <Quizzes />}
      {view === 'profile' && <Profile session={p.session} role="admin" stats={[['Users', users.length], ['Posts', d.posts.length], ['Pending', pending.length]]} />}
    </Shell>
  );
}

/* ───────── overview ───────── */
function Overview({ stats, d, users }: { stats: any; d: Data; users: AdminUser[] }) { // eslint-disable-line @typescript-eslint/no-explicit-any
  const byRole: Record<string, number> = stats.users_by_role ?? {};
  const total = Object.values(byRole).reduce((a, b) => a + b, 0);
  const max = Math.max(...Object.values(byRole), 1);
  return (
    <>
      <div className="g g-4">
        <Stat label="Total users" value={total} sub={`${users.filter((u) => u.status === 'Verified').length} verified`} icon={Users} />
        <Stat label="Posts" value={stats.posts} sub={`${stats.comments} comments`} icon={MessageSquare} />
        <Stat label="Jobs & internships" value={stats.opportunities} sub={`${stats.applications} applications`} icon={Briefcase} />
        <Stat label="Paid tasks" value={stats.tasks} sub={`${stats.submissions} submissions`} icon={ClipboardList} />
      </div>
      <div className="g g-4 mt">
        <Stat label="Events" value={stats.events} sub={`${stats.registrations} registrations`} icon={CalendarDays} />
        <Stat label="Startup ideas" value={stats.ideas} sub="pitched to investors" icon={Brain} />
        <Stat label="Committed" value={`₹${stats.committed_lakh ?? 0}L`} sub="by investors" icon={BarChart3} />
        <Stat label="Announcements" value={d.announcements.length} sub="from colleges" icon={FileText} />
      </div>
      <div className="g g-2 mt">
        <div className="d-card rv">
          <div className="c-head"><span className="c-title">Users by <em>role</em></span></div>
          <div className="bars">
            {Object.entries(byRole).map(([r, n]) => (
              <div className="bar-row" key={r}>
                <span style={{ textTransform: 'capitalize' }}>{r}</span>
                <span className="tr"><i style={{ ['--w' as string]: `${(n / max) * 100}%` } as React.CSSProperties} /></span>
                <b>{n}</b>
              </div>
            ))}
          </div>
        </div>
        <div className="d-card rv">
          <div className="c-head"><span className="c-title">Latest <em>posts</em></span></div>
          <div className="rows">
            {d.posts.slice(-4).reverse().map((x) => (
              <div className="row" key={x.id}>
                <span className="d-avatar" style={{ width: 32, height: 32, fontSize: 11 }}>{initials(x.author?.name ?? '?')}</span>
                <div className="t">
                  <b>{x.title || x.body}</b>
                  <small>{x.author?.name} · {x.time}</small>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

/* ───────── content ───────── */
function Content({ d, p }: { d: Data; p: P }) {
  const toast = useToast();
  const [open, setOpen] = useState<number | null>(null);
  const post = d.posts.find((x) => x.id === open);
  const patch = (id: number, body: { hidden?: boolean; pinned?: boolean }) =>
    p.act('PATCH', `/posts/${id}`, body, (x) => ({ ...x, posts: x.posts.map((q) => (q.id === id ? { ...q, ...body } : q)) })).then((r) => r && toast(body.hidden !== undefined ? (body.hidden ? 'Post hidden' : 'Post visible again') : body.pinned ? 'Post pinned' : 'Post unpinned'));
  const del = (id: number) =>
    confirm('Delete this post permanently?') && p.act('DELETE', `/posts/${id}`, undefined, (x) => ({ ...x, posts: x.posts.filter((q) => q.id !== id) })).then((r) => r && (toast('Post deleted'), setOpen(null)));
  const delComment = (pid: number, cid: number) =>
    p.act('DELETE', `/comments/${cid}`, undefined, (x) => ({ ...x, posts: x.posts.map((q) => (q.id === pid ? { ...q, comments: q.comments.filter((c) => c.id !== cid) } : q)) })).then((r) => r && toast('Comment deleted'));
  return (
    <>
      <div className="d-card rv">
        <div className="tbl-wrap">
          <table className="tbl">
            <thead>
              <tr><th>Post</th><th>Author</th><th>Likes</th><th>Comments</th><th>Status</th><th>Pinned</th><th /></tr>
            </thead>
            <tbody>
              {d.posts.map((x) => (
                <tr key={x.id} style={x.hidden ? { opacity: 0.55 } : undefined}>
                  <td style={{ maxWidth: 340 }}>
                    <button onClick={() => setOpen(x.id)} style={{ textAlign: 'left' }}>
                      <b style={{ fontWeight: 600 }}>{x.title || 'Post'}</b>
                      <div className="c-sub" style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: 320 }}>{x.body}</div>
                    </button>
                  </td>
                  <td>{x.author?.name}</td>
                  <td>{x.likes}</td>
                  <td>{x.comments.length}</td>
                  <td><span className={`pill-s ${x.hidden ? 'bad' : 'ok'}`}>{x.hidden ? 'Hidden' : 'Visible'}</span></td>
                  <td><Toggle on={!!x.pinned} onChange={(v) => patch(x.id, { pinned: v })} label="Pinned" /></td>
                  <td>
                    <div className="row-acts">
                      <button className="mini-b" onClick={() => setOpen(x.id)}>Comments</button>
                      <button className="mini-b" onClick={() => patch(x.id, { hidden: !x.hidden })}>{x.hidden ? 'Unhide' : 'Hide'}</button>
                      <button className="mini-b danger" onClick={() => del(x.id)}>Delete</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      <Modal open={!!post} onClose={() => setOpen(null)} wide>
        {post && (
          <>
            <span className="pill-s">{post.src || 'Post'} · {post.time}</span>
            <h3 style={{ marginTop: 10 }}>{post.title || 'Post'}</h3>
            <p className="c-sub">by {post.author?.name}</p>
            <p className="mt" style={{ lineHeight: 1.6 }}>{post.body}</p>
            {post.url && <p className="c-sub mt">{post.url}</p>}
            <div className="c-title mt" style={{ fontSize: 22, marginBottom: 8 }}>Comments ({post.comments.length})</div>
            <div className="rows">
              {post.comments.length === 0 && <div className="c-sub">No comments</div>}
              {post.comments.map((c) => (
                <div className="row" key={c.id}>
                  <span className="d-avatar" style={{ width: 30, height: 30, fontSize: 11 }}>{initials(c.author?.name ?? '?')}</span>
                  <div className="t">
                    <b>{c.author?.name}</b>
                    <small>{c.text}</small>
                  </div>
                  <button className="mini-b danger" onClick={() => delComment(post.id, c.id)} aria-label="Delete comment"><Trash2 size={12} /></button>
                </div>
              ))}
            </div>
            <div className="row-acts mt">
              <button className="b ghost" onClick={() => patch(post.id, { hidden: !post.hidden })}>{post.hidden ? 'Unhide post' : 'Hide post'}</button>
              <button className="b danger" onClick={() => del(post.id)}>Delete post</button>
            </div>
          </>
        )}
      </Modal>
    </>
  );
}

/* ───────── listings ───────── */
function Listings({ d, p }: { d: Data; p: P }) {
  const toast = useToast();
  const live = (id: number, v: boolean) =>
    p.act('PATCH', `/opportunities/${id}`, { live: v }, (x) => ({ ...x, opportunities: x.opportunities.map((o) => (o.id === id ? { ...o, live: v } : o)) })).then((r) => r && toast(v ? 'Listing restored' : 'Listing taken down'));
  const del = (kind: 'opportunities' | 'tasks' | 'events', id: number) =>
    confirm('Delete this listing permanently?') &&
    p.act('DELETE', `/${kind}/${id}`, undefined, (x) => ({ ...x, [kind]: (x[kind] as { id: number }[]).filter((o) => o.id !== id) })).then((r) => r && toast('Deleted'));
  return (
    <>
      <div className="d-card rv">
        <div className="c-head"><span className="c-title">Jobs & <em>internships</em></span></div>
        <div className="tbl-wrap">
          <table className="tbl">
            <thead><tr><th>Role</th><th>Company</th><th>Applicants</th><th>Live</th><th /></tr></thead>
            <tbody>
              {d.opportunities.map((o) => (
                <tr key={o.id}>
                  <td><b>{o.title}</b><div className="c-sub">{o.internship ? 'Internship' : 'Job'} · {o.pay}</div></td>
                  <td>{o.company}</td>
                  <td>{o.applicants}</td>
                  <td><Toggle on={o.live} onChange={(v) => live(o.id, v)} label="Live" /></td>
                  <td><button className="mini-b danger" onClick={() => del('opportunities', o.id)}>Delete</button></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      <div className="g g-2 mt">
        <div className="d-card rv">
          <div className="c-head"><span className="c-title">Paid <em>tasks</em></span></div>
          <div className="rows">
            {d.tasks.map((t) => (
              <div className="row" key={t.id}>
                <div className="t"><b>{t.title}</b><small>{t.company} · ₹{t.reward.toLocaleString('en-IN')} · {t.submissions.length} submissions</small></div>
                <button className="mini-b danger" onClick={() => del('tasks', t.id)}>Delete</button>
              </div>
            ))}
          </div>
        </div>
        <div className="d-card rv">
          <div className="c-head"><span className="c-title"><em>Events</em></span></div>
          <div className="rows">
            {d.events.map((e) => (
              <div className="row" key={e.id}>
                <div className="t"><b>{e.title}</b><small>{e.organiser} · {e.dates}</small></div>
                <button className="mini-b danger" onClick={() => del('events', e.id)}>Delete</button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

/* ───────── users ───────── */
function UsersView({ users, p, me }: { users: AdminUser[]; p: P; me: string }) {
  const toast = useToast();
  const [f, setF] = useState('all');
  const [q, setQ] = useState('');
  const list = users.filter((u) => (f === 'all' || u.role === f) && u.name.toLowerCase().includes(q.toLowerCase()));
  const patch = (u: AdminUser, body: Partial<AdminUser>, msg: string) =>
    p.actAdmin('PATCH', `/users/${u.id}`, body, (xs) => xs.map((x) => (x.id === u.id ? { ...x, ...body } : x))).then((ok) => ok && toast(msg));
  const del = (u: AdminUser) =>
    confirm(`Delete ${u.name}? This cannot be undone.`) && p.actAdmin('DELETE', `/users/${u.id}`, undefined, (xs) => xs.filter((x) => x.id !== u.id)).then((ok) => ok && toast('User deleted'));
  return (
    <>
      <div className="c-head" style={{ flexWrap: 'wrap' }}>
        <div className="filters2">
          {['all', 'student', 'company', 'investor', 'college', 'admin'].map((r) => (
            <button key={r} className={f === r ? 'on' : ''} onClick={() => setF(r)} style={{ textTransform: 'capitalize' }}>{r}</button>
          ))}
        </div>
        <div className="r fld" style={{ margin: 0 }}>
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search users" style={{ padding: '9px 12px' }} />
        </div>
      </div>
      <div className="d-card rv">
        <div className="tbl-wrap">
          <table className="tbl">
            <thead><tr><th>User</th><th>Role</th><th>Status</th><th>Admin</th><th /></tr></thead>
            <tbody>
              {list.map((u) => (
                <tr key={u.id}>
                  <td>
                    <div className="who">
                      <span className="d-avatar" style={{ width: 32, height: 32, fontSize: 11 }}>{initials(u.name)}</span>
                      <span><b style={{ fontWeight: 600 }}>{u.name}</b><small>{u.id}</small></span>
                    </div>
                  </td>
                  <td style={{ textTransform: 'capitalize' }}>{u.role}</td>
                  <td><span className={`pill-s ${u.status === 'Verified' ? 'ok' : u.status === 'Suspended' ? 'bad' : 'warn'}`}>{u.status}</span></td>
                  <td><Toggle on={!!u.is_admin} onChange={(v) => u.id !== me && patch(u, { is_admin: v ? 1 : 0 }, v ? `${u.name} is now an admin` : 'Admin rights removed')} label="Admin" /></td>
                  <td>
                    <div className="row-acts">
                      {u.status !== 'Verified' && <button className="mini-b" onClick={() => patch(u, { status: 'Verified' }, `${u.name} verified`)}>Verify</button>}
                      {u.status !== 'Suspended' ? (
                        <button className="mini-b" onClick={() => u.id !== me && patch(u, { status: 'Suspended' }, `${u.name} suspended`)}>Suspend</button>
                      ) : (
                        <button className="mini-b" onClick={() => patch(u, { status: 'Verified' }, `${u.name} restored`)}>Restore</button>
                      )}
                      {u.id !== me && <button className="mini-b danger" onClick={() => del(u)}>Delete</button>}
                    </div>
                  </td>
                </tr>
              ))}
              {list.length === 0 && <tr><td colSpan={5} className="empty">No users</td></tr>}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}

/* ───────── quizzes & badges (saved in this browser) ───────── */
type Quiz = { id: number; title: string; topic: string; questions: number; minutes: number; live: boolean };
type Badge = { id: number; name: string; rule: string; holders: number };
const QZ: Quiz[] = [
  { id: 1, title: 'JavaScript fundamentals', topic: 'Web', questions: 20, minutes: 15, live: true },
  { id: 2, title: 'Logical reasoning · Set A', topic: 'Reasoning', questions: 25, minutes: 20, live: true },
  { id: 3, title: 'IQ test · Standard', topic: 'IQ', questions: 30, minutes: 25, live: true },
  { id: 4, title: 'Startup basics', topic: 'Founders', questions: 15, minutes: 10, live: false },
];
const BG: Badge[] = [
  { id: 1, name: '30-day streak', rule: 'Finish all 30 MSW Labs days', holders: 412 },
  { id: 2, name: 'Hackathon finalist', rule: 'Reach the final round of any hackathon', holders: 188 },
  { id: 3, name: 'First PR merged', rule: 'Get a company task approved', holders: 96 },
  { id: 4, name: 'Top referrer', rule: 'Refer 10 friends who join', holders: 51 },
];
function useStored<T>(key: string, init: T) {
  const [v, setV] = useState<T>(init);
  useEffect(() => {
    try {
      const s = localStorage.getItem(key);
      if (s) setV(JSON.parse(s));
    } catch {}
  }, [key]);
  const set = (n: T) => {
    setV(n);
    try {
      localStorage.setItem(key, JSON.stringify(n));
    } catch {}
  };
  return [v, set] as const;
}

function Quizzes() {
  const toast = useToast();
  const [quizzes, setQuizzes] = useStored<Quiz[]>('msw-quizzes', QZ);
  const [badges, setBadges] = useStored<Badge[]>('msw-badges', BG);
  const [qf, setQf] = useState<{ title: string; topic: string; questions: string; minutes: string } | null>(null);
  const [bf, setBf] = useState<{ name: string; rule: string } | null>(null);
  const nextId = useMemo(() => () => Date.now(), []);
  return (
    <div className="g g-2">
      <div className="d-card rv">
        <div className="c-head">
          <span className="c-title"><em>Quizzes</em></span>
          <div className="r"><button className="b sm" onClick={() => setQf({ title: '', topic: 'Web', questions: '20', minutes: '15' })}><Plus size={14} /> New quiz</button></div>
        </div>
        <div className="rows">
          {quizzes.map((z) => (
            <div className="row" key={z.id}>
              <div className="t"><b>{z.title}</b><small>{z.topic} · {z.questions} questions · {z.minutes} min</small></div>
              <Toggle on={z.live} onChange={(v) => { setQuizzes(quizzes.map((x) => (x.id === z.id ? { ...x, live: v } : x))); toast(v ? 'Quiz published' : 'Quiz unpublished'); }} label="Live" />
              <button className="mini-b danger" aria-label="Delete quiz" onClick={() => { setQuizzes(quizzes.filter((x) => x.id !== z.id)); toast('Quiz deleted'); }}><Trash2 size={12} /></button>
            </div>
          ))}
        </div>
      </div>
      <div className="d-card rv">
        <div className="c-head">
          <span className="c-title"><em>Badges</em></span>
          <div className="r"><button className="b sm" onClick={() => setBf({ name: '', rule: '' })}><Plus size={14} /> New badge</button></div>
        </div>
        <div className="rows">
          {badges.map((b) => (
            <div className="row" key={b.id}>
              <span className="n-ic"><Award size={16} /></span>
              <div className="t"><b>{b.name}</b><small>{b.rule} · {b.holders} holders</small></div>
              <button className="mini-b danger" aria-label="Delete badge" onClick={() => { setBadges(badges.filter((x) => x.id !== b.id)); toast('Badge deleted'); }}><Trash2 size={12} /></button>
            </div>
          ))}
        </div>
      </div>
      <Modal open={!!qf} onClose={() => setQf(null)}>
        {qf && (
          <>
            <h3>New <em>quiz</em></h3>
            <div className="fld"><label>Title</label><input value={qf.title} onChange={(e) => setQf({ ...qf, title: e.target.value })} /></div>
            <div className="fld"><label>Topic</label>
              <select value={qf.topic} onChange={(e) => setQf({ ...qf, topic: e.target.value })}>{['Web', 'Reasoning', 'IQ', 'Founders', 'DSA', 'Design'].map((t) => <option key={t}>{t}</option>)}</select>
            </div>
            <div className="fld-row">
              <div className="fld"><label>Questions</label><input type="number" value={qf.questions} onChange={(e) => setQf({ ...qf, questions: e.target.value })} /></div>
              <div className="fld"><label>Minutes</label><input type="number" value={qf.minutes} onChange={(e) => setQf({ ...qf, minutes: e.target.value })} /></div>
            </div>
            <button className="b" onClick={() => { if (!qf.title.trim()) return toast('Add a title'); setQuizzes([...quizzes, { id: nextId(), title: qf.title.trim(), topic: qf.topic, questions: Number(qf.questions) || 10, minutes: Number(qf.minutes) || 10, live: false }]); setQf(null); toast('Quiz created as draft'); }}>Create quiz</button>
          </>
        )}
      </Modal>
      <Modal open={!!bf} onClose={() => setBf(null)}>
        {bf && (
          <>
            <h3>New <em>badge</em></h3>
            <div className="fld"><label>Name</label><input value={bf.name} onChange={(e) => setBf({ ...bf, name: e.target.value })} /></div>
            <div className="fld"><label>How to earn it</label><input value={bf.rule} onChange={(e) => setBf({ ...bf, rule: e.target.value })} /></div>
            <button className="b" onClick={() => { if (!bf.name.trim()) return toast('Add a name'); setBadges([...badges, { id: nextId(), name: bf.name.trim(), rule: bf.rule, holders: 0 }]); setBf(null); toast('Badge created'); }}>Create badge</button>
          </>
        )}
      </Modal>
    </div>
  );
}
