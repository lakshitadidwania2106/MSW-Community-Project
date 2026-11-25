'use client';
import { useEffect } from 'react';

const clamp = (v: number, a = 0, b = 1) => Math.min(b, Math.max(a, v));

function countUp(el: HTMLElement) {
  if (el.dataset.done) return;
  el.dataset.done = '1';
  const to = Number(el.dataset.to ?? 0), dec = Number(el.dataset.dec ?? 0), start = performance.now(), dur = 1700;
  const f = (now: number) => {
    const k = clamp((now - start) / dur), e = 1 - Math.pow(1 - k, 4);
    el.textContent = (to * e).toLocaleString('en-IN', { minimumFractionDigits: dec, maximumFractionDigits: dec });
    if (k < 1) requestAnimationFrame(f);
  };
  requestAnimationFrame(f);
}

/**
 * Page-wide motion: reveal-on-scroll (.reveal, .reveal-up, .split, .count),
 * magnetic buttons ([data-magnetic]) and the spotlight on cards (.card, .d-card).
 * Re-scans the DOM when content changes so dashboards get it too.
 */
export default function Effects() {
  useEffect(() => {
    const fine = matchMedia('(hover: hover) and (pointer: fine)').matches;
    const io = new IntersectionObserver(
      (entries) =>
        entries.forEach((e) => {
          if (!e.isIntersecting) return;
          const t = e.target as HTMLElement;
          t.classList.add('in');
          if (t.matches('.count')) countUp(t);
          t.querySelectorAll<HTMLElement>('.count').forEach(countUp);
          io.unobserve(t);
        }),
      { threshold: 0.15, rootMargin: '0px 0px -5% 0px' },
    );
    const seen = new WeakSet<Element>();
    const scan = () => {
      document.querySelectorAll('.split, .reveal, .reveal-up, .count, .idea, .b-iq, .b-git, .b-idea, .b-resume, .plan').forEach((el) => {
        if (seen.has(el) || el.closest('.hero')) return;
        seen.add(el);
        io.observe(el);
      });
      if (fine)
        document.querySelectorAll<HTMLElement>('[data-magnetic]').forEach((el) => {
          if (seen.has(el)) return;
          seen.add(el);
          const inner = el.firstElementChild as HTMLElement | null;
          el.addEventListener('pointermove', (e) => {
            const r = el.getBoundingClientRect(), x = e.clientX - r.left - r.width / 2, y = e.clientY - r.top - r.height / 2;
            el.style.transition = 'transform .2s';
            el.style.transform = `translate(${x * 0.28}px,${y * 0.4}px)`;
            if (inner) inner.style.transform = `translate(${x * 0.12}px,${y * 0.16}px)`;
          });
          el.addEventListener('pointerleave', () => {
            el.style.transition = 'transform .8s cubic-bezier(.22,1,.36,1)';
            el.style.transform = '';
            if (inner) {
              inner.style.transition = 'transform .8s cubic-bezier(.22,1,.36,1)';
              inner.style.transform = '';
            }
          });
        });
    };
    scan();
    const mo = new MutationObserver(() => scan());
    mo.observe(document.body, { childList: true, subtree: true });
    const spot = (e: PointerEvent) => {
      const c = (e.target as HTMLElement).closest?.('.card, .d-card') as HTMLElement | null;
      if (!c) return;
      const r = c.getBoundingClientRect();
      c.style.setProperty('--mx', `${e.clientX - r.left}px`);
      c.style.setProperty('--my', `${e.clientY - r.top}px`);
    };
    document.addEventListener('pointermove', spot);
    return () => {
      io.disconnect();
      mo.disconnect();
      document.removeEventListener('pointermove', spot);
    };
  }, []);
  return null;
}
