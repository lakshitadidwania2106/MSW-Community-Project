/* MSW Community — College / organiser dashboard (IIT Bombay E-Cell) */
(function () {
  const { $, $$, icon, esc, fmt } = Dash;
  const THEMES = { Indigo: ['#1b1464', '#6c5ce7', '#00d2d3'], Sunset: ['#ff7a59', '#ffd166', '#ef476f'], Forest: ['#0f3d2e', '#2f8f7a', '#d4f56b'], Neon: ['#3a0ca3', '#f72585', '#4cc9f0'] };
  const poster = (e) => { const t = THEMES[e.theme] || THEMES.Indigo; return `radial-gradient(circle at 85% 15%,${t[1]},transparent 50%),radial-gradient(circle at 10% 90%,${t[2]},transparent 45%),${t[0]}`; };
  let events = [
    { n: 'E-Summit Hackathon', d: 'Jan 18–19', mode: 'In person', prize: '₹3,00,000', seats: 600, reg: 472, st: 'Live', theme: 'Indigo' },
    { n: 'Design Sprint', d: 'Apr 02', mode: 'In person', prize: '₹1,50,000', seats: 200, reg: 188, st: 'Live', theme: 'Sunset' },
    { n: 'Founders Fireside', d: 'Feb 07', mode: 'Online', prize: '—', seats: 300, reg: 0, st: 'Draft', theme: 'Forest' },
    { n: 'Code Relay ’25', d: 'Oct 12', mode: 'In person', prize: '₹80,000', seats: 250, reg: 250, st: 'Completed', theme: 'Neon' },
  ];
  const evCard = (e, i) => `<div class="d-card rv" style="padding:0;border:0;overflow:hidden;--i:${i}">
    <div style="background:${poster(e)};color:#fff;padding:22px;min-height:170px;display:flex;flex-direction:column;justify-content:flex-end">
      <span class="chip2 dark" style="align-self:flex-start;margin-bottom:auto">${e.st}</span><span class="mono" style="opacity:.75;margin-top:16px">${e.d} · ${e.mode}</span><div class="c-title" style="font-size:36px;color:#fff">${esc(e.n)}</div></div>
    <div style="padding:18px 22px"><div style="display:flex;justify-content:space-between;font-size:13px;margin-bottom:8px"><span class="muted">Registrations</span><b>${fmt(e.reg)} / ${fmt(e.seats)}</b></div><div class="prog"><i style="--w:${(e.reg / e.seats) * 100}%"></i></div>
      <div style="display:flex;justify-content:space-between;align-items:center;margin-top:14px"><span><b>${e.prize}</b> <span class="muted">prize pool</span></span>${e.st === 'Draft' ? `<button class="b sm publish-ev" data-i="${i}">Publish</button>` : `<button class="b sm ghost share-ev">Share link</button>`}</div></div></div>`;

  const teams = [
    ['Byte Me', 'Aanya S., Rohan K., Dev S.', 'IIT Delhi', 'Submitted'], ['Null Pointers', 'Meera J., Kabir N.', 'IIT KGP', 'Checked in'], ['Ctrl Alt Elite', 'Sana K., Arjun R., Rhea P., Ishaan M.', 'Mixed', 'Submitted'],
    ['Git Happens', 'Priya M., Varun T.', 'VJTI', 'Registered'], ['Stack Smashers', 'Neha R., Omkar P., Zoya A.', 'IIT Bombay', 'Checked in'], ['404 Sleep', 'Kunal S., Tara D.', 'SPIT', 'Registered'],
  ];
  const subs = [{ t: 'Byte Me', p: 'Krishi Lite — soil reports over SMS', s: [8, 7, 9] }, { t: 'Ctrl Alt Elite', p: 'Campus Pulse — anonymous mental-health check-ins', s: [9, 8, 8] }, { t: 'Null Pointers', p: 'Queue-less — OPD tokens on WhatsApp', s: [7, 8, 7] }];
  const verify = [['Zoya Ansari', 'B.Tech CSE · 2nd year', 'zoya@iitb.ac.in'], ['Omkar Patil', 'M.Tech EE · 1st year', 'omkar@iitb.ac.in'], ['Neha Rao', 'B.Des · 3rd year', 'neha@iitb.ac.in'], ['Varun Tiwari', 'B.Tech ME · 4th year', 'varun@iitb.ac.in']];

  function hostModal() {
    Dash.modal(`<p class="mono label">Host on MSW</p><h3>Host a <em>hackathon.</em></h3>
      <div class="g g-2" style="margin-top:18px">
        <div>
          <div class="fld"><label>Event name</label><input class="h-n" value="Build for Bharat" /></div>
          <div class="fld-row"><div class="fld"><label>Dates</label><input class="h-d" value="Mar 08–09" /></div><div class="fld"><label>Mode</label><select class="h-m"><option>In person</option><option>Online</option><option>Hybrid</option></select></div></div>
          <div class="fld-row"><div class="fld"><label>Prize pool</label><input class="h-p" value="₹2,00,000" /></div><div class="fld"><label>Seats</label><input class="h-s" type="number" value="400" /></div></div>
          <div class="fld"><label>Poster theme</label><div class="filters2 themes">${Object.keys(THEMES).map((t, i) => `<button type="button" class="${i ? '' : 'on'}" data-t="${t}"><span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:${THEMES[t][1]};margin-right:6px"></span>${t}</button>`).join('')}</div></div>
          <div class="fld"><label>Judging</label><select><option>MSW judges + your faculty</option><option>Your faculty only</option></select></div>
        </div>
        <div><p class="mono label">Poster preview</p><div class="h-prev" style="border-radius:22px;min-height:330px;color:#fff;padding:24px;display:flex;flex-direction:column;justify-content:flex-end;transition:background .6s"></div>
          <p class="muted" style="font-size:12px;margin-top:10px">This poster appears on the website, in the app and is sent to 12,400+ students.</p></div>
      </div>
      <div style="display:flex;gap:10px"><button class="b pub">${icon('upload')}Publish event</button><button class="b ghost draft">Save as draft</button></div>`, {
      wide: true,
      onOpen(m, close) {
        let theme = 'Indigo';
        const upd = () => { const e = { theme }; $('.h-prev', m).style.background = poster(e); $('.h-prev', m).innerHTML = `<span class="chip2 dark" style="align-self:flex-start;margin-bottom:auto">IIT Bombay E-Cell × MSW</span><span class="mono" style="opacity:.8">${esc($('.h-d', m).value)} · ${esc($('.h-m', m).value)}</span><div style="font-family:var(--serif);font-size:48px;line-height:.95;margin:6px 0">${esc($('.h-n', m).value || 'Event name')}</div><div style="display:flex;justify-content:space-between;border-top:1px solid rgba(255,255,255,.25);padding-top:12px;margin-top:8px"><b>${esc($('.h-p', m).value)}</b><span>${esc($('.h-s', m).value)} seats</span></div>`; };
        $$('input,select', m).forEach((x) => x.addEventListener('input', upd));
        $$('.themes button', m).forEach((b) => (b.onclick = () => { theme = b.dataset.t; $$('.themes button', m).forEach((x) => x.classList.toggle('on', x === b)); upd(); }));
        upd();
        const save = (st) => { events.unshift({ n: $('.h-n', m).value || 'New event', d: $('.h-d', m).value, mode: $('.h-m', m).value, prize: $('.h-p', m).value, seats: +$('.h-s', m).value || 100, reg: 0, st, theme }); close(); const g = $('.ev-grid'); if (g) g.innerHTML = events.map(evCard).join(''); Dash.toast(st === 'Live' ? 'Event published — students notified' : 'Saved as draft', st === 'Live' ? '🚀' : '✎'); };
        $('.pub', m).onclick = () => save('Live'); $('.draft', m).onclick = () => save('Draft');
      },
    });
  }

  Dash.init({
    role: 'college', roleName: 'College', color: '#0a66c2',
    user: { name: 'IIT Bombay E-Cell', sub: 'Organiser · Prof. Mehta', initials: 'IB', grad: 'linear-gradient(135deg,#0a66c2,#9fd3ff)' },
    notifications: [{ ic: '🎉', t: 'E-Summit Hackathon hit 472 registrations', s: '1 hour ago' }, { ic: '🎓', t: '4 students waiting for verification', s: 'Today' }, { ic: '✅', t: 'MSW approved your event listing', s: 'Yesterday' }],
    actions: [{ label: 'Host a hackathon or event', ic: 'plus', run: hostModal }, { label: 'Verify students', ic: 'shield', run: () => Dash.go('students') }],
    nav: [
      { id: 'overview', label: 'Overview', icon: 'home', group: 'Campus' },
      { id: 'events', label: 'Hackathons & events', icon: 'trophy', badge: events.length },
      { id: 'teams', label: 'Teams', icon: 'users' },
      { id: 'judging', label: 'Judging', icon: 'star', badge: subs.length },
      { id: 'students', label: 'Student verification', icon: 'shield', badge: verify.length, group: 'Students' },
      { id: 'placements', label: 'Placements', icon: 'briefcase' },
    ],
    views: {
      overview: {
        title: ['Your campus, ', 'on the map.'], crumb: 'Overview',
        render: () => `
          <div class="d-banner rv" style="min-height:190px"><canvas></canvas><div class="grow"><p class="mono" style="color:var(--sky)">IIT BOMBAY E-CELL · VERIFIED ORGANISER</p><h2>Host it. <em>We’ll handle it.</em></h2>
            <div class="bt"><button class="b light host">${icon('plus')}Host a hackathon</button><button class="b ghost go-v">${icon('shield')}Verify students</button></div></div></div>
          <div class="g g-4 mt">
            ${Dash.stat({ label: 'Events hosted', value: 14, delta: '3 this semester', spark: [2, 4, 5, 7, 9, 11, 14], ic: 'trophy' })}
            ${Dash.stat({ label: 'Registrations', value: 3860, delta: '28% vs last sem', spark: [300, 520, 800, 1300, 2100, 2900, 3860], ic: 'users' })}
            ${Dash.stat({ label: 'Verified students', value: 1240, delta: '86 this week', spark: [400, 600, 750, 900, 1050, 1180, 1240], ic: 'shield' })}
            ${Dash.stat({ label: 'Placed via MSW', value: 63, suffix: '%', delta: '9 pts', spark: [32, 38, 44, 49, 55, 58, 63], ic: 'briefcase' })}
          </div>
          <div class="g g-21 mt">
            <div class="d-card rv"><div class="c-head"><span class="c-title">Registrations <em>by week</em></span></div>${Dash.chart([{ name: 'Registrations', color: '#0a66c2', data: [40, 62, 58, 110, 145, 190, 240, 310, 290, 380, 420, 472] }], ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10', 'W11', 'Now'])}</div>
            <div class="d-card rv"><div class="c-head"><span class="c-title">Participants <em>by branch</em></span></div>${Dash.donut([{ label: 'CSE', value: 46, color: '#0a66c2' }, { label: 'EE', value: 18, color: '#2f8f7a' }, { label: 'Design', value: 14, color: '#9b87f5' }, { label: 'Others', value: 22, color: '#d4f56b' }], '472', 'registered')}</div>
          </div>`,
        mount(r) { $('.host', r).onclick = hostModal; $('.go-v', r).onclick = () => Dash.go('students'); },
      },
      events: {
        title: ['Hackathons ', '& events.'], crumb: 'Events',
        render: () => `<div class="rv" style="display:flex;justify-content:flex-end;margin-bottom:16px"><button class="b host">${icon('plus')}Host a hackathon / event</button></div><div class="g g-2 ev-grid">${events.map(evCard).join('')}</div>`,
        mount(r) {
          $('.host', r).onclick = hostModal;
          r.addEventListener('click', (e) => {
            const p = e.target.closest('.publish-ev'); if (p) { events[+p.dataset.i].st = 'Live'; $('.ev-grid', r).innerHTML = events.map(evCard).join(''); Dash.toast('Event is live', '🚀'); }
            if (e.target.closest('.share-ev')) { try { navigator.clipboard.writeText('https://msw.community/e/iitb'); } catch (_) {} Dash.toast('Registration link copied'); }
          });
        },
      },
      teams: {
        title: ['Teams ', '& check-in.'], crumb: 'E-Summit Hackathon',
        render: () => `<div class="d-card rv"><div style="display:flex;gap:12px;flex-wrap:wrap;margin-bottom:14px"><div class="fld" style="margin:0;flex:1;min-width:220px"><input class="q" placeholder="Search teams or members…" /></div><button class="b ghost exp">${icon('upload')}Export CSV</button></div>
          <div class="tbl-wrap"><table class="tbl"><thead><tr><th>Team</th><th>Members</th><th>College</th><th>Status</th><th></th></tr></thead><tbody>${teams.map((t) => `<tr data-s="${esc(t.join(' ').toLowerCase())}"><td><b>${t[0]}</b></td><td>${t[1]}</td><td>${t[2]}</td><td class="st"><span class="chip2 ${t[3] === 'Submitted' ? 'teal' : t[3] === 'Checked in' ? 'sky' : ''}">${t[3]}</span></td><td>${t[3] === 'Registered' ? '<button class="b sm ci">Check in</button>' : ''}</td></tr>`).join('')}</tbody></table></div></div>`,
        mount(r) {
          $('.q', r).addEventListener('input', (e) => $$('tbody tr', r).forEach((tr) => (tr.style.display = tr.dataset.s.includes(e.target.value.toLowerCase()) ? '' : 'none')));
          $('.exp', r).onclick = () => Dash.toast('teams.csv downloaded', '⬇');
          r.addEventListener('click', (e) => { const b = e.target.closest('.ci'); if (!b) return; b.closest('tr').querySelector('.st').innerHTML = '<span class="chip2 sky">Checked in</span>'; b.remove(); Dash.toast('Checked in ✓'); });
        },
      },
      judging: {
        title: ['Judging ', 'panel.'], crumb: 'Score submissions',
        render: () => `<div class="g g-21"><div class="judge-list">${subs.map((s, i) => `<div class="d-card rv jcard" data-i="${i}" style="margin-bottom:14px"><div class="c-head"><span class="c-title">${s.t}</span><span class="r c-title tot" style="color:var(--rc)">${s.s.reduce((a, b) => a + b)}</span></div><p class="muted" style="margin:-6px 0 14px">${s.p}</p>
            ${['Innovation', 'Execution', 'Impact'].map((k, j) => `<div class="fld" style="margin-bottom:8px"><label style="display:flex;justify-content:space-between">${k}<b class="v">${s.s[j]}</b></label><input type="range" min="0" max="10" value="${s.s[j]}" data-j="${j}" /></div>`).join('')}</div>`).join('')}</div>
          <div class="d-card dark rv" style="align-self:start"><div class="c-head"><span class="c-title">Live <em>leaderboard</em></span></div><div class="rows lb"></div><button class="b lime lock" style="margin-top:16px;width:100%">Lock scores & announce</button></div></div>`,
        mount(r) {
          const draw = () => { const ranked = subs.map((s) => ({ t: s.t, v: s.s.reduce((a, b) => a + b) })).sort((a, b) => b.v - a.v); $('.lb', r).innerHTML = ranked.map((x, i) => `<div class="row" style="border-color:rgba(255,255,255,.08)"><span style="font-size:22px">${['🥇', '🥈', '🥉'][i] || i + 1}</span><div class="t"><b>${x.t}</b></div><b>${x.v}</b></div>`).join(''); };
          r.addEventListener('input', (e) => { const inp = e.target.closest('input[type=range]'); if (!inp) return; const c = inp.closest('.jcard'), s = subs[+c.dataset.i]; s.s[+inp.dataset.j] = +inp.value; inp.closest('.fld').querySelector('.v').textContent = inp.value; $('.tot', c).textContent = s.s.reduce((a, b) => a + b); draw(); });
          $('.lock', r).onclick = () => { Dash.toast('Winners announced — certificates issued to all teams', '🏆'); $('.lock', r).textContent = 'Scores locked ✓'; };
          draw();
        },
      },
      students: {
        title: ['Student ', 'verification.'], crumb: 'Verify enrolment',
        render: () => `<div class="g g-21"><div class="d-card rv"><div class="c-head"><span class="c-title">Waiting <em>for you</em></span></div><div class="rows vq">${verify.map((v) => `<div class="row vr"><div class="av sm" style="background:linear-gradient(135deg,#0a66c2,#9fd3ff)">${v[0].split(' ').map((w) => w[0]).join('')}</div><div class="t"><b>${v[0]}</b><small>${v[1]} · ${v[2]}</small></div><button class="b sm ok">${icon('check')}Verify</button><button class="b sm ghost no">Reject</button></div>`).join('')}</div></div>
          <div class="d-card rv" style="display:flex;flex-direction:column;align-items:center;gap:10px;text-align:center"><div class="c-head" style="width:100%"><span class="c-title">Verified</span></div>${Dash.ring(0.82, '1,240', 'students')}<p class="muted" style="font-size:13px">Verified students get the “✓ IIT Bombay” stamp on their MSW ID.</p></div></div>`,
        mount(r) {
          r.addEventListener('click', async (e) => { const ok = e.target.closest('.ok'), no = e.target.closest('.no'); const row = (ok || no)?.closest('.vr'); if (!row) return; const n = $('b', row).textContent; await Dash.flyOut(row, !!no); Dash.toast(ok ? `${n} verified — ID stamped` : `${n} rejected`, ok ? '✓' : '✕'); if (!$$('.vr', r).length) $('.vq', r).innerHTML = '<div class="empty">Everyone is verified ✨</div>'; });
        },
      },
      placements: {
        title: ['Placements ', 'via MSW.'], crumb: 'Outcomes',
        render: () => `<div class="g g-3">${Dash.stat({ label: 'Offers', value: 214, delta: '41 this month', ic: 'briefcase' })}${Dash.stat({ label: 'Internships', value: 386, delta: '22%', ic: 'calendar' })}${Dash.stat({ label: 'Median stipend', value: 38, prefix: '₹', suffix: 'k', delta: '₹6k', ic: 'coin' })}</div>
          <div class="g g-2 mt"><div class="d-card rv"><div class="c-head"><span class="c-title">Top <em>recruiters</em></span></div>${Dash.bars([{ label: 'Lumen Labs', value: 38 }, { label: 'Kite AI', value: 31 }, { label: 'Parallax', value: 24 }, { label: 'Helio', value: 19 }, { label: 'Northwind', value: 12 }])}</div>
          <div class="d-card rv"><div class="c-head"><span class="c-title">Offer <em>types</em></span></div>${Dash.donut([{ label: 'Internship', value: 386, color: '#0a66c2' }, { label: 'Full-time', value: 214, color: '#2f8f7a' }, { label: 'Paid tasks', value: 520, color: '#d4f56b' }], '1,120', 'outcomes')}</div></div>`,
      },
    },
  });
})();
