import type { Metadata, Viewport } from 'next';
import { Instrument_Serif, Inter, JetBrains_Mono } from 'next/font/google';
import Cursor from '@/components/Cursor';
import { ToastProvider } from '@/components/Toast';
import './landing.css';
import './portal.css';
import './extras.css';

const serif = Instrument_Serif({ subsets: ['latin'], weight: '400', style: ['normal', 'italic'], variable: '--font-serif', display: 'swap' });
const sans = Inter({ subsets: ['latin'], variable: '--font-sans', display: 'swap' });
const mono = JetBrains_Mono({ subsets: ['latin'], weight: ['400', '500'], variable: '--font-mono', display: 'swap' });

export const metadata: Metadata = {
  title: 'MSW Community — where students, companies & investors meet',
  description: 'Hackathons, reels-based courses, jobs, internships, company tasks, a digital student ID and investors — one community.',
  icons: { icon: '/img/icon.png' },
};

export const viewport: Viewport = { width: 'device-width', initialScale: 1 };

/** Sets the theme before first paint so there is never a flash of the wrong theme. */
const themeScript = `(function(){try{var t=localStorage.getItem('msw-theme');if(!t){t=matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light'}document.documentElement.setAttribute('data-theme',t)}catch(e){document.documentElement.setAttribute('data-theme','light')}})();`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning className={`${serif.variable} ${sans.variable} ${mono.variable}`}>
      <head>
        <script dangerouslySetInnerHTML={{ __html: themeScript }} />
      </head>
      <body>
        <ToastProvider>
          {children}
          <Cursor />
        </ToastProvider>
      </body>
    </html>
  );
}
