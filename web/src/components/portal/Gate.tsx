'use client';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import type { Role } from '@/lib/api';

/** Shown while the session loads; sends signed-out visitors to the login page. */
export default function Gate({ role, ready, loading }: { role: Role; ready: boolean; loading?: boolean }) {
  const router = useRouter();
  useEffect(() => {
    if (ready && !loading) router.replace(`/login?role=${role}`);
  }, [ready, loading, role, router]);
  return (
    <div className="page" style={{ display: 'grid', placeItems: 'center' }}>
      <p className="mono" style={{ color: 'var(--muted)' }}>
        {loading ? 'Loading your workspace…' : <Link href={`/login?role=${role}`}>Redirecting to login…</Link>}
      </p>
    </div>
  );
}
