'use client';
import { useEffect, useRef, useState } from 'react';
import { startHands } from '@/lib/hands';

/** Scroll-driven scene: two dotted hands reach for each other and touch. */
export default function Touch() {
  const section = useRef<HTMLElement>(null);
  const canvas = useRef<HTMLCanvasElement>(null);
  const [step, setStep] = useState(-1);
  useEffect(() => {
    if (!section.current || !canvas.current) return;
    return startHands(section.current, canvas.current, (p) => {
      const s = p > 0.8 ? 2 : p > 0.36 && p < 0.72 ? 1 : p > 0.02 && p < 0.3 ? 0 : -1;
      setStep((prev) => (prev === s ? prev : s));
    });
  }, []);
  const lines: [string, string, string][] = [
    ['01 — The idea', 'Every great career starts with ', 'one connection.'],
    ['02 — The people', 'Students. Companies. Colleges. ', 'Investors.'],
    ['03 — The community', 'One touch. ', 'Infinite opportunities.'],
  ];
  return (
    <section className="touch" id="touch" ref={section}>
      <div className="touch-sticky">
        <canvas ref={canvas} className="hands-canvas" />
        <div className="touch-copy">
          {lines.map(([k, a, b], i) => (
            <p key={k} className={`tc${step === i ? ' on' : ''}`}>
              <span className="mono">{k}</span>
              {a}
              <em>{b}</em>
            </p>
          ))}
        </div>
        <div className="touch-hint mono">Keep scrolling — bring them together</div>
        <div className="touch-progress">
          <i />
        </div>
      </div>
    </section>
  );
}

const MANIFESTO =
  'Students lose hours scrolling Instagram, chase jobs that never reply and sit on ideas nobody validates. MSW turns that screen time into something real. Learn in 60-second reels, build at hackathons, ship tasks for companies, get mentored, pitch to investors — and let your work speak louder than any résumé.';
const ACCENT = new Set(['Instagram,', 'validates.', 'real.', 'reels,', 'mentored,', 'investors', 'résumé.']);

/** Paragraph whose words light up as you scroll past it. */
export function Manifesto() {
  const ref = useRef<HTMLParagraphElement>(null);
  const words = MANIFESTO.split(/\s+/);
  const [lit, setLit] = useState(0);
  useEffect(() => {
    let raf = 0;
    const loop = () => {
      const el = ref.current;
      if (el) {
        const r = el.getBoundingClientRect(), vh = innerHeight;
        const k = Math.min(1, Math.max(0, (vh * 0.85 - r.top) / (r.height + vh * 0.25)));
        const n = Math.floor(k * words.length * 1.05);
        setLit((p) => (p === n ? p : n));
      }
      raf = requestAnimationFrame(loop);
    };
    raf = requestAnimationFrame(loop);
    return () => cancelAnimationFrame(raf);
  }, [words.length]);
  return (
    <section className="manifesto">
      <p className="mono label">( Why MSW )</p>
      <p className="manifesto-text" ref={ref}>
        {words.map((w, i) => (
          <span key={i}>
            <span className={`mw${ACCENT.has(w) ? ' accent' : ''}${i < lit ? ' lit' : ''}`}>{w}</span>{' '}
          </span>
        ))}
      </p>
    </section>
  );
}
