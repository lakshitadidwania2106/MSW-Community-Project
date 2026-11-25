'use client';
import Lenis from 'lenis';
import { useEffect } from 'react';

/** Lenis smooth scrolling for the landing page; anchor links scroll smoothly too. */
export default function SmoothScroll() {
  useEffect(() => {
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    const lenis = new Lenis({ lerp: 0.1, smoothWheel: true });
    let raf = 0;
    const loop = (t: number) => {
      lenis.raf(t);
      raf = requestAnimationFrame(loop);
    };
    raf = requestAnimationFrame(loop);
    const onClick = (e: MouseEvent) => {
      const a = (e.target as HTMLElement).closest('a[href*="#"]') as HTMLAnchorElement | null;
      if (!a) return;
      const url = new URL(a.href);
      if (url.pathname !== location.pathname || !url.hash || url.hash === '#') return;
      const el = document.querySelector(url.hash);
      if (!el) return;
      e.preventDefault();
      lenis.scrollTo(el as HTMLElement, { offset: -20 });
    };
    document.addEventListener('click', onClick);
    return () => {
      cancelAnimationFrame(raf);
      document.removeEventListener('click', onClick);
      lenis.destroy();
    };
  }, []);
  return null;
}
