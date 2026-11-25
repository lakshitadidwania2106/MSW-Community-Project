'use client';
import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import Logo from '@/components/Logo';
import ThemeToggle from '@/components/ThemeToggle';

const LINKS = [
  ['#ecosystem', 'Ecosystem'],
  ['#features', 'Platform'],
  ['#events', 'Hackathons'],
  ['#investors', 'Investors'],
  ['#pricing', 'Pricing'],
] as const;

/** Top navigation: hides on scroll down, frosts when scrolled, inverts over dark sections. */
export default function Nav({ landing = true }: { landing?: boolean }) {
  const ref = useRef<HTMLElement>(null);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    let lastY = 0, raf = 0;
    const loop = () => {
      const nav = ref.current;
      if (nav) {
        const y = scrollY;
        nav.classList.toggle('scrolled', y > 40);
        if (y > lastY + 2 && y > 300 && !document.body.classList.contains('menu-open')) nav.classList.add('hidden');
        if (y < lastY - 2) nav.classList.remove('hidden');
        lastY = y;
        const dark = Array.from(document.querySelectorAll('.touch, .investors, .social, .footer')).some((s) => {
          const r = s.getBoundingClientRect();
          return r.top <= 40 && r.bottom >= 40;
        });
        nav.classList.toggle('dark', dark && !document.body.classList.contains('menu-open'));
      }
      raf = requestAnimationFrame(loop);
    };
    raf = requestAnimationFrame(loop);
    return () => cancelAnimationFrame(raf);
  }, []);

  useEffect(() => {
    document.body.classList.toggle('menu-open', open);
  }, [open]);

  const href = (h: string) => (landing ? h : `/${h}`);
  return (
    <>
      <header className="nav" ref={ref}>
        <Logo />
        <nav className="nav-links">
          {LINKS.map(([h, l]) => (
            <a key={h} href={href(h)}>
              {l}
            </a>
          ))}
          <Link href="/blog">Blog</Link>
          <Link href="/login">Log in</Link>
        </nav>
        <ThemeToggle />
        <Link href="/get-app" className="btn-outline" data-magnetic>
          <span>Get the app</span>
        </Link>
        <button className="burger" aria-label="Menu" onClick={() => setOpen((o) => !o)}>
          <i />
          <i />
        </button>
      </header>
      <div className="mobile-menu" onClick={() => setOpen(false)}>
        {LINKS.map(([h, l]) => (
          <a key={h} href={href(h)}>
            {l}
          </a>
        ))}
        <Link href="/blog">Blog</Link>
        <Link href="/login">Log in</Link>
        <Link href="/get-app">
          Get the app <ArrowUpRight size={36} strokeWidth={1.4} style={{ display: 'inline' }} />
        </Link>
      </div>
    </>
  );
}
