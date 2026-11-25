import { notFound } from 'next/navigation';
import PageTop from '@/components/PageTop';
import { ARTICLES } from '@/lib/blog';

export function generateStaticParams() {
  return ARTICLES.map((a) => ({ slug: a.slug }));
}

export default async function ArticlePage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const a = ARTICLES.find((x) => x.slug === slug);
  if (!a) notFound();
  return (
    <div className="page">
      <PageTop back="/blog" backLabel="All stories" />
      <article className="article">
        <span className="mono">
          {a.cat} · {a.mins} min read
        </span>
        <h1>{a.title}</h1>
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img className="hero-img" src={a.img} alt="" />
        <p style={{ fontSize: 21, color: 'var(--ink)' }}>{a.dek}</p>
        {a.body.map((p, i) => (
          <p key={i}>{p}</p>
        ))}
      </article>
    </div>
  );
}
