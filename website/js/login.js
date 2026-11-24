/* MSW Community — login portal: role switching, morphing copy, fake submit */
(function () {
  const $ = (s, c = document) => c.querySelector(s);
  const $$ = (s, c = document) => [...c.querySelectorAll(s)];
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

  const ROLES = {
    student: {
      color: '#2f8f7a', eyebrow: 'Student portal', title: 'Welcome <em>back.</em>',
      sub: 'Pick up your streak, check new hackathons and see who viewed your ID.',
      email: 'College email', cta: 'Enter the community', oauth: true,
      quote: 'Learn, build <em>&amp; get discovered.</em>', qtext: 'Reels, hackathons, jobs and real company tasks — your whole college journey, verified on one ID.',
      card: ['✦', '12,400+ students', 'already building with MSW'], extra: '',
    },
    company: {
      color: '#ff7a59', eyebrow: 'Company portal', title: 'Hire by what <em>they’ve built.</em>',
      sub: 'Post jobs and internships, publish paid tasks and shortlist from verified student IDs.',
      email: 'Work email', cta: 'Open company dashboard', oauth: false,
      quote: 'Talent you can <em>actually verify.</em>', qtext: 'Every applicant comes with hackathon history, task reviews and a GitHub score.',
      card: ['◆', '640 companies', 'posted roles this month'],
      extra: '<div class="field"><input id="org" placeholder=" " /><label for="org">Company name</label></div>',
    },
    investor: {
      color: '#6c5ce7', eyebrow: 'Investor portal', title: 'Find founders <em>early.</em>',
      sub: 'Browse student ideas with real traction, pledge to the ones you believe in and track your portfolio.',
      email: 'Email', cta: 'View deal flow', oauth: false,
      quote: 'Back the idea <em>before it’s big.</em>', qtext: '1,280 student ideas, each tied to a verified founder ID and build history.',
      card: ['₹', '₹4.2Cr pledged', 'across 312 investors'],
      extra: '<div class="field-row"><div class="field"><input id="firm" placeholder=" " /><label for="firm">Fund / Angel</label></div><div class="field"><select id="ticket"><option>₹1L – ₹10L</option><option>₹10L – ₹50L</option><option>₹50L+</option></select><label for="ticket">Ticket size</label></div></div>',
    },
    college: {
      color: '#0a66c2', eyebrow: 'College & organiser portal', title: 'Host it. <em>We’ll handle it.</em>',
      sub: 'Run hackathons and events, verify your students and see placement insights in one place.',
      email: 'Institution email', cta: 'Go to campus dashboard', oauth: false,
      quote: 'Your campus, <em>on the map.</em>', qtext: 'Registrations, teams, judging and certificates — done for you.',
      card: ['⚡', '210 hackathons', 'hosted with MSW'],
      extra: '<div class="field"><input id="inst" placeholder=" " /><label for="inst">Institution / Club name</label></div>',
    },
    admin: {
      color: '#121212', eyebrow: 'Mission control', title: 'Admin <em>access.</em>',
      sub: 'Allocate tasks, run quizzes and badges, approve contributions and moderate the platform.',
      email: 'Admin email', cta: 'Unlock control panel', oauth: false,
      quote: 'Every community needs <em>a centre.</em>', qtext: 'Full control over tasks, quizzes, badges, contributions and users.',
      card: ['◎', 'Restricted area', '2-factor required'],
      extra: '<div class="field"><input id="otp" inputmode="numeric" maxlength="6" placeholder=" " /><label for="otp">6-digit 2FA code</label></div>',
    },
  };
  const order = Object.keys(ROLES);

  const dots = Halftone($('#authDots'), { swirlX: 1.1, swirlY: 0.75 });
  const pill = $('.role-pill');
  let current = null;

  async function setRole(role, instant) {
    if (!ROLES[role] || role === current) return;
    current = role; const R = ROLES[role];
    document.documentElement.style.setProperty('--rc', R.color);
    $$('.roles button').forEach((b) => b.classList.toggle('active', b.dataset.role === role));
    if (instant) { pill.style.transition = 'none'; requestAnimationFrame(() => requestAnimationFrame(() => (pill.style.transition = ''))); }
    pill.style.transform = `translateX(${order.indexOf(role) * 100}%)`;
    history.replaceState(null, '', `?role=${role}`);
    const swaps = $$('.swap');
    if (!instant) { swaps.forEach((s) => s.classList.add('out')); await sleep(300); }
    $('.h-eyebrow').textContent = R.eyebrow;
    $('.h-title').innerHTML = R.title;
    $('.h-sub').textContent = R.sub;
    $('.email-label').textContent = R.email;
    $('.submit-text').textContent = R.cta;
    $('.q-title').innerHTML = R.quote;
    $('.q-text').textContent = R.qtext;
    $('.rc-ic').textContent = R.card[0]; $('.rc-title').textContent = R.card[1]; $('.rc-sub').textContent = R.card[2];
    $('#extra').innerHTML = R.extra;
    $('#extra').style.display = R.extra ? '' : 'none';
    $$('.oauth-wrap').forEach((el) => (el.style.display = R.oauth ? '' : 'none'));
    swaps.forEach((s) => s.classList.remove('out'));
  }

  $$('.roles button').forEach((b) => b.addEventListener('click', () => setRole(b.dataset.role)));
  const initial = new URLSearchParams(location.search).get('role');
  setRole(ROLES[initial] ? initial : 'student', true);

  $('#form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = $('.submit');
    btn.classList.add('loading'); $('.submit-text').textContent = 'Authenticating…';
    await sleep(1400);
    btn.classList.remove('loading');
    const dash = { student: 'student.html', company: 'company.html', investor: 'investor.html', admin: 'admin.html', college: 'college.html' }[current];
    $('.succ-text').textContent = dash ? `Opening your ${ROLES[current].eyebrow.toLowerCase()} dashboard…` : `${ROLES[current].eyebrow} — the dashboard is next on the build list. This is a UI preview.`;
    $('#success').classList.add('show');
    if (dash) setTimeout(() => (location.href = dash), 1300);
  });

  /* minimal cursor on this page */
  const cur = $('.cursor');
  if (cur && matchMedia('(hover: hover) and (pointer: fine)').matches) {
    const dot = $('.c-dot'), ring = $('.c-ring'); let mx = 0, my = 0, rx = 0, ry = 0;
    addEventListener('pointermove', (e) => { mx = e.clientX; my = e.clientY; });
    (function loop() { rx += (mx - rx) * 0.16; ry += (my - ry) * 0.16; dot.style.transform = `translate(${mx}px,${my}px)`; ring.style.transform = `translate(${rx}px,${ry}px)`; requestAnimationFrame(loop); })();
    document.addEventListener('pointerover', (e) => cur.classList.toggle('is-link', !!e.target.closest('a,button,input,select,label')));
  }
})();
