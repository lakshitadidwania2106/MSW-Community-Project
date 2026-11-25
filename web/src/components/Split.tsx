import { Fragment, type ReactNode } from 'react';

type Part = string | { em: string } | { mark: string } | 'br';

/**
 * Headline whose words slide up when it scrolls into view.
 * Pass parts: plain strings, { em } for italic serif, { mark } for the highlight, 'br' for a line break.
 */
export default function Split({ as: Tag = 'h2', parts, className = '' }: { as?: 'h1' | 'h2' | 'h3'; parts: Part[]; className?: string }) {
  let i = 0;
  const word = (w: string, wrap?: 'em' | 'mark') => {
    const n = i++;
    const inner = wrap === 'em' ? <em>{w}</em> : wrap === 'mark' ? <mark>{w}</mark> : w;
    return (
      <span className="w" key={n}>
        <span className="wi" style={{ ['--i' as string]: n } as React.CSSProperties}>
          {inner}
        </span>
      </span>
    );
  };
  const out: ReactNode[] = [];
  parts.forEach((p, pi) => {
    if (p === 'br') {
      out.push(<br key={`br${pi}`} className="br-d" />);
      return;
    }
    const text = typeof p === 'string' ? p : 'em' in p ? p.em : p.mark;
    const wrap = typeof p === 'string' ? undefined : 'em' in p ? 'em' : 'mark';
    text
      .split(/\s+/)
      .filter(Boolean)
      .forEach((w, wi, arr) => {
        out.push(<Fragment key={`${pi}-${wi}`}>{word(w, wrap)}{wi < arr.length - 1 || pi < parts.length - 1 ? ' ' : ''}</Fragment>);
      });
  });
  return <Tag className={`split ${className}`}>{out}</Tag>;
}
