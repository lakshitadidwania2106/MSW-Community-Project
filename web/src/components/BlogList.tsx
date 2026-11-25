'use client';
import Link from 'next/link';
import { useState } from 'react';
import { ARTICLES } from '@/lib/blog';

export default function BlogList() {
  const cats = ['All', ...Array.from(new Set(ARTICLES.map((a) => a.cat)))];
  const [f, setF] = useState('All');
  return (
    <>
      <div className="blog-filters">
        {cats.map((c) => (
          <button key={c} className={f === c ? 'on' : ''} onClick={() => setF(c)}>
            {c}
          </button>
        ))}
      </div>
      <div className="blog-grid">
        {ARTICLES.filter((a) => f === 'All' || a.cat === f).map((a) => (
          <Link key={a.slug} href={`/blog/${a.slug}`} className="blog-card" data-cursor="Read">
            <div className="cover">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={a.img} alt="" loading="lazy" />
            </div>
            <span className="mono">
              {a.cat} · {a.mins} min
            </span>
            <h3>{a.title}</h3>
            <p>{a.dek}</p>
          </Link>
        ))}
      </div>
    </>
  );
}
