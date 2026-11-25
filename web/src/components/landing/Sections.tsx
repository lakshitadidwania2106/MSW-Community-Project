'use client';
import Link from 'next/link';
import { ArrowRight, ArrowUp, ArrowUpRight, BadgeCheck, Check, Coins, Smartphone } from 'lucide-react';
import { useEffect, useMemo, useRef, useState } from 'react';
import Split from '@/components/Split';
import { PHOTOS } from '@/lib/photos';

/* ───────── Ecosystem ───────── */
const ECO = [
  { n: '01', a: 'MSW', b: 'Labs', p: 'The 30-day full-stack challenge. Daily lessons, code challenges, certificates.', live: true, href: 'https://intern.mystartupwave.com/', img: 2 },
  { n: '02', a: 'MSW', b: 'Hackathons', p: 'Hackathons we’ve powered, judged and shown up to — and the ones coming next.', live: true, href: '#events', img: 5 },
  { n: '03', a: 'MSW', b: 'Services', p: 'Websites, apps and campus workshops — built by the team behind the community.', live: true, href: '#', img: 8 },
  { n: '04', a: 'MSW', b: 'Careers', p: 'Jobs, internships and paid company tasks for members.', live: false, href: '#features', img: 11 },
  { n: '05', a: 'MSW', b: 'Ventures', p: 'Student ideas, meet investors. Pitch, get backed, build.', live: false, href: '#investors', img: 14 },
];

export function Ecosystem() {
  const prev = useRef<HTMLDivElement>(null);
  const [img, setImg] = useState<number | null>(null);
  useEffect(() => {
    let px = 0, py = 0, tx = 0, ty = 0, raf = 0;
    const move = (e: PointerEvent) => {
      tx = e.clientX + 170;
      ty = e.clientY;
    };
    const loop = () => {
      px += (tx - px) * 0.12;
      py += (ty - py) * 0.12;
      if (prev.current) {
        prev.current.style.left = `${px}px`;
        prev.current.style.top = `${py}px`;
      }
      raf = requestAnimationFrame(loop);
    };
    addEventListener('pointermove', move);
    raf = requestAnimationFrame(loop);
    return () => {
      removeEventListener('pointermove', move);
      cancelAnimationFrame(raf);
    };
  }, []);
  return (
    <section className="ecosystem" id="ecosystem">
      <div className="sec-head">
        <p className="mono label">( The MSW ecosystem )</p>
        <Split parts={['One community.', { em: 'Every door.' }]} />
        <p className="eco-sub reveal-up">MSW Community is the home base. Everything we build plugs into it — learn on MSW Labs, compete at our hackathons, work with our services, get hired, get funded.</p>
      </div>
      <div className="eco-list">
        {ECO.map((e) => (
          <a
            key={e.n}
            className="eco reveal"
            href={e.href}
            target={e.href.startsWith('http') ? '_blank' : undefined}
            rel="noopener noreferrer"
            onPointerEnter={() => setImg(e.img)}
            onPointerLeave={() => setImg(null)}
          >
            <span className="mono e-num">{e.n}</span>
            <h3>
              {e.a} <em>{e.b}</em>
            </h3>
            <p>{e.p}</p>
            <span className={`e-tag${e.live ? ' live' : ''}`}>{e.live ? 'Live' : 'Soon'}</span>
            <span className="e-arrow">
              <ArrowUpRight size={28} strokeWidth={1.5} />
            </span>
          </a>
        ))}
      </div>
      <div className={`eco-preview${img !== null ? ' on' : ''}`} aria-hidden="true" ref={prev}>
        {/* eslint-disable-next-line @next/next/no-img-element */}
        {img !== null && <img alt="" src={PHOTOS[img % PHOTOS.length]} />}
      </div>
    </section>
  );
}

/* ───────── Hackathons (horizontal scroll) ───────── */
const EVENTS = [
  ['ev-1', 'MAR 14–16 · Online', 'HackNova ’26', '48 hours. AI for Bharat.', '₹5,00,000', '1–4 / team', 1052537],
  ['ev-2', 'APR 02 · IIT Bombay', 'Design Sprint', 'UI/UX, 12 hours, one brief.', '₹1,50,000', 'Solo', 2718480],
  ['ev-3', 'APR 20 · Hybrid', 'Climate Code', 'Hack for a greener grid.', '₹3,00,000', '2–5 / team', 4243200],
  ['ev-4', 'MAY 09 · Online', 'CTF Night', 'Capture the flag till sunrise.', '₹75,000', '1–3 / team', 5911937],
  ['ev-5', 'MAY 24 · BITS Pilani', 'FinTech Forge', 'Rebuild money for Gen Z.', '₹2,00,000', '2–4 / team', 7238100],
] as const;

export function Hackathons() {
  const section = useRef<HTMLElement>(null);
  const track = useRef<HTMLDivElement>(null);
  const [cur, setCur] = useState(1);
  const [tick, setTick] = useState(0);
  useEffect(() => {
    const t = setInterval(() => setTick((x) => x + 1), 1000);
    const size = () => {
      if (section.current && track.current) section.current.style.height = `${track.current.scrollWidth - innerWidth + innerHeight}px`;
    };
    size();
    addEventListener('resize', size);
    let raf = 0;
    const loop = () => {
      if (section.current && track.current) {
        const r = section.current.getBoundingClientRect(), max = track.current.scrollWidth - innerWidth;
        const k = Math.min(1, Math.max(0, -r.top / (r.height - innerHeight)));
        track.current.style.transform = `translate3d(${-k * max}px,0,0)`;
        const c = Math.min(6, Math.floor(k * 5.99) + 1);
        setCur((p) => (p === c ? p : c));
      }
      raf = requestAnimationFrame(loop);
    };
    raf = requestAnimationFrame(loop);
    return () => {
      clearInterval(t);
      removeEventListener('resize', size);
      cancelAnimationFrame(raf);
    };
  }, []);
  const cd = (s0: number) => {
    const s = Math.max(0, s0 - tick), p = (n: number) => String(n).padStart(2, '0');
    return `${Math.floor(s / 86400)}d ${p(Math.floor((s % 86400) / 3600))}h ${p(Math.floor((s % 3600) / 60))}m ${p(s % 60)}s`;
  };
  return (
    <section className="hscroll" id="events" ref={section}>
      <div className="hs-sticky">
        <div className="hs-head">
          <p className="mono label">( Hackathons & events )</p>
          <h2>
            Hackathons we power. <em>Build this weekend.</em>
          </h2>
          <div className="hs-count mono">
            <span>{String(cur).padStart(2, '0')}</span> / 06
          </div>
        </div>
        <div className="hs-track" ref={track}>
          {EVENTS.map(([c, d, t, s, prize, team, secs]) => (
            <Link key={t} className={`event ${c}`} href="/get-app" data-cursor="Register">
              <div className="ev-art">
                <i />
                <i />
                <i />
              </div>
              <div className="ev-meta">
                <span className="mono">{d}</span>
                <h4>{t}</h4>
                <p>{s}</p>
                <div className="ev-row">
                  <b>{prize}</b>
                  <span>{team}</span>
                </div>
                <div className="countdown">{cd(secs)}</div>
              </div>
            </Link>
          ))}
          <Link className="event ev-6 ev-more" href="/get-app" data-cursor="Open">
            <div className="ev-meta">
              <span className="mono">For students</span>
              <h4>
                Register in <em>the app.</em>
              </h4>
              <p>Every hackathon, team invite and certificate lives in the MSW Community app.</p>
              <span className="ev-arrow">
                <ArrowRight size={26} />
              </span>
            </div>
          </Link>
        </div>
      </div>
    </section>
  );
}

/* ───────── Digital ID ───────── */
export function IdShowcase() {
  const stage = useRef<HTMLDivElement>(null);
  const [flipped, setFlipped] = useState(false);
  const [tilt, setTilt] = useState({ x: 0, y: 0 });
  const qr = useMemo(() => {
    const N = 21, cells: boolean[] = [];
    let seed = 7;
    const rnd = () => (seed = (seed * 16807) % 2147483647) / 2147483647;
    for (let y = 0; y < N; y++)
      for (let x = 0; x < N; x++) {
        const fz = (x < 8 && y < 8) || (x > N - 9 && y < 8) || (x < 8 && y > N - 9);
        if (fz) {
          const fx = x < 8 ? 0 : N - 7, fy = y < 8 ? 0 : N - 7, dx = x - fx, dy = y - fy;
          cells.push(dx >= 0 && dy >= 0 && dx <= 6 && dy <= 6 && (dx === 0 || dy === 0 || dx === 6 || dy === 6 || (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4)));
        } else cells.push(rnd() > 0.5);
      }
    return cells;
  }, []);
  const tf = `${flipped ? 'rotateY(180deg) ' : ''}rotateY(${tilt.x * 24}deg) rotateX(${-tilt.y * 24}deg)`;
  const holo = { ['--hx' as string]: `${(tilt.x + 0.5) * 100}%`, ['--hy' as string]: `${(tilt.y + 0.5) * 100}%`, ['--ha' as string]: `${tilt.x * 180}deg` } as React.CSSProperties;
  return (
    <section className="idshow" id="id">
      <div className="id-copy">
        <p className="mono label">( Your profile )</p>
        <Split parts={['Not a résumé.', { em: 'A passport.' }]} />
        <p>Every badge, hackathon, task and course you finish is stamped onto a verified digital ID. Recruiters scan it. Investors bookmark it. You just keep building.</p>
        <ul className="id-points">
          <li>
            <b>Verified</b> by your college
          </li>
          <li>
            <b>Live</b> badges & streaks
          </li>
          <li>
            <b>One QR</b> to share it all
          </li>
        </ul>
        <p className="mono hint">Click the card to flip it</p>
      </div>
      <div
        className="id-stage"
        data-cursor="Flip"
        ref={stage}
        onPointerMove={(e) => {
          const r = stage.current!.getBoundingClientRect();
          setTilt({ x: (e.clientX - r.left) / r.width - 0.5, y: (e.clientY - r.top) / r.height - 0.5 });
        }}
        onPointerLeave={() => setTilt({ x: 0, y: 0 })}
        onClick={() => setFlipped((f) => !f)}
      >
        <div className="idcard" style={{ transform: tf }}>
          <div className="id-face id-front">
            <div className="holo" style={holo} />
            <div className="idf-top">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/img/logo_light.png" alt="MSW" className="idf-logo" />
              <span className="mono">
                STUDENT · VERIFIED <BadgeCheck size={12} style={{ display: 'inline', verticalAlign: '-2px' }} />
              </span>
            </div>
            <div className="idf-photo">
              <div className="avatar av-big">AS</div>
              <div className="idf-chip" />
            </div>
            <div className="idf-name">
              <h4>Aanya Sharma</h4>
              <p>B.Tech Computer Science · 3rd year</p>
              <p className="mono">IIT Delhi</p>
            </div>
            <div className="idf-stats">
              {[
                ['14', 'Level'],
                ['9', 'Hackathons'],
                ['23', 'Badges'],
                ['128', 'IQ'],
              ].map(([b, s]) => (
                <div key={s}>
                  <b>{b}</b>
                  <small>{s}</small>
                </div>
              ))}
            </div>
            <div className="idf-bot">
              <span className="mono">MSW-2026-0412</span>
              <div className="barcode" />
            </div>
          </div>
          <div className="id-face id-back">
            <div className="idb-top">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/img/logo_dark.png" alt="MSW" className="idb-logo logo-mark" />
              <span className="mono">SCAN TO VIEW PROFILE</span>
            </div>
            <div className="qr">
              {qr.map((on, i) => (
                <i key={i} className={on ? '' : 'o'} />
              ))}
            </div>
            <div className="skills">
              {['React', 'Python', 'Figma', 'ML', 'Public speaking'].map((s) => (
                <span key={s}>{s}</span>
              ))}
            </div>
            <p className="mono small">Valid while you keep building · msw.community/aanya</p>
          </div>
        </div>
        <div className="id-shadow" />
      </div>
    </section>
  );
}

/* ───────── Portals ───────── */
const DOORS = [
  { n: '01', t: 'Students', h: 'Students', p: 'Learn through reels, join hackathons, post, apply to jobs, take on company tasks and grow your ID — all in the app.', li: ['Feed & posts', '30-day reel courses', 'Jobs, internships, tasks'], cta: 'Get the app', href: '/get-app', art: 'da-1' },
  { n: '02', t: 'Companies', h: 'Companies', p: 'Post jobs and internships, publish paid tasks and discover talent by what they’ve actually built.', li: ['Job & internship posts', 'Paid tasks with GitHub', 'Talent search by ID'], cta: 'Company login', href: '/login?role=company', art: 'da-2' },
  { n: '03', t: 'Investors', h: 'Investors', p: 'Browse student ideas, follow traction and back founders before anyone else knows their name.', li: ['Idea discovery', 'Back for equity', 'Founder watchlist'], cta: 'Investor login', href: '/login?role=investor', art: 'da-3' },
];

export function Portals() {
  const [open, setOpen] = useState(0);
  return (
    <section className="portals" id="portals">
      <div className="sec-head">
        <p className="mono label">( Portals )</p>
        <Split parts={['One platform.', { em: 'Three doors.' }]} />
      </div>
      <div className="doors">
        {DOORS.map((d, i) => (
          <Link
            key={d.n}
            href={d.href}
            className={`door${open === i ? ' is-open' : ''}`}
            data-cursor="Enter"
            onPointerEnter={() => setOpen(i)}
            onClick={(e) => {
              if (open !== i) {
                e.preventDefault();
                setOpen(i);
              }
            }}
          >
            <span className="mono d-num">{d.n}</span>
            <span className="d-vert">{d.t}</span>
            <div className="d-body">
              <h3>{d.h}</h3>
              <p>{d.p}</p>
              <ul>
                {d.li.map((x) => (
                  <li key={x}>{x}</li>
                ))}
              </ul>
              <span className="d-cta">
                {d.cta} <ArrowRight size={16} />
              </span>
            </div>
            <div className={`d-art ${d.art}`} />
          </Link>
        ))}
      </div>
    </section>
  );
}

/* ───────── Investors ───────── */
export function Investors() {
  const ideas = [
    ['AgriTech', 'Seed', 'Krishi — soil health from a ₹200 sensor', 'by Meera J. · IIT Kharagpur', 78, '₹7.8L', '₹10L'],
    ['EdTech', 'Pre-seed', 'Nibble — exam prep in 5-minute bites', 'by Arjun & Sana · DTU', 46, '₹2.3L', '₹5L'],
    ['HealthTech', 'Idea', 'Pulse — AI triage for rural clinics', 'by Kabir N. · AIIMS', 22, '₹1.1L', '₹5L'],
  ] as const;
  return (
    <section className="investors" id="investors">
      <div className="inv-grid">
        <div className="inv-copy">
          <p className="mono label">( For investors )</p>
          <Split parts={['Back the next big idea,', { em: 'before it’s big.' }]} />
          <p>Students pitch. You discover. Every idea comes with the founder’s verified ID, their build history and real traction.</p>
          <div className="inv-stats">
            <div>
              <b>
                ₹<span className="count" data-to="42">0</span>Cr
              </b>
              <small>committed on MSW</small>
            </div>
            <div>
              <b className="count" data-to="1280">
                0
              </b>
              <small>ideas pitched</small>
            </div>
            <div>
              <b className="count" data-to="312">
                0
              </b>
              <small>active investors</small>
            </div>
          </div>
          <Link href="/login?role=investor" className="btn-solid light" data-magnetic>
            <span>Investor login</span>
            <ArrowRight size={18} strokeWidth={1.8} />
          </Link>
        </div>
        <div className="ideas">
          {ideas.map(([sec, st, h, by, w, r, g]) => (
            <div className="idea reveal" key={h}>
              <div className="idea-top">
                <span className="tag dark">{sec}</span>
                <span className="mono">{st}</span>
              </div>
              <h4>{h}</h4>
              <p className="mono">{by}</p>
              <div className="fund">
                <i style={{ ['--w' as string]: `${w}%` } as React.CSSProperties} />
              </div>
              <div className="idea-bot">
                <span>
                  <b>{r}</b> of {g}
                </span>
                <Link href="/login?role=investor" className="idea-btn">
                  View deal
                </Link>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ───────── Blog teaser ───────── */
export function BlogTeaser() {
  const posts = [
    ['cv-1', 'Careers · 6 min', 'The internship cold email that got 9 replies'],
    ['cv-2', 'Hackathons · 8 min', 'What judges actually look for in 48 hours'],
    ['cv-3', 'Founders · 5 min', 'From dorm-room idea to ₹10L pre-seed'],
  ];
  return (
    <section className="blog-teaser">
      <div className="sec-head row">
        <div>
          <p className="mono label">( Journal )</p>
          <Split parts={['Fresh from', { em: 'the blog.' }]} />
        </div>
        <Link href="/blog" className="btn-ghost" data-magnetic>
          <span>
            All stories <ArrowRight size={16} style={{ display: 'inline', verticalAlign: '-3px' }} />
          </span>
        </Link>
      </div>
      <div className="posts">
        {posts.map(([c, m, t]) => (
          <Link href="/blog" className="post reveal" data-cursor="Read" key={t}>
            <div className={`cover ${c}`}>
              <span />
            </div>
            <span className="mono">{m}</span>
            <h4>{t}</h4>
          </Link>
        ))}
      </div>
    </section>
  );
}

/* ───────── Pricing: ₹99 (or credits) vs ₹299 (verified) ───────── */
const SHARED = ['Full MSW Labs Day 1–30 + certificate', 'Unlimited jobs, internships & company tasks', 'All quizzes, IQ & reasoning tests', 'Resume builder & GitHub analyser', 'Pitch ideas to investors'];

export function Pricing() {
  return (
    <section className="pricing" id="pricing">
      <div className="sec-head">
        <p className="mono label">( Pricing )</p>
        <Split parts={['Two plans.', { em: 'One difference.' }]} />
        <p className="eco-sub reveal-up">Both plans unlock everything. Pro can be unlocked for free with credits you earn by posting, watching reels and finishing challenges. Pro Verified adds the verified badge recruiters and investors trust.</p>
      </div>
      <div className="plans two">
        <div className="plan reveal">
          <span className="mono">Pro</span>
          <div className="price">
            ₹99<small>/month</small>
          </div>
          <p>Or unlock it with credits — no payment needed.</p>
          <ul>
            {SHARED.map((s) => (
              <li key={s}>
                <Check size={16} className="li-ic" /> {s}
              </li>
            ))}
            <li className="credits-li">
              <Coins size={16} className="li-ic" /> Earn credits: post, watch reels, finish challenges
            </li>
          </ul>
          <Link href="/get-app" className="b-plan">
            Get Pro in the app
          </Link>
        </div>
        <div className="plan pro reveal">
          <span className="mono">
            Pro Verified <em className="pop">Recommended</em>
          </span>
          <div className="price">
            ₹299<small>/month</small>
          </div>
          <p>Everything in Pro, plus a verified profile.</p>
          <ul>
            {SHARED.map((s) => (
              <li key={s}>
                <Check size={16} className="li-ic" /> {s}
              </li>
            ))}
            <li className="credits-li">
              <BadgeCheck size={16} className="li-ic" /> Verified badge on your ID, posts and applications
            </li>
          </ul>
          <Link href="/get-app" className="b-plan">
            Get verified in the app
          </Link>
        </div>
      </div>
      <p className="plans-note mono">Verification can’t be unlocked with credits · Companies & investors — talk to us</p>
    </section>
  );
}

/* ───────── CTA ───────── */
export function Cta() {
  return (
    <section className="cta">
      <div className="orbits" aria-hidden="true">
        <i />
        <i />
        <i />
        <b />
        <b />
        <b />
      </div>
      <p className="mono label">( Ready? )</p>
      <Split className="cta-title" parts={['Join', { em: 'the community.' }]} />
      <div className="hero-cta center">
        <Link href="/get-app" className="btn-solid" data-magnetic>
          <span>Get the app</span>
          <Smartphone size={18} strokeWidth={1.8} />
        </Link>
        <span className="store mono">iOS & Android</span>
      </div>
    </section>
  );
}

/* ───────── Social & media ───────── */
const SOCIAL: [string, string, string, string, React.ReactNode][] = [
  ['ic-x', 'X', 'Where to catch MSW updates first, before anywhere else.', 'Follow', <path key="x" fill="#fff" d="M17.8 3h3.1l-6.8 7.7L22 21h-6.2l-4.9-6.3L5.3 21H2.2l7.2-8.3L2 3h6.4l4.4 5.8L17.8 3zm-1.1 16.2h1.7L7.4 4.7H5.6l11.1 14.5z" />],
  ['ic-ig', 'Instagram', 'Reels, recaps & behind-the-scenes from every hackathon we power.', 'Follow', <g key="ig" fill="none" stroke="#fff" strokeWidth="2"><rect x="3.5" y="3.5" width="17" height="17" rx="5" /><circle cx="12" cy="12" r="4" /><circle cx="17.3" cy="6.7" r="1" fill="#fff" stroke="none" /></g>],
  ['ic-li', 'LinkedIn', 'Partnership news, hiring calls & professional updates from MSW.', 'Follow', <path key="li" fill="#fff" d="M5 9h3v10H5zM6.5 4.2a1.8 1.8 0 1 1 0 3.6 1.8 1.8 0 0 1 0-3.6zM10 9h2.9v1.4h.1c.4-.8 1.4-1.6 2.9-1.6 3.1 0 3.6 2 3.6 4.6V19h-3v-4.9c0-1.2 0-2.6-1.6-2.6s-1.9 1.2-1.9 2.5v5H10z" />],
  ['ic-yt', 'YouTube', 'Watch mentor sessions & hackathon highlights, anytime, for free.', 'Watch', <g key="yt" fill="none" stroke="#fff" strokeWidth="2"><rect x="3" y="6" width="18" height="12" rx="3.5" /><path d="M10.5 9.5v5l4-2.5z" fill="#fff" stroke="none" /></g>],
  ['ic-wa', 'WhatsApp', 'Join the community group — don’t miss event drops & opportunities.', 'Join', <path key="wa" fill="none" stroke="#fff" strokeWidth="2" d="M4 20l1.3-3.9A8 8 0 1 1 8 19z" />],
  ['ic-luma', 'Luma', 'Upcoming hackathons, workshops & meetups — RSVP on the MSW events calendar.', 'RSVP', <path key="lu" fill="#121212" d="M12 2c.9 6.2 3.3 8.9 10 10-6.7 1.1-9.1 3.8-10 10-.9-6.2-3.3-8.9-10-10 6.7-1.1 9.1-3.8 10-10z" />],
];

export function Social() {
  const rows = [0, 1, 2].map((r) => Array.from({ length: 6 }, (_, i) => PHOTOS[(r * 6 + i) % PHOTOS.length]));
  const ars = [1.5, 1.1, 1.8, 0.8, 1.3, 1.6];
  return (
    <section className="social" id="social">
      <div className="mosaic" aria-hidden="true">
        {rows.map((set, r) => (
          <div className="m-row" key={r}>
            <div className="m-track">
              {[...set, ...set].map((src, i) => (
                // eslint-disable-next-line @next/next/no-img-element
                <img key={i} src={src} alt="" loading="lazy" style={{ ['--ar' as string]: ars[(i + r * 2) % ars.length] } as React.CSSProperties} />
              ))}
            </div>
          </div>
        ))}
      </div>
      <div className="social-inner">
        <div className="social-head">
          <p className="mono label">( Stay connected )</p>
          <Split parts={['Social', { em: '&' }, 'Media']} />
          <p className="reveal-up">Follow now, join the builder community.</p>
        </div>
        <div className="soc-grid">
          {SOCIAL.map(([ic, name, p, cur, svg]) => (
            <a className="soc reveal" href="#" key={name} data-cursor={cur}>
              <span className={`soc-ic ${ic}`}>
                <svg viewBox="0 0 24 24">{svg}</svg>
              </span>
              <span className="mono">{name}</span>
              <p>{p}</p>
            </a>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ───────── Footer ───────── */
export function Footer() {
  const [ok, setOk] = useState(false);
  return (
    <footer className="footer">
      <div className="f-cols">
        <div>
          <p className="mono label">Platform</p>
          <a href="/#features">Feed</a>
          <a href="/#features">Reels</a>
          <a href="/#events">Hackathons</a>
          <a href="/#pricing">Pricing</a>
        </div>
        <div>
          <p className="mono label">Portals</p>
          <Link href="/get-app">Students</Link>
          <Link href="/login?role=company">Companies</Link>
          <Link href="/login?role=investor">Investors</Link>
        </div>
        <div>
          <p className="mono label">Ecosystem</p>
          <a href="https://intern.mystartupwave.com/" target="_blank" rel="noopener noreferrer">
            MSW Labs
          </a>
          <a href="/#events">Hackathons</a>
          <a href="#">Services</a>
          <Link href="/blog">Blog</Link>
        </div>
        <div className="f-news">
          <p className="mono label">Newsletter</p>
          <form
            className={ok ? 'ok' : ''}
            onSubmit={(e) => {
              e.preventDefault();
              setOk(true);
            }}
          >
            <input type="email" placeholder="you@company.com" required />
            <button aria-label="Subscribe">
              <ArrowRight size={22} />
            </button>
            <span className="ok-msg">You’re in</span>
          </form>
        </div>
      </div>
      <div className="f-word" aria-hidden="true">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src="/img/logo_light.png" alt="" />
      </div>
      <div className="f-bot mono">
        <span>© 2026 MSW Community</span>
        <span>Made for students, by students</span>
        <a href="#" onClick={(e) => (e.preventDefault(), window.scrollTo({ top: 0, behavior: 'smooth' }))} className="to-top">
          Back to top <ArrowUp size={12} style={{ display: 'inline' }} />
        </a>
      </div>
    </footer>
  );
}
