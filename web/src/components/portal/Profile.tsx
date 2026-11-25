'use client';
import { BadgeCheck, Pencil } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useToast } from '@/components/Toast';
import { initials, type Role, type Session } from '@/lib/api';

const DEFAULTS: Record<Role, Record<string, string>> = {
  company: { tagline: 'Design-to-code platform for product teams', website: 'lumenlabs.io', location: 'Bengaluru, India', size: '51–200 people', industry: 'Developer tools', email: 'hiring@lumenlabs.io', about: 'We build the tools 40,000 designers use to ship production-ready UI. We hire students who ship.' },
  investor: { tagline: 'Angel investor · Pre-seed & seed', website: 'nikhilvarma.vc', location: 'Mumbai, India', size: '₹5L – ₹25L cheques', industry: 'AgriTech, HealthTech, EdTech', email: 'deals@nikhilvarma.vc', about: 'Backing student founders building for Bharat. Former operator, two exits.' },
  admin: { tagline: 'MSW Community administrator', website: 'mystartupwave.com', location: 'India', size: 'Core team', industry: 'Community', email: 'admin@mystartupwave.com', about: 'Keeps the community safe, verified and running.' },
};
const LABELS: Record<Role, Record<string, string>> = {
  company: { tagline: 'Tagline', website: 'Website', location: 'Headquarters', size: 'Team size', industry: 'Industry', email: 'Hiring email', about: 'About' },
  investor: { tagline: 'Tagline', website: 'Website', location: 'Based in', size: 'Cheque size', industry: 'Focus sectors', email: 'Deal email', about: 'About' },
  admin: { tagline: 'Title', website: 'Website', location: 'Location', size: 'Team', industry: 'Area', email: 'Email', about: 'About' },
};

/** Profile page reached from the avatar in the top-right corner. Edits are saved in this browser. */
export default function Profile({ session, role, stats }: { session: Session; role: Role; stats: [string, number | string][] }) {
  const toast = useToast();
  const key = `msw-profile-${session.id}`;
  const [info, setInfo] = useState(DEFAULTS[role]);
  const [edit, setEdit] = useState(false);
  useEffect(() => {
    try {
      const s = localStorage.getItem(key);
      if (s) setInfo({ ...DEFAULTS[role], ...JSON.parse(s) });
    } catch {}
  }, [key, role]);
  const save = () => {
    try {
      localStorage.setItem(key, JSON.stringify(info));
    } catch {}
    setEdit(false);
    toast('Profile saved');
  };
  const L = LABELS[role];
  return (
    <>
      <div className="d-card rv">
        <div className="prof-head">
          <span className="d-avatar big">{initials(session.name)}</span>
          <div style={{ flex: 1, minWidth: 220 }}>
            <h2 style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              {session.name} <BadgeCheck size={26} style={{ color: 'var(--teal-d)' }} aria-label="Verified" />
            </h2>
            <p>{info.tagline}</p>
          </div>
          <button className={edit ? 'b' : 'b ghost'} onClick={() => (edit ? save() : setEdit(true))}>
            {edit ? 'Save changes' : (<><Pencil size={14} /> Edit profile</>)}
          </button>
        </div>
      </div>
      <div className="g g-3 mt">
        {stats.map(([l, v]) => (
          <div className="d-card stat rv" key={l}>
            <span className="lbl">{l}</span>
            <span className="val">{v}</span>
          </div>
        ))}
      </div>
      <div className="d-card rv mt">
        <div className="c-head">
          <span className="c-title">Details</span>
        </div>
        {edit ? (
          <>
            {Object.keys(L).map((k) => (
              <div className="fld" key={k}>
                <label>{L[k]}</label>
                {k === 'about' ? (
                  <textarea value={info[k]} onChange={(e) => setInfo({ ...info, [k]: e.target.value })} />
                ) : (
                  <input value={info[k]} onChange={(e) => setInfo({ ...info, [k]: e.target.value })} />
                )}
              </div>
            ))}
            <div className="row-acts">
              <button className="b" onClick={save}>Save changes</button>
              <button className="b ghost" onClick={() => setEdit(false)}>Cancel</button>
            </div>
          </>
        ) : (
          <dl className="kv">
            {Object.keys(L).map((k) => (
              <div key={k} style={{ display: 'contents' }}>
                <dt>{L[k]}</dt>
                <dd>{info[k]}</dd>
              </div>
            ))}
            <dt>Account ID</dt>
            <dd className="mono" style={{ textTransform: 'none' }}>{session.id}</dd>
          </dl>
        )}
      </div>
    </>
  );
}
