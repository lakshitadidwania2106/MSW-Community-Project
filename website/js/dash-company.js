/* MSW Community — Company dashboard (Lumen Labs) */
(function () {
  const { $, $$, icon, esc, fmt } = Dash;
  const G = ['linear-gradient(135deg,#ff9a76,#c86dd7)', 'linear-gradient(135deg,#2f8f7a,#9fd3ff)', 'linear-gradient(135deg,#6c5ce7,#00d2d3)', 'linear-gradient(135deg,#ffb38a,#ef476f)', 'linear-gradient(135deg,#d4f56b,#2f8f7a)', 'linear-gradient(135deg,#9fd3ff,#6c5ce7)'];
  const people = [
    { n: 'Aanya Sharma', c: 'IIT Delhi · CSE ’27', iq: 128, gh: 87, lv: 14, sk: ['React', 'Python', 'Figma'], st: 'interview' },
    { n: 'Rohan Kapoor', c: 'NIT Trichy · ECE ’27', iq: 121, gh: 79, lv: 11, sk: ['Flutter', 'Firebase'], st: 'short' },
    { n: 'Meera Joshi', c: 'IIT KGP · AgE ’26', iq: 133, gh: 91, lv: 17, sk: ['IoT', 'Python', 'ML'], st: 'applied' },
    { n: 'Arjun Rao', c: 'DTU · IT ’27', iq: 118, gh: 84, lv: 12, sk: ['Next.js', 'Node'], st: 'applied' },
    { n: 'Sana Khan', c: 'BITS Pilani · CS ’26', iq: 125, gh: 89, lv: 15, sk: ['TypeScript', 'GraphQL'], st: 'short' },
    { n: 'Dev Shah', c: 'VIT · CSE ’28', iq: 112, gh: 66, lv: 8, sk: ['HTML', 'CSS', 'JS'], st: 'applied' },
    { n: 'Rhea Pillai', c: 'IIIT Hyd · CSE ’26', iq: 130, gh: 93, lv: 18, sk: ['Rust', 'Go'], st: 'hired' },
  ];
  const ini = (n) => n.split(' ').map((w) => w[0]).join('');
  const kbCard = (p, i) => `<div class="kb-card" draggable="true" data-p="${people.indexOf(p)}">
      <div class="top"><div class="av sm" style="background:${G[i % G.length]}">${ini(p.n)}</div><div><b>${p.n}</b><small class="muted" style="font-size:11px">${p.c}</small></div></div>
      <div class="filters2">${p.sk.map((s) => `<span class="chip2" style="font-size:11px;padding:3px 8px">${s}</span>`).join('')}</div>
      <div class="meta"><span>IQ ${p.iq} · GH ${p.gh}</span><span class="chip2 teal" style="font-size:11px;padding:3px 8px">Lvl ${p.lv}</span></div></div>`;

  let postings = [
    { r: 'Frontend Intern', t: 'Internship', loc: 'Remote', pay: '₹40k/mo', a: 128, v: 2140, on: true },
    { r: 'Backend Intern', t: 'Internship', loc: 'Bengaluru', pay: '₹45k/mo', a: 86, v: 1620, on: true },
    { r: 'Product Designer', t: 'Full-time', loc: 'Hybrid', pay: '₹12 LPA', a: 42, v: 980, on: true },
    { r: 'DevRel Intern', t: 'Internship', loc: 'Remote', pay: '₹30k/mo', a: 17, v: 410, on: false },
  ];
  const postRow = (p, i) => `<tr data-i="${i}"><td><div class="who"><div class="sq" style="background:#ff7a59;width:36px;height:36px">L</div><div><b>${esc(p.r)}</b><small>${p.t} · ${esc(p.loc)} · ${esc(p.pay)}</small></div></div></td>
    <td><b>${p.a}</b></td><td>${fmt(p.v)}</td><td><span class="meter"><i style="--w:${Math.min(100, (p.a / p.v) * 1000)}%"></i></span></td>
    <td><button class="tg ${p.on ? 'on' : ''}" aria-label="Toggle"></button></td><td><span class="chip2 ${p.on ? 'teal' : ''}">${p.on ? 'Live' : 'Paused'}</span></td></tr>`;

  const tasks = [
    { t: 'Fix checkout bug on mobile web', r: 3000, sub: 4, who: 'Aanya Sharma', st: 'In progress' },
    { t: 'Write onboarding email sequence', r: 1800, sub: 2, who: '—', st: 'Open' },
    { t: 'Accessibility audit of dashboard', r: 4500, sub: 1, who: 'Rhea Pillai', st: 'Submitted' },
  ];
  const subs = [
    { n: 'Rhea Pillai', t: 'Accessibility audit of dashboard', l: 'figma.com/file/a11y-audit', r: 4500 },
    { n: 'Arjun Rao', t: 'Fix checkout bug on mobile web', l: 'github.com/arjun/checkout-fix', r: 3000 },
    { n: 'Sana Khan', t: 'Landing hero animation', l: 'codepen.io/sana/hero', r: 2000 },
  ];

  function profileDrawer(p, i) {
    Dash.drawer(`<p class="mono label">Candidate</p>
      <div style="display:flex;gap:14px;align-items:center;margin:6px 0 18px"><div class="av lg" style="background:${G[i % G.length]}">${ini(p.n)}</div><div><h3 style="font-size:36px">${p.n}</h3><p class="muted">${p.c}</p></div></div>
      <div class="g g-3" style="margin-bottom:16px">${[['IQ', p.iq], ['GitHub', p.gh], ['Level', p.lv]].map((x) => `<div class="d-card" style="padding:14px"><span class="mono" style="font-size:10px;color:var(--muted)">${x[0]}</span><div class="c-title" style="font-size:34px"><span class="count" data-to="${x[1]}">0</span></div></div>`).join('')}</div>
      <p class="mono label">Verified on MSW ID</p>
      <div class="rows" style="margin-bottom:18px"><div class="row"><span>🏆</span><div class="t"><b>2× hackathon finalist</b><small>HackNova ’25 · Climate Code</small></div></div><div class="row"><span>📚</span><div class="t"><b>MSW Labs Day 24 / 30</b><small>Full-Stack Challenge</small></div></div><div class="row"><span>⚡</span><div class="t"><b>6 company tasks shipped</b><small>4.9★ average review</small></div></div></div>
      <div class="filters2" style="margin-bottom:22px">${p.sk.map((s) => `<span class="chip2">${s}</span>`).join('')}</div>
      <div style="display:flex;gap:10px;flex-wrap:wrap"><button class="b adv">Move to interview</button><button class="b ghost msg">${icon('msg')}Message</button><button class="b ghost rej" style="color:#c43c3c">Reject</button></div>`, (dr, close) => {
      $('.adv', dr).onclick = () => { close(); Dash.toast(`${p.n} moved to Interview — invite sent`); };
      $('.msg', dr).onclick = () => Dash.toast('Chat opened (coming soon)', '💬');
      $('.rej', dr).onclick = () => { close(); Dash.toast(`${p.n} was notified kindly`, '✉️'); };
    });
  }

  function postJobModal() {
    Dash.modal(`<p class="mono label">New posting</p><h3>Post a <em>role.</em></h3>
      <div class="g g-2" style="margin-top:18px">
        <div>
          <div class="fld"><label>Role title</label><input class="j-r" value="Mobile Developer Intern" /></div>
          <div class="fld-row"><div class="fld"><label>Type</label><select class="j-t"><option>Internship</option><option>Full-time</option><option>Part-time</option></select></div><div class="fld"><label>Location</label><input class="j-l" value="Remote" /></div></div>
          <div class="fld"><label>Pay</label><input class="j-p" value="₹35k/mo" /></div>
          <div class="fld"><label>Skills (comma separated)</label><input class="j-s" value="Flutter, Dart, Firebase" /></div>
          <div class="fld"><label>Minimum MSW level</label><input type="range" min="1" max="20" value="8" class="j-lv" /></div>
        </div>
        <div><p class="mono label">Live preview</p>
          <div class="d-card" style="background:var(--card)"><div class="row" style="border:0;padding:0 0 12px"><div class="sq" style="background:#ff7a59">L</div><div class="t"><b class="p-r">Mobile Developer Intern</b><small class="p-m">Lumen Labs · Remote · ₹35k/mo</small></div></div>
            <div class="filters2 p-s"></div><div style="display:flex;justify-content:space-between;align-items:center;margin-top:14px"><span class="chip2 p-t">Internship</span><span class="mono p-lv">LVL 8+</span></div>
            <button class="b" style="width:100%;margin-top:14px">One-tap apply</button></div>
          <p class="muted" style="font-size:12px;margin-top:10px">Students see exactly this card in the app and on the website.</p></div>
      </div>
      <button class="b publish" style="margin-top:8px">${icon('upload')}Publish to MSW Careers</button>`, {
      wide: true,
      onOpen(m, close) {
        const upd = () => {
          $('.p-r', m).textContent = $('.j-r', m).value || 'Role title';
          $('.p-m', m).textContent = `Lumen Labs · ${$('.j-l', m).value} · ${$('.j-p', m).value}`;
          $('.p-t', m).textContent = $('.j-t', m).value;
          $('.p-lv', m).textContent = `LVL ${$('.j-lv', m).value}+`;
          $('.p-s', m).innerHTML = $('.j-s', m).value.split(',').filter((s) => s.trim()).map((s) => `<span class="chip2">${esc(s.trim())}</span>`).join('');
        };
        $$('input,select', m).forEach((x) => x.addEventListener('input', upd)); upd();
        $('.publish', m).onclick = () => {
          postings.unshift({ r: $('.j-r', m).value, t: $('.j-t', m).value, loc: $('.j-l', m).value, pay: $('.j-p', m).value, a: 0, v: 0, on: true });
          close();
          const tb = $('.post-tbody'); if (tb) tb.innerHTML = postings.map(postRow).join('');
          Dash.toast('Role published — 1,240 matching students notified', '🚀');
        };
      },
    });
  }

  function taskModal() {
    Dash.modal(`<p class="mono label">Allocate a task</p><h3>Get it <em>done.</em></h3>
      <div class="fld"><label>Task</label><input class="t-t" placeholder="e.g. Build a pricing page in Next.js" /></div>
      <div class="fld"><label>Brief</label><textarea placeholder="What does done look like?"></textarea></div>
      <div class="fld-row"><div class="fld"><label>Reward (₹)</label><input class="t-r" type="number" value="2500" /></div><div class="fld"><label>Deadline</label><input type="date" /></div></div>
      <div class="fld"><label>Assign to</label><select class="t-w"><option value="">Open to all students</option>${people.map((p) => `<option>${p.n}</option>`).join('')}</select></div>
      <button class="b go">${icon('task')}Allocate task</button>`, {
      onOpen(m, close) {
        $('.go', m).onclick = () => {
          const t = $('.t-t', m).value || 'New task'; const w = $('.t-w', m).value;
          tasks.unshift({ t, r: +$('.t-r', m).value || 0, sub: 0, who: w || '—', st: w ? 'Assigned' : 'Open' });
          close(); const tb = $('.task-tbody'); if (tb) tb.innerHTML = tasks.map(taskRow).join('');
          Dash.toast(w ? `Assigned to ${w}` : 'Task is live for all students', '⚡');
        };
      },
    });
  }
  const taskRow = (t) => `<tr><td><b>${esc(t.t)}</b></td><td>₹${fmt(t.r)}</td><td>${t.sub}</td><td>${esc(t.who)}</td><td><span class="chip2 ${t.st === 'Open' ? 'sky' : t.st === 'Submitted' ? 'peach' : 'teal'}">${t.st}</span></td></tr>`;

  Dash.init({
    role: 'company', roleName: 'Company', color: '#e8613f',
    user: { name: 'Lumen Labs', sub: 'Hiring team · Priya M.', initials: 'L', grad: 'linear-gradient(135deg,#ff7a59,#ffb38a)' },
    notifications: [
      { ic: '👋', t: '23 new applicants for Frontend Intern', s: '10 min ago' },
      { ic: '📦', t: 'Rhea Pillai submitted the accessibility audit', s: '1 hour ago' },
      { ic: '⭐', t: 'Your posting is trending at IIT Delhi', s: 'Today' },
    ],
    actions: [{ label: 'Post a job or internship', ic: 'plus', run: postJobModal }, { label: 'Allocate a task', ic: 'task', run: taskModal }],
    nav: [
      { id: 'overview', label: 'Overview', icon: 'home', group: 'Hiring' },
      { id: 'jobs', label: 'Job postings', icon: 'briefcase', badge: postings.length },
      { id: 'applicants', label: 'Applicants', icon: 'users', badge: 273 },
      { id: 'tasks', label: 'Tasks', icon: 'task', group: 'Work' },
      { id: 'talent', label: 'Talent search', icon: 'search' },
    ],
    views: {
      overview: {
        title: ['Hiring, ', 'at a glance.'], crumb: 'Overview',
        render: () => `
          <div class="d-banner rv" style="min-height:190px"><canvas></canvas><div class="grow"><p class="mono" style="color:var(--peach)">LUMEN LABS · VERIFIED COMPANY</p><h2>Hire by what <em>they’ve built.</em></h2>
            <div class="bt"><button class="b light new-job">${icon('plus')}Post a role</button><button class="b ghost new-task">${icon('task')}Allocate a task</button></div></div></div>
          <div class="g g-4 mt">
            ${Dash.stat({ label: 'Open roles', value: 3, delta: '1 new', spark: [1, 1, 2, 2, 2, 3, 3, 3], ic: 'briefcase' })}
            ${Dash.stat({ label: 'Applicants', value: 273, delta: '41% this week', spark: [20, 34, 30, 55, 61, 80, 120, 140, 190, 273], ic: 'users' })}
            ${Dash.stat({ label: 'Tasks live', value: 6, delta: '₹18,300 committed', spark: [2, 3, 3, 4, 4, 5, 6], ic: 'task' })}
            ${Dash.stat({ label: 'Days to hire', value: 9, suffix: 'd', delta: '3d faster', spark: [21, 18, 17, 15, 14, 12, 11, 9], ic: 'calendar' })}
          </div>
          <div class="g g-21 mt">
            <div class="d-card rv"><div class="c-head"><span class="c-title">Applicants <em>over time</em></span><div class="r legend"><span><i style="background:#e8613f"></i>Applied</span><span><i style="background:#2f8f7a"></i>Shortlisted</span></div></div>
              ${Dash.chart([{ name: 'Applied', color: '#e8613f', data: [8, 14, 12, 22, 19, 31, 28, 36, 42, 39, 51, 47, 58, 63] }, { name: 'Shortlisted', color: '#2f8f7a', data: [2, 3, 3, 6, 5, 8, 7, 10, 12, 11, 14, 13, 17, 19] }], ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10', 'W11', 'W12', 'W13', 'Now'])}</div>
            <div class="d-card rv"><div class="c-head"><span class="c-title">Funnel</span></div>${Dash.bars([{ label: 'Viewed', value: 5150 }, { label: 'Applied', value: 273 }, { label: 'Shortlisted', value: 64 }, { label: 'Interview', value: 18 }, { label: 'Hired', value: 4 }])}</div>
          </div>
          <div class="g g-2 mt">
            <div class="d-card rv"><div class="c-head"><span class="c-title">Top <em>candidates</em></span><span class="r"><button class="b sm ghost go-app">Pipeline</button></span></div>
              <div class="rows">${people.slice(0, 4).map((p, i) => `<div class="row cand" data-i="${i}" style="cursor:pointer"><div class="av sm" style="background:${G[i]}">${ini(p.n)}</div><div class="t"><b>${p.n}</b><small>${p.c}</small></div><span class="chip2 teal">GH ${p.gh}</span><span class="chip2 lilac">IQ ${p.iq}</span></div>`).join('')}</div></div>
            <div class="d-card rv"><div class="c-head"><span class="c-title">Where they <em>come from</em></span></div>${Dash.donut([{ label: 'IITs', value: 38, color: '#e8613f' }, { label: 'NITs', value: 24, color: '#2f8f7a' }, { label: 'BITS / IIITs', value: 18, color: '#9b87f5' }, { label: 'Other colleges', value: 20, color: '#d4f56b' }], '120+', 'colleges')}</div>
          </div>`,
        mount(r) {
          $('.new-job', r).onclick = postJobModal; $('.new-task', r).onclick = taskModal; $('.go-app', r).onclick = () => Dash.go('applicants');
          $$('.cand', r).forEach((c) => (c.onclick = () => profileDrawer(people[+c.dataset.i], +c.dataset.i)));
        },
      },
      jobs: {
        title: ['Job ', 'postings.'], crumb: 'Careers',
        render: () => `<div class="d-card rv"><div class="c-head"><span class="c-title">All <em>roles</em></span><span class="r"><button class="b new-job">${icon('plus')}Post a role</button></span></div>
          <div class="tbl-wrap"><table class="tbl"><thead><tr><th>Role</th><th>Applicants</th><th>Views</th><th>Conversion</th><th>Live</th><th>Status</th></tr></thead><tbody class="post-tbody">${postings.map(postRow).join('')}</tbody></table></div></div>`,
        mount(r) {
          $('.new-job', r).onclick = postJobModal;
          r.addEventListener('click', (e) => {
            const tg = e.target.closest('.tg'); if (!tg) return;
            const i = +tg.closest('tr').dataset.i; postings[i].on = !postings[i].on;
            tg.classList.toggle('on', postings[i].on);
            const chip = tg.closest('tr').querySelector('td:last-child .chip2'); chip.className = `chip2 ${postings[i].on ? 'teal' : ''}`; chip.textContent = postings[i].on ? 'Live' : 'Paused';
            Dash.toast(`${postings[i].r} ${postings[i].on ? 'is live again' : 'paused'}`, postings[i].on ? '▶' : '❚❚');
          });
        },
      },
      applicants: {
        title: ['Applicant ', 'pipeline.'], crumb: 'Frontend Intern · drag cards between stages',
        render: () => `<div class="filters2 rv" style="margin-bottom:14px">${postings.filter((p) => p.on).map((p, i) => `<button class="${i ? '' : 'on'}">${esc(p.r)}</button>`).join('')}</div>
          <div class="rv">${Dash.kanban([
            { id: 'applied', title: 'Applied', cards: people.filter((p) => p.st === 'applied').map(kbCard) },
            { id: 'short', title: 'Shortlisted', cards: people.filter((p) => p.st === 'short').map(kbCard) },
            { id: 'interview', title: 'Interview', cards: people.filter((p) => p.st === 'interview').map(kbCard) },
            { id: 'hired', title: 'Hired 🎉', cards: people.filter((p) => p.st === 'hired').map(kbCard) },
          ])}</div>`,
        mount(r) {
          Dash.dnd(r, (card, to) => { const p = people[+card.dataset.p]; Dash.toast(`${p.n} → ${{ applied: 'Applied', short: 'Shortlisted', interview: 'Interview', hired: 'Hired 🎉' }[to]}`, to === 'hired' ? '🎉' : '→'); });
          r.addEventListener('click', (e) => { const c = e.target.closest('.kb-card'); if (c) profileDrawer(people[+c.dataset.p], +c.dataset.p); });
          $$('.filters2 button', r).forEach((b) => (b.onclick = () => $$('.filters2 button', r).forEach((x) => x.classList.toggle('on', x === b))));
        },
      },
      tasks: {
        title: ['Tasks ', '& submissions.'], crumb: 'Work',
        render: () => `<div class="g g-21">
          <div class="d-card rv"><div class="c-head"><span class="c-title">Allocated <em>tasks</em></span><span class="r"><button class="b new-task">${icon('plus')}Allocate task</button></span></div>
            <div class="tbl-wrap"><table class="tbl"><thead><tr><th>Task</th><th>Reward</th><th>Submissions</th><th>Assignee</th><th>Status</th></tr></thead><tbody class="task-tbody">${tasks.map(taskRow).join('')}</tbody></table></div></div>
          <div class="d-card dark rv"><div class="c-head"><span class="c-title">To <em>review</em></span><span class="r chip2 dark sub-n">${subs.length}</span></div>
            <div class="sub-list">${subs.map((s) => `<div class="sub" style="padding:14px 0;border-bottom:1px solid rgba(255,255,255,.08)"><b style="display:block">${s.t}</b><small class="muted">${s.n} · ${s.l}</small>
              <div style="display:flex;gap:8px;margin-top:10px"><button class="b sm lime ok" data-r="${s.r}" data-n="${s.n}">Approve & pay ₹${fmt(s.r)}</button><button class="b sm ghost no">Request changes</button></div></div>`).join('')}</div></div></div>`,
        mount(r) {
          $('.new-task', r).onclick = taskModal;
          r.addEventListener('click', async (e) => {
            const ok = e.target.closest('.ok'), no = e.target.closest('.no'); const s = (ok || no)?.closest('.sub'); if (!s) return;
            await Dash.flyOut(s, !!no);
            Dash.toast(ok ? `₹${fmt(+ok.dataset.r)} paid to ${ok.dataset.n}` : 'Feedback sent to the student', ok ? '💸' : '✎');
            const n = $$('.sub', r).length; $('.sub-n', r).textContent = n; if (!n) $('.sub-list', r).innerHTML = '<div class="empty">All caught up ✨</div>';
          });
        },
      },
      talent: {
        title: ['Talent ', 'search.'], crumb: 'Discover students',
        render: () => `<div class="d-card rv" style="margin-bottom:16px"><div class="fld" style="margin:0"><input class="q" placeholder="Search by name, skill or college — try “Python” or “IIT”" /></div>
          <div class="filters2" style="margin-top:12px">${['All', 'IQ 125+', 'GitHub 85+', 'Level 12+'].map((f, i) => `<button class="${i ? '' : 'on'}" data-f="${f}">${f}</button>`).join('')}</div></div>
          <div class="g g-3 talent">${people.map((p, i) => `<div class="d-card rv tal" data-i="${i}" data-s="${esc((p.n + ' ' + p.c + ' ' + p.sk.join(' ')).toLowerCase())}">
            <div class="row" style="border:0;padding:0 0 12px"><div class="av" style="background:${G[i % G.length]}">${ini(p.n)}</div><div class="t"><b>${p.n}</b><small>${p.c}</small></div></div>
            <div class="filters2" style="margin-bottom:12px">${p.sk.map((s) => `<span class="chip2">${s}</span>`).join('')}</div>
            <div class="g g-3" style="gap:8px;margin-bottom:14px">${[['IQ', p.iq], ['GH', p.gh], ['LVL', p.lv]].map((x) => `<div style="background:var(--bg);border-radius:12px;padding:8px 10px"><span class="mono" style="font-size:9px;color:var(--muted)">${x[0]}</span><div class="c-title">${x[1]}</div></div>`).join('')}</div>
            <div style="display:flex;gap:8px"><button class="b sm invite">Invite to apply</button><button class="b sm ghost view">View ID</button></div></div>`).join('')}</div>`,
        mount(r) {
          let f = 'All';
          const apply = () => {
            const q = $('.q', r).value.toLowerCase();
            $$('.tal', r).forEach((c) => { const p = people[+c.dataset.i]; const okF = f === 'All' || (f === 'IQ 125+' && p.iq >= 125) || (f === 'GitHub 85+' && p.gh >= 85) || (f === 'Level 12+' && p.lv >= 12); c.style.display = okF && c.dataset.s.includes(q) ? '' : 'none'; });
          };
          $('.q', r).addEventListener('input', apply);
          $$('.filters2 button', r).forEach((b) => (b.onclick = () => { f = b.dataset.f; $$('.filters2 button', r).forEach((x) => x.classList.toggle('on', x === b)); apply(); }));
          r.addEventListener('click', (e) => {
            const inv = e.target.closest('.invite'); if (inv && !inv.classList.contains('done')) { inv.classList.add('done'); inv.textContent = 'Invited ✓'; Dash.toast('Invite sent to their MSW inbox', '✉️'); }
            const v = e.target.closest('.view'); if (v) { const i = +v.closest('.tal').dataset.i; profileDrawer(people[i], i); }
          });
        },
      },
    },
  });
})();
