'use client';
import { useParams } from 'next/navigation';
import {
  Briefcase, Check, ClipboardList, ExternalLink, Eye, GitPullRequest, LayoutDashboard, Plus, Search, Trash2, UserRound, Users,
} from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { useToast } from '@/components/Toast';
import { PHOTOS } from '@/lib/photos';
import { initials, type Data, type Opp, type Person, type Submission, type Task, usePortal } from '@/lib/api';
import Gate from './Gate';
import Profile from './Profile';
import Shell, { Modal, Stat, Toggle, type NavItem } from './Shell';

const lines = (s: string) => s.split('\n').map((x) => x.trim()).filter(Boolean);
const csv = (s: string) => s.split(',').map((x) => x.trim()).filter(Boolean);

export default function CompanyPortal() {
  const p = usePortal('company');
  const params = useParams<{ view?: string[] }>();
  const view = params.view?.[0] ?? 'overview';
  if (!p.ready || !p.session) return <Gate role="company" ready={p.ready} />;
  if (!p.data) return <Gate role="company" ready loading />;
  const d = p.data;
  const me = d.me?.name ?? p.session.name;
  const jobs = d.opportunities.filter((o) => o.company === me);
  const tasks = d.tasks.filter((t) => t.company === me);
  const toReview = tasks.flatMap((t) => t.submissions.filter((s) => s.status === 'In review'));
  const nav: NavItem[] = [
    { key: 'overview', label: 'Overview', icon: LayoutDashboard },
    { key: 'jobs', label: 'Job postings', icon: Briefcase, badge: jobs.length },
    { key: 'applicants', label: 'Applicants', icon: Users },
    { key: 'tasks', label: 'Paid tasks', icon: ClipboardList, badge: toReview.length || undefined },
    { key: 'talent', label: 'Talent search', icon: Search },
    { key: 'profile', label: 'Profile', icon: UserRound },
  ];
  const titles: Record<string, [string, React.ReactNode]> = {
    overview: ['Company portal', <>Hello, <em>{me}</em></>],
    jobs: ['Hiring', <>Job <em>postings</em></>],
    applicants: ['Hiring', <><em>Applicants</em></>],
    tasks: ['Contribute', <>Paid <em>tasks</em></>],
    talent: ['Discover', <>Talent <em>search</em></>],
    profile: ['Account', <>Company <em>profile</em></>],
  };
  const [crumb, title] = titles[view] ?? titles.overview;
  const notices = [
    ...toReview.slice(0, 3).map((s) => ({ icon: GitPullRequest, text: `${s.student?.name ?? 'A student'} submitted a pull request`, sub: 'Waiting for your review' })),
    ...jobs.slice(0, 2).map((j) => ({ icon: Users, text: `${j.applicants} applicants on ${j.title}`, sub: j.live ? 'Posting is live' : 'Posting is paused' })),
  ];

  return (
    <Shell role="company" session={p.session} nav={nav} view={view} title={title} crumb={crumb} notices={notices} online={p.online}>
      {view === 'overview' && <Overview d={d} jobs={jobs} tasks={tasks} toReview={toReview} />}
      {view === 'jobs' && <Jobs jobs={jobs} p={p} me={me} />}
      {view === 'applicants' && <Applicants jobs={jobs} p={p} students={d.users.filter((u) => u.role === 'student')} />}
      {view === 'tasks' && <Tasks tasks={tasks} p={p} me={me} />}
      {view === 'talent' && <Talent students={d.users.filter((u) => u.role === 'student')} />}
      {view === 'profile' && <Profile session={p.session} role="company" stats={[['Live postings', jobs.filter((j) => j.live).length], ['Paid tasks', tasks.length], ['Applicants', jobs.reduce((a, j) => a + j.applicants, 0)]]} />}
    </Shell>
  );
}

type P = ReturnType<typeof usePortal>;

/* ───────── overview ───────── */
function Overview({ d, jobs, tasks, toReview }: { d: Data; jobs: Opp[]; tasks: Task[]; toReview: Submission[] }) {
  const applicants = jobs.reduce((a, j) => a + j.applicants, 0);
  const paid = tasks.flatMap((t) => t.submissions.filter((s) => s.status === 'Approved').map(() => t.reward)).reduce((a, b) => a + b, 0);
  return (
    <>
      <div className="g g-4">
        <Stat label="Live postings" value={jobs.filter((j) => j.live).length} sub={`${jobs.length} total`} icon={Briefcase} />
        <Stat label="Applicants" value={applicants} sub="across all postings" icon={Users} />
        <Stat label="To review" value={toReview.length} sub="task submissions" icon={GitPullRequest} />
        <Stat label="Paid out" value={`₹${paid.toLocaleString('en-IN')}`} sub="approved tasks" icon={Check} />
      </div>
      <div className="g g-2 mt">
        <div className="d-card rv">
          <div className="c-head">
            <span className="c-title">Your <em>postings</em></span>
          </div>
          <div className="rows">
            {jobs.length === 0 && <div className="empty">No postings yet</div>}
            {jobs.map((j) => (
              <div className="row" key={j.id}>
                <span className={`status-dot${j.live ? '' : ' off'}`} />
                <div className="t">
                  <b>{j.title}</b>
                  <small>{j.internship ? 'Internship' : 'Job'} · {j.work_mode} · {j.pay}</small>
                </div>
                <span className="pill-s">{j.applicants} applied</span>
              </div>
            ))}
          </div>
        </div>
        <div className="d-card rv">
          <div className="c-head">
            <span className="c-title">Waiting for <em>review</em></span>
          </div>
          <div className="rows">
            {toReview.length === 0 && <div className="empty">All caught up</div>}
            {toReview.map((s) => (
              <div className="row" key={s.id}>
                <span className="d-avatar" style={{ width: 34, height: 34, fontSize: 12 }}>{initials(s.student?.name ?? '?')}</span>
                <div className="t">
                  <b>{s.student?.name}</b>
                  <small>{s.repo}</small>
                </div>
                <span className="pill-s warn">In review</span>
              </div>
            ))}
          </div>
        </div>
      </div>
      <div className="d-card rv mt">
        <div className="c-head">
          <span className="c-title">Top <em>talent</em> this week</span>
        </div>
        <div className="rows">
          {d.users
            .filter((u) => u.role === 'student')
            .sort((a, b) => (b.level ?? 0) - (a.level ?? 0))
            .slice(0, 4)
            .map((u) => (
              <div className="row" key={u.id}>
                <span className="d-avatar" style={{ width: 34, height: 34, fontSize: 12 }}>{initials(u.name)}</span>
                <div className="t">
                  <b>{u.name}</b>
                  <small>{u.headline} · {u.college}</small>
                </div>
                <span className="pill-s">Level {u.level}</span>
              </div>
            ))}
        </div>
      </div>
    </>
  );
}

/* ───────── job postings ───────── */
const EMPTY_JOB = { title: '', internship: true, work_mode: 'Remote', location: '', pay: '', duration: '3 months', start_date: '', apply_by: '', openings: '1', experience: 'Freshers welcome', skills: '', eligibility: '', about: '', responsibilities: '', perks: 'Certificate\nLetter of recommendation' };

function Jobs({ jobs, p, me }: { jobs: Opp[]; p: P; me: string }) {
  const toast = useToast();
  const [open, setOpen] = useState<Opp | null>(null);
  const [form, setForm] = useState<typeof EMPTY_JOB | null>(null);
  const set = (k: keyof typeof EMPTY_JOB, v: string | boolean) => setForm((f) => (f ? { ...f, [k]: v } : f));

  const toggleLive = (j: Opp, live: boolean) =>
    p.act('PATCH', `/opportunities/${j.id}`, { live }, (d) => ({ ...d, opportunities: d.opportunities.map((o) => (o.id === j.id ? { ...o, live } : o)) })).then((r) => r && toast(live ? 'Posting is live' : 'Posting paused'));
  const remove = (j: Opp) =>
    confirm(`Delete “${j.title}”?`) &&
    p.act('DELETE', `/opportunities/${j.id}`, undefined, (d) => ({ ...d, opportunities: d.opportunities.filter((o) => o.id !== j.id) })).then((r) => r && toast('Posting deleted'));

  const publish = async () => {
    if (!form || !form.title.trim()) return toast('Add a title first');
    const o = {
      title: form.title.trim(), company: me, color: 4279964772, internship: form.internship, work_mode: form.work_mode, location: form.location, pay: form.pay, duration: form.duration,
      start_date: form.start_date, apply_by: form.apply_by, openings: Number(form.openings) || 1, experience: form.experience, skills: csv(form.skills), eligibility: lines(form.eligibility),
      about: form.about, responsibilities: lines(form.responsibilities), perks: lines(form.perks), rounds: [], about_company: '', views: 0, live: true,
    };
    const res = await p.act('POST', '/opportunities', o, (d) => d);
    if (!res) return toast('Could not publish');
    const id = res.id ?? Date.now();
    p.setData((d) => (d ? { ...d, opportunities: [...d.opportunities, { ...o, id, applicants: 0 } as Opp] } : d));
    setForm(null);
    toast('Posting published');
  };

  return (
    <>
      <div className="c-head">
        <span className="c-sub">{jobs.length} postings · students apply from the app</span>
        <div className="r">
          <button className="b" onClick={() => setForm({ ...EMPTY_JOB })}>
            <Plus size={16} /> New posting
          </button>
        </div>
      </div>
      <div className="d-card rv">
        <div className="tbl-wrap">
          <table className="tbl">
            <thead>
              <tr>
                <th>Role</th>
                <th>Type</th>
                <th>Pay</th>
                <th>Apply by</th>
                <th>Applicants</th>
                <th>Live</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {jobs.map((j) => (
                <tr key={j.id}>
                  <td>
                    <button className="who" onClick={() => setOpen(j)} style={{ textAlign: 'left' }}>
                      <span>
                        <b style={{ fontWeight: 600 }}>{j.title}</b>
                        <small>{j.location}</small>
                      </span>
                    </button>
                  </td>
                  <td>{j.internship ? 'Internship' : 'Job'} · {j.work_mode}</td>
                  <td>{j.pay}</td>
                  <td>{j.apply_by}</td>
                  <td>{j.applicants}</td>
                  <td>
                    <Toggle on={j.live} onChange={(v) => toggleLive(j, v)} label="Live" />
                  </td>
                  <td>
                    <div className="row-acts">
                      <button className="mini-b" onClick={() => setOpen(j)}>
                        <Eye size={12} style={{ display: 'inline', verticalAlign: -2 }} /> View
                      </button>
                      <button className="mini-b danger" onClick={() => remove(j)}>
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {jobs.length === 0 && (
                <tr>
                  <td colSpan={7} className="empty">No postings yet. Create your first one.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      <Modal open={!!open} onClose={() => setOpen(null)} wide>
        {open && <JobDetail j={open} />}
      </Modal>

      <Modal open={!!form} onClose={() => setForm(null)} wide>
        {form && (
          <>
            <h3>
              New <em>posting</em>
            </h3>
            <p className="c-sub" style={{ marginBottom: 20 }}>Detailed postings get 3x more applications. Everything here is shown to students in the app.</p>
            <div className="fld">
              <label>Role title</label>
              <input value={form.title} onChange={(e) => set('title', e.target.value)} placeholder="Frontend Developer Intern" />
            </div>
            <div className="fld-row">
              <div className="fld">
                <label>Type</label>
                <select value={form.internship ? 'i' : 'j'} onChange={(e) => set('internship', e.target.value === 'i')}>
                  <option value="i">Internship</option>
                  <option value="j">Full-time job</option>
                </select>
              </div>
              <div className="fld">
                <label>Work mode</label>
                <select value={form.work_mode} onChange={(e) => set('work_mode', e.target.value)}>
                  <option>Remote</option>
                  <option>Hybrid</option>
                  <option>On-site</option>
                </select>
              </div>
            </div>
            <div className="fld-row">
              <div className="fld">
                <label>Location</label>
                <input value={form.location} onChange={(e) => set('location', e.target.value)} placeholder="Bengaluru (Remote)" />
              </div>
              <div className="fld">
                <label>Stipend / salary</label>
                <input value={form.pay} onChange={(e) => set('pay', e.target.value)} placeholder="₹40,000 / month" />
              </div>
            </div>
            <div className="fld-row">
              <div className="fld">
                <label>Duration</label>
                <input value={form.duration} onChange={(e) => set('duration', e.target.value)} />
              </div>
              <div className="fld">
                <label>Openings</label>
                <input type="number" min={1} value={form.openings} onChange={(e) => set('openings', e.target.value)} />
              </div>
            </div>
            <div className="fld-row">
              <div className="fld">
                <label>Start date</label>
                <input value={form.start_date} onChange={(e) => set('start_date', e.target.value)} placeholder="Jan 05, 2027" />
              </div>
              <div className="fld">
                <label>Apply by</label>
                <input value={form.apply_by} onChange={(e) => set('apply_by', e.target.value)} placeholder="Dec 15, 2026" />
              </div>
            </div>
            <div className="fld-row">
              <div className="fld">
                <label>Experience</label>
                <input value={form.experience} onChange={(e) => set('experience', e.target.value)} />
              </div>
              <div className="fld">
                <label>Skills (comma separated)</label>
                <input value={form.skills} onChange={(e) => set('skills', e.target.value)} placeholder="React, TypeScript, Git" />
              </div>
            </div>
            <div className="fld">
              <label>About the role</label>
              <textarea value={form.about} onChange={(e) => set('about', e.target.value)} />
            </div>
            <div className="fld-row">
              <div className="fld">
                <label>Responsibilities (one per line)</label>
                <textarea value={form.responsibilities} onChange={(e) => set('responsibilities', e.target.value)} />
              </div>
              <div className="fld">
                <label>Eligibility (one per line)</label>
                <textarea value={form.eligibility} onChange={(e) => set('eligibility', e.target.value)} />
              </div>
            </div>
            <div className="fld">
              <label>Perks (one per line)</label>
              <textarea value={form.perks} onChange={(e) => set('perks', e.target.value)} />
            </div>
            <button className="b" onClick={publish}>
              Publish posting
            </button>
          </>
        )}
      </Modal>
    </>
  );
}

function JobDetail({ j }: { j: Opp }) {
  const List = ({ t, xs }: { t: string; xs?: string[] }) =>
    xs && xs.length ? (
      <div className="mt">
        <div className="c-title" style={{ fontSize: 22, marginBottom: 10 }}>{t}</div>
        <ul className="ul-plain">
          {xs.map((x) => (
            <li key={x}>
              <Check size={14} /> {x}
            </li>
          ))}
        </ul>
      </div>
    ) : null;
  return (
    <>
      <span className="pill-s">{j.internship ? 'Internship' : 'Job'} · {j.live ? 'Live' : 'Paused'}</span>
      <h3 style={{ marginTop: 10 }}>{j.title}</h3>
      <p className="c-sub">{j.company} · {j.location}</p>
      <div className="metric-row mt">
        <div><b>{j.pay}</b><small>Pay</small></div>
        <div><b>{j.duration}</b><small>Duration</small></div>
        <div><b>{j.openings}</b><small>Openings</small></div>
        <div><b>{j.applicants}</b><small>Applicants</small></div>
      </div>
      <dl className="kv mt">
        <dt>Work mode</dt><dd>{j.work_mode}</dd>
        <dt>Start date</dt><dd>{j.start_date || '—'}</dd>
        <dt>Apply by</dt><dd>{j.apply_by || '—'}</dd>
        <dt>Experience</dt><dd>{j.experience}</dd>
        <dt>Skills</dt><dd>{j.skills?.join(', ')}</dd>
      </dl>
      {j.about && <p className="mt" style={{ lineHeight: 1.6 }}>{j.about}</p>}
      <List t="Responsibilities" xs={j.responsibilities} />
      <List t="Eligibility" xs={j.eligibility} />
      <List t="Perks" xs={j.perks} />
    </>
  );
}

/* ───────── applicants ───────── */
const STAGES = ['Applied', 'Shortlisted', 'Interview', 'Hired', 'Rejected'];
type App = { user_id: string; name: string; link: string; note: string };

function Applicants({ jobs, p, students }: { jobs: Opp[]; p: P; students: Person[] }) {
  const toast = useToast();
  const [jid, setJid] = useState<number | null>(jobs[0]?.id ?? null);
  const [apps, setApps] = useState<App[]>([]);
  const [stage, setStage] = useState<Record<string, string>>({});
  const [who, setWho] = useState<Person | null>(null);

  useEffect(() => {
    try {
      setStage(JSON.parse(localStorage.getItem('msw-stages') || '{}'));
    } catch {}
  }, []);
  useEffect(() => {
    if (jid == null) return;
    p.applications(jid).then((list) => {
      // offline demo: show a few students as applicants
      setApps(list.length || p.online ? list : students.slice(0, 3).map((s) => ({ user_id: s.id, name: s.name, link: `github.com/${s.id}`, note: s.headline })));
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [jid, p.online]);

  const move = (uid: string, s: string) => {
    const next = { ...stage, [`${jid}:${uid}`]: s };
    setStage(next);
    try {
      localStorage.setItem('msw-stages', JSON.stringify(next));
    } catch {}
    toast(`Moved to ${s}`);
  };
  const find = (id: string) => students.find((s) => s.id === id);

  return (
    <>
      <div className="filters2" style={{ marginBottom: 16 }}>
        {jobs.map((j) => (
          <button key={j.id} className={jid === j.id ? 'on' : ''} onClick={() => setJid(j.id)}>
            {j.title}
          </button>
        ))}
      </div>
      {jobs.length === 0 && <div className="d-card empty">Create a posting to start receiving applications.</div>}
      {jid != null && (
        <div className="kb" style={{ ['--cols' as string]: 5 } as React.CSSProperties}>
          {STAGES.map((s) => {
            const col = apps.filter((a) => (stage[`${jid}:${a.user_id}`] ?? 'Applied') === s);
            return (
              <div
                className="kb-col"
                key={s}
                onDragOver={(e) => {
                  e.preventDefault();
                  e.currentTarget.classList.add('over');
                }}
                onDragLeave={(e) => e.currentTarget.classList.remove('over')}
                onDrop={(e) => {
                  e.currentTarget.classList.remove('over');
                  move(e.dataTransfer.getData('text/plain'), s);
                }}
              >
                <h6>
                  {s} <b>{col.length}</b>
                </h6>
                {col.map((a) => {
                  const st = find(a.user_id);
                  return (
                    <div className="kb-card" key={a.user_id} draggable onDragStart={(e) => e.dataTransfer.setData('text/plain', a.user_id)} onClick={() => st && setWho(st)}>
                      <div className="top">
                        <span className="d-avatar" style={{ width: 28, height: 28, fontSize: 11 }}>{initials(a.name)}</span>
                        <b>{a.name}</b>
                      </div>
                      <div className="c-sub">{st?.college ?? a.note}</div>
                      <div className="meta">
                        <span>Level {st?.level ?? '—'}</span>
                        <select
                          value={s}
                          onClick={(e) => e.stopPropagation()}
                          onChange={(e) => move(a.user_id, e.target.value)}
                          style={{ font: 'inherit', fontSize: 12, border: '1px solid var(--line-2)', borderRadius: 8, padding: '2px 4px', background: 'var(--card)', color: 'var(--ink)' }}
                        >
                          {STAGES.map((x) => (
                            <option key={x}>{x}</option>
                          ))}
                        </select>
                      </div>
                    </div>
                  );
                })}
              </div>
            );
          })}
        </div>
      )}
      {jid != null && apps.length === 0 && <p className="c-sub mt">No applications yet. Students apply from the MSW Community app.</p>}
      <Modal open={!!who} onClose={() => setWho(null)}>
        {who && <StudentCard s={who} />}
      </Modal>
    </>
  );
}

function StudentCard({ s }: { s: Person }) {
  const toast = useToast();
  return (
    <>
      <div className="prof-head">
        <span className="d-avatar big">{initials(s.name)}</span>
        <div>
          <h3 style={{ marginBottom: 4 }}>{s.name}</h3>
          <p className="c-sub">{s.headline}</p>
          <p className="c-sub">{s.course} · {s.college}</p>
        </div>
      </div>
      <div className="metric-row mt">
        <div><b>{s.level}</b><small>Level</small></div>
        <div><b>{s.hackathons}</b><small>Hackathons</small></div>
        <div><b>{s.iq}</b><small>IQ score</small></div>
        <div><b>{s.gh}</b><small>GitHub score</small></div>
      </div>
      {s.bio && <p className="mt">{s.bio}</p>}
      <div className="filters2 mt">
        {(s.skills ?? []).map((k: string) => (
          <span className="chip2" key={k}>{k}</span>
        ))}
      </div>
      <div className="row-acts mt">
        <button className="b" onClick={() => toast(`Invite sent to ${s.name}`)}>Invite to apply</button>
        <button className="b ghost" onClick={() => toast('Shortlisted')}>Shortlist</button>
      </div>
    </>
  );
}

/* ───────── paid tasks ───────── */
const EMPTY_TASK = { title: '', reward: '3000', days: '3', level: '2', stack: '', repo: '', description: '', deliverables: 'Pull request against the main branch\nScreenshots or a short video of the result', acceptance: 'All existing tests pass' };

function Tasks({ tasks, p, me }: { tasks: Task[]; p: P; me: string }) {
  const toast = useToast();
  const [sub, setSub] = useState<{ t: Task; s: Submission } | null>(null);
  const [form, setForm] = useState<typeof EMPTY_TASK | null>(null);
  const set = (k: keyof typeof EMPTY_TASK, v: string) => setForm((f) => (f ? { ...f, [k]: v } : f));

  const review = async (s: Submission, status: string) => {
    const r = await p.act('PATCH', `/submissions/${s.id}`, { status }, (d) => ({ ...d, tasks: d.tasks.map((t) => ({ ...t, submissions: t.submissions.map((x) => (x.id === s.id ? { ...x, status } : x)) })) }));
    if (r) {
      toast(status === 'Approved' ? `Approved · payment of ₹${sub?.t.reward.toLocaleString('en-IN')} released` : 'Changes requested');
      setSub(null);
    }
  };
  const remove = (t: Task) =>
    confirm(`Delete “${t.title}”?`) && p.act('DELETE', `/tasks/${t.id}`, undefined, (d) => ({ ...d, tasks: d.tasks.filter((x) => x.id !== t.id) })).then((r) => r && toast('Task deleted'));

  const publish = async () => {
    if (!form || !form.title.trim() || !form.repo.trim()) return toast('Title and GitHub repo are required');
    const t = { title: form.title.trim(), company: me, color: 4279964772, reward: Number(form.reward) || 0, days: Number(form.days) || 1, level: Number(form.level) || 1, stack: csv(form.stack), repo: form.repo.trim(), description: form.description, deliverables: lines(form.deliverables), acceptance: lines(form.acceptance) };
    const res = await p.act('POST', '/tasks', t, (d) => d);
    if (!res) return toast('Could not publish');
    p.setData((d) => (d ? { ...d, tasks: [...d.tasks, { ...t, id: res.id ?? Date.now(), submissions: [] } as Task] } : d));
    setForm(null);
    toast('Task published');
  };

  return (
    <>
      <div className="c-head">
        <span className="c-sub">Students fork your repo, open a PR and submit proof. You approve and pay, or request changes.</span>
        <div className="r">
          <button className="b" onClick={() => setForm({ ...EMPTY_TASK })}>
            <Plus size={16} /> New task
          </button>
        </div>
      </div>
      <div className="g g-2">
        {tasks.map((t) => (
          <div className="d-card rv" key={t.id}>
            <div className="c-head">
              <span className="pill-s">₹{t.reward.toLocaleString('en-IN')} · {t.days} days · Level {t.level}</span>
              <div className="r">
                <button className="mini-b danger" onClick={() => remove(t)} aria-label="Delete task">
                  <Trash2 size={12} />
                </button>
              </div>
            </div>
            <div className="c-title" style={{ marginBottom: 8 }}>{t.title}</div>
            <p className="c-sub">{t.description}</p>
            <p className="c-sub mt" style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
              <GitPullRequest size={14} /> {t.repo}
            </p>
            <div className="mt">
              <div className="d-crumb" style={{ marginBottom: 6 }}>Submissions ({t.submissions.length})</div>
              <div className="rows">
                {t.submissions.length === 0 && <div className="c-sub">No submissions yet</div>}
                {t.submissions.map((s) => (
                  <button className="row" key={s.id} onClick={() => setSub({ t, s })} style={{ width: '100%', textAlign: 'left' }}>
                    <span className="d-avatar" style={{ width: 30, height: 30, fontSize: 11 }}>{initials(s.student?.name ?? '?')}</span>
                    <div className="t">
                      <b>{s.student?.name}</b>
                      <small>{s.repo}</small>
                    </div>
                    <span className={`pill-s ${s.status === 'Approved' ? 'ok' : s.status === 'Changes requested' ? 'bad' : 'warn'}`}>{s.status}</span>
                  </button>
                ))}
              </div>
            </div>
          </div>
        ))}
        {tasks.length === 0 && <div className="d-card empty">No tasks yet. Post one with a GitHub repo.</div>}
      </div>

      <Modal open={!!sub} onClose={() => setSub(null)} wide>
        {sub && (
          <>
            <span className={`pill-s ${sub.s.status === 'Approved' ? 'ok' : sub.s.status === 'Changes requested' ? 'bad' : 'warn'}`}>{sub.s.status}</span>
            <h3 style={{ marginTop: 10 }}>{sub.t.title}</h3>
            <p className="c-sub">Submitted by {sub.s.student?.name} · {sub.s.student?.college}</p>
            <dl className="kv mt">
              <dt>Pull request</dt>
              <dd>
                <a href={`https://${sub.s.repo}`} target="_blank" rel="noopener noreferrer" style={{ textDecoration: 'underline' }}>
                  {sub.s.repo} <ExternalLink size={12} style={{ display: 'inline' }} />
                </a>
              </dd>
              <dt>Live demo</dt>
              <dd>{sub.s.demo ? <a href={`https://${sub.s.demo}`} target="_blank" rel="noopener noreferrer" style={{ textDecoration: 'underline' }}>{sub.s.demo}</a> : '—'}</dd>
              <dt>Reward</dt>
              <dd>₹{sub.t.reward.toLocaleString('en-IN')}</dd>
            </dl>
            {sub.s.notes && <p className="mt" style={{ lineHeight: 1.6 }}>{sub.s.notes}</p>}
            {sub.s.shots?.length > 0 && (
              <div className="shots mt">
                {sub.s.shots.map((i) => (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img key={i} src={PHOTOS[i % PHOTOS.length]} alt="Screenshot" />
                ))}
              </div>
            )}
            <div className="mt">
              <div className="c-title" style={{ fontSize: 22, marginBottom: 10 }}>Acceptance criteria</div>
              <ul className="ul-plain">
                {sub.t.acceptance.map((a) => (
                  <li key={a}>
                    <Check size={14} /> {a}
                  </li>
                ))}
              </ul>
            </div>
            <div className="row-acts mt">
              <button className="b" onClick={() => review(sub.s, 'Approved')}>
                <Check size={16} /> Approve & pay
              </button>
              <button className="b ghost" onClick={() => review(sub.s, 'Changes requested')}>
                Request changes
              </button>
            </div>
          </>
        )}
      </Modal>

      <Modal open={!!form} onClose={() => setForm(null)} wide>
        {form && (
          <>
            <h3>
              New paid <em>task</em>
            </h3>
            <p className="c-sub" style={{ marginBottom: 20 }}>Link a GitHub repo. Students submit a pull request, a demo and screenshots.</p>
            <div className="fld">
              <label>Task title</label>
              <input value={form.title} onChange={(e) => set('title', e.target.value)} placeholder="Fix checkout bug on mobile web" />
            </div>
            <div className="fld">
              <label>GitHub repository</label>
              <input value={form.repo} onChange={(e) => set('repo', e.target.value)} placeholder="github.com/your-org/repo" />
            </div>
            <div className="fld-row">
              <div className="fld">
                <label>Reward (₹)</label>
                <input type="number" value={form.reward} onChange={(e) => set('reward', e.target.value)} />
              </div>
              <div className="fld">
                <label>Days to complete</label>
                <input type="number" value={form.days} onChange={(e) => set('days', e.target.value)} />
              </div>
            </div>
            <div className="fld-row">
              <div className="fld">
                <label>Minimum MSW level</label>
                <input type="number" value={form.level} onChange={(e) => set('level', e.target.value)} />
              </div>
              <div className="fld">
                <label>Stack (comma separated)</label>
                <input value={form.stack} onChange={(e) => set('stack', e.target.value)} placeholder="React, Node" />
              </div>
            </div>
            <div className="fld">
              <label>Description</label>
              <textarea value={form.description} onChange={(e) => set('description', e.target.value)} />
            </div>
            <div className="fld-row">
              <div className="fld">
                <label>Deliverables (one per line)</label>
                <textarea value={form.deliverables} onChange={(e) => set('deliverables', e.target.value)} />
              </div>
              <div className="fld">
                <label>Acceptance criteria (one per line)</label>
                <textarea value={form.acceptance} onChange={(e) => set('acceptance', e.target.value)} />
              </div>
            </div>
            <button className="b" onClick={publish}>Publish task</button>
          </>
        )}
      </Modal>
    </>
  );
}

/* ───────── talent ───────── */
function Talent({ students }: { students: Person[] }) {
  const [q, setQ] = useState('');
  const [who, setWho] = useState<Person | null>(null);
  const list = useMemo(
    () => students.filter((s) => [s.name, s.college, s.headline, ...(s.skills ?? [])].join(' ').toLowerCase().includes(q.toLowerCase())).sort((a, b) => (b.level ?? 0) - (a.level ?? 0)),
    [students, q],
  );
  return (
    <>
      <div className="fld" style={{ maxWidth: 460 }}>
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search by skill, college or name" />
      </div>
      <div className="g g-3">
        {list.map((s) => (
          <button className="d-card rv deal-card" key={s.id} onClick={() => setWho(s)}>
            <div className="c-head">
              <span className="d-avatar">{initials(s.name)}</span>
              <div>
                <b>{s.name}</b>
                <div className="c-sub">{s.college}</div>
              </div>
              <div className="r">
                <span className="pill-s">Lv {s.level}</span>
              </div>
            </div>
            <p className="c-sub">{s.headline}</p>
            <div className="filters2 mt">
              {(s.skills ?? []).map((k: string) => (
                <span className="chip2" key={k}>{k}</span>
              ))}
            </div>
          </button>
        ))}
        {list.length === 0 && <div className="d-card empty">No students match “{q}”</div>}
      </div>
      <Modal open={!!who} onClose={() => setWho(null)}>
        {who && <StudentCard s={who} />}
      </Modal>
    </>
  );
}
