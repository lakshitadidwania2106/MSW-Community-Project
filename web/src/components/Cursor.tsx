'use client';
import { useEffect, useRef, useState } from 'react';

/** Custom cursor: a dot plus a trailing ring that grows and shows a label over [data-cursor] elements. */
export default function Cursor() {
  const root = useRef<HTMLDivElement>(null);
  const dot = useRef<HTMLDivElement>(null);
  const ring = useRef<HTMLDivElement>(null);
  const [label, setLabel] = useState('');
  const [enabled, setEnabled] = useState(false);

  useEffect(() => {
    if (!matchMedia('(hover: hover) and (pointer: fine)').matches) return;
    setEnabled(true);
    let mx = -100, my = -100, rx = -100, ry = -100, raf = 0;
    const move = (e: PointerEvent) => {
      mx = e.clientX;
      my = e.clientY;
    };
    const over = (e: PointerEvent) => {
      const t = e.target as HTMLElement;
      const lab = t.closest<HTMLElement>('[data-cursor]');
      const link = t.closest('a, button, input, select, textarea, label, [role="button"]');
      root.current?.classList.toggle('is-hover', !!lab);
      root.current?.classList.toggle('is-link', !!link && !lab);
      if (lab) setLabel(lab.dataset.cursor ?? '');
    };
    const loop = () => {
      rx += (mx - rx) * 0.16;
      ry += (my - ry) * 0.16;
      if (dot.current) dot.current.style.transform = `translate(${mx}px,${my}px)`;
      if (ring.current) ring.current.style.transform = `translate(${rx}px,${ry}px)`;
      raf = requestAnimationFrame(loop);
    };
    addEventListener('pointermove', move);
    document.addEventListener('pointerover', over);
    raf = requestAnimationFrame(loop);
    return () => {
      removeEventListener('pointermove', move);
      document.removeEventListener('pointerover', over);
      cancelAnimationFrame(raf);
    };
  }, []);

  if (!enabled) return null;
  return (
    <div className="cursor" aria-hidden="true" ref={root}>
      <div className="c-dot" ref={dot} />
      <div className="c-ring" ref={ring}>
        <span className="c-label">{label}</span>
      </div>
    </div>
  );
}
