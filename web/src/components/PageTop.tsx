import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import Logo from '@/components/Logo';
import ThemeToggle from '@/components/ThemeToggle';

export default function PageTop({ back = '/', backLabel = 'Back to site' }: { back?: string; backLabel?: string }) {
  return (
    <header className="page-top">
      <Logo />
      <div className="right">
        <Link href={back} className="back">
          <ArrowLeft size={16} /> {backLabel}
        </Link>
        <ThemeToggle />
      </div>
    </header>
  );
}
