'use client';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { ArrowLeft, Bookmark, BookmarkCheck, Briefcase, Check, LayoutDashboard, Rocket, TrendingUp, UserRound, Wallet, X } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { useToast } from '@/components/Toast';
import { lakh, type Idea, usePortal } from '@/lib/api';
import Gate from './Gate';
import Profile from './Profile';
import Shell, { Stat, type NavItem } from './Shell';

type P = ReturnType<typeof usePortal>;

function useWatch() {
  const [w, setW] = useState<number[]>([]);
  useEffect(() => {
    try {
      setW(JSON.parse(localStorage.getItem('msw-watch') || '[]'));
    } catch {}
  }, []);
  const toggle = (id: number) =>
    setW((cur) => {
      const n = cur.includes(id) ? cur.filter((x) => x !== id) : [...cur, id];
      try {
        localStorage.setItem('msw-watch', JSON.stringify(n));
      } catch {}
      return n;
    });
  return [w, toggle] as const;
}

export default function InvestorPortal() {
  const p = usePortal('investor');
  const params = useParams<{ view?: string[] }>();
  const view = params.view?.[0] ?? 'overview';
  const dealId = params.view?.[1] ? Number(params.view[1]) : null;
  const [watch, toggleWatch] = useWatch();
  if (!p.ready || !p.session) return <Gate role="investor" ready={p.ready} />;
  if (!p.data) return <Gate role="investor" ready loading />;
  const ideas = p.data.ideas;
  const backed = ideas.filter((i) => i.decision === 'backed');
  const open = ideas.filter((i) => i.decision == null);
  const nav: NavItem[] = [
    { key: 'overview', label: 'Overview', icon: LayoutDashboard },
    { key: 'deals', label: 'Deals', icon: Rocket, badge: open.length || undefined },
    { key: 'portfolio', label: 'Portfolio', icon: Briefcase, badge: backed.length || undefined },
    { key: 'watchlist', label: 'Watchlist', icon: Bookmark, badge: watch.length || undefined },
    { key: 'profile', label: 'Profile', icon: UserRound },
  ];
  const deal = dealId != null ? ideas.find((i) => i.id === dealId) : null;
  const titles: Record<string, [string, React.ReactNode]> = {
    overview: ['Investor portal', <>Hello, <em>{p.session.name.split(' ')[0]}</em></>],
    deals: deal ? ['Deals', <>{deal.name}</>] : ['Discover', <>Student <em>deals</em></>],
    portfolio: ['Your bets', <><em>Portfolio</em></>],
    watchlist: ['Saved', <><em>Watchlist</em></>],
    profile: ['Account', <>Investor <em>profile</em></>],
  };
  const [crumb, title] = titles[view] ?? titles.overview;
  const notices = open.slice(0, 3).map((i) => ({ icon: Rocket, text: `New deal: ${i.name}`, sub: `${i.sector} · asking ${lakh(i.ask)}` }));
  const committed = backed.reduce((a, i) => a + (i.my_cheque || 0), 0);

  return (
    <Shell role="investor" session={p.session} nav={nav} view={view} title={title} crumb={crumb} notices={notices} online={p.online}>
      {view === 'overview' && (
        <>
          <div className="g g-4">
            <Stat label="Committed" value={lakh(committed)} sub={`${backed.length} startups backed`} icon={Wallet} />
            <Stat label="Open deals" value={open.length} sub="waiting for a decision" icon={Rocket} />
            <Stat label="Watchlist" value={watch.length} sub="saved deals" icon={Bookmark} />
            <Stat label="Avg. growth" value={`${Math.round(ideas.reduce((a, i) => a + i.growth, 0) / Math.max(ideas.length, 1))}%`} sub="month on month" icon={TrendingUp} />
          </div>
          <div className="d-card rv mt">
            <div className="c-head">
              <span className="c-title">Fresh <em>deals</em></span>
            </div>
            <DealGrid ideas={open.length ? open : ideas} watch={watch} />
          </div>
        </>
      )}
      {view === 'deals' && (deal ? <DealDetail key={deal.id} i={deal} p={p} watched={watch.includes(deal.id)} toggleWatch={toggleWatch} /> : <Deals ideas={ideas} watch={watch} />)}
      {view === 'portfolio' && <Portfolio ideas={backed} />}
      {view === 'watchlist' && (watch.length ? <DealGrid ideas={ideas.filter((i) => watch.includes(i.id))} watch={watch} /> : <div className="d-card empty">Save deals to keep an eye on them.</div>)}
      {view === 'profile' && <Profile session={p.session} role="investor" stats={[['Committed', lakh(committed)], ['Startups backed', backed.length], ['Deals reviewed', ideas.filter((i) => i.decision).length]]} />}
    </Shell>
  );
}

function Spark({ xs }: { xs: number[] }) {
  const max = Math.max(...xs, 1);
  const pts = xs.map((v, i) => `${(i / (xs.length - 1)) * 100},${40 - (v / max) * 36}`).join(' ');
  return (
    <svg viewBox="0 0 100 40" preserveAspectRatio="none" style={{ width: '100%', height: 44 }}>
      <polyline points={pts} fill="none" stroke="var(--teal-d)" strokeWidth="2" vectorEffect="non-scaling-stroke" />
    </svg>
  );
}

function DealGrid({ ideas, watch }: { ideas: Idea[]; watch: number[] }) {
  return (
    <div className="g g-3">
      {ideas.map((i) => (
        <Link className="d-card rv deal-card" key={i.id} href={`/investor/deals/${i.id}`}>
          <div className="c-head">
            <span className="pill-s">{i.sector}</span>
            <span className="c-sub">{i.stage}</span>
            <div className="r">
              {watch.includes(i.id) && <BookmarkCheck size={16} />}
              {i.decision === 'backed' && <span className="pill-s ok">Backed</span>}
              {i.decision === 'passed' && <span className="pill-s">Passed</span>}
            </div>
          </div>
          <div className="c-title">{i.name}</div>
          <p className="c-sub" style={{ margin: '8px 0 12px' }}>{i.pitch}</p>
          <Spark xs={i.spark} />
          <div className="fund-bar mt">
            <i style={{ width: `${Math.min(100, (i.raised / i.ask) * 100)}%` }} />
          </div>
          <div className="c-head" style={{ marginTop: 10, marginBottom: 0 }}>
            <span className="c-sub">
              <b style={{ color: 'var(--ink)' }}>{lakh(i.raised)}</b> of {lakh(i.ask)}
            </span>
            <span className="r c-sub">{i.growth}% MoM</span>
          </div>
        </Link>
      ))}
    </div>
  );
}

function Deals({ ideas, watch }: { ideas: Idea[]; watch: number[] }) {
  const sectors = ['All', ...Array.from(new Set(ideas.map((i) => i.sector)))];
  const [f, setF] = useState('All');
  const list = useMemo(() => ideas.filter((i) => f === 'All' || i.sector === f), [ideas, f]);
  return (
    <>
      <div className="filters2" style={{ marginBottom: 16 }}>
        {sectors.map((s) => (
          <button key={s} className={f === s ? 'on' : ''} onClick={() => setF(s)}>
            {s}
          </button>
        ))}
      </div>
      <p className="c-sub" style={{ marginBottom: 14 }}>Click a deal to see the full pitch, traction and founders.</p>
      <DealGrid ideas={list} watch={watch} />
    </>
  );
}

function DealDetail({ i, p, watched, toggleWatch }: { i: Idea; p: P; watched: boolean; toggleWatch: (id: number) => void }) {
  const toast = useToast();
  const remaining = Math.max(i.ask - i.raised + (i.decision === 'backed' ? i.my_cheque : 0), i.min_ticket);
  const [amt, setAmt] = useState(i.my_cheque || i.min_ticket);
  const decide = async (decision: 'backed' | 'passed' | null) => {
    const amount = decision === 'backed' ? amt : 0;
    const res = await p.act('POST', `/ideas/${i.id}/decision`, { decision, amount }, (d) => ({
      ...d,
      ideas: d.ideas.map((x) => {
        if (x.id !== i.id) return x;
        let raised = x.raised - (x.decision === 'backed' ? x.my_cheque : 0);
        if (decision === 'backed') raised += amount;
        return { ...x, decision, my_cheque: amount, raised: Math.max(raised, 0) };
      }),
    }));
    if (res) toast(decision === 'backed' ? `Committed ${lakh(amount)} to ${i.name}` : decision === 'passed' ? `Passed on ${i.name}` : 'Decision undone');
  };
  return (
    <>
      <Link href="/investor/deals" className="b ghost sm" style={{ marginBottom: 16 }}>
        <ArrowLeft size={14} /> All deals
      </Link>
      <div className="g g-21">
        <div>
          <div className="d-card rv">
            <div className="deal-hero">
              <div className="row-acts">
                <span className="pill-s">{i.sector}</span>
                <span className="pill-s">{i.stage}</span>
                {i.decision === 'backed' && <span className="pill-s ok">You backed this · {lakh(i.my_cheque)}</span>}
                {i.decision === 'passed' && <span className="pill-s">You passed</span>}
              </div>
              <h2>{i.name}</h2>
              <p className="c-sub" style={{ fontSize: 16 }}>{i.pitch}</p>
            </div>
            <div className="metric-row mt">
              <div><b>{i.users.toLocaleString('en-IN')}</b><small>Users</small></div>
              <div><b>{i.growth}%</b><small>MoM growth</small></div>
              <div><b>{i.revenue}</b><small>Revenue</small></div>
              <div><b>{i.equity}%</b><small>Equity offered</small></div>
            </div>
            <div className="mt">
              <div className="d-crumb">Traction</div>
              <Spark xs={i.spark} />
            </div>
          </div>
          <div className="g g-2 mt">
            <div className="d-card rv">
              <div className="c-title" style={{ fontSize: 22, marginBottom: 8 }}>Problem</div>
              <p>{i.problem}</p>
            </div>
            <div className="d-card rv">
              <div className="c-title" style={{ fontSize: 22, marginBottom: 8 }}>Solution</div>
              <p>{i.solution}</p>
            </div>
          </div>
          <div className="d-card rv mt">
            <dl className="kv">
              <dt>Market</dt><dd>{i.market}</dd>
              <dt>Business model</dt><dd>{i.model}</dd>
              <dt>Valuation (implied)</dt><dd>{lakh(Math.round((i.ask / i.equity) * 100 * 10) / 10)}</dd>
            </dl>
          </div>
          <div className="g g-2 mt">
            <div className="d-card rv">
              <div className="c-title" style={{ fontSize: 22, marginBottom: 12 }}>Founders</div>
              <div className="rows">
                {i.founders.map(([n, r, c]) => (
                  <div className="row" key={n}>
                    <span className="d-avatar" style={{ width: 34, height: 34, fontSize: 12 }}>{n.split(' ').map((w) => w[0]).join('')}</span>
                    <div className="t">
                      <b>{n}</b>
                      <small>{r} · {c}</small>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="d-card rv">
              <div className="c-title" style={{ fontSize: 22, marginBottom: 12 }}>Use of funds</div>
              <div className="bars">
                {i.use_of_funds.map(([k, v]) => (
                  <div className="bar-row" key={k}>
                    <span>{k}</span>
                    <span className="tr"><i style={{ ['--w' as string]: `${v}%` } as React.CSSProperties} /></span>
                    <b>{v}%</b>
                  </div>
                ))}
              </div>
            </div>
          </div>
          <div className="d-card rv mt">
            <div className="c-title" style={{ fontSize: 22, marginBottom: 12 }}>Milestones</div>
            <ul className="ul-plain">
              {i.milestones.map((m) => (
                <li key={m}><Check size={14} /> {m}</li>
              ))}
            </ul>
          </div>
        </div>
        <div>
          <div className="d-card rv" style={{ position: 'sticky', top: 100 }}>
            <div className="c-title" style={{ marginBottom: 6 }}>The round</div>
            <p className="c-sub">{lakh(i.raised)} raised of {lakh(i.ask)} · min. cheque {lakh(i.min_ticket)}</p>
            <div className="fund-bar mt">
              <i style={{ width: `${Math.min(100, (i.raised / i.ask) * 100)}%` }} />
            </div>
            <div className="mt">
              <div className="d-crumb">Your cheque</div>
              <div className="stat"><span className="val">{lakh(amt)}</span></div>
              <input className="slider" type="range" min={i.min_ticket} max={Math.max(remaining, i.min_ticket)} step={0.5} value={amt} onChange={(e) => setAmt(Number(e.target.value))} />
              <p className="c-sub">≈ {((amt / i.ask) * i.equity).toFixed(2)}% equity</p>
            </div>
            <div className="row-acts mt">
              <button className="b" onClick={() => decide('backed')}>
                <Check size={16} /> {i.decision === 'backed' ? 'Update cheque' : 'Back this'}
              </button>
              {i.decision !== 'passed' && (
                <button className="b ghost" onClick={() => decide('passed')}>
                  <X size={16} /> Pass
                </button>
              )}
              {i.decision && (
                <button className="b ghost" onClick={() => decide(null)}>
                  Undo
                </button>
              )}
            </div>
            <button className="b ghost mt" style={{ width: '100%' }} onClick={() => { toggleWatch(i.id); toast(watched ? 'Removed from watchlist' : 'Saved to watchlist'); }}>
              {watched ? <BookmarkCheck size={16} /> : <Bookmark size={16} />} {watched ? 'On your watchlist' : 'Add to watchlist'}
            </button>
          </div>
        </div>
      </div>
    </>
  );
}

function Portfolio({ ideas }: { ideas: Idea[] }) {
  const total = ideas.reduce((a, i) => a + i.my_cheque, 0);
  if (!ideas.length) return <div className="d-card empty">You haven’t backed anyone yet. Open a deal to commit a cheque.</div>;
  return (
    <div className="d-card rv">
      <div className="c-head">
        <span className="c-title">{lakh(total)} <em>committed</em></span>
      </div>
      <div className="tbl-wrap">
        <table className="tbl">
          <thead>
            <tr><th>Startup</th><th>Sector</th><th>Your cheque</th><th>Equity</th><th>Round</th><th /></tr>
          </thead>
          <tbody>
            {ideas.map((i) => (
              <tr key={i.id}>
                <td><b>{i.name}</b><div className="c-sub">{i.pitch}</div></td>
                <td>{i.sector}</td>
                <td>{lakh(i.my_cheque)}</td>
                <td>{((i.my_cheque / i.ask) * i.equity).toFixed(2)}%</td>
                <td>
                  <span className="meter"><i style={{ ['--w' as string]: `${Math.min(100, (i.raised / i.ask) * 100)}%` } as React.CSSProperties} /></span>
                </td>
                <td><Link className="mini-b" href={`/investor/deals/${i.id}`}>Open</Link></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
