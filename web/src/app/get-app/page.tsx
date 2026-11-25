import { BadgeCheck, Check } from 'lucide-react';
import PageTop from '@/components/PageTop';
import Qr from '@/components/Qr';

export const metadata = { title: 'Get the app — MSW Community' };

const Apple = () => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
    <path d="M16.4 12.6c0-2.6 2.1-3.8 2.2-3.9-1.2-1.8-3.1-2-3.7-2-1.6-.2-3.1.9-3.9.9-.8 0-2-.9-3.4-.9-1.7 0-3.3 1-4.2 2.6-1.8 3.1-.5 7.7 1.3 10.2.9 1.2 1.9 2.6 3.2 2.6 1.3-.1 1.8-.8 3.3-.8 1.6 0 2 .8 3.4.8 1.4 0 2.3-1.3 3.1-2.5 1-1.4 1.4-2.8 1.4-2.9 0 0-2.7-1-2.7-4.1zM13.9 5c.7-.8 1.2-2 1-3.1-1 0-2.2.7-2.9 1.5-.6.7-1.2 1.9-1 3 1.1.1 2.2-.6 2.9-1.4z" />
  </svg>
);
const Play = () => (
  <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
    <path d="M4 2.8v18.4c0 .5.5.8 1 .6l10.6-9.2L5 2.2c-.5-.2-1 .1-1 .6zm12.8 8.1 2.9-1.7c.9.5.9 1.8 0 2.4l-2.9 1.7-2.4-2.1 2.4-.3zM6.5 1.7l9.4 8.1-2.3 2-9.3-9.5c.6-.6 1.4-.8 2.2-.6zm7.1 10.6 2.3 2-9.4 8.1c-.8.2-1.6 0-2.2-.6l9.3-9.5z" />
  </svg>
);

export default function GetApp() {
  return (
    <div className="page">
      <PageTop />
      <section className="getapp">
        <div>
          <p className="mono label">( For students )</p>
          <h1>
            Your community lives <em>in the app.</em>
          </h1>
          <p className="lead">Feed, reels courses, hackathons, jobs, internships, paid tasks and your verified digital ID. Students use MSW Community on their phone.</p>
          <div className="stores">
            <a className="store-btn" href="#" aria-label="Download on the App Store">
              <Apple />
              <span>
                <small>Download on the</small>
                <b>App Store</b>
              </span>
            </a>
            <a className="store-btn" href="#" aria-label="Get it on Google Play">
              <Play />
              <span>
                <small>Get it on</small>
                <b>Google Play</b>
              </span>
            </a>
          </div>
          <ul className="ga-list">
            {['Learn in 30-day reel courses with MSW Labs', 'Register for hackathons and events', 'Apply to jobs, internships and paid company tasks', 'Pro for ₹99 a month, or unlock it free with credits'].map((x) => (
              <li key={x}>
                <Check size={18} /> {x}
              </li>
            ))}
            <li>
              <BadgeCheck size={18} /> Pro Verified for ₹299 a month adds the verified badge
            </li>
          </ul>
        </div>
        <div className="ga-side">
          <div className="ga-qr">
            <Qr seed={11} />
            <p className="mono">Scan to download</p>
          </div>
          <p className="ga-note">Company, investor or admin? Use the website: <a href="/login" style={{ textDecoration: 'underline' }}>log in here</a>.</p>
        </div>
      </section>
    </div>
  );
}
