'use client';
import { useMemo } from 'react';

/** Decorative QR-style grid (finder squares + seeded modules). */
export default function Qr({ seed = 7, className = 'qr-grid' }: { seed?: number; className?: string }) {
  const cells = useMemo(() => {
    const N = 21, out: boolean[] = [];
    let s = seed;
    const rnd = () => (s = (s * 16807) % 2147483647) / 2147483647;
    for (let y = 0; y < N; y++)
      for (let x = 0; x < N; x++) {
        const fz = (x < 8 && y < 8) || (x > N - 9 && y < 8) || (x < 8 && y > N - 9);
        if (fz) {
          const fx = x < 8 ? 0 : N - 7, fy = y < 8 ? 0 : N - 7, dx = x - fx, dy = y - fy;
          out.push(dx >= 0 && dy >= 0 && dx <= 6 && dy <= 6 && (dx === 0 || dy === 0 || dx === 6 || dy === 6 || (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4)));
        } else out.push(rnd() > 0.5);
      }
    return out;
  }, [seed]);
  return (
    <div className={className} aria-label="QR code">
      {cells.map((on, i) => (
        <i key={i} className={on ? '' : 'o'} />
      ))}
    </div>
  );
}
