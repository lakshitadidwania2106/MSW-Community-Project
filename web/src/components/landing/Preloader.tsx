'use client';
import { useEffect, useRef, useState } from 'react';
import { PHOTOS } from '@/lib/photos';

const clamp = (v: number, a = 0, b = 1) => Math.min(b, Math.max(a, v));

/** Opening sequence: community photos pop into a collage, a counter runs, the last photo fills the screen. */
export default function Preloader() {
  const [count, setCount] = useState(0);
  const [shown, setShown] = useState(0);
  const [phase, setPhase] = useState<'run' | 'zoom' | 'done' | 'gone'>('run');
  const spots = useRef(
    PHOTOS.slice(0, 12).map((src, i, arr) => {
      const ang = i * 2.4, rad = 0.35 + (i % 3) * 0.22, last = i === arr.length - 1;
      return { src, dx: last ? 0 : Math.cos(ang) * rad, dy: last ? 0 : Math.sin(ang) * rad, r: (((i * 37) % 17) - 8) * 1 };
    }),
  );

  useEffect(() => {
    document.body.classList.add('is-loading');
    const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
    const start = performance.now(), dur = reduce ? 200 : 2600;
    let raf = 0;
    const tick = (now: number) => {
      const k = clamp((now - start) / dur), e = 1 - Math.pow(1 - k, 3);
      setCount(Math.round(e * 100));
      setShown(Math.floor(k * 1.08 * spots.current.length));
      if (k < 1) {
        raf = requestAnimationFrame(tick);
        return;
      }
      setPhase('zoom');
      setTimeout(() => {
        setPhase('done');
        setTimeout(() => {
          document.body.classList.remove('is-loading');
          document.body.classList.add('loaded');
          document.dispatchEvent(new Event('msw:loaded'));
        }, 350);
        setTimeout(() => setPhase('gone'), 1300);
      }, reduce ? 0 : 900);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, []);

  if (phase === 'gone') return null;
  return (
    <div className={`preloader${phase === 'done' ? ' done' : ''}`} aria-hidden="true" style={{ ['--pl' as string]: count / 100 } as React.CSSProperties}>
      <div className={`pl-photos${phase !== 'run' ? ' zoom' : ''}`}>
        {spots.current.map((s, i) => (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            key={s.src}
            src={s.src}
            alt=""
            className={i < shown ? 'show' : ''}
            style={{ ['--dx' as string]: `${s.dx * 34}vw`, ['--dy' as string]: `${s.dy * 30}vh`, ['--r' as string]: `${s.r}deg` } as React.CSSProperties}
          />
        ))}
      </div>
      <div className="pl-inner">
        <div className="pl-word">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img className="pl-logo" src="/img/logo_light.png" alt="MSW" />
        </div>
        <div className="pl-bar">
          <i />
        </div>
        <div className="pl-meta">
          <span>Loading the community</span>
          <span>{String(count).padStart(3, '0')}</span>
        </div>
      </div>
    </div>
  );
}
