'use client';
import Link from 'next/link';
import { ArrowRight } from 'lucide-react';
import { useEffect, useRef } from 'react';
import Halftone from '@/components/Halftone';
import Split from '@/components/Split';

export default function Hero() {
  const ref = useRef<HTMLElement>(null);
  useEffect(() => {
    const show = () => ref.current?.querySelectorAll('.split, .reveal-up').forEach((el) => el.classList.add('in'));
    if (document.body.classList.contains('loaded')) show();
    document.addEventListener('msw:loaded', show);
    return () => document.removeEventListener('msw:loaded', show);
  }, []);
  return (
    <section className="hero" data-cursor="Move" ref={ref}>
      <Halftone className="hero-dots" />
      <div className="hero-inner">
        <p className="eyebrow reveal-up">
          <span className="pulse" /> The student operating system
        </p>
        <Split as="h1" className="hero-title" parts={['Where', { mark: 'You' }, { em: 'build,' }, 'learn', 'br', '& get', { em: 'discovered.' }]} />
        <p className="hero-sub reveal-up">Hackathons, 30-day reel courses, jobs, internships, real company tasks and a digital ID that travels with you — all inside one community.</p>
        <div className="hero-cta reveal-up">
          <Link href="/get-app" className="btn-solid" data-magnetic>
            <span>Get the app</span>
            <ArrowRight size={18} strokeWidth={1.8} />
          </Link>
          <a href="#touch" className="btn-ghost" data-magnetic>
            <span>See how it works</span>
          </a>
        </div>
      </div>
      <div className="hero-foot">
        <span className="mono">( Scroll )</span>
        <div className="scroll-line">
          <i />
        </div>
        <span className="mono">12,400+ students already in the community</span>
      </div>
    </section>
  );
}

export function Marquee() {
  const words: [string, boolean][] = [
    ['Hackathons', false],
    ['Reels', true],
    ['Internships', false],
    ['Tasks', true],
    ['Badges', false],
    ['IQ tests', true],
    ['Investors', false],
    ['Blogs', true],
  ];
  const row = (k: string) =>
    words.map(([w, it]) => (
      <span key={k + w} className="mq-item">
        <span>{it ? <em>{w}</em> : w}</span>
        <i className="mq-dot" />
      </span>
    ));
  return (
    <div className="marquee" aria-hidden="true">
      <div className="marquee-track">
        {row('a')}
        {row('b')}
      </div>
    </div>
  );
}
