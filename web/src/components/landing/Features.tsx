'use client';
import Link from 'next/link';
import { ArrowUpRight, Bolt, Brain, Flame, Gem, Heart, Link2, MessageCircle, Puzzle, Share2, Sparkles, Target, Trophy, Zap } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import Split from '@/components/Split';
import { useToast } from '@/components/Toast';

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

const LINKS = [
  { url: 'https://x.com/aanya/status/18324…', src: 'X', cls: '', name: 'Aanya Sharma', av: 'AS', meta: 'IIT Delhi · now', body: 'Just shipped my first open-source PR.', title: 'Building in public, week 1', domain: 'x.com', g: 'linear-gradient(135deg,#d4f56b,#7fd1bd)' },
  { url: 'https://linkedin.com/posts/rohan-k-intern…', src: 'in', cls: 'li', name: 'Rohan Kapoor', av: 'RK', meta: 'NIT Trichy · now', body: 'Excited to start my internship at Lumen Labs this summer.', title: 'Rohan joined Lumen Labs', domain: 'linkedin.com', g: 'linear-gradient(135deg,#9fd3ff,#0a66c2)' },
  { url: 'https://reddit.com/r/cscareers/comments/…', src: 'r/', cls: 'rd', name: 'Meera Joshi', av: 'MJ', meta: 'IIT KGP · now', body: 'This thread on cracking system design rounds is gold.', title: 'How I prepped for SDE interviews', domain: 'reddit.com', g: 'linear-gradient(135deg,#ffb38a,#ff4500)' },
];

function FeedDemo() {
  const [typed, setTyped] = useState('');
  const [idx, setIdx] = useState(0);
  const [hide, setHide] = useState(false);
  const [press, setPress] = useState(false);
  const [liked, setLiked] = useState(false);
  const [likes, setLikes] = useState(128);
  useEffect(() => {
    let alive = true;
    (async () => {
      let i = 0;
      while (alive) {
        const l = LINKS[i % LINKS.length];
        i++;
        setTyped('');
        await sleep(500);
        for (const ch of l.url) {
          if (!alive) return;
          setTyped((t) => t + ch);
          await sleep(28);
        }
        await sleep(350);
        setPress(true);
        setHide(true);
        await sleep(220);
        setPress(false);
        await sleep(300);
        setIdx((i - 1) % LINKS.length);
        setLikes(40 + Math.floor(Math.random() * 200));
        setLiked(false);
        setHide(false);
        await sleep(3600);
      }
    })();
    return () => {
      alive = false;
    };
  }, []);
  const l = LINKS[idx];
  return (
    <div className="paste-demo">
      <div className="paste-bar">
        <Link2 size={18} className="pb-ic" />
        <span className="paste-text">{typed}</span>
        <span className="caret" />
        <button className={`paste-btn${press ? ' press' : ''}`}>Post</button>
      </div>
      <div className={`post-card${hide ? ' hide' : ''}`}>
        <div className="post-head">
          <div className="avatar av-1">{l.av}</div>
          <div>
            <b>{l.name}</b>
            <small>{l.meta}</small>
          </div>
          <span className={`src-pill ${l.cls}`}>{l.src}</span>
        </div>
        <p className="post-body">{l.body}</p>
        <div className="post-preview">
          <div className="pp-thumb" style={{ background: l.g }} />
          <div>
            <b className="pp-title">{l.title}</b>
            <small className="pp-domain">{l.domain}</small>
          </div>
        </div>
        <div className="post-actions">
          <span
            className={liked ? 'liked' : ''}
            onClick={() => {
              setLiked(!liked);
              setLikes((n) => n + (liked ? -1 : 1));
            }}
          >
            <Heart size={14} fill={liked ? 'currentColor' : 'none'} /> <b>{likes}</b>
          </span>
          <span>
            <MessageCircle size={14} /> 24
          </span>
          <span>
            <Share2 size={14} /> Share
          </span>
        </div>
      </div>
    </div>
  );
}

const REELS = [
  ['DAY 01', 'Python, the 60-sec intro', 3, 'r1'],
  ['DAY 07', 'APIs explained with pizza', 23, 'r2'],
  ['DAY 12', 'System design: the URL shortener', 40, 'r3'],
  ['DAY 21', 'Git like a senior engineer', 70, 'r4'],
  ['DAY 30', 'Ship it. Your capstone.', 100, 'r5'],
] as const;
const DAYS = [1, 7, 12, 21, 30];

function ReelsDemo() {
  const [ri, setRi] = useState(0);
  useEffect(() => {
    const t = setInterval(() => setRi((i) => (i + 1) % REELS.length), 2400);
    return () => clearInterval(t);
  }, []);
  const d = DAYS[ri];
  return (
    <>
      <div className="phone">
        <div className="phone-notch" />
        <div className="reel-track" style={{ transform: `translateY(${-ri * 100}%)` }}>
          {REELS.map(([day, t, w, c]) => (
            <div key={day} className={`reel ${c}`}>
              <span className="mono">{day}</span>
              <b>{t}</b>
              <i style={{ ['--w' as string]: `${w}%` } as React.CSSProperties} />
            </div>
          ))}
        </div>
        <div className="reel-ui">
          <Heart size={16} />
          <Sparkles size={16} />
          <Share2 size={16} />
        </div>
      </div>
      <div className="streak" style={{ ['--sp' as string]: d / 30 } as React.CSSProperties}>
        <div className="ring">
          <svg viewBox="0 0 40 40">
            <circle cx="20" cy="20" r="17" />
            <circle className="ring-fg" cx="20" cy="20" r="17" />
          </svg>
          <b>{d}</b>
        </div>
        <div>
          <b>{d}-day streak</b>
          <small>{d === 30 ? 'Certificate unlocked' : `${30 - d} days to certificate`}</small>
        </div>
      </div>
    </>
  );
}

function MiniId() {
  const area = useRef<HTMLElement>(null);
  const [tf, setTf] = useState('');
  const [h, setH] = useState({ x: 50, y: 50, a: 0 });
  return (
    <article
      className="card b-id reveal"
      data-cursor="Tilt"
      ref={area}
      style={{ perspective: 800 }}
      onPointerMove={(e) => {
        const r = area.current!.getBoundingClientRect(), x = (e.clientX - r.left) / r.width - 0.5, y = (e.clientY - r.top) / r.height - 0.5;
        setTf(`rotateY(${x * 22}deg) rotateX(${-y * 22}deg)`);
        setH({ x: (x + 0.5) * 100, y: (y + 0.5) * 100, a: x * 180 });
      }}
      onPointerLeave={() => setTf('')}
    >
      <div className="card-top">
        <span className="tag">Digital ID</span>
        <span className="mono num">03</span>
      </div>
      <div className="mini-id" style={{ transform: tf }}>
        <div className="holo" style={{ ['--hx' as string]: `${h.x}%`, ['--hy' as string]: `${h.y}%`, ['--ha' as string]: `${h.a}deg` } as React.CSSProperties} />
        <div className="mi-top">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src="/img/logo_light.png" alt="MSW" className="mi-logo" />
          <span className="mono">STUDENT</span>
        </div>
        <div className="mi-mid">
          <div className="avatar av-2">RK</div>
          <div>
            <b>Rohan Kapoor</b>
            <small>NIT Trichy · ECE ’27</small>
          </div>
        </div>
        <div className="mi-bot">
          <span className="mono">MSW-2026-0412</span>
          <span className="lvl">LVL 14</span>
        </div>
      </div>
      <p>Your profile is a verified ID card — scan, share, get hired.</p>
    </article>
  );
}

function Jobs() {
  const [done, setDone] = useState<Record<number, boolean>>({});
  const jobs = [
    ['L', 'ls-1', 'Frontend Intern', 'Lumen Labs · Remote · ₹40k/mo'],
    ['K', 'ls-2', 'ML Research Intern', 'Kite AI · Bengaluru'],
    ['P', 'ls-3', 'Product Designer', 'Parallax · Full-time'],
  ];
  return (
    <ul className="job-list">
      {jobs.map(([l, c, t, m], i) => (
        <li key={t}>
          <div className={`logo-sq ${c}`}>{l}</div>
          <div>
            <b>{t}</b>
            <small>{m}</small>
          </div>
          <button className={`apply${done[i] ? ' done' : ''}`} onClick={() => setDone((d) => ({ ...d, [i]: !d[i] }))}>
            {done[i] ? 'Applied' : 'Apply'}
          </button>
        </li>
      ))}
    </ul>
  );
}

type K = { t: string; s: string };
function Kanban() {
  const [cols, setCols] = useState<K[][]>([
    [
      { t: 'Fix checkout bug', s: 'Helio · ₹3,000' },
      { t: 'Landing page copy', s: 'Northwind · ₹1,500' },
    ],
    [{ t: 'Data cleaning', s: 'Kite AI · ₹2,200' }],
    [],
  ]);
  useEffect(() => {
    const t = setInterval(
      () =>
        setCols(([o, d, done]) => {
          if (d.length) return [o, d.slice(1), [...done, d[0]]];
          if (o.length) return [o.slice(1), [o[0]], done];
          return [done, [], []];
        }),
      2000,
    );
    return () => clearInterval(t);
  }, []);
  return (
    <div className="kanban">
      {['Open', 'Doing', 'Done'].map((name, ci) => (
        <div className="col" data-col={ci} key={name}>
          <span className="mono">{name}</span>
          {cols[ci].map((k) => (
            <div className="kcard" key={k.t}>
              <b>{k.t}</b>
              <small>{k.s}</small>
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}

function Heatmap() {
  const ref = useRef<HTMLDivElement>(null);
  const [cells, setCells] = useState<string[]>(() => Array(26 * 7).fill(''));
  useEffect(() => {
    const lvl = () => {
      const r = Math.random();
      return r < 0.35 ? '' : r < 0.6 ? 'l1' : r < 0.8 ? 'l2' : r < 0.93 ? 'l3' : 'l4';
    };
    let iv: ReturnType<typeof setInterval>;
    const io = new IntersectionObserver(([e]) => {
      if (!e.isIntersecting) return;
      io.disconnect();
      setCells((c) => c.map(lvl));
      iv = setInterval(() => setCells((c) => c.map((x) => (Math.random() < 0.04 ? lvl() : x))), 500);
    });
    if (ref.current) io.observe(ref.current);
    return () => {
      io.disconnect();
      clearInterval(iv);
    };
  }, []);
  return (
    <div className="heatmap" aria-hidden="true" ref={ref}>
      {cells.map((c, i) => (
        <i key={i} className={c} />
      ))}
    </div>
  );
}

function Refer() {
  const toast = useToast();
  const [copied, setCopied] = useState(false);
  return (
    <button
      className={`copy-link${copied ? ' copied' : ''}`}
      onClick={() => {
        navigator.clipboard?.writeText('https://msw.community/r/rohan').catch(() => {});
        setCopied(true);
        toast('Invite link copied');
        setTimeout(() => setCopied(false), 1800);
      }}
    >
      <span className="mono">msw.community/r/rohan</span>
      <em>{copied ? 'Copied' : 'Copy'}</em>
    </button>
  );
}

const GAME_ICONS = [Brain, Zap, Target, Puzzle, Flame, Gem];

export default function Features() {
  return (
    <section className="features" id="features">
      <div className="sec-head">
        <p className="mono label">( The platform )</p>
        <Split parts={['Everything a student needs,', { em: 'in one community.' }]} />
      </div>

      <div className="bento">
        <article className="card b-feed reveal" data-cursor="Try">
          <div className="card-top">
            <span className="tag">Feed</span>
            <span className="mono num">01</span>
          </div>
          <h3>
            Paste a link. <em>Get a post.</em>
          </h3>
          <p>Drop any link from X, LinkedIn, Instagram or Reddit — MSW turns it into a rich post your network can react to.</p>
          <FeedDemo />
        </article>

        <article className="card b-reels reveal" data-cursor="Scroll">
          <div className="card-top">
            <span className="tag">Reels</span>
            <span className="mono num">02</span>
          </div>
          <h3>
            Day 1 to Day 30. <em>Learn in reels.</em>
          </h3>
          <a className="powered mono" href="https://intern.mystartupwave.com/" target="_blank" rel="noopener noreferrer">
            Powered by MSW Labs <ArrowUpRight size={12} style={{ display: 'inline' }} />
          </a>
          <ReelsDemo />
        </article>

        <MiniId />

        <article className="card b-jobs reveal">
          <div className="card-top">
            <span className="tag">Jobs & internships</span>
            <span className="mono num">04</span>
          </div>
          <h3>
            One tap. <em>Applied.</em>
          </h3>
          <Jobs />
        </article>

        <article className="card b-tasks reveal">
          <div className="card-top">
            <span className="tag">Company tasks</span>
            <span className="mono num">05</span>
          </div>
          <h3>
            Solve real problems. <em>Get paid.</em>
          </h3>
          <Kanban />
        </article>

        <article className="card b-iq reveal">
          <div className="card-top">
            <span className="tag">Quiz · IQ · Reasoning</span>
            <span className="mono num">06</span>
          </div>
          <div className="dial">
            <svg viewBox="0 0 120 120">
              <circle cx="60" cy="60" r="50" className="d-bg" />
              <circle cx="60" cy="60" r="50" className="d-fg" />
            </svg>
            <div className="dial-n">
              <b className="count" data-to="128">
                0
              </b>
              <small>IQ score</small>
            </div>
            <div className="orbit-badges">
              {[Trophy, Flame, Brain, Bolt].map((I, i) => (
                <span key={i}>
                  <I size={16} />
                </span>
              ))}
            </div>
          </div>
          <p>Badges, quizzes and reasoning tests that actually show up on your ID.</p>
        </article>

        <article className="card b-git reveal" data-cursor="Analyse">
          <div className="card-top">
            <span className="tag">GitHub analyser</span>
            <span className="mono num">07</span>
          </div>
          <div className="git-wrap">
            <div>
              <h3>
                Your code, <em>decoded.</em>
              </h3>
              <p>Connect GitHub and get an instant profile score, top languages and what recruiters will notice first.</p>
              <div className="git-stats">
                <div>
                  <b className="count" data-to="87">
                    0
                  </b>
                  <small>/100 profile score</small>
                </div>
                <div className="langs">
                  {[
                    ['TypeScript', 46],
                    ['Python', 28],
                    ['Go', 14],
                  ].map(([l, w]) => (
                    <span key={l} style={{ ['--w' as string]: `${w}%` } as React.CSSProperties}>
                      {l}
                    </span>
                  ))}
                </div>
              </div>
            </div>
            <Heatmap />
          </div>
        </article>

        <article className="card b-refer reveal">
          <div className="card-top">
            <span className="tag">Refer & earn</span>
            <span className="mono num">08</span>
          </div>
          <div className="credits">
            <b className="count" data-to="2450">
              0
            </b>
            <small>credits earned</small>
          </div>
          <div className="coins">
            {[0, 1, 2, 3, 4].map((i) => (
              <i key={i} />
            ))}
          </div>
          <Refer />
        </article>

        <article className="card b-blog reveal" data-cursor="Read">
          <div className="card-top">
            <span className="tag">Blogs</span>
            <span className="mono num">09</span>
          </div>
          <h3>
            Stories from <em>the community.</em>
          </h3>
          <Link href="/blog" className="blog-stack">
            <div className="bs bs-3" />
            <div className="bs bs-2" />
            <div className="bs bs-1">
              <span className="mono">7 min read</span>
              <b>How I won 3 hackathons in my 2nd year</b>
            </div>
          </Link>
        </article>

        <article className="card b-idea reveal" data-cursor="Pitch">
          <div className="card-top">
            <span className="tag">Business ideas</span>
            <span className="mono num">10</span>
          </div>
          <h3>
            Pitch it. Validate it. <em>Get it funded.</em>
          </h3>
          <p>Post your startup idea, get a validation score from the community, a mentor on your project, and a direct line to investors.</p>
          <div className="idea-flow">
            {['Pitch', 'Validate', 'Mentor', 'Investors'].map((s, i) => (
              <div className="if-step" key={s}>
                <b>0{i + 1}</b>
                <span>{s}</span>
              </div>
            ))}
            <i className="if-dot" />
          </div>
          <div className="idea-score">
            <span className="mono">Validation score</span>
            <div className="meter2">
              <i />
            </div>
            <b className="count" data-to="82">
              0
            </b>
          </div>
        </article>

        <article className="card b-resume reveal" data-cursor="Build">
          <div className="card-top">
            <span className="tag">Resume</span>
            <span className="mono num">11</span>
          </div>
          <h3>
            Your résumé <em>writes itself.</em>
          </h3>
          <div className="paper">
            <b>Aanya Sharma</b>
            <small>Full-stack · IIT Delhi</small>
            {[90, 70, 82, 55].map((w) => (
              <i key={w} style={{ ['--w' as string]: `${w}%` } as React.CSSProperties} />
            ))}
            <span className="ats">ATS 92</span>
          </div>
        </article>

        <article className="card b-games reveal" data-cursor="Play">
          <div className="card-top">
            <span className="tag">Games</span>
            <span className="mono num">12</span>
          </div>
          <h3>
            Play. Think. <em>Earn credits.</em>
          </h3>
          <div className="flip-grid">
            {GAME_ICONS.map((I, i) => (
              <span key={i}>
                <I size={24} />
              </span>
            ))}
          </div>
        </article>
      </div>
    </section>
  );
}

