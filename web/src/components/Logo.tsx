import Link from 'next/link';

/** MSW logo mark followed by the word "community". */
export default function Logo({ href = '/', className = 'logo', onDark = false }: { href?: string; className?: string; onDark?: boolean }) {
  return (
    <Link href={href} className={`${className}${onDark ? ' on-dark' : ''}`} aria-label="MSW Community home">
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img className="logo-mark" src="/img/logo_dark.png" alt="MSW" />
      <span className="logo-word">community</span>
    </Link>
  );
}
