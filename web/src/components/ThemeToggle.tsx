'use client';
import { Moon, Sun } from 'lucide-react';
import { useTheme } from '@/lib/theme';

export default function ThemeToggle({ className = 'theme-btn' }: { className?: string }) {
  const [theme, toggle] = useTheme();
  return (
    <button className={className} onClick={toggle} aria-label={theme === 'dark' ? 'Switch to light theme' : 'Switch to dark theme'} type="button">
      {theme === 'dark' ? <Moon size={18} strokeWidth={1.8} /> : <Sun size={18} strokeWidth={1.8} />}
    </button>
  );
}
