'use client';
import { useEffect, useState } from 'react';

export type Theme = 'light' | 'dark';

export function getTheme(): Theme {
  if (typeof document === 'undefined') return 'light';
  return document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
}

export function setTheme(t: Theme) {
  document.documentElement.setAttribute('data-theme', t);
  try {
    localStorage.setItem('msw-theme', t);
  } catch {}
  document.dispatchEvent(new CustomEvent('themechange', { detail: t }));
}

/** Current theme, kept in sync across components. */
export function useTheme(): [Theme, () => void] {
  const [theme, set] = useState<Theme>('light');
  useEffect(() => {
    set(getTheme());
    const on = () => set(getTheme());
    document.addEventListener('themechange', on);
    return () => document.removeEventListener('themechange', on);
  }, []);
  return [theme, () => setTheme(getTheme() === 'dark' ? 'light' : 'dark')];
}
