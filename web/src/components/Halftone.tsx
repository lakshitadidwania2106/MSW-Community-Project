'use client';
import { useEffect, useRef } from 'react';
import { startHalftone, type HalftoneOptions } from '@/lib/halftone';

/** Animated halftone dot field that fills its parent. */
export default function Halftone({ className, ...opts }: HalftoneOptions & { className?: string }) {
  const ref = useRef<HTMLCanvasElement>(null);
  const key = JSON.stringify(opts);
  useEffect(() => {
    if (!ref.current) return;
    return startHalftone(ref.current, JSON.parse(key));
  }, [key]);
  return <canvas ref={ref} className={className} aria-hidden="true" />;
}
