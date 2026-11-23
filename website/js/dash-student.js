/* MSW Community — Student dashboard */
(function () {
  const { $, $$, icon, esc, fmt } = Dash;
  const hour = new Date().getHours();
  const greet = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

  const TOPICS = ['Hello, Web', 'HTML in 60s', 'CSS that doesn’t fight you', 'Flexbox & Grid', 'JavaScript essentials', 'The DOM', 'APIs explained with pizza', 'Git & GitHub', 'React: why components?', 'Props vs state', 'Hooks', 'Routing in Next.js', 'Tailwind speed-run', 'Mini project: portfolio', 'Node & Express', 'REST API design', 'SQL you’ll use', 'Auth & JWT', 'FastAPI in Python', 'Testing', 'Git like a senior', 'Deploy it', 'Docker in one reel', 'System design: URL shortener', 'Caching', 'Performance', 'Security basics', 'Portfolio that gets calls', 'Interview playbook', 'Ship it: capstone'];
  let doneDays = 12;

  const posts = [
    { n: 'Rohan Kapoor', i: 'RK', g: 'linear-gradient(135deg,#2f8f7a,#9fd3ff)', m: 'NIT Trichy · 1h', b: 'Excited to start my internship at Lumen Labs — found it on MSW Careers!', src: 'LinkedIn', t: 'Rohan joined Lumen Labs', d: 'linkedin.com', l: 342 },
    { n: 'Meera Joshi', i: 'MJ', g: 'linear-gradient(135deg,#ffb38a,#c86dd7)', m: 'IIT KGP · 3h', b: 'This thread on system design rounds is gold 👇', src: 'Reddit', t: 'How I prepped for SDE interviews', d: 'reddit.com', l: 96 },
    { n: 'Kabir Nair', i: 'KN', g: 'linear-gradient(135deg,#6c5ce7,#00d2d3)', m: 'AIIMS · 5h', b: 'We just crossed 1,000 clinic triages on Pulse. Building in public 🚀', src: 'X', t: 'Pulse: week 12 update', d: 'x.com', l: 211 },
  ];
  const srcColor = { X: '#000', LinkedIn: '#0a66c2', Reddit: '#ff4500', Link: '#2f8f7a' };
  const postHtml = (p) => `
    <div class="d-card rv post-c">
      <div class="row" style="border:0;padding:0 0 12px"><div class="av" style="background:${p.g}">${p.i}</div><div class="t"><b>${esc(p.n)}</b><small>${esc(p.m)}</small></div><span class="chip2" style="background:${srcColor[p.src] || '#2f8f7a'};color:#fff">${p.src}</span></div>
      <p style="font-size:15px;margin-bottom:12px">${esc(p.b)}</p>
      <div class="row" style="background:var(--bg);border-radius:14px;padding:8px;border:0"><div class="sq" style="width:64px;height:48px;background:linear-gradient(135deg,var(--lime),var(--teal))"></div><div class="t"><b>${esc(p.t)}</b><small class="mono" style="font-size:10px">${esc(p.d)}</small></div></div>
      <div style="display:flex;gap:18px;margin-top:12px;font-size:13px;color:var(--muted)"><button class="like" data-n="${p.l}">♡ <b>${p.l}</b></button><span>💬 ${Math.round(p.l / 7)}</span><span>↗ Share</span></div>
    </div>`;

  const jobs = [
    { r: 'Frontend Intern', c: 'Lumen Labs', m: 'Remote · ₹40k/mo', col: '#ff7a59', tag: 'Internship', match: 94 },
    { r: 'ML Research Intern', c: 'Kite AI', m: 'Bengaluru · ₹55k/mo', col: '#3b82f6', tag: 'Internship', match: 81 },
    { r: 'Product Designer', c: 'Parallax', m: 'Hybrid · ₹12 LPA', col: '#111', tag: 'Full-time', match: 72 },
    { r: 'Backend Intern', c: 'Helio', m: 'Pune · ₹35k/mo', col: '#2f8f7a', tag: 'Internship', match: 88 },
    { r: 'Flutter Developer', c: 'Northwind', m: 'Remote · ₹9 LPA', col: '#6c5ce7', tag: 'Full-time', match: 77 },
  ];
  const apps = [
    { r: 'Frontend Intern', c: 'Lumen Labs', col: '#ff7a59', s: 3 },
    { r: 'Backend Intern', c: 'Helio', col: '#2f8f7a', s: 1 },
    { r: 'Data Analyst Intern', c: 'Kite AI', col: '#3b82f6', s: 2 },
  ];
  const STAGES = ['Applied', 'Shortlisted', 'Interview', 'Offer'];
  const appRow = (a) => `<div class="row"><div class="sq" style="background:${a.col}">${a.c[0]}</div><div class="t"><b>${a.r}</b><small>${a.c} · ${STAGES[a.s]}</small><div class="pipeline" style="margin-top:8px">${STAGES.map((_, i) => `<span class="${i <= a.s ? 'on' : ''}"></span>`).join('')}</div></div></div>`;

  const hacks = [
    { n: 'HackNova ’26', t: '48 hours. AI for Bharat.', d: 'Mar 14–16 · Online', p: '₹5,00,000', bg: 'radial-gradient(circle at 80% 20%,#6c5ce7,transparent 50%),radial-gradient(circle at 10% 80%,#00d2d3,transparent 45%),#1b1464', s: 1052537 },
    { n: 'Design Sprint', t: 'UI/UX, 12 hours, one brief.', d: 'Apr 02 · IIT Bombay', p: '₹1,50,000', bg: 'radial-gradient(circle at 80% 20%,#ffd166,transparent 50%),radial-gradient(circle at 10% 80%,#ef476f,transparent 45%),#ff7a59', s: 2718480 },
    { n: 'Climate Code', t: 'Hack for a greener grid.', d: 'Apr 20 · Hybrid', p: '₹3,00,000', bg: 'radial-gradient(circle at 80% 20%,#2f8f7a,transparent 50%),radial-gradient(circle at 10% 80%,#d4f56b,transparent 45%),#0f3d2e', s: 4243200 },
    { n: 'FinTech Forge', t: 'Rebuild money for Gen Z.', d: 'May 24 · BITS Pilani', p: '₹2,00,000', bg: 'radial-gradient(circle at 80% 20%,#f72585,transparent 50%),radial-gradient(circle at 10% 80%,#4cc9f0,transparent 45%),#3a0ca3', s: 7238100 },
  ];
  const cd = (s) => { const d = Math.floor(s / 86400), h = Math.floor((s % 86400) / 3600), m = Math.floor((s % 3600) / 60), x = s % 60; return `${d}d ${String(h).padStart(2, '0')}h ${String(m).padStart(2, '0')}m ${String(x).padStart(2, '0')}s`; };
  let tick = 0; setInterval(() => { tick++; $$('[data-cd]').forEach((el) => (el.textContent = cd(Math.max(0, +el.dataset.cd - tick)))); }, 1000);

  const tasks = [
    { t: 'Fix checkout bug on mobile web', c: 'Helio', r: 3000, d: 3, lvl: 2, sk: ['JavaScript', 'Debugging'] },
    { t: 'Clean 10k rows of survey data', c: 'Kite AI', r: 2200, d: 5, lvl: 1, sk: ['Python', 'Pandas'] },
    { t: 'Landing page copy for launch', c: 'Northwind', r: 1500, d: 2, lvl: 1, sk: ['Writing'] },
    { t: 'Build a Flutter onboarding flow', c: 'Parallax', r: 6000, d: 7, lvl: 3, sk: ['Flutter', 'UI'] },
  ];

  const QS = [
    ['What comes next?  2, 6, 12, 20, 30, …', ['40', '42', '44', '36'], 1],
    ['All Bloops are Razzies and all Razzies are Lazzies. Are all Bloops definitely Lazzies?', ['Yes', 'No', 'Cannot say'], 0],
    ['Which word is the odd one out?', ['Python', 'Java', 'Cobra', 'Rust'], 2],
    ['A clock shows 3:15. What is the angle between the hands?', ['0°', '7.5°', '15°', '22.5°'], 1],
    ['Book is to Reading as Fork is to…', ['Drawing', 'Writing', 'Eating', 'Stirring'], 2],
  ];
  function runQuiz(name) {
    let q = 0, right = 0;
    Dash.modal(`<div class="quiz"></div>`, {
      onOpen(m, close) {
        const box = $('.quiz', m);
        const draw = () => {
          if (q >= QS.length) {
            const score = 92 + right * 8;
            box.innerHTML = `<p class="mono label">${name} · result</p><h3>You scored <em>${score}.</em></h3><p class="muted">${right} / ${QS.length} correct · Badge unlocked: 🧠 Sharp Mind</p>
              <div style="display:flex;justify-content:center;margin:24px 0">${Dash.ring(score / 140, score, 'score')}</div>
              <div style="display:flex;gap:10px"><button class="b" data-close>Add to my ID</button><button class="b ghost again">Try again</button></div>`;
            Dash.hydrate(box);
            $('.again', box).onclick = () => { q = 0; right = 0; draw(); };
            $('[data-close]', box).addEventListener('click', () => Dash.toast(`${name} score ${score} added to your ID`));
            return;
          }
          const [qq, opts, ans] = QS[q];
          box.innerHTML = `<p class="mono label">${name} · Question ${q + 1} of ${QS.length}</p>
            <div class="pipeline" style="margin-bottom:22px">${QS.map((_, i) => `<span class="${i <= q ? 'on' : ''}"></span>`).join('')}</div>
            <h3 style="font-size:34px;line-height:1.08;margin-bottom:22px">${qq}</h3>
            ${opts.map((o, i) => `<button class="quiz-opt rv" style="--i:${i}" data-i="${i}"><b>${'ABCD'[i]}</b>${o}</button>`).join('')}`;
          $$('.quiz-opt', box).forEach((b) => (b.onclick = () => {
            const i = +b.dataset.i; if (box.dataset.lock) return; box.dataset.lock = 1;
            if (i === ans) right++;
            $$('.quiz-opt', box).forEach((x) => { if (+x.dataset.i === ans) x.classList.add('ok'); else if (x === b) x.classList.add('bad'); });
            setTimeout(() => { delete box.dataset.lock; q++; draw(); }, 900);
          }));
        };
        draw();
      },
    });
  }

  const idCard = (name = 'Aanya Sharma', course = 'B.Tech Computer Science · 3rd year', college = 'IIT Delhi') => `
    <div class="id-stage" data-cursor="Flip" style="padding:10px 0">
      <div class="idcard">
        <div class="id-face id-front"><div class="holo"></div>
          <div class="idf-top"><b class="logo-s">MSW<i>.</i></b><span class="mono">STUDENT · VERIFIED ✓</span></div>
          <div class="idf-photo"><div class="avatar av-big id-ini">AS</div><div class="idf-chip"></div></div>
          <div class="idf-name"><h4 class="id-n">${esc(name)}</h4><p class="id-c">${esc(course)}</p><p class="mono id-col">${esc(college)}</p></div>
          <div class="idf-stats"><div><b>14</b><small>Level</small></div><div><b>9</b><small>Hackathons</small></div><div><b>23</b><small>Badges</small></div><div><b>128</b><small>IQ</small></div></div>
          <div class="idf-bot"><span class="mono">MSW-2026-0412</span><div class="barcode"></div></div>
        </div>
        <div class="id-face id-back">
          <div class="idb-top"><b class="logo-s">MSW<i>.</i></b><span class="mono">SCAN TO VIEW PROFILE</span></div>
          <div class="qr"></div>
          <div class="skills"><span>React</span><span>Python</span><span>Figma</span><span>ML</span><span>Public speaking</span></div>
          <p class="mono small">Valid while you keep building · msw.community/aanya</p>
        </div>
      </div>
    </div>`;
  function mountId(root) {
    const stage = $('.id-stage', root), card = $('.idcard', root); let flipped = false;
    stage.addEventListener('pointermove', (e) => {
      const r = stage.getBoundingClientRect(), x = (e.clientX - r.left) / r.width - 0.5, y = (e.clientY - r.top) / r.height - 0.5;
      card.style.transform = `${flipped ? 'rotateY(180deg)' : ''} rotateY(${x * 24}deg) rotateX(${-y * 24}deg)`;
      $$('.holo', card).forEach((h) => { h.style.setProperty('--hx', `${(x + 0.5) * 100}%`); h.style.setProperty('--hy', `${(y + 0.5) * 100}%`); h.style.setProperty('--ha', `${x * 180}deg`); });
    });
    stage.addEventListener('pointerleave', () => (card.style.transform = flipped ? 'rotateY(180deg)' : ''));
    stage.addEventListener('click', () => { flipped = !flipped; card.style.transform = flipped ? 'rotateY(180deg)' : ''; });
    const qr = $('.qr', root), N = 21; let seed = 7; const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);
    for (let y = 0; y < N; y++) for (let x = 0; x < N; x++) {
      const c = document.createElement('i'); let on;
      if ((x < 8 && y < 8) || (x > N - 9 && y < 8) || (x < 8 && y > N - 9)) { const fx = x < 8 ? 0 : N - 7, fy = y < 8 ? 0 : N - 7, dx = x - fx, dy = y - fy; on = dx >= 0 && dy >= 0 && dx <= 6 && dy <= 6 && (dx === 0 || dy === 0 || dx === 6 || dy === 6 || (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4)); } else on = rnd() > 0.5;
      if (!on) c.className = 'o'; qr.appendChild(c);
    }
  }

  function dayModal(d) {
    const st = d < doneDays ? 'done' : d === doneDays ? 'now' : 'lock';
    Dash.modal(`<p class="mono label">MSW Labs · Day ${String(d + 1).padStart(2, '0')} of 30</p><h3>${TOPICS[d]}<em>.</em></h3>
      <p class="muted" style="margin-bottom:18px">A 60-second reel, a 10-minute lesson and one hands-on challenge. Finish all three to unlock Day ${d + 2 > 30 ? 30 : d + 2}.</p>
      <div class="rows" style="margin-bottom:20px">
        <div class="row"><span class="n-ic">${icon('play')}</span><div class="t"><b>Watch the reel</b><small>60 sec</small></div><span class="chip2 ${st === 'lock' ? '' : 'teal'}">${st === 'lock' ? 'Locked' : '✓'}</span></div>
        <div class="row"><span class="n-ic">${icon('book')}</span><div class="t"><b>Read the lesson</b><small>10 min</small></div><span class="chip2 ${st === 'done' ? 'teal' : ''}">${st === 'done' ? '✓' : '—'}</span></div>
        <div class="row"><span class="n-ic">${icon('task')}</span><div class="t"><b>Code challenge</b><small>Runs in the MSW Labs editor</small></div><span class="chip2 ${st === 'done' ? 'teal' : ''}">${st === 'done' ? '✓' : '—'}</span></div>
      </div>
      ${st === 'lock' ? `<button class="b ghost" data-close>Locked — finish Day ${doneDays + 1} first</button>` : st === 'now' ? `<button class="b complete">Mark Day ${d + 1} complete</button>` : `<button class="b ghost" data-close>Completed ✓ — rewatch</button>`} <a class="b ghost" href="https://intern.mystartupwave.com/" target="_blank" rel="noopener" style="margin-left:6px">Open on MSW Labs ↗</a>`, {
      onOpen(m, close) {
        const c = $('.complete', m);
        if (c) c.onclick = () => { doneDays = Math.min(30, doneDays + 1); close(); redrawDays(); Dash.toast(`Day ${d + 1} complete — +50 XP 🔥`); };
      },
    });
  }
  function daysHtml() { return TOPICS.map((t, i) => `<div class="day rv ${i < doneDays ? 'done' : i === doneDays ? 'now' : 'lock'}" data-d="${i}" title="${esc(t)}">${String(i + 1).padStart(2, '0')}<small>${i < doneDays ? 'DONE' : i === doneDays ? 'TODAY' : 'LOCKED'}</small></div>`).join(''); }
  function redrawDays() {
    const g = $('.days'); if (g) g.innerHTML = daysHtml();
    $$('.labs-n').forEach((e) => (e.textContent = doneDays));
    const r = $('.labs-ring'); if (r) { r.innerHTML = Dash.ring(doneDays / 30, doneDays, 'of 30 days'); Dash.hydrate(r); }
  }


  const blogs = [
    { t: 'How I won 3 hackathons in my 2nd year', c: 'Hackathons', m: 7, by: 'Aanya Sharma', g: 'radial-gradient(circle at 30% 30%,#d4f56b,transparent 45%),radial-gradient(circle at 70% 70%,#7fd1bd,transparent 50%),#1a1a1a' },
    { t: 'The internship cold email that got 9 replies', c: 'Careers', m: 6, by: 'Rohan Kapoor', g: 'repeating-radial-gradient(circle at 50% 120%,#ff7a59 0 18px,#ffd166 18px 36px)' },
    { t: 'From dorm-room idea to ₹10L pre-seed', c: 'Founders', m: 5, by: 'Meera Joshi', g: 'conic-gradient(from 200deg at 50% 60%,#c9b8ff,#9fd3ff,#ffb38a,#c9b8ff)' },
  ];
  const blogCard = (b) => `<div class="d-card rv" style="display:flex;gap:16px;align-items:center;margin-bottom:14px;padding:14px"><div style="width:120px;height:96px;border-radius:16px;flex:none;background:${b.g}"></div><div style="min-width:0"><span class="mono" style="font-size:10px;color:var(--muted)">${b.c.toUpperCase()} · ${b.m} MIN · ${esc(b.by).toUpperCase()}</span><div class="c-title" style="font-size:28px;margin-top:6px">${esc(b.t)}</div></div></div>`;
  const myIdeas = [{ n: 'Krishi Lite', p: 'Soil reports over SMS for small farmers', sec: 'AgriTech', score: 82, step: 2, votes: 146 }];
  const STEPS = ['Pitched', 'Validated', 'Mentor', 'Investors'];
  const myIdeaCard = (x) => `<div class="d-card rv" style="margin-bottom:14px"><div class="c-head"><span class="chip2 lilac">${x.sec}</span><span class="r mono" style="font-size:11px;color:var(--muted)">${x.votes} VALIDATIONS</span></div>
    <div class="c-title" style="font-size:32px">${esc(x.n)} — <em style="color:#6c5ce7">${esc(x.p.toLowerCase())}</em></div>
    <div style="display:flex;align-items:center;gap:14px;margin:16px 0"><span class="mono" style="font-size:11px;color:var(--muted)">VALIDATION</span><div class="prog" style="flex:1"><i style="--w:${x.score}%"></i></div><b class="c-title">${x.score}</b></div>
    <div class="pipeline">${STEPS.map((_, i) => `<span class="${i <= x.step ? 'on' : ''}"></span>`).join('')}</div><div class="pipeline-l">${STEPS.map((s) => `<span>${s}</span>`).join('')}</div>
    <div style="display:flex;gap:8px;margin-top:16px;flex-wrap:wrap">${x.step >= 2 ? '<span class="chip2 teal">Mentor: Sana Khan</span>' : ''}<button class="b sm to-inv">Share with investors</button></div></div>`;
  function pitchModal(root) {
    Dash.modal(`<p class="mono label">New pitch</p><h3>Pitch your <em>idea.</em></h3>
      <div class="fld"><label>Idea name</label><input class="pn" placeholder="e.g. HostelHub" /></div>
      <div class="fld"><label>One-liner</label><input class="pl" placeholder="What does it do, in one line?" /></div>
      <div class="fld"><label>The problem</label><textarea placeholder="Who has this problem, and how bad is it?"></textarea></div>
      <div class="fld-row"><div class="fld"><label>Sector</label><select class="ps"><option>EdTech</option><option>FinTech</option><option>HealthTech</option><option>AgriTech</option><option>Consumer</option><option>ClimateTech</option></select></div><div class="fld"><label>Stage</label><select><option>Just an idea</option><option>Prototype</option><option>Early users</option></select></div></div>
      <div class="val-box" style="display:none;margin:4px 0 16px"></div>
      <button class="b go">${icon('sparkle')}Submit for validation</button>`, {
      onOpen(m, close) {
        $('.go', m).onclick = () => {
          const box = $('.val-box', m), go = $('.go', m); go.disabled = true; go.textContent = 'Validating…'; box.style.display = 'block';
          const score = 70 + Math.floor(Math.random() * 22);
          box.innerHTML = `<div class="d-card dark" style="display:flex;align-items:center;gap:18px">${Dash.ring(score / 100, score, 'validation')}<div><b>Early validation score</b><p class="muted" style="font-size:13px;margin-top:6px">Based on problem clarity, market size and similar ideas on MSW. Community votes will refine it.</p></div></div>`;
          Dash.hydrate(box);
          setTimeout(() => { go.disabled = false; go.textContent = 'Publish to the community'; go.onclick = () => { myIdeas.unshift({ n: $('.pn', m).value || 'New idea', p: $('.pl', m).value || 'An idea worth building', sec: $('.ps', m).value, score, step: 0, votes: 0 }); close(); $('.my-ideas', root).innerHTML = myIdeas.map(myIdeaCard).join(''); Dash.hydrate($('.my-ideas', root)); Dash.toast('Idea published — the community can now validate it', '💡'); }; }, 1600);
        };
      },
    });
  }
  const resumeFields = [
    ['name', 'Full name', 'Aanya Sharma'], ['headline', 'Headline', 'Full-stack developer · 3× hackathon finalist'], ['contact', 'Contact', 'aanya@iitd.ac.in · github.com/aanya-codes · msw.community/aanya'],
    ['edu', 'Education (one per line)', 'B.Tech Computer Science, IIT Delhi — 2023–2027 · CGPA 8.9', 1],
    ['exp', 'Experience (one per line)', 'Frontend Intern, Lumen Labs — built the onboarding flow used by 40k users\nPaid task, Kite AI — cleaned & labelled 10k survey rows', 1],
    ['proj', 'Projects & hackathons (one per line)', 'Winner, Climate Code ’25 — grid-load forecaster\nMSW Labs 30-Day Full-Stack Challenge — Day 12/30', 1],
    ['skills', 'Skills', 'React, Next.js, Python, FastAPI, Figma, SQL'],
  ];
  document.addEventListener('click', (e) => {
    if (e.target.closest('.post-ev')) Dash.modal(`<p class="mono label">Post an event</p><h3>Bring people <em>together.</em></h3>
      <div class="fld"><label>Event name</label><input class="en" value="React Hooks Workshop" /></div>
      <div class="fld-row"><div class="fld"><label>Type</label><select class="et"><option>Workshop</option><option>Meetup</option><option>Hackathon</option><option>Webinar</option></select></div><div class="fld"><label>Date</label><input class="ed" value="Dec 06 · 6 PM" /></div></div>
      <div class="fld"><label>Where</label><input class="ew" value="Online · Google Meet" /></div>
      <button class="b go">${icon('upload')}Submit for listing</button>`, { onOpen(m, close) { $('.go', m).onclick = () => { const g = $('.hk-grid'); if (g) g.insertAdjacentHTML('afterbegin', `<div class="d-card rv" style="padding:24px;min-height:300px;background:var(--lime);border:0;display:flex;flex-direction:column"><span class="chip2" style="align-self:flex-start">${esc($('.et', m).value)} · In review</span><p class="mono" style="margin-top:auto">${esc($('.ed', m).value)} · ${esc($('.ew', m).value)}</p><h3 style="font-size:44px">${esc($('.en', m).value)}</h3><p>Posted by you · waiting for MSW approval</p></div>`); close(); Dash.toast('Sent to MSW admins — usually approved within a few hours', '📅'); }; } });
    const c = e.target.closest('.contrib'); if (c && !c.classList.contains('done')) { c.classList.add('done'); c.textContent = 'Sent ✓'; Dash.toast(`“${c.dataset.n}” sent to admins for allocation`, '🤝'); }
    const u = e.target.closest('.upgrade'); if (u) Dash.modal(`<p class="mono label">Upgrade</p><h3>Go <em>${u.dataset.p}.</em></h3><div class="c-title" style="font-size:64px;margin:10px 0">${u.dataset.price}<small class="c-sub">/month</small></div><div class="fld"><label>UPI ID</label><input placeholder="name@upi" /></div><button class="b pay">Pay ${u.dataset.price}</button><p class="muted" style="font-size:12px;margin-top:10px">Payments are a UI preview — nothing is charged.</p>`, { onOpen(m, close) { $('.pay', m).onclick = () => { close(); Dash.toast(`Welcome to ${u.dataset.p} 🎉`); }; } });
    const k = e.target.closest('.unlock'); if (k) Dash.toast(+k.dataset.c > 2450 ? `You need ${fmt(+k.dataset.c - 2450)} more credits for ${k.dataset.p}` : `${k.dataset.p} unlocked with credits`, +k.dataset.c > 2450 ? '🔒' : '🎉');
  });

  Dash.init({
    role: 'student', roleName: 'Student', color: '#2f8f7a',
    user: { name: 'Aanya Sharma', sub: 'IIT Delhi · Lvl 14', initials: 'AS', grad: 'linear-gradient(135deg,#ff9a76,#c86dd7)' },
    notifications: [
      { ic: '🎉', t: 'Lumen Labs moved you to Interview', s: '2 min ago' },
      { ic: '⚡', t: 'HackNova ’26 registrations close in 12 days', s: '1 hour ago' },
      { ic: '🔥', t: 'Keep your 12-day streak alive — Day 13 is ready', s: 'Today' },
      { ic: '💰', t: '₹2,200 paid for “Data cleaning” task', s: 'Yesterday' },
    ],
    actions: [
      { label: 'Take the IQ test', ic: 'brain', run: () => runQuiz('IQ test') },
      { label: 'Paste a link to post', ic: 'link', run: () => Dash.go('feed') },
      { label: 'Continue MSW Labs', ic: 'book', run: () => Dash.go('learn') },
    ],
    nav: [
      { id: 'overview', label: 'Overview', icon: 'home', group: 'Home' },
      { id: 'feed', label: 'Feed & posts', icon: 'feed' },
      { id: 'blogs', label: 'Blogs', icon: 'msg' },
      { id: 'learn', label: 'MSW Labs · Day 1–30', icon: 'book', badge: '13', group: 'Learn' },
      { id: 'quizzes', label: 'Quiz · IQ · Reasoning', icon: 'brain' },
      { id: 'games', label: 'Games', icon: 'grid' },
      { id: 'hackathons', label: 'Hackathons & events', icon: 'trophy', group: 'Opportunities' },
      { id: 'jobs', label: 'Jobs & internships', icon: 'briefcase', badge: 5 },
      { id: 'tasks', label: 'Tasks & contribute', icon: 'task' },
      { id: 'ideas', label: 'Business ideas', icon: 'sparkle', group: 'Build' },
      { id: 'resume', label: 'Resume', icon: 'doc' },
      { id: 'id', label: 'My ID', icon: 'id', group: 'You' },
      { id: 'refer', label: 'Credits & plans', icon: 'gift' },
    ],
    views: {
      overview: {
        title: [`${greet}, `, 'Aanya.'], crumb: 'Overview',
        render: () => `
          <div class="d-banner rv"><canvas></canvas>
            <div class="grow"><p class="mono" style="color:var(--teal)">MSW LABS · 30-DAY FULL-STACK CHALLENGE</p><h2>Day 13 is <em>waiting.</em></h2><p>Routing in Next.js — a 60-second reel, a short lesson and one challenge. Keep your 12-day streak alive.</p>
              <div class="bt"><button class="b teal go-learn">${icon('play')}Continue Day 13</button><button class="b ghost go-feed">${icon('link')}Paste a link</button></div></div>
            ${Dash.ring(12 / 30, '<span class="labs-n">12</span>', 'of 30 days')}
          </div>
          <div class="g g-4 mt">
            ${Dash.stat({ label: 'Level 14 · XP', value: 8420, delta: '640 this week', spark: [3, 5, 4, 7, 6, 9, 8, 12, 11, 14], ic: 'star' })}
            ${Dash.stat({ label: 'Credits', value: 2450, delta: '350 from referrals', spark: [2, 3, 3, 5, 6, 6, 8, 9, 10, 12], ic: 'coin' })}
            ${Dash.stat({ label: 'Day streak', value: 12, suffix: ' 🔥', delta: 'Best ever', spark: [1, 2, 3, 4, 5, 6, 7, 8, 9, 12], ic: 'sparkle' })}
            ${Dash.stat({ label: 'Profile views', value: 1284, delta: '18% vs last week', spark: [5, 8, 6, 9, 12, 10, 14, 13, 17, 19], ic: 'eye' })}
          </div>
          <div class="g g-21 mt">
            <div class="d-card rv"><div class="c-head"><span class="c-title">Your <em>activity</em></span><div class="r legend"><span><i style="background:#2f8f7a"></i>XP</span><span><i style="background:#c9b8ff"></i>Class avg</span></div></div>
              ${Dash.chart([{ name: 'XP', color: '#2f8f7a', data: [220, 310, 280, 460, 390, 520, 610, 480, 700, 640, 760, 820, 790, 940] }, { name: 'Avg', color: '#9b87f5', data: [200, 240, 260, 300, 310, 330, 360, 350, 380, 390, 410, 420, 430, 450] }], ['Nov 10', 'Nov 11', 'Nov 12', 'Nov 13', 'Nov 14', 'Nov 15', 'Nov 16', 'Nov 17', 'Nov 18', 'Nov 19', 'Nov 20', 'Nov 21', 'Nov 22', 'Today'], { unit: ' XP' })}</div>
            <div class="d-card dark rv"><div class="c-head"><span class="c-title">Up <em>next</em></span></div>
              <div class="rows">
                <div class="row" style="border-color:rgba(255,255,255,.08)"><span class="n-ic" style="background:#6c5ce7">⚡</span><div class="t"><b>HackNova ’26</b><small class="muted" data-cd="1052537">${cd(1052537)}</small></div></div>
                <div class="row" style="border-color:rgba(255,255,255,.08)"><span class="n-ic" style="background:#ff7a59">🎤</span><div class="t"><b>Interview · Lumen Labs</b><small class="muted">Thu, 4:00 PM · Google Meet</small></div></div>
                <div class="row" style="border-color:rgba(255,255,255,.08)"><span class="n-ic" style="background:#2f8f7a">✓</span><div class="t"><b>Submit “Fix checkout bug”</b><small class="muted">Helio · due in 3 days</small></div></div>
                <div class="row" style="border:0"><span class="n-ic" style="background:#c6a400">🧠</span><div class="t"><b>Daily quiz is live</b><small class="muted">5 questions · +30 XP</small></div><button class="b sm lime do-quiz">Start</button></div>
              </div></div>
          </div>
          <div class="g g-3 mt">
            <div class="d-card rv"><div class="c-head"><span class="c-title">Applications</span><span class="r"><button class="b sm ghost go-jobs">All</button></span></div><div class="rows">${apps.map(appRow).join('')}</div></div>
            <div class="d-card rv"><div class="c-head"><span class="c-title">Picked <em>for you</em></span></div><div class="rows">${jobs.slice(0, 3).map((j) => `<div class="row"><div class="sq" style="background:${j.col}">${j.c[0]}</div><div class="t"><b>${j.r}</b><small>${j.c} · ${j.m}</small></div><span class="chip2 teal">${j.match}%</span></div>`).join('')}</div></div>
            <div class="d-card lime rv"><div class="c-head"><span class="c-title">Badges</span><span class="r mono" style="font-size:11px">23 EARNED</span></div>
              <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px;font-size:30px;text-align:center">${['🔥', '🏆', '🧠', '⚡', '🚀', '💎', '🎯', '🌱'].map((e, i) => `<span style="background:#fff;border-radius:16px;padding:10px 0;${i > 5 ? 'opacity:.35;filter:grayscale(1)' : ''}">${e}</span>`).join('')}</div></div>
          </div>`,
        mount(r) {
          $('.go-learn', r).onclick = () => Dash.go('learn'); $('.go-feed', r).onclick = () => Dash.go('feed'); $('.go-jobs', r).onclick = () => Dash.go('jobs');
          $('.do-quiz', r).onclick = () => runQuiz('Daily quiz');
        },
      },

      feed: {
        title: ['Your ', 'feed.'], crumb: 'Feed',
        render: () => `<div class="g g-21">
          <div>
            <div class="d-card rv"><div class="c-head"><div class="av">AS</div><div><b style="font-weight:600">Paste a link. Get a post.</b><div class="c-sub">X, LinkedIn, Reddit — or any link</div></div></div>
              <div class="fld" style="margin:0"><input class="paste" placeholder="https://x.com/…" /></div>
              <div class="filters2" style="margin:10px 0 14px">${['x.com/aanya/status/1832491', 'linkedin.com/posts/rohan-k-intern', 'reddit.com/r/cscareers/comments/sd'].map((u) => `<button data-u="https://${u}">Try ${u.split('.')[0].replace('x', 'X')}</button>`).join('')}</div>
              <div class="pp-prev"><span class="muted">Preview appears here</span></div>
              <div style="display:flex;justify-content:flex-end;margin-top:14px"><button class="b do-post" disabled style="opacity:.4">Post to community</button></div>
            </div>
            <div class="posts-list">${posts.map(postHtml).join('')}</div>
          </div>
          <div>
            <div class="d-card dark rv"><div class="c-head"><span class="c-title">Trending</span></div><div class="rows">${['#HackNova26', '#MSWLabsDay12', '#BuildInPublic', '#InternshipSeason'].map((t, i) => `<div class="row" style="border-color:rgba(255,255,255,.08)"><span class="mono" style="color:var(--teal)">0${i + 1}</span><div class="t"><b>${t}</b><small class="muted">${fmt(4200 - i * 870)} posts</small></div></div>`).join('')}</div></div>
            <div class="d-card rv mt"><div class="c-head"><span class="c-title">Who to <em>follow</em></span></div><div class="rows">${[['Meera Joshi', 'IIT KGP · Krishi founder', 'MJ'], ['Arjun Rao', 'DTU · 3× hackathon winner', 'AR'], ['Sana Khan', 'MSW Labs mentor', 'SK']].map((p) => `<div class="row"><div class="av sm" style="background:linear-gradient(135deg,#2f8f7a,#d4f56b)">${p[2]}</div><div class="t"><b>${p[0]}</b><small>${p[1]}</small></div><button class="b sm ghost follow">Follow</button></div>`).join('')}</div></div>
          </div></div>`,
        mount(r) {
          const inp = $('.paste', r), prev = $('.pp-prev', r), btn = $('.do-post', r);
          const upd = () => {
            const s = Dash.detect(inp.value);
            btn.disabled = !s; btn.style.opacity = s ? 1 : 0.4;
            prev.innerHTML = s ? `<div class="row" style="border:0;padding:0;animation:kin .5s var(--ease)"><div class="sq" style="background:${s.color};width:60px;height:60px;font-size:20px">${s.short}</div><div class="t"><span class="chip2" style="margin-bottom:6px">Detected: ${s.name}</span><b>Link preview ready to share</b><small>${esc(inp.value)}</small></div></div>` : '<span class="muted">Preview appears here</span>';
          };
          inp.addEventListener('input', upd);
          $$('[data-u]', r).forEach((b) => (b.onclick = () => { inp.value = b.dataset.u; upd(); }));
          btn.onclick = () => {
            const s = Dash.detect(inp.value); if (!s) return;
            $('.posts-list', r).insertAdjacentHTML('afterbegin', postHtml({ n: 'Aanya Sharma', i: 'AS', g: 'linear-gradient(135deg,#ff9a76,#c86dd7)', m: 'IIT Delhi · now', b: `Sharing this from ${s.name} 👇`, src: s.name, t: `Shared from ${s.name}`, d: (inp.value.split('/')[2] || ''), l: 0 }));
            inp.value = ''; upd(); Dash.toast('Posted to the community');
          };
          r.addEventListener('click', (e) => {
            const l = e.target.closest('.like');
            if (l) { const on = l.classList.toggle('on'); const n = +l.dataset.n + (on ? 1 : 0); l.innerHTML = `${on ? '♥' : '♡'} <b>${n}</b>`; l.style.color = on ? '#e0245e' : ''; l.animate([{ transform: 'scale(1.4)' }, { transform: 'scale(1)' }], { duration: 400, easing: 'cubic-bezier(.22,1,.36,1)' }); }
            const f = e.target.closest('.follow');
            if (f) { const on = f.classList.toggle('done'); f.textContent = on ? 'Following ✓' : 'Follow'; }
          });
        },
      },

      learn: {
        title: ['MSW ', 'Labs.'], crumb: '30-Day Full-Stack Challenge',
        render: () => `
          <div class="g g-12">
            <div class="d-card dark rv" style="display:flex;flex-direction:column;align-items:center;justify-content:center;gap:14px;text-align:center"><div class="labs-ring">${Dash.ring(doneDays / 30, doneDays, 'of 30 days')}</div><p class="muted">Finish all 30 days to earn your<br/>MSW Labs Full-Stack certificate.</p><div class="prog" style="width:100%"><i style="--w:40%"></i></div><a class="b teal" href="https://intern.mystartupwave.com/" target="_blank" rel="noopener">Open MSW Labs ↗</a></div>
            <div class="d-card rv"><div class="c-head"><span class="c-title">The <em>30 days</em></span><span class="r legend"><span><i style="background:var(--ink)"></i>Done</span><span><i style="background:var(--lime)"></i>Today</span><span><i style="background:var(--bg-2)"></i>Locked</span></span></div>
              <div class="days">${daysHtml()}</div></div>
          </div>`,
        mount(r) { r.addEventListener('click', (e) => { const d = e.target.closest('.day'); if (d) dayModal(+d.dataset.d); }); },
      },

      quizzes: {
        title: ['Quizzes ', '& IQ.'], crumb: 'Tests',
        render: () => `<div class="g g-4">
          ${[['IQ test', '5 Qs · 3 min', '#c9b8ff', 'brain'], ['Reasoning', '10 Qs · 6 min', '#ffb38a', 'layers'], ['Daily quiz', 'New every day', '#9fd3ff', 'sparkle'], ['Aptitude', '15 Qs · 10 min', '#d4f56b', 'chart']].map((q) => `
            <button class="d-card rv start-q" data-q="${q[0]}" style="background:${q[2]};border:0;text-align:left;min-height:200px;display:flex;flex-direction:column">
              <span class="sq" style="background:var(--ink)">${icon(q[3])}</span><span style="margin-top:auto" class="c-title">${q[0]}</span><span class="c-sub" style="color:var(--ink-2)">${q[1]} · Start →</span></button>`).join('')}</div>
          <div class="g g-2 mt">
            <div class="d-card rv"><div class="c-head"><span class="c-title">Your <em>scores</em></span></div>${Dash.bars([{ label: 'IQ', value: 128 }, { label: 'Reasoning', value: 86 }, { label: 'Aptitude', value: 74 }, { label: 'Daily avg', value: 91 }])}</div>
            <div class="d-card rv"><div class="c-head"><span class="c-title">Leaderboard</span><span class="r chip2 teal">IIT Delhi</span></div><div class="rows">${[['Ishaan M.', 142], ['Aanya Sharma (you)', 128], ['Rhea P.', 124], ['Dev S.', 119]].map((p, i) => `<div class="row"><span class="mono">0${i + 1}</span><div class="t"><b>${p[0]}</b></div><b>${p[1]}</b></div>`).join('')}</div></div>
          </div>`,
        mount(r) { $$('.start-q', r).forEach((b) => (b.onclick = () => runQuiz(b.dataset.q))); },
      },

      hackathons: {
        title: ['Hackathons ', 'we power.'], crumb: 'Hackathons',
        render: () => `<div class="d-card rv" style="display:flex;align-items:center;gap:16px;flex-wrap:wrap;margin-bottom:16px"><div style="flex:1;min-width:220px"><b style="font-weight:600">Running a workshop, meetup or club hackathon?</b><div class="c-sub">Students can post events too — MSW reviews and lists them for everyone.</div></div><button class="b post-ev">${icon('plus')}Post an event</button></div><div class="g g-2 hk-grid">${hacks.map((h) => `
          <div class="d-card rv" style="padding:0;border:0;min-height:300px;background:${h.bg};color:#fff;display:flex;flex-direction:column;justify-content:flex-end">
            <div style="padding:24px;background:linear-gradient(transparent,rgba(0,0,0,.55))">
              <span class="chip2 dark" data-cd="${h.s}" style="font-family:var(--mono)">${cd(h.s)}</span>
              <p class="mono" style="margin-top:14px;opacity:.75">${h.d}</p><h3 style="font-size:48px">${h.n}</h3><p style="opacity:.8">${h.t}</p>
              <div style="display:flex;align-items:center;justify-content:space-between;margin-top:16px;padding-top:14px;border-top:1px solid rgba(255,255,255,.25)"><b>${h.p}</b><button class="b light reg">Register</button></div>
            </div></div>`).join('')}</div>`,
        mount(r) { $$('.reg', r).forEach((b) => (b.onclick = () => { const on = b.classList.toggle('lime'); b.textContent = on ? 'Registered ✓' : 'Register'; if (on) Dash.toast('Registered — team invite link sent to your email', '🎉'); })); },
      },

      jobs: {
        title: ['Jobs ', '& internships.'], crumb: 'Careers',
        render: () => `
          <div class="filters2 rv" style="margin-bottom:16px">${['All', 'Internship', 'Full-time', 'Remote'].map((f, i) => `<button class="${i ? '' : 'on'}" data-f="${f}">${f}</button>`).join('')}</div>
          <div class="g g-21">
            <div class="d-card rv"><div class="rows job-list">${jobs.map((j) => `<div class="row" data-tag="${j.tag}" data-remote="${j.m.includes('Remote')}"><div class="sq" style="background:${j.col}">${j.c[0]}</div><div class="t"><b>${j.r}</b><small>${j.c} · ${j.m}</small></div><span class="chip2">${j.tag}</span><span class="chip2 teal">${j.match}% match</span><button class="b sm apply" data-r="${j.r}" data-c="${j.c}">Apply</button></div>`).join('')}</div></div>
            <div class="d-card rv"><div class="c-head"><span class="c-title">Tracker</span></div><div class="rows app-list">${apps.map(appRow).join('')}</div>
              <div class="pipeline-l" style="margin-top:14px">${STAGES.map((s) => `<span>${s}</span>`).join('')}</div></div>
          </div>`,
        mount(r) {
          $$('.filters2 button', r).forEach((b) => (b.onclick = () => {
            $$('.filters2 button', r).forEach((x) => x.classList.toggle('on', x === b));
            $$('.job-list .row', r).forEach((row) => { const f = b.dataset.f; row.style.display = f === 'All' || row.dataset.tag === f || (f === 'Remote' && row.dataset.remote === 'true') ? '' : 'none'; });
          }));
          $$('.apply', r).forEach((b) => (b.onclick = () => {
            if (b.classList.contains('done')) return;
            Dash.modal(`<p class="mono label">Apply with MSW ID</p><h3>${b.dataset.r} <em>@ ${b.dataset.c}</em></h3><p class="muted" style="margin-bottom:18px">Your verified ID, badges, MSW Labs progress and GitHub score are attached automatically.</p>
              <div class="fld"><label>Why you? (optional)</label><textarea placeholder="Two lines on what you’d build first…"></textarea></div>
              <div class="fld"><label>Portfolio / GitHub</label><input value="github.com/aanya-codes" /></div>
              <button class="b send">${icon('arrow')}Send application</button>`, {
              onOpen(m, close) { $('.send', m).onclick = () => { close(); b.classList.add('done'); b.textContent = 'Applied ✓'; $('.app-list', r).insertAdjacentHTML('afterbegin', appRow({ r: b.dataset.r, c: b.dataset.c, col: '#2f8f7a', s: 0 })); Dash.toast(`Applied to ${b.dataset.c}`); }; },
            });
          }));
        },
      },

      tasks: {
        title: ['Company ', 'tasks.'], crumb: 'Tasks',
        render: () => `<div class="g g-21">
          <div class="g g-2" style="align-content:start">${tasks.map((t) => `
            <div class="d-card rv"><div class="c-head"><span class="chip2">${t.c}</span><span class="r mono" style="font-size:11px">${t.d}D LEFT</span></div>
              <div class="c-title" style="font-size:28px;line-height:1.05">${t.t}</div>
              <div class="filters2" style="margin:12px 0">${t.sk.map((s) => `<span class="chip2">${s}</span>`).join('')}<span class="chip2 ${['teal', 'peach', 'red'][t.lvl - 1]}">${['Easy', 'Medium', 'Hard'][t.lvl - 1]}</span></div>
              <div style="display:flex;align-items:center;justify-content:space-between"><span class="c-title" style="color:var(--teal-d)">₹${fmt(t.r)}</span><button class="b take" data-t="${esc(t.t)}" data-c="${t.c}" data-r="${t.r}">Take task</button></div></div>`).join('')}</div>
          <div style="align-self:start;display:grid;gap:16px"><div class="d-card dark rv"><div class="c-head"><span class="c-title">My <em>tasks</em></span></div>
            <div class="rows my-tasks"><div class="row" style="border-color:rgba(255,255,255,.08)"><div class="t"><b>Fix checkout bug</b><small class="muted">Helio · in progress</small></div><button class="b sm lime submit-t">Submit</button></div>
            <div class="row" style="border:0"><div class="t"><b>Data cleaning</b><small class="muted">Kite AI · paid ₹2,200</small></div><span class="chip2 teal">Paid</span></div></div>
            <div class="prog" style="margin-top:14px"><i style="--w:62%"></i></div><p class="muted" style="font-size:12px;margin-top:8px">₹7,400 earned this semester</p></div>
            <div class="d-card lime rv"><div class="c-head"><span class="c-title">Contribute <em>to MSW</em></span></div><div class="rows">${[['🎬', 'Script a reel for MSW Labs', 300], ['🧩', 'Write 10 quiz questions', 150], ['🤝', 'Mentor a junior for a week', 400]].map((c) => `<div class="row" style="border-color:rgba(0,0,0,.08)"><span style="font-size:22px">${c[0]}</span><div class="t"><b>${c[1]}</b><small>+${c[2]} credits</small></div><button class="b sm contrib" data-n="${c[1]}">Contribute</button></div>`).join('')}</div></div></div></div>`,
        mount(r) {
          r.addEventListener('click', (e) => {
            const t = e.target.closest('.take');
            if (t && !t.classList.contains('done')) { t.classList.add('done'); t.textContent = 'Taken ✓'; $('.my-tasks', r).insertAdjacentHTML('afterbegin', `<div class="row" style="border-color:rgba(255,255,255,.08);animation:kin .5s var(--ease)"><div class="t"><b>${t.dataset.t}</b><small class="muted">${t.dataset.c} · in progress · ₹${fmt(+t.dataset.r)}</small></div><button class="b sm lime submit-t">Submit</button></div>`); Dash.toast(`${t.dataset.c} has been notified`, '⚡'); }
            const s = e.target.closest('.submit-t');
            if (s) Dash.modal(`<p class="mono label">Submit your work</p><h3>Ship <em>it.</em></h3><div class="fld"><label>Link to your work (GitHub, Drive, Figma…)</label><input placeholder="https://" /></div><div class="fld"><label>Notes for the reviewer</label><textarea></textarea></div><button class="b go">Submit for review</button>`, { onOpen(m, close) { $('.go', m).onclick = () => { close(); s.outerHTML = '<span class="chip2 peach">In review</span>'; Dash.toast('Submitted — the company will review within 48h'); }; } });
          });
        },
      },


      blogs: {
        title: ['Blogs ', '& stories.'], crumb: 'Read & write',
        render: () => `<div class="g g-21">
          <div class="blog-list">${blogs.map(blogCard).join('')}</div>
          <div style="align-self:start;display:grid;gap:16px"><div class="d-card dark rv"><div class="c-title" style="font-size:34px">Write <em style="color:var(--teal)">your story.</em></div><p class="muted" style="margin:10px 0 16px">Hackathon wins, internship lessons, project breakdowns. Good blogs earn credits and land on the MSW website.</p><button class="b teal write">${icon('plus')}Write a blog</button></div>
            <div class="d-card rv"><div class="c-head"><span class="c-title">Your <em>stats</em></span></div><div class="rows"><div class="row"><div class="t"><b>3 published</b><small>2,140 reads</small></div></div><div class="row"><div class="t"><b>+450 credits</b><small>from blogs this month</small></div></div></div></div></div></div>`,
        mount(r) {
          $('.write', r).onclick = () => Dash.modal(`<p class="mono label">New blog</p><h3>Write <em>it down.</em></h3>
            <div class="fld"><label>Title</label><input class="bt" placeholder="How I built my first SaaS in 30 days" /></div>
            <div class="fld"><label>Category</label><select class="bc"><option>Hackathons</option><option>Careers</option><option>Founders</option><option>Learning</option></select></div>
            <div class="fld"><label>Story</label><textarea class="bb" style="min-height:180px" placeholder="Start writing…"></textarea></div>
            <div style="display:flex;align-items:center;gap:12px"><button class="b pub">${icon('upload')}Publish</button><span class="mono wc" style="color:var(--muted)">0 WORDS · 1 MIN READ</span></div>`, {
            onOpen(m, close) {
              $('.bb', m).addEventListener('input', (e) => { const w = e.target.value.trim().split(/\s+/).filter(Boolean).length; $('.wc', m).textContent = `${w} WORDS · ${Math.max(1, Math.round(w / 200))} MIN READ`; });
              $('.pub', m).onclick = () => { const t = $('.bt', m).value || 'Untitled story'; blogs.unshift({ t, c: $('.bc', m).value, m: Math.max(1, Math.round($('.bb', m).value.split(/\s+/).length / 200)), by: 'You', g: 'linear-gradient(135deg,#d4f56b,#7fd1bd)' }); close(); $('.blog-list', r).innerHTML = blogs.map(blogCard).join(''); Dash.toast('Published — +150 credits', '✍️'); };
            },
          });
        },
      },

      games: {
        title: ['Games ', 'that train your brain.'], crumb: 'Play & earn credits',
        render: () => `<div class="g g-2">
          <div class="d-card rv"><div class="c-head"><span class="c-title">Memory <em>match</em></span><span class="r mono mm-stat" style="font-size:11px">0 MOVES</span></div><div class="mm"></div><button class="b sm ghost mm-reset" style="margin-top:14px">Shuffle & restart</button></div>
          <div class="d-card dark rv"><div class="c-head"><span class="c-title">Reaction <em>time</em></span><span class="r mono rt-best" style="font-size:11px;color:var(--teal)">BEST —</span></div><button class="rt">Tap to start</button><p class="muted" style="font-size:13px;margin-top:12px">Wait for green, then tap as fast as you can. Under 250ms earns +20 credits.</p></div>
        </div>
        <div class="g g-3 mt">${[['🔤', 'Word sprint', 'Make words against the clock'], ['🧮', 'Number ninja', 'Mental math, 60 seconds'], ['🗺', 'Logic grid', 'Classic deduction puzzles']].map((g) => `<div class="d-card rv"><div style="font-size:32px">${g[0]}</div><div class="c-title" style="margin:8px 0 4px">${g[1]}</div><div class="c-sub">${g[2]}</div><span class="chip2" style="margin-top:12px">Coming soon</span></div>`).join('')}</div>`,
        mount(r) {
          const EM = ['🧠', '⚡', '🎯', '🧩', '🔥', '💎'];
          let first = null, lock = false, moves = 0, found = 0;
          const deal = () => {
            const deck = [...EM, ...EM].sort(() => Math.random() - 0.5); moves = 0; found = 0; first = null;
            $('.mm-stat', r).textContent = '0 MOVES';
            $('.mm', r).innerHTML = deck.map((e) => `<button class="mm-c" data-e="${e}"><span>${e}</span></button>`).join('');
          };
          $('.mm', r).addEventListener('click', (e) => {
            const c = e.target.closest('.mm-c'); if (!c || lock || c.classList.contains('open')) return;
            c.classList.add('open');
            if (!first) { first = c; return; }
            moves++; $('.mm-stat', r).textContent = `${moves} MOVES`;
            if (first.dataset.e === c.dataset.e) { first.classList.add('got'); c.classList.add('got'); first = null; if (++found === EM.length) Dash.toast(`Solved in ${moves} moves — +${Math.max(10, 60 - moves * 2)} credits`, '🧠'); }
            else { lock = true; const a = first; first = null; setTimeout(() => { a.classList.remove('open'); c.classList.remove('open'); lock = false; }, 700); }
          });
          $('.mm-reset', r).onclick = deal; deal();
          const btn = $('.rt', r); let state = 'idle', t0 = 0, timer = null, best = null;
          btn.onclick = () => {
            if (state === 'idle' || state === 'done') { state = 'wait'; btn.className = 'rt wait'; btn.textContent = 'Wait for green…'; timer = setTimeout(() => { state = 'go'; btn.className = 'rt go'; btn.textContent = 'TAP!'; t0 = performance.now(); }, 1200 + Math.random() * 2200); }
            else if (state === 'wait') { clearTimeout(timer); state = 'done'; btn.className = 'rt'; btn.textContent = 'Too early! Tap to retry'; }
            else if (state === 'go') { const ms = Math.round(performance.now() - t0); state = 'done'; btn.className = 'rt'; btn.innerHTML = `<b>${ms} ms</b><small>Tap to play again</small>`; if (!best || ms < best) { best = ms; $('.rt-best', r).textContent = `BEST ${ms}MS`; } if (ms < 250) Dash.toast('Lightning reflexes — +20 credits', '⚡'); }
          };
        },
      },

      ideas: {
        title: ['Business ', 'ideas.'], crumb: 'Pitch · validate · mentor · invest',
        render: () => `
          <div class="d-banner rv" style="min-height:180px"><canvas></canvas><div class="grow"><p class="mono" style="color:var(--lilac)">FROM IDEA TO INVESTOR</p><h2>Pitch it. Validate it. <em>Get it funded.</em></h2><div class="bt"><button class="b teal pitch">${icon('sparkle')}Pitch a new idea</button></div></div></div>
          <div class="g g-21 mt">
            <div><div class="my-ideas">${myIdeas.map(myIdeaCard).join('')}</div>
              <div class="d-card rv mt"><div class="c-head"><span class="c-title">Validate <em>others’ ideas</em></span><span class="r c-sub">+10 credits per review</span></div><div class="rows">${[['Loop', 'Campus resale marketplace', 'Dev S. · VIT'], ['Volt', 'Battery swapping for e-rickshaws', 'Ishaan M. · IIT Delhi'], ['StudyBuddy', 'Find a study partner in your hostel', 'Tara D. · SPIT']].map((x) => `<div class="row"><div class="sq" style="background:#6c5ce7">${x[0][0]}</div><div class="t"><b>${x[0]} — ${x[1]}</b><small>${x[2]}</small></div><button class="b sm ghost vote" data-v="yes">👍 Would use</button><button class="b sm ghost vote" data-v="no">🤔 Not sure</button></div>`).join('')}</div></div></div>
            <div class="d-card rv" style="align-self:start"><div class="c-head"><span class="c-title">Mentors</span></div><div class="rows">${[['Sana Khan', 'Product · ex-Razorpay', 'SK'], ['Vikram Rao', 'Founder · 2 exits', 'VR'], ['Dr. Anita Shah', 'HealthTech · AIIMS', 'AS']].map((m) => `<div class="row"><div class="av sm" style="background:linear-gradient(135deg,#6c5ce7,#d4f56b)">${m[2]}</div><div class="t"><b>${m[0]}</b><small>${m[1]}</small></div><button class="b sm mentor" data-n="${m[0]}">Request</button></div>`).join('')}</div><p class="muted" style="font-size:12px;margin-top:10px">Mentor sessions are included in Pro+ or cost 400 credits.</p></div>
          </div>`,
        mount(r) {
          $('.pitch', r).onclick = () => pitchModal(r);
          r.addEventListener('click', (e) => {
            const v = e.target.closest('.vote'); if (v) { const row = v.closest('.row'); $$('.vote', row).forEach((x) => x.remove()); row.insertAdjacentHTML('beforeend', `<span class="chip2 ${v.dataset.v === 'yes' ? 'teal' : 'peach'}">${v.dataset.v === 'yes' ? 'Voted 👍' : 'Feedback sent'}</span>`); Dash.toast('Thanks for validating — +10 credits'); }
            const m = e.target.closest('.mentor'); if (m && !m.classList.contains('done')) { m.classList.add('done'); m.textContent = 'Requested ✓'; Dash.toast(`${m.dataset.n} will confirm a slot within 24h`, '🤝'); }
            const inv = e.target.closest('.to-inv'); if (inv && !inv.classList.contains('done')) { inv.classList.add('done'); inv.textContent = 'Shared with investors ✓'; Dash.toast('Now visible in 312 investors’ deal flow', '🚀'); }
          });
        },
      },

      resume: {
        title: ['Your ', 'résumé.'], crumb: 'Built from your MSW ID',
        render: () => `<div class="g g-2">
          <div class="d-card rv"><div class="c-head"><span class="c-title">Details</span><span class="r"><button class="b sm ghost import">${icon('id')}Import from MSW ID</button></span></div>
            ${resumeFields.map((f) => `<div class="fld"><label>${f[1]}</label>${f[3] ? `<textarea data-k="${f[0]}">${esc(f[2])}</textarea>` : `<input data-k="${f[0]}" value="${esc(f[2])}" />`}</div>`).join('')}</div>
          <div style="align-self:start;position:sticky;top:110px">
            <div class="cv-paper rv"></div>
            <div style="display:flex;gap:10px;margin-top:14px;align-items:center"><button class="b dl">${icon('upload')}Download PDF</button><span class="chip2 lime ats-s">ATS score 92</span></div></div></div>`,
        mount(r) {
          const val = (k) => ($(`[data-k="${k}"]`, r) || {}).value || '';
          const draw = () => {
            const lines = (k) => val(k).split('\n').filter(Boolean).map((l) => `<li>${esc(l)}</li>`).join('');
            $('.cv-paper', r).innerHTML = `<h4>${esc(val('name'))}</h4><p class="cv-h">${esc(val('headline'))}</p><p class="cv-c">${esc(val('contact'))}</p>
              <h6>Education</h6><ul>${lines('edu')}</ul><h6>Experience</h6><ul>${lines('exp')}</ul><h6>Projects & hackathons</h6><ul>${lines('proj')}</ul><h6>Skills</h6><p>${esc(val('skills'))}</p>
              <p class="cv-f">Verified on MSW Community · MSW-2026-0412</p>`;
            const score = Math.min(99, 60 + Math.round((val('exp') + val('proj') + val('skills')).length / 12));
            $('.ats-s', r).textContent = `ATS score ${score}`;
          };
          r.addEventListener('input', draw); draw();
          $('.import', r).onclick = () => { Dash.toast('Imported badges, hackathons & tasks from your ID'); };
          $('.dl', r).onclick = () => {
            const w = window.open('', '_blank'); if (!w) return Dash.toast('Allow pop-ups to download', '⚠');
            w.document.write(`<html><head><title>${esc(val('name'))} — Resume</title><link href="https://fonts.googleapis.com/css2?family=Instrument+Serif&family=Inter:wght@400;600&display=swap" rel="stylesheet"><style>body{font-family:Inter,sans-serif;max-width:760px;margin:40px auto;color:#121212;font-size:14px;line-height:1.5}h4{font-family:'Instrument Serif',serif;font-weight:400;font-size:44px;margin:0}h6{font-size:11px;letter-spacing:.1em;text-transform:uppercase;color:#2f8f7a;margin:22px 0 6px;border-bottom:1px solid #ddd;padding-bottom:4px}ul{margin:0;padding-left:18px}.cv-h{margin:4px 0;font-weight:600}.cv-c,.cv-f{color:#666}.cv-f{margin-top:30px;font-size:11px}</style></head><body>${$('.cv-paper', r).innerHTML}<script>setTimeout(()=>print(),600)<\/script></body></html>`);
            w.document.close();
          };
        },
      },

      id: {
        title: ['My ', 'ID.'], crumb: 'Digital ID',
        render: () => `<div class="g g-2">
          <div class="rv">${idCard()}<p class="mono" style="text-align:center;color:var(--muted)">Move to tilt · click to flip</p></div>
          <div class="d-card rv" style="align-self:start"><div class="c-head"><span class="c-title">Edit <em>profile</em></span><span class="r chip2 teal">Live preview</span></div>
            <div class="fld"><label>Full name</label><input class="e-n" value="Aanya Sharma" /></div>
            <div class="fld"><label>Course & year</label><input class="e-c" value="B.Tech Computer Science · 3rd year" /></div>
            <div class="fld"><label>College</label><input class="e-col" value="IIT Delhi" /></div>
            <div class="fld"><label>Skills</label><input value="React, Python, Figma, ML, Public speaking" /></div>
            <div style="display:flex;gap:10px"><button class="b save">Save profile</button><button class="b ghost share">${icon('link')}Copy profile link</button></div></div></div>`,
        mount(r) {
          mountId(r);
          const bind = (sel, tgt, fn = (v) => v) => $(sel, r).addEventListener('input', (e) => { $(tgt, r).textContent = fn(e.target.value); });
          bind('.e-n', '.id-n'); bind('.e-c', '.id-c'); bind('.e-col', '.id-col');
          $('.e-n', r).addEventListener('input', (e) => { $('.id-ini', r).textContent = e.target.value.split(' ').map((w) => w[0] || '').join('').slice(0, 2).toUpperCase(); });
          $('.save', r).onclick = () => Dash.toast('Profile saved — your ID is updated');
          $('.share', r).onclick = () => { try { navigator.clipboard.writeText('https://msw.community/aanya'); } catch (_) {} Dash.toast('Link copied: msw.community/aanya'); };
        },
      },

      refer: {
        title: ['Refer ', '& credits.'], crumb: 'Rewards',
        render: () => `<div class="g g-12">
          <div class="d-card lime rv"><p class="mono">CREDITS BALANCE</p><div class="stat"><span class="val" style="font-size:88px"><span class="count" data-to="2450">0</span></span></div><p>7 friends joined · 350 credits per signup</p>
            <button class="b copy-ref" style="margin-top:18px;width:100%;justify-content:space-between"><span class="mono">MSW.COMMUNITY/R/AANYA</span><span>Copy</span></button></div>
          <div class="d-card rv"><div class="c-head"><span class="c-title">Spend your <em>credits</em></span></div>
            <div class="g g-3">${[['Mock interview with a mentor', 800, '🎤'], ['MSW hoodie', 1500, '🧥'], ['Priority hackathon seat', 600, '⚡'], ['1:1 resume review', 500, '📄'], ['Premium MSW Labs track', 2000, '🚀'], ['Coffee chat with an investor', 2500, '☕']].map((x) => `<div class="d-card" style="padding:16px"><div style="font-size:28px">${x[2]}</div><b style="display:block;margin:8px 0 4px;font-size:14px">${x[0]}</b><div style="display:flex;justify-content:space-between;align-items:center"><span class="mono">${fmt(x[1])} CR</span><button class="b sm ${x[1] > 2450 ? 'ghost' : ''} redeem" data-c="${x[1]}" data-n="${esc(x[0])}">${x[1] > 2450 ? 'Locked' : 'Redeem'}</button></div></div>`).join('')}</div></div></div>
          <div class="d-card rv mt"><div class="c-head"><span class="c-title">Your <em>plan</em></span><span class="r c-sub">Pay with money or unlock with credits</span></div>
            <div class="g g-3">${[['Starter', '₹0', 'Current plan', ['Feed, blogs, reels', 'MSW Labs Day 1–7', '5 applications / month'], 0], ['Pro', '₹99', '/month · or 2,000 credits', ['Full Day 1–30 + certificate', 'Unlimited applications & tasks', 'All quizzes, resume, GitHub analyser'], 2000], ['Pro+', '₹299', '/month · or 5,000 credits', ['Pitch ideas to investors', '2 mentor sessions / month', 'Mock interviews'], 5000]].map((pl, i) => `<div class="d-card ${i === 1 ? 'dark' : ''}" style="padding:20px"><span class="mono" style="font-size:11px;${i === 1 ? 'color:var(--teal)' : 'color:var(--muted)'}">${pl[0].toUpperCase()}</span><div class="c-title" style="font-size:52px;margin:6px 0 2px">${pl[1]}</div><div class="c-sub">${pl[2]}</div><ul style="list-style:none;display:grid;gap:6px;margin:14px 0;font-size:13px">${pl[3].map((f) => `<li>✓ ${f}</li>`).join('')}</ul>${i === 0 ? '<span class="chip2 teal">Active</span>' : `<div style="display:flex;gap:8px;flex-wrap:wrap"><button class="b sm ${i === 1 ? 'teal' : ''} upgrade" data-p="${pl[0]}" data-price="${pl[1]}">Upgrade · ${pl[1]}</button><button class="b sm ghost unlock" data-c="${pl[4]}" data-p="${pl[0]}">Use credits</button></div>`}</div>`).join('')}</div></div>`,
        mount(r) {
          $('.copy-ref', r).onclick = () => { try { navigator.clipboard.writeText('https://msw.community/r/aanya'); } catch (_) {} Dash.toast('Invite link copied'); };
          $$('.redeem', r).forEach((b) => (b.onclick = () => { if (+b.dataset.c > 2450) return Dash.toast('Earn a few more credits to unlock this', '🔒'); b.classList.add('done'); b.textContent = 'Redeemed ✓'; Dash.toast(`Redeemed: ${b.dataset.n}`, '🎁'); }));
        },
      },
    },
  });
})();
