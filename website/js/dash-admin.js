/* MSW Community — Admin / mission control */
(function () {
  const { $, $$, icon, esc, fmt } = Dash;
  const students = ['Aanya Sharma', 'Rohan Kapoor', 'Meera Joshi', 'Arjun Rao', 'Sana Khan', 'Rhea Pillai', 'Dev Shah'];
  const tcard = (t) => `<div class="kb-card" draggable="true"><div class="top"><span class="chip2 ${t.p === 'High' ? 'red' : t.p === 'Med' ? 'peach' : 'sky'}" style="font-size:10px;padding:2px 8px">${t.p}</span><span class="mono" style="margin-left:auto;font-size:10px;color:var(--muted)">${t.src}</span></div><b>${esc(t.t)}</b><div class="meta"><span>${t.who ? '👤 ' + esc(t.who) : 'Unassigned'}</span><span>₹${fmt(t.r)}</span></div></div>`;
  const tasks = {
    open: [{ t: 'Write Day 14 challenge tests', p: 'High', src: 'MSW LABS', r: 1500 }, { t: 'Design HackNova certificate', p: 'Med', src: 'EVENTS', r: 2000 }, { t: 'Translate Day 1–5 reels to Hindi', p: 'Low', src: 'MSW LABS', r: 3000 }],
    assigned: [{ t: 'Moderate #InternshipSeason', p: 'Med', src: 'COMMUNITY', r: 800, who: 'Sana Khan' }, { t: 'Fix checkout bug (Helio)', p: 'High', src: 'COMPANY', r: 3000, who: 'Aanya Sharma' }],
    review: [{ t: 'Accessibility audit (Lumen Labs)', p: 'Med', src: 'COMPANY', r: 4500, who: 'Rhea Pillai' }],
    done: [{ t: 'Data cleaning (Kite AI)', p: 'Low', src: 'COMPANY', r: 2200, who: 'Meera Joshi' }],
  };
  let quizzes = [
    { n: 'IQ test', q: 5, t: 3, plays: 4210, live: true },
    { n: 'Reasoning', q: 10, t: 6, plays: 2890, live: true },
    { n: 'Daily quiz — Nov 23', q: 5, t: 2, plays: 1120, live: true },
    { n: 'Aptitude', q: 15, t: 10, plays: 1840, live: true },
    { n: 'React fundamentals', q: 12, t: 8, plays: 0, live: false },
  ];
  const quizRow = (q, i) => `<tr data-i="${i}"><td><b>${esc(q.n)}</b></td><td>${q.q}</td><td>${q.t} min</td><td>${fmt(q.plays)}</td><td><button class="tg ${q.live ? 'on' : ''}"></button></td></tr>`;
  const users = [
    ['Aanya Sharma', 'Student', 'IIT Delhi', 'Active'], ['Lumen Labs', 'Company', 'Bengaluru', 'Verified'], ['Nikhil Varma', 'Investor', 'Angel', 'Verified'], ['IIT Bombay — E-Cell', 'College', 'Mumbai', 'Verified'],
    ['Rohan Kapoor', 'Student', 'NIT Trichy', 'Active'], ['Kite AI', 'Company', 'Bengaluru', 'Pending'], ['spam_bot_221', 'Student', '—', 'Suspended'], ['Meera Joshi', 'Student', 'IIT KGP', 'Active'],
  ];
  const roleCol = { Student: 'teal', Company: 'peach', Investor: 'lilac', College: 'sky' };
  const statusChip = (s) => `<span class="chip2 ${s === 'Suspended' ? 'red' : s === 'Pending' ? 'peach' : 'teal'}">${s}</span>`;
  const events = [
    ['🎓', 'New student signed up', 'Ishaan M. · IIT Delhi'], ['💼', 'Kite AI posted a role', 'ML Research Intern'], ['🚀', 'Idea pledged', 'Nikhil V. → Krishi · ₹2L'], ['✅', 'Task submitted', 'Rhea P. · Accessibility audit'],
    ['🔥', 'Day 30 completed', 'Sana K. finished MSW Labs'], ['🏆', 'Hackathon registered', 'Team Byte Me · HackNova'], ['📝', 'New post', 'Arjun R. shared a LinkedIn link'], ['🧠', 'IQ test finished', 'Dev S. scored 118'],
  ];

  function newTaskModal() {
    Dash.modal(`<p class="mono label">Task allocation</p><h3>New <em>task.</em></h3>
      <div class="fld"><label>Task</label><input class="t" placeholder="e.g. Record Day 15 reel voice-over" /></div>
      <div class="fld-row"><div class="fld"><label>Source</label><select class="s"><option>MSW LABS</option><option>EVENTS</option><option>COMMUNITY</option><option>COMPANY</option></select></div><div class="fld"><label>Priority</label><select class="p"><option>High</option><option selected>Med</option><option>Low</option></select></div></div>
      <div class="fld-row"><div class="fld"><label>Reward (₹)</label><input class="r" type="number" value="1500" /></div><div class="fld"><label>Assign to</label><select class="w"><option value="">Leave open</option>${students.map((s) => `<option>${s}</option>`).join('')}</select></div></div>
      <button class="b go">${icon('task')}Create & allocate</button>`, {
      onOpen(m, close) {
        $('.go', m).onclick = () => {
          const t = { t: $('.t', m).value || 'Untitled task', src: $('.s', m).value, p: $('.p', m).value, r: +$('.r', m).value || 0, who: $('.w', m).value };
          const col = $(`.kb-col[data-col="${t.who ? 'assigned' : 'open'}"]`);
          if (col) { col.insertAdjacentHTML('beforeend', tcard(t)); $('h6 b', col).textContent = $$('.kb-card', col).length; } else tasks[t.who ? 'assigned' : 'open'].push(t);
          close(); Dash.toast(t.who ? `Allocated to ${t.who}` : 'Task posted to the open board', '⚡');
        };
      },
    });
  }

  function quizBuilder() {
    Dash.modal(`<p class="mono label">Quiz builder</p><h3>Build a <em>quiz.</em></h3>
      <div class="fld-row"><div class="fld"><label>Quiz name</label><input class="qn" value="JavaScript basics" /></div><div class="fld"><label>Time limit (min)</label><input class="qt" type="number" value="5" /></div></div>
      <div class="qs"></div>
      <button class="b ghost add-q" style="margin-bottom:16px">${icon('plus')}Add question</button>
      <div class="fld"><label>Badge on completion</label><select><option>🧠 Sharp Mind</option><option>⚡ Quick Thinker</option><option>🏅 JS Rookie</option></select></div>
      <button class="b pub">${icon('upload')}Publish quiz</button>`, {
      wide: true,
      onOpen(m, close) {
        let n = 0;
        const addQ = () => {
          n++;
          $('.qs', m).insertAdjacentHTML('beforeend', `<div class="d-card" style="padding:16px;margin-bottom:12px;animation:kin .5s var(--ease)"><div class="fld"><label>Question ${n}</label><input placeholder="Type the question…" /></div>
            <div class="fld-row">${['A', 'B', 'C', 'D'].map((l, i) => `<div class="fld" style="margin:0 0 8px"><label><input type="radio" name="ans${n}" ${i ? '' : 'checked'} style="width:auto;margin-right:6px"/>Option ${l}${i ? '' : ' (correct)'}</label><input placeholder="Answer ${l}" /></div>`).join('')}</div></div>`);
        };
        addQ(); addQ();
        $('.add-q', m).onclick = addQ;
        $('.pub', m).onclick = () => {
          quizzes.unshift({ n: $('.qn', m).value || 'New quiz', q: n, t: +$('.qt', m).value || 5, plays: 0, live: true });
          close(); const tb = $('.quiz-tbody'); if (tb) tb.innerHTML = quizzes.map(quizRow).join('');
          Dash.toast('Quiz published to the app and website', '🧠');
        };
      },
    });
  }

  Dash.init({
    role: 'admin', roleName: 'Admin', color: '#121212',
    user: { name: 'MSW Admin', sub: 'Mission control', initials: 'M.', grad: 'linear-gradient(135deg,#121212,#2f8f7a)' },
    notifications: [
      { ic: '⚠️', t: '3 posts reported in the last hour', s: 'Moderation' },
      { ic: '🏛', t: 'IIT Bombay E-Cell requested a hackathon', s: 'Approvals' },
      { ic: '🏢', t: 'Kite AI is waiting for verification', s: 'Approvals' },
    ],
    actions: [{ label: 'Create & allocate a task', ic: 'task', run: newTaskModal }, { label: 'Build a quiz', ic: 'brain', run: quizBuilder }, { label: 'Review approvals', ic: 'shield', run: () => Dash.go('approvals') }],
    nav: [
      { id: 'overview', label: 'Overview', icon: 'home', group: 'Control' },
      { id: 'tasks', label: 'Task allocation', icon: 'task', badge: 7 },
      { id: 'quizzes', label: 'Quizzes & badges', icon: 'brain' },
      { id: 'approvals', label: 'Approvals', icon: 'shield', badge: 6, group: 'Community' },
      { id: 'users', label: 'Users', icon: 'users' },
      { id: 'moderation', label: 'Moderation', icon: 'flag', badge: 3 },
    ],
    views: {
      overview: {
        title: ['Mission ', 'control.'], crumb: 'Overview',
        render: () => `
          <div class="g g-4">
            ${Dash.stat({ label: 'Students', value: 12460, delta: '612 this week', spark: [4, 5, 6, 7, 8, 9, 10, 11, 12.4], ic: 'users' })}
            ${Dash.stat({ label: 'Companies', value: 640, delta: '38 this week', spark: [2, 3, 3, 4, 4, 5, 6, 6.4], ic: 'briefcase' })}
            ${Dash.stat({ label: 'Colleges', value: 124, delta: '6 new', spark: [3, 4, 5, 7, 8, 10, 11, 12.4], ic: 'globe' })}
            ${Dash.stat({ label: 'Investors', value: 312, delta: '₹4.2Cr pledged', spark: [1, 1.5, 2, 2.2, 2.6, 2.9, 3.1], ic: 'wallet' })}
          </div>
          <div class="g g-21 mt">
            <div class="d-card rv"><div class="c-head"><span class="c-title">Sign-ups</span><div class="r legend"><span><i style="background:#121212"></i>Students</span><span><i style="background:#2f8f7a"></i>Orgs</span></div></div>
              ${Dash.chart([{ name: 'Students', color: '#121212', data: [180, 240, 210, 320, 380, 360, 440, 520, 480, 590, 640, 612] }, { name: 'Orgs', color: '#2f8f7a', data: [8, 12, 10, 15, 18, 17, 22, 26, 24, 31, 36, 44] }], ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'])}</div>
            <div class="d-card dark rv"><div class="c-head"><span class="c-title">Live <em>activity</em></span><span class="r" style="display:flex;align-items:center;gap:6px;font-size:12px"><span class="pulse"></span>LIVE</span></div><div class="rows feed-live"></div></div>
          </div>
          <div class="g g-3 mt">
            <div class="d-card rv"><div class="c-head"><span class="c-title">MSW Labs <em>funnel</em></span></div>${Dash.bars([{ label: 'Day 1', value: 9800 }, { label: 'Day 7', value: 7200 }, { label: 'Day 14', value: 5100 }, { label: 'Day 21', value: 3900 }, { label: 'Day 30', value: 2640 }])}</div>
            <div class="d-card rv" style="display:flex;flex-direction:column;align-items:center;gap:12px;text-align:center"><div class="c-head" style="width:100%"><span class="c-title">Platform <em>health</em></span></div>${Dash.ring(0.998, '99.8', 'uptime %')}<p class="muted" style="font-size:13px">API 142ms · 0 incidents this week</p></div>
            <div class="d-card lime rv"><div class="c-head"><span class="c-title">Needs <em>you</em></span></div><div class="rows">
              <div class="row" style="border-color:rgba(0,0,0,.08)"><b style="width:28px">6</b><div class="t">Approvals waiting</div><button class="b sm go" data-v="approvals">Open</button></div>
              <div class="row" style="border-color:rgba(0,0,0,.08)"><b style="width:28px">3</b><div class="t">Reported posts</div><button class="b sm go" data-v="moderation">Open</button></div>
              <div class="row" style="border:0"><b style="width:28px">3</b><div class="t">Unassigned tasks</div><button class="b sm go" data-v="tasks">Open</button></div></div></div>
          </div>`,
        mount(r) {
          $$('.go', r).forEach((b) => (b.onclick = () => Dash.go(b.dataset.v)));
          const box = $('.feed-live', r); let k = 0;
          const push = () => {
            const e = events[k++ % events.length];
            box.insertAdjacentHTML('afterbegin', `<div class="row" style="border-color:rgba(255,255,255,.08)"><span class="n-ic" style="background:rgba(255,255,255,.08)">${e[0]}</span><div class="t"><b>${e[1]}</b><small class="muted">${e[2]} · just now</small></div></div>`);
            const rows = $$('.row', box); if (rows.length > 6) rows[rows.length - 1].remove();
          };
          for (let i = 0; i < 5; i++) push();
          setInterval(push, 2600);
        },
      },
      tasks: {
        title: ['Task ', 'allocation.'], crumb: 'Drag tasks between columns',
        render: () => `<div class="rv" style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;gap:12px;flex-wrap:wrap"><div class="filters2">${['All', 'MSW Labs', 'Events', 'Company', 'Community'].map((f, i) => `<button class="${i ? '' : 'on'}">${f}</button>`).join('')}</div><button class="b new-t">${icon('plus')}New task</button></div>
          <div class="rv">${Dash.kanban([
            { id: 'open', title: 'Open', cards: tasks.open.map(tcard) },
            { id: 'assigned', title: 'Assigned', cards: tasks.assigned.map(tcard) },
            { id: 'review', title: 'In review', cards: tasks.review.map(tcard) },
            { id: 'done', title: 'Done & paid', cards: tasks.done.map(tcard) },
          ])}</div>`,
        mount(r) {
          $('.new-t', r).onclick = newTaskModal;
          $$('.filters2 button', r).forEach((b) => (b.onclick = () => {
            $$('.filters2 button', r).forEach((x) => x.classList.toggle('on', x === b));
            const f = b.textContent.toUpperCase();
            $$('.kb-card', r).forEach((c) => (c.style.display = f === 'ALL' || $('.mono', c).textContent === f ? '' : 'none'));
          }));
          Dash.dnd(r, (card, to) => {
            if (to === 'assigned' && card.querySelector('.meta span').textContent === 'Unassigned') {
              const who = students[Math.floor(Math.random() * students.length)];
              card.querySelector('.meta span').textContent = '👤 ' + who;
              Dash.toast(`Auto-assigned to ${who} (best match)`, '⚡');
            } else Dash.toast(to === 'done' ? 'Marked done — payout queued' : `Moved to ${{ open: 'Open', assigned: 'Assigned', review: 'In review', done: 'Done' }[to]}`, to === 'done' ? '💸' : '→');
          });
        },
      },
      quizzes: {
        title: ['Quizzes ', '& badges.'], crumb: 'Engine',
        render: () => `<div class="g g-21">
          <div class="d-card rv"><div class="c-head"><span class="c-title">Quizzes</span><span class="r"><button class="b build">${icon('plus')}Build a quiz</button></span></div>
            <div class="tbl-wrap"><table class="tbl"><thead><tr><th>Quiz</th><th>Questions</th><th>Time</th><th>Plays</th><th>Live</th></tr></thead><tbody class="quiz-tbody">${quizzes.map(quizRow).join('')}</tbody></table></div></div>
          <div class="d-card rv"><div class="c-head"><span class="c-title">Badges</span><span class="r"><button class="b sm ghost nb">${icon('plus')}New</button></span></div>
            <div class="g g-2 badges" style="gap:10px">${[['🔥', '12-day streak', 3120], ['🏆', 'Hackathon winner', 214], ['🧠', 'IQ 120+', 1980], ['⚡', 'First task', 2400], ['🚀', 'Shipped capstone', 2640], ['💎', 'Top 1%', 124]].map((b) => `<div style="background:var(--bg);border-radius:16px;padding:14px;text-align:center"><div style="font-size:30px">${b[0]}</div><b style="font-size:13px;display:block;margin-top:4px">${b[1]}</b><small class="muted">${fmt(b[2])} earned</small></div>`).join('')}</div></div></div>`,
        mount(r) {
          $('.build', r).onclick = quizBuilder;
          r.addEventListener('click', (e) => { const tg = e.target.closest('.tg'); if (!tg) return; const q = quizzes[+tg.closest('tr').dataset.i]; q.live = !q.live; tg.classList.toggle('on', q.live); Dash.toast(`${q.n} is ${q.live ? 'live' : 'hidden'}`); });
          $('.nb', r).onclick = () => Dash.modal(`<p class="mono label">Badge</p><h3>New <em>badge.</em></h3><div class="fld-row"><div class="fld"><label>Emoji</label><input class="be" value="🌟" /></div><div class="fld"><label>Name</label><input class="bn" value="Community hero" /></div></div><div class="fld"><label>Earned when…</label><select><option>Completes a quiz</option><option>Wins a hackathon</option><option>Ships 5 tasks</option><option>Refers 10 friends</option></select></div><button class="b mk">Create badge</button>`, { onOpen(m, close) { $('.mk', m).onclick = () => { $('.badges', r).insertAdjacentHTML('afterbegin', `<div style="background:var(--lime);border-radius:16px;padding:14px;text-align:center;animation:kin .5s var(--ease)"><div style="font-size:30px">${esc($('.be', m).value)}</div><b style="font-size:13px;display:block;margin-top:4px">${esc($('.bn', m).value)}</b><small>0 earned</small></div>`); close(); Dash.toast('Badge created'); }; } });
        },
      },
      approvals: {
        title: ['Approval ', 'queue.'], crumb: 'Contributions · events · verification',
        render: () => `<div class="g g-3">${[
          ['Contribution', '🎬', 'Day 15 reel script — Hooks deep-dive', 'Sana Khan · MSW Labs mentor', 'lilac'],
          ['Contribution', '🧩', '12 new reasoning questions', 'Ishaan M. · IIT Delhi', 'lilac'],
          ['Event', '🏛', 'E-Summit Hackathon (Jan 18–19)', 'IIT Bombay E-Cell · 600 seats', 'sky'],
          ['Event', '🌱', 'Green Code Sprint', 'BITS Pilani ACM · online', 'sky'],
          ['Company', '🏢', 'Verify Kite AI', 'kite.ai · 40 employees · GST verified', 'peach'],
          ['Investor', '💼', 'Verify Ananya Capital', 'Angel syndicate · 12 members', 'teal'],
        ].map((a) => `<div class="d-card rv appr"><div class="c-head"><span class="chip2 ${a[4]}">${a[0]}</span><span class="r" style="font-size:28px">${a[1]}</span></div><div class="c-title" style="font-size:26px;line-height:1.05">${a[2]}</div><p class="c-sub" style="margin:8px 0 18px">${a[3]}</p>
          <div style="display:flex;gap:8px"><button class="b sm ok">${icon('check')}Approve</button><button class="b sm ghost no">Decline</button></div></div>`).join('')}</div>`,
        mount(r) {
          r.addEventListener('click', async (e) => {
            const ok = e.target.closest('.ok'), no = e.target.closest('.no'); const c = (ok || no)?.closest('.appr'); if (!c) return;
            const name = $('.c-title', c).textContent;
            await Dash.flyOut(c, !!no);
            Dash.toast(ok ? `Approved: ${name}` : `Declined: ${name}`, ok ? '✓' : '✕');
            if (!$$('.appr', r).length) r.innerHTML = '<div class="d-card empty">Inbox zero. Nothing waiting for approval ✨</div>';
          });
        },
      },
      users: {
        title: ['All ', 'users.'], crumb: 'Directory',
        render: () => `<div class="d-card rv"><div style="display:flex;gap:12px;flex-wrap:wrap;margin-bottom:14px"><div class="fld" style="margin:0;flex:1;min-width:220px"><input class="q" placeholder="Search users…" /></div><div class="filters2 rf">${['All', 'Student', 'Company', 'Investor', 'College'].map((f, i) => `<button class="${i ? '' : 'on'}">${f}</button>`).join('')}</div></div>
          <div class="tbl-wrap"><table class="tbl"><thead><tr><th>User</th><th>Role</th><th>Where</th><th>Status</th><th></th></tr></thead><tbody>${users.map((u, i) => `<tr data-role="${u[1]}" data-s="${esc(u.join(' ').toLowerCase())}"><td><div class="who"><div class="av sm" style="background:linear-gradient(135deg,#2f8f7a,#c9b8ff)">${u[0][0]}</div><b>${esc(u[0])}</b></div></td><td><span class="chip2 ${roleCol[u[1]]}">${u[1]}</span></td><td>${esc(u[2])}</td><td class="st">${statusChip(u[3])}</td><td><button class="b sm ghost sus" data-i="${i}">${u[3] === 'Suspended' ? 'Restore' : 'Suspend'}</button></td></tr>`).join('')}</tbody></table></div></div>`,
        mount(r) {
          let role = 'All';
          const apply = () => { const q = $('.q', r).value.toLowerCase(); $$('tbody tr', r).forEach((tr) => (tr.style.display = (role === 'All' || tr.dataset.role === role) && tr.dataset.s.includes(q) ? '' : 'none')); };
          $('.q', r).addEventListener('input', apply);
          $$('.rf button', r).forEach((b) => (b.onclick = () => { role = b.textContent; $$('.rf button', r).forEach((x) => x.classList.toggle('on', x === b)); apply(); }));
          r.addEventListener('click', (e) => {
            const b = e.target.closest('.sus'); if (!b) return; const u = users[+b.dataset.i];
            u[3] = u[3] === 'Suspended' ? 'Active' : 'Suspended';
            b.closest('tr').querySelector('.st').innerHTML = statusChip(u[3]); b.textContent = u[3] === 'Suspended' ? 'Restore' : 'Suspend';
            Dash.toast(`${u[0]} ${u[3] === 'Suspended' ? 'suspended' : 'restored'}`, u[3] === 'Suspended' ? '⛔' : '✓');
          });
        },
      },
      moderation: {
        title: ['Content ', 'moderation.'], crumb: 'Reported posts',
        render: () => `<div class="g g-3">${[
          ['Spam', 'spam_bot_221', '🔥 Get 10,000 followers in 1 day!!! click here →', 14],
          ['Harassment', 'anon_user_77', 'Replying to Meera: nobody asked for your opinion lol', 6],
          ['Off-topic', 'Dev Shah', 'Selling my old cycle, DM me 🚲', 2],
        ].map((p) => `<div class="d-card rv rep"><div class="c-head"><span class="chip2 red">${p[0]}</span><span class="r mono" style="font-size:10px;color:var(--muted)">${p[3]} REPORTS</span></div><b style="display:block;margin-bottom:6px">@${esc(p[1])}</b><p style="background:var(--bg);border-radius:14px;padding:12px;font-size:14px;margin-bottom:16px">${esc(p[2])}</p>
          <div style="display:flex;gap:8px;flex-wrap:wrap"><button class="b sm danger rm">Remove post</button><button class="b sm ghost keep">Keep</button><button class="b sm ghost ban">Ban user</button></div></div>`).join('')}</div>`,
        mount(r) {
          r.addEventListener('click', async (e) => {
            const b = e.target.closest('.rm,.keep,.ban'); if (!b) return; const c = b.closest('.rep');
            await Dash.flyOut(c, b.classList.contains('keep'));
            Dash.toast(b.classList.contains('rm') ? 'Post removed' : b.classList.contains('ban') ? 'User banned and post removed' : 'Post kept — reporters notified', b.classList.contains('keep') ? '✓' : '🛡');
            if (!$$('.rep', r).length) r.innerHTML = '<div class="d-card empty">No reports. The community is behaving 🌱</div>';
          });
        },
      },
    },
  });
})();
