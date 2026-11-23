/* MSW Community — Investor dashboard */
(function () {
  const { $, $$, icon, esc, fmt } = Dash;
  const ideas = [
    { n: 'Krishi', p: 'Soil health from a ₹200 sensor', by: 'Meera J. · IIT Kharagpur', sec: 'AgriTech', st: 'Seed', raised: 7.8, goal: 10, users: 1840, gr: [2, 3, 5, 6, 9, 12, 15, 21], col: '#2f8f7a' },
    { n: 'Nibble', p: 'Exam prep in 5-minute bites', by: 'Arjun & Sana · DTU', sec: 'EdTech', st: 'Pre-seed', raised: 2.3, goal: 5, users: 12400, gr: [3, 4, 4, 7, 8, 11, 14, 19], col: '#6c5ce7' },
    { n: 'Pulse', p: 'AI triage for rural clinics', by: 'Kabir N. · AIIMS', sec: 'HealthTech', st: 'Idea', raised: 1.1, goal: 5, users: 1020, gr: [1, 1, 2, 2, 3, 5, 6, 9], col: '#e8613f' },
    { n: 'Ledgerly', p: 'UPI bookkeeping for kirana stores', by: 'Rhea P. · IIIT Hyd', sec: 'FinTech', st: 'Seed', raised: 6.4, goal: 15, users: 3300, gr: [4, 5, 7, 8, 8, 10, 13, 16], col: '#0a66c2' },
    { n: 'Loop', p: 'Campus resale marketplace', by: 'Dev S. · VIT', sec: 'Consumer', st: 'Pre-seed', raised: 0.9, goal: 3, users: 5600, gr: [2, 4, 5, 5, 6, 8, 9, 12], col: '#c6a400' },
    { n: 'Volt', p: 'Battery swapping for e-rickshaws', by: 'Ishaan M. · IIT Delhi', sec: 'ClimateTech', st: 'Idea', raised: 0.4, goal: 8, users: 140, gr: [1, 1, 1, 2, 2, 3, 3, 4], col: '#7fd1bd' },
  ];
  const portfolio = [
    { n: 'Krishi', amt: 2, val: 3.4, st: 'Seed', ch: 70 },
    { n: 'Ledgerly', amt: 1.5, val: 2.1, st: 'Seed', ch: 40 },
    { n: 'Nibble', amt: 0.8, val: 0.95, st: 'Pre-seed', ch: 19 },
    { n: 'Hive', amt: 1, val: 0.7, st: 'Pre-seed', ch: -30 },
  ];
  const watch = new Set(['Krishi', 'Pulse']);

  const ideaCard = (x, i) => `<div class="d-card rv idea-card" data-sec="${x.sec}" data-st="${x.st}" style="--i:${i}">
    <div class="c-head" style="margin-bottom:10px"><span class="chip2">${x.sec}</span><span class="chip2 ${x.st === 'Seed' ? 'teal' : x.st === 'Idea' ? 'peach' : 'lilac'}">${x.st}</span><button class="r star" data-n="${x.n}" aria-label="Watch" style="font-size:20px;color:${watch.has(x.n) ? '#e0b400' : 'var(--line-2)'}">★</button></div>
    <div class="idea-c"><h4>${x.n} — <em style="color:${x.col}">${x.p.toLowerCase()}</em></h4><span class="mono" style="color:var(--muted);font-size:10px">BY ${x.by.toUpperCase()}</span></div>
    <div style="display:flex;align-items:flex-end;gap:14px;margin:14px 0"><div><span class="mono" style="font-size:10px;color:var(--muted)">USERS</span><div class="c-title">${fmt(x.users)}</div></div><div style="flex:1">${Dash.spark(x.gr)}</div></div>
    <div class="prog"><i style="--w:${(x.raised / x.goal) * 100}%"></i></div>
    <div style="display:flex;justify-content:space-between;align-items:center;margin-top:12px"><span><b>₹${x.raised}L</b> <span class="muted">of ₹${x.goal}L</span></span><button class="b sm back-idea" data-i="${i}">Back idea</button></div></div>`;

  function backModal(x) {
    Dash.modal(`<p class="mono label">${x.sec} · ${x.st}</p><h3>Back <em>${x.n}.</em></h3><p class="muted">${x.p} — ${x.by}</p>
      <div class="g g-2" style="margin:20px 0">
        <div class="d-card" style="padding:16px"><span class="mono" style="font-size:10px;color:var(--muted)">YOUR PLEDGE</span><div class="c-title" style="font-size:44px">₹<span class="amt">2.0</span>L</div></div>
        <div class="d-card dark" style="padding:16px"><span class="mono" style="font-size:10px;color:var(--teal)">EST. EQUITY*</span><div class="c-title" style="font-size:44px"><span class="eq">1.6</span>%</div></div>
      </div>
      <div class="fld"><label>Amount (₹ lakh)</label><input type="range" min="0.5" max="10" step="0.5" value="2" class="rng" /></div>
      <div class="fld"><label>Note to founders</label><textarea placeholder="What excites you about this?"></textarea></div>
      <p class="muted" style="font-size:12px;margin-bottom:16px">*Illustrative only, at a ₹1.25Cr pre-money valuation. Final terms come in the term sheet.</p>
      <button class="b pledge">${icon('wallet')}Pledge ₹<span class="amt2">2.0</span>L</button>`, {
      onOpen(m, close) {
        const rng = $('.rng', m);
        const upd = () => { const v = +rng.value; $('.amt', m).textContent = v.toFixed(1); $('.amt2', m).textContent = v.toFixed(1); $('.eq', m).textContent = ((v / 125) * 100).toFixed(1); };
        rng.addEventListener('input', upd); upd();
        $('.pledge', m).onclick = () => { close(); x.raised = Math.min(x.goal, +(x.raised + +rng.value).toFixed(1)); const g = $('.deal-grid'); if (g) g.innerHTML = ideas.map(ideaCard).join(''); Dash.toast(`Pledged ₹${(+rng.value).toFixed(1)}L to ${x.n} — founders notified`, '🚀'); };
      },
    });
  }

  Dash.init({
    role: 'investor', roleName: 'Investor', color: '#6c5ce7',
    user: { name: 'Nikhil Varma', sub: 'Angel · Bengaluru', initials: 'NV', grad: 'linear-gradient(135deg,#6c5ce7,#c9b8ff)' },
    notifications: [
      { ic: '📈', t: 'Krishi crossed 1,800 farmers onboarded', s: '30 min ago' },
      { ic: '🎤', t: 'Pitch Day #7 starts Friday at 5 PM', s: 'Today' },
      { ic: '✨', t: '4 new ideas match your thesis (EdTech, Climate)', s: 'Yesterday' },
    ],
    actions: [{ label: 'Browse deal flow', ic: 'layers', run: () => Dash.go('deals') }, { label: 'Back Krishi', ic: 'wallet', run: () => backModal(ideas[0]) }],
    nav: [
      { id: 'overview', label: 'Overview', icon: 'home', group: 'Invest' },
      { id: 'deals', label: 'Deal flow', icon: 'layers', badge: ideas.length },
      { id: 'portfolio', label: 'Portfolio', icon: 'wallet' },
      { id: 'watch', label: 'Watchlist', icon: 'star', group: 'Founders' },
      { id: 'pitch', label: 'Pitch days', icon: 'calendar' },
    ],
    views: {
      overview: {
        title: ['Back ideas ', 'before they’re big.'], crumb: 'Overview',
        render: () => `
          <div class="g g-4">
            ${Dash.stat({ label: 'Total pledged', value: 5.3, dec: 1, prefix: '₹', suffix: 'L', delta: '₹2L this month', spark: [1, 1, 2, 2, 3, 3.5, 4, 5.3], ic: 'wallet' })}
            ${Dash.stat({ label: 'Portfolio value', value: 7.15, dec: 2, prefix: '₹', suffix: 'L', delta: '35% unrealised', spark: [1, 1.5, 2.4, 3, 3.8, 4.9, 6.2, 7.15], ic: 'trend' })}
            ${Dash.stat({ label: 'Ideas backed', value: 4, delta: '1 new', spark: [1, 1, 2, 2, 3, 3, 4], ic: 'sparkle' })}
            ${Dash.stat({ label: 'New this week', value: 23, delta: '8 match you', spark: [5, 8, 7, 12, 10, 15, 18, 23], ic: 'layers' })}
          </div>
          <div class="g g-21 mt">
            <div class="d-card rv"><div class="c-head"><span class="c-title">Portfolio <em>value</em></span><div class="r legend"><span><i style="background:#6c5ce7"></i>Value</span><span><i style="background:#9fd3ff"></i>Invested</span></div></div>
              ${Dash.chart([{ name: 'Value', color: '#6c5ce7', data: [0.5, 0.9, 1.6, 2.2, 2.9, 3.4, 4.1, 4.6, 5.2, 5.9, 6.4, 7.15] }, { name: 'Invested', color: '#5aa9e6', data: [0.5, 0.8, 1.3, 1.8, 2.3, 2.8, 3.3, 3.8, 4.2, 4.6, 5, 5.3] }], ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'], { unit: 'L' })}</div>
            <div class="d-card rv"><div class="c-head"><span class="c-title">By <em>sector</em></span></div>${Dash.donut([{ label: 'AgriTech', value: 2, color: '#2f8f7a', display: '₹2L' }, { label: 'FinTech', value: 1.5, color: '#0a66c2', display: '₹1.5L' }, { label: 'EdTech', value: 0.8, color: '#6c5ce7', display: '₹0.8L' }, { label: 'Consumer', value: 1, color: '#d4f56b', display: '₹1L' }], '4', 'startups')}</div>
          </div>
          <div class="d-card rv mt"><div class="c-head"><span class="c-title">Hot <em>this week</em></span><span class="r"><button class="b sm ghost go-deals">All ideas</button></span></div>
            <div class="g g-3">${ideas.slice(0, 3).map(ideaCard).join('')}</div></div>`,
        mount(r) { $('.go-deals', r).onclick = () => Dash.go('deals'); bindIdeas(r); },
      },
      deals: {
        title: ['Deal ', 'flow.'], crumb: 'Student ideas',
        render: () => `<div class="d-card rv" style="margin-bottom:16px;display:flex;gap:16px;flex-wrap:wrap;align-items:center">
            <div class="filters2 secs">${['All', 'AgriTech', 'EdTech', 'HealthTech', 'FinTech', 'Consumer', 'ClimateTech'].map((f, i) => `<button class="${i ? '' : 'on'}" data-f="${f}">${f}</button>`).join('')}</div>
            <div class="filters2 stages" style="margin-left:auto">${['Any stage', 'Idea', 'Pre-seed', 'Seed'].map((f, i) => `<button class="${i ? '' : 'on'}" data-f="${f}">${f}</button>`).join('')}</div></div>
          <div class="g g-3 deal-grid">${ideas.map(ideaCard).join('')}</div>`,
        mount(r) {
          let sec = 'All', st = 'Any stage';
          const apply = () => $$('.idea-card', r).forEach((c) => (c.style.display = (sec === 'All' || c.dataset.sec === sec) && (st === 'Any stage' || c.dataset.st === st) ? '' : 'none'));
          $$('.secs button', r).forEach((b) => (b.onclick = () => { sec = b.dataset.f; $$('.secs button', r).forEach((x) => x.classList.toggle('on', x === b)); apply(); }));
          $$('.stages button', r).forEach((b) => (b.onclick = () => { st = b.dataset.f; $$('.stages button', r).forEach((x) => x.classList.toggle('on', x === b)); apply(); }));
          bindIdeas(r);
        },
      },
      portfolio: {
        title: ['Your ', 'portfolio.'], crumb: 'Investments',
        render: () => `<div class="g g-3">
            ${Dash.stat({ label: 'Invested', value: 5.3, dec: 1, prefix: '₹', suffix: 'L', ic: 'wallet' })}
            ${Dash.stat({ label: 'Current value', value: 7.15, dec: 2, prefix: '₹', suffix: 'L', delta: '+₹1.85L', ic: 'trend' })}
            ${Dash.stat({ label: 'Best performer', value: 70, prefix: '+', suffix: '%', delta: 'Krishi', ic: 'star' })}</div>
          <div class="d-card rv mt"><div class="tbl-wrap"><table class="tbl"><thead><tr><th>Startup</th><th>Stage</th><th>Invested</th><th>Value</th><th>Change</th><th></th></tr></thead><tbody>
            ${portfolio.map((p) => `<tr><td><div class="who"><div class="sq" style="background:${(ideas.find((x) => x.n === p.n) || { col: '#999' }).col};width:36px;height:36px">${p.n[0]}</div><b>${p.n}</b></div></td><td><span class="chip2">${p.st}</span></td><td>₹${p.amt}L</td><td><b>₹${p.val}L</b></td><td><span class="delta ${p.ch < 0 ? 'down' : ''}">${p.ch < 0 ? '↓' : '↑'} ${Math.abs(p.ch)}%</span></td><td><button class="b sm ghost upd" data-n="${p.n}">Updates</button></td></tr>`).join('')}
          </tbody></table></div></div>`,
        mount(r) { $$('.upd', r).forEach((b) => (b.onclick = () => Dash.drawer(`<p class="mono label">Founder updates</p><h3 style="font-size:40px">${b.dataset.n}</h3>${['Crossed a new usage milestone this month 🎉', 'Hired our first full-time engineer from MSW Careers', 'Closed a pilot with a state agency'].map((u, i) => `<div class="d-card" style="margin-top:12px;padding:16px"><span class="mono" style="font-size:10px;color:var(--muted)">${['NOV 18', 'OCT 30', 'OCT 02'][i]}</span><p style="margin-top:6px">${u}</p></div>`).join('')}`))); },
      },
      watch: {
        title: ['Founder ', 'watchlist.'], crumb: 'Founders',
        render: () => `<div class="d-card rv"><div class="rows">${ideas.map((x) => `<div class="row"><div class="av" style="background:${x.col}">${x.by.split(' ')[0][0]}${x.by.split(' ')[1][0]}</div><div class="t"><b>${x.by.split(' · ')[0]}</b><small>${x.n} · ${x.by.split(' · ')[1]} · MSW Lvl ${10 + (x.users % 8)}</small></div><span class="chip2">${x.sec}</span><button class="b sm ${watch.has(x.n) ? 'done' : 'ghost'} w" data-n="${x.n}">${watch.has(x.n) ? 'Watching ★' : 'Watch'}</button><button class="b sm ghost intro" data-n="${x.n}">Request intro</button></div>`).join('')}</div></div>`,
        mount(r) {
          r.addEventListener('click', (e) => {
            const w = e.target.closest('.w'); if (w) { const n = w.dataset.n; watch.has(n) ? watch.delete(n) : watch.add(n); w.classList.toggle('done', watch.has(n)); w.classList.toggle('ghost', !watch.has(n)); w.textContent = watch.has(n) ? 'Watching ★' : 'Watch'; }
            const i = e.target.closest('.intro'); if (i && !i.classList.contains('done')) { i.classList.add('done'); i.textContent = 'Requested ✓'; Dash.toast(`Intro requested with ${i.dataset.n}’s founders`, '🤝'); }
          });
        },
      },
      pitch: {
        title: ['Pitch ', 'days.'], crumb: 'Events',
        render: () => `<div class="g g-3">${[['Pitch Day #7', 'Fri, Nov 28 · 5 PM', 'Online · 8 student startups', '#6c5ce7'], ['Demo Day — HackNova ’26', 'Mar 16 · 3 PM', 'Online · top 10 hackathon teams', '#1b1464'], ['Climate Founders Night', 'Apr 21 · 7 PM', 'Bengaluru · in person', '#0f3d2e']].map((p) => `
          <div class="d-card rv" style="background:${p[3]};color:#fff;border:0;min-height:260px;display:flex;flex-direction:column"><span class="mono" style="opacity:.7">${p[1]}</span><h3 style="font-size:40px;margin:14px 0 8px">${p[0]}</h3><p style="opacity:.75">${p[2]}</p><button class="b light rsvp" style="margin-top:auto;align-self:flex-start">RSVP</button></div>`).join('')}</div>`,
        mount(r) { $$('.rsvp', r).forEach((b) => (b.onclick = () => { const on = b.classList.toggle('lime'); b.textContent = on ? 'Going ✓' : 'RSVP'; if (on) Dash.toast('Added to your calendar', '📅'); })); },
      },
    },
  });

  function bindIdeas(r) {
    r.addEventListener('click', (e) => {
      const b = e.target.closest('.back-idea'); if (b) backModal(ideas[+b.dataset.i]);
      const s = e.target.closest('.star');
      if (s) { const n = s.dataset.n; watch.has(n) ? watch.delete(n) : watch.add(n); s.style.color = watch.has(n) ? '#e0b400' : 'var(--line-2)'; s.animate([{ transform: 'scale(1.6) rotate(20deg)' }, { transform: 'none' }], { duration: 500, easing: 'cubic-bezier(.22,1,.36,1)' }); Dash.toast(watch.has(n) ? `${n} added to watchlist` : `${n} removed`, '★'); }
    });
  }
})();
