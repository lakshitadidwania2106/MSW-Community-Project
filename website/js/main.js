/* =========================================================
   MSW Community — interactions & motion
   ========================================================= */
(function () {
  const $ = (s, c = document) => c.querySelector(s);
  const $$ = (s, c = document) => [...c.querySelectorAll(s)];
  const clamp = (v, a = 0, b = 1) => Math.min(b, Math.max(a, v));
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const fine = matchMedia('(hover: hover) and (pointer: fine)').matches;
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

  /* ---------- smooth scroll ---------- */
  let lenis = null;
  if (window.Lenis && !reduce) {
    lenis = new Lenis({ lerp: 0.09, smoothWheel: true });
    const raf = (t) => { lenis.raf(t); requestAnimationFrame(raf); };
    requestAnimationFrame(raf);
  }
  const goTo = (target) => (lenis ? lenis.scrollTo(target, { duration: 1.6 }) : (typeof target === 'number' ? window.scrollTo({ top: target, behavior: 'smooth' }) : target.scrollIntoView({ behavior: 'smooth' })));
  $$('a[href^="#"]').forEach((a) => a.addEventListener('click', (e) => {
    const id = a.getAttribute('href');
    e.preventDefault(); document.body.classList.remove('menu-open');
    if (id === '#') return goTo(0);
    const el = $(id); if (el) goTo(el);
  }));

  /* ---------- split text ---------- */
  function splitEl(el) {
    let i = 0; const frag = document.createDocumentFragment();
    const make = (text, tag) => text.split(/(\s+)/).forEach((part) => {
      if (!part) return;
      if (/^\s+$/.test(part)) return frag.appendChild(document.createTextNode(' '));
      const w = document.createElement('span'); w.className = 'w';
      const wi = document.createElement('span'); wi.className = 'wi'; wi.style.setProperty('--i', i++);
      if (tag) { const e = document.createElement(tag); e.textContent = part; wi.appendChild(e); } else wi.textContent = part;
      w.appendChild(wi); frag.appendChild(w);
    });
    [...el.childNodes].forEach((n) => {
      if (n.nodeType === 3) make(n.textContent);
      else if (n.tagName === 'BR') frag.appendChild(n.cloneNode());
      else make(n.textContent, n.tagName.toLowerCase());
    });
    el.innerHTML = ''; el.appendChild(frag);
  }
  $$('.split').forEach(splitEl);

  /* ---------- preloader ---------- */
  const pre = $('.preloader');
  function finishLoad() {
    document.body.classList.remove('is-loading');
    document.body.classList.add('loaded');
    $$('.hero .split, .hero .reveal-up').forEach((el) => el.classList.add('in'));
  }
  if (pre) {
    const cnt = $('.pl-count'), start = performance.now(), dur = reduce ? 200 : 2600;
    // community photo collage: pictures pop in one after another across the screen
    const box = $('.pl-photos'), photos = (window.MSW_PHOTOS || []).slice(0, 12), imgs = [];
    if (box && !reduce) photos.forEach((src, i) => {
      const im = new Image(); im.src = src; im.alt = '';
      const ang = i * 2.4, rad = 0.35 + (i % 3) * 0.22;
      im.style.setProperty('--dx', `${Math.cos(ang) * innerWidth * 0.34 * rad}px`);
      im.style.setProperty('--dy', `${Math.sin(ang) * innerHeight * 0.3 * rad}px`);
      im.style.setProperty('--r', `${(Math.random() - 0.5) * 16}deg`);
      if (i === photos.length - 1) { im.style.setProperty('--dx', '0px'); im.style.setProperty('--dy', '0px'); }
      box.appendChild(im); imgs.push(im);
    });
    (function tick(now) {
      const k = clamp((now - start) / dur), e = 1 - Math.pow(1 - k, 3);
      cnt.textContent = String(Math.round(e * 100)).padStart(3, '0');
      pre.style.setProperty('--pl', e);
      const shown = Math.floor(k * 1.08 * imgs.length);
      imgs.forEach((im, i) => { if (i < shown) im.classList.add('show'); });
      if (k < 1) return requestAnimationFrame(tick);
      const outDelay = imgs.length ? 900 : 0;
      if (imgs.length) box.classList.add('zoom');
      setTimeout(() => { pre.classList.add('done'); setTimeout(finishLoad, 350); setTimeout(() => pre.remove(), 1300); }, outDelay);
    })(start);
  } else finishLoad();

  /* ---------- ecosystem: cursor-following photo preview ---------- */
  const prev = $('.eco-preview');
  if (prev && fine) {
    const pim = $('img', prev), P = window.MSW_PHOTOS || [];
    let px = 0, py = 0, tx = 0, ty = 0, on = false;
    $$('.eco').forEach((row) => {
      row.addEventListener('pointerenter', () => { pim.src = P[+row.dataset.img % P.length] || ''; prev.classList.add('on'); on = true; });
      row.addEventListener('pointerleave', () => { prev.classList.remove('on'); on = false; });
    });
    addEventListener('pointermove', (e) => { tx = e.clientX + 170; ty = e.clientY; });
    (function follow() { px += (tx - px) * 0.12; py += (ty - py) * 0.12; if (on) { prev.style.left = `${px}px`; prev.style.top = `${py}px`; } requestAnimationFrame(follow); })();
  }

  /* ---------- social mosaic (3 drifting rows of community photos) ---------- */
  const mosaic = $('.mosaic');
  if (mosaic) {
    const P = window.MSW_PHOTOS || [], ars = [1.5, 1.1, 1.8, 0.8, 1.3, 1.6];
    for (let r = 0; r < 3; r++) {
      const row = document.createElement('div'); row.className = 'm-row';
      const track = document.createElement('div'); track.className = 'm-track';
      const set = Array.from({ length: 6 }, (_, i) => P[(r * 6 + i) % P.length]);
      [...set, ...set].forEach((src, i) => {
        const im = new Image(); im.src = src; im.alt = ''; im.loading = 'lazy';
        im.style.setProperty('--ar', ars[(i + r * 2) % ars.length]); track.appendChild(im);
      });
      row.appendChild(track); mosaic.appendChild(row);
    }
  }

  /* ---------- reveal on view ---------- */
  $$('.bento .card').forEach((c, i) => c.style.setProperty('--d', `${(i % 3) * 0.08}s`));
  $$('.soc, .eco, .plan').forEach((c, i) => c.style.setProperty('--d', `${(i % 3) * 0.08}s`));
  const io = new IntersectionObserver((entries) => entries.forEach((e) => {
    if (!e.isIntersecting) return;
    e.target.classList.add('in');
    if (e.target.matches('.count')) countUp(e.target);
    $$('.count', e.target).forEach(countUp);
    io.unobserve(e.target);
  }), { threshold: 0.18, rootMargin: '0px 0px -5% 0px' });
  $$('.split, .reveal, .reveal-up, .count, .idea').forEach((el) => { if (!el.closest('.hero')) io.observe(el); });

  function countUp(el) {
    if (el.dataset.done) return; el.dataset.done = 1;
    const to = +el.dataset.to, start = performance.now(), dur = 1800;
    (function f(now) {
      const k = clamp((now - start) / dur), e = 1 - Math.pow(1 - k, 4);
      el.textContent = Math.round(to * e).toLocaleString('en-IN');
      if (k < 1) requestAnimationFrame(f);
    })(start);
  }

  /* ---------- cursor ---------- */
  const cur = $('.cursor');
  if (cur && fine) {
    const dot = $('.c-dot'), ring = $('.c-ring'), label = $('.c-label');
    let mx = innerWidth / 2, my = innerHeight / 2, rx = mx, ry = my;
    addEventListener('pointermove', (e) => { mx = e.clientX; my = e.clientY; });
    (function loop() {
      rx += (mx - rx) * 0.16; ry += (my - ry) * 0.16;
      dot.style.transform = `translate(${mx}px,${my}px)`;
      ring.style.transform = `translate(${rx}px,${ry}px)`;
      requestAnimationFrame(loop);
    })();
    document.addEventListener('pointerover', (e) => {
      const lab = e.target.closest('[data-cursor]');
      const link = e.target.closest('a, button, input, select, label');
      cur.classList.toggle('is-hover', !!lab && !e.target.closest('.hero-cta, .nav'));
      cur.classList.toggle('is-link', !!link && !lab);
      if (lab) label.textContent = lab.dataset.cursor;
    });
  }

  /* ---------- magnetic ---------- */
  if (fine) $$('[data-magnetic]').forEach((el) => {
    const inner = el.firstElementChild;
    el.addEventListener('pointermove', (e) => {
      const r = el.getBoundingClientRect(), x = e.clientX - r.left - r.width / 2, y = e.clientY - r.top - r.height / 2;
      el.style.transition = 'transform .2s'; el.style.transform = `translate(${x * 0.28}px,${y * 0.4}px)`;
      if (inner) inner.style.transform = `translate(${x * 0.12}px,${y * 0.16}px)`;
    });
    el.addEventListener('pointerleave', () => {
      el.style.transition = 'transform .8s cubic-bezier(.22,1,.36,1)'; el.style.transform = '';
      if (inner) { inner.style.transition = 'transform .8s cubic-bezier(.22,1,.36,1)'; inner.style.transform = ''; }
    });
  });

  /* ---------- card spotlight ---------- */
  $$('.card').forEach((c) => c.addEventListener('pointermove', (e) => {
    const r = c.getBoundingClientRect();
    c.style.setProperty('--mx', `${e.clientX - r.left}px`); c.style.setProperty('--my', `${e.clientY - r.top}px`);
  }));

  /* ---------- menu ---------- */
  const burger = $('.burger');
  if (burger) burger.addEventListener('click', () => document.body.classList.toggle('menu-open'));
  $$('.mobile-menu a').forEach((a) => a.addEventListener('click', () => document.body.classList.remove('menu-open')));

  /* ---------- canvases ---------- */
  const heroCanvas = $('#heroDots');
  if (heroCanvas && window.Halftone) Halftone(heroCanvas);
  const touch = $('.touch'), hands = $('#handsCanvas');
  if (touch && hands && window.TouchHands) TouchHands(touch, hands);

  /* ---------- hero chip parallax ---------- */
  const hero = $('.hero');
  if (hero && fine) hero.addEventListener('pointermove', (e) => {
    const x = e.clientX / innerWidth - 0.5, y = e.clientY / innerHeight - 0.5;
    $$('.chip', hero).forEach((c) => { const d = +c.dataset.depth; c.style.transform = `translate(${x * d * 2}px,${y * d * 2}px)`; });
  });

  /* ---------- manifesto ---------- */
  const man = $('#manifesto');
  let mWords = [];
  if (man) {
    const accent = new Set(['Instagram,', 'validates.', 'real.', 'reels,', 'mentored,', 'investors', 'résumé.']);
    man.innerHTML = man.textContent.trim().split(/\s+/).map((w) => `<span class="mw${accent.has(w) ? ' accent' : ''}">${w}</span>`).join(' ');
    mWords = $$('.mw', man);
  }

  /* ---------- horizontal scroll ---------- */
  const hs = $('.hscroll'), track = $('.hs-track'), hsCur = $('.hs-cur');
  function sizeHS() { if (hs && track) hs.style.height = `${track.scrollWidth - innerWidth + innerHeight}px`; }
  sizeHS(); addEventListener('resize', sizeHS); addEventListener('load', sizeHS);

  /* ---------- scroll loop ---------- */
  const nav = $('.nav'); let lastY = 0;
  const darkSecs = $$('.touch, .investors, .social, .footer');
  const tcs = $$('.tc');
  function onFrame() {
    const y = scrollY, vh = innerHeight;
    if (nav) {
      nav.classList.toggle('scrolled', y > 40);
      if (!document.body.classList.contains('menu-open')) nav.classList.toggle('hidden', y > lastY + 2 && y > 300);
      if (y < lastY - 2) nav.classList.remove('hidden');
      nav.classList.toggle('dark', !document.body.classList.contains('menu-open') && darkSecs.some((s) => { const r = s.getBoundingClientRect(); return r.top <= 40 && r.bottom >= 40; }));
    }
    lastY = y;
    if (mWords.length) {
      const r = man.getBoundingClientRect();
      const k = clamp((vh * 0.85 - r.top) / (r.height + vh * 0.25));
      const n = Math.floor(k * mWords.length * 1.05);
      mWords.forEach((w, i) => w.classList.toggle('lit', i < n));
    }
    if (hs && track) {
      const r = hs.getBoundingClientRect(), max = track.scrollWidth - innerWidth;
      const k = clamp(-r.top / (r.height - vh));
      track.style.transform = `translate3d(${-k * max}px,0,0)`;
      if (hsCur) hsCur.textContent = String(Math.min(6, Math.floor(k * 5.99) + 1)).padStart(2, '0');
    }
    if (touch && tcs.length) {
      const r = touch.getBoundingClientRect(), p = clamp(-r.top / (r.height - vh));
      tcs[0].classList.toggle('on', p > 0.02 && p < 0.3);
      tcs[1].classList.toggle('on', p > 0.36 && p < 0.72);
      tcs[2].classList.toggle('on', p > 0.8);
    }
    requestAnimationFrame(onFrame);
  }
  requestAnimationFrame(onFrame);

  /* ---------- feed: paste a link ---------- */
  const pasteText = $('.paste-text');
  if (pasteText) {
    const card = $('.post-card'), btn = $('.paste-btn');
    const links = [
      { url: 'https://x.com/aanya/status/18324…', src: 'X', cls: '', name: 'Aanya Sharma', av: 'AS', meta: 'IIT Delhi · now', body: 'Just shipped my first open-source PR 🚀', title: 'Building in public, week 1', domain: 'x.com', g: 'linear-gradient(135deg,#d4f56b,#7fd1bd)' },
      { url: 'https://linkedin.com/posts/rohan-k-intern…', src: 'in', cls: 'li', name: 'Rohan Kapoor', av: 'RK', meta: 'NIT Trichy · now', body: 'Excited to start my internship at Lumen Labs this summer!', title: 'Rohan joined Lumen Labs', domain: 'linkedin.com', g: 'linear-gradient(135deg,#9fd3ff,#0a66c2)' },
      { url: 'https://reddit.com/r/cscareers/comments/…', src: 'r/', cls: 'rd', name: 'Meera Joshi', av: 'MJ', meta: 'IIT KGP · now', body: 'This thread on cracking system design rounds is gold 👇', title: 'How I prepped for SDE interviews', domain: 'reddit.com', g: 'linear-gradient(135deg,#ffb38a,#ff4500)' },
    ];
    let idx = 0;
    const setCard = (l) => {
      $('.post-head .avatar', card).textContent = l.av;
      $('.post-head b', card).textContent = l.name;
      $('.post-head small', card).textContent = l.meta;
      const pill = $('.src-pill', card); pill.textContent = l.src; pill.className = `src-pill ${l.cls}`;
      $('.post-body', card).textContent = l.body;
      $('.pp-title', card).textContent = l.title;
      $('.pp-domain', card).textContent = l.domain;
      $('.pp-thumb', card).style.background = l.g;
      $('.likes', card).textContent = 40 + Math.floor(Math.random() * 200);
    };
    (async function loop() {
      while (true) {
        const l = links[idx % links.length]; idx++;
        pasteText.textContent = '';
        await sleep(500);
        for (const ch of l.url) { pasteText.textContent += ch; await sleep(reduce ? 0 : 28); }
        await sleep(350); btn.classList.add('press'); card.classList.add('hide');
        await sleep(220); btn.classList.remove('press');
        await sleep(300); setCard(l); card.classList.remove('hide');
        await sleep(3600);
      }
    })();
    $('.post-actions span').addEventListener('click', (e) => {
      const s = e.currentTarget, n = $('.likes', s);
      s.classList.toggle('liked'); n.textContent = +n.textContent + (s.classList.contains('liked') ? 1 : -1);
    });
  }

  /* ---------- reels ---------- */
  const reelTrack = $('.reel-track');
  if (reelTrack) {
    const days = [1, 7, 12, 21, 30]; let ri = 0;
    const streak = $('.streak'), sn = $('.streak-n'), sb = $('.streak b:not(.streak-n)'), ss = $('.streak small');
    setInterval(() => {
      ri = (ri + 1) % days.length;
      reelTrack.style.transform = `translateY(${-ri * 100}%)`;
      const d = days[ri];
      streak.style.setProperty('--sp', d / 30); sn.textContent = d;
      sb.textContent = `${d}-day streak`; ss.textContent = d === 30 ? 'Certificate unlocked 🎓' : `${30 - d} days to certificate`;
    }, 2400);
    streak.style.setProperty('--sp', 1 / 30); sn.textContent = 1;
  }

  /* ---------- tilt helper ---------- */
  function tilt(area, el, max = 14, extra = () => '') {
    if (!fine) return;
    area.addEventListener('pointermove', (e) => {
      const r = area.getBoundingClientRect(), x = (e.clientX - r.left) / r.width - 0.5, y = (e.clientY - r.top) / r.height - 0.5;
      el.style.transform = `${extra()} rotateY(${x * max}deg) rotateX(${-y * max}deg)`;
      $$('.holo', el).forEach((hh) => { hh.style.setProperty('--hx', `${(x + 0.5) * 100}%`); hh.style.setProperty('--hy', `${(y + 0.5) * 100}%`); hh.style.setProperty('--ha', `${x * 180}deg`); });
    });
    area.addEventListener('pointerleave', () => { el.style.transform = extra(); });
  }
  const miniId = $('.mini-id');
  if (miniId) { miniId.parentElement.style.perspective = '800px'; tilt(miniId.closest('.card'), miniId, 22); }

  /* ---------- jobs ---------- */
  $$('.apply').forEach((b) => b.addEventListener('click', () => {
    b.classList.toggle('done'); b.textContent = b.classList.contains('done') ? 'Applied ✓' : 'Apply';
  }));

  /* ---------- kanban ---------- */
  const cols = $$('.kanban .col');
  if (cols.length) setInterval(() => {
    const inDoing = $$('.kcard', cols[1]), inOpen = $$('.kcard', cols[0]);
    if (inDoing.length) cols[2].appendChild(inDoing[0]);
    else if (inOpen.length) cols[1].appendChild(inOpen[0]);
    else $$('.kcard', cols[2]).forEach((c) => cols[0].appendChild(c));
  }, 2000);

  /* ---------- heatmap ---------- */
  const heat = $('.heatmap');
  if (heat) {
    const cells = [];
    for (let i = 0; i < 26 * 7; i++) { const c = document.createElement('i'); heat.appendChild(c); cells.push(c); }
    const lvl = () => { const r = Math.random(); return r < 0.35 ? '' : r < 0.6 ? 'l1' : r < 0.8 ? 'l2' : r < 0.93 ? 'l3' : 'l4'; };
    // cells fill column by column when the card enters
    new IntersectionObserver(([e], obs) => {
      if (!e.isIntersecting) return; obs.disconnect();
      cells.forEach((c, i) => setTimeout(() => { c.className = lvl(); }, (i % 26) * 40 + Math.floor(i / 26) * 15));
      setInterval(() => { for (let k = 0; k < 6; k++) cells[Math.floor(Math.random() * cells.length)].className = lvl(); }, 500);
    }, { threshold: 0.3 }).observe(heat);
  }

  /* ---------- refer copy ---------- */
  const copy = $('.copy-link');
  if (copy) copy.addEventListener('click', () => {
    try { navigator.clipboard && navigator.clipboard.writeText('https://msw.community/r/rohan'); } catch (e) {}
    copy.classList.add('copied'); $('em', copy).textContent = 'Copied ✓';
    setTimeout(() => { copy.classList.remove('copied'); $('em', copy).textContent = 'Copy'; }, 1800);
  });

  /* ---------- ID card: tilt + flip ---------- */
  const idcard = $('.idcard'), stage = $('.id-stage');
  if (idcard && stage) {
    let flipped = false;
    tilt(stage, idcard, 24, () => (flipped ? 'rotateY(180deg)' : ''));
    stage.addEventListener('click', () => { flipped = !flipped; idcard.style.transform = flipped ? 'rotateY(180deg)' : ''; });
    // generate QR-like pattern
    const qr = $('.qr'), N = 21;
    const inFinderZone = (x, y) => (x < 8 && y < 8) || (x > N - 9 && y < 8) || (x < 8 && y > N - 9);
    let seed = 7; const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);
    for (let y = 0; y < N; y++) for (let x = 0; x < N; x++) {
      const c = document.createElement('i');
      let on;
      if (inFinderZone(x, y)) {
        const fx = x < 8 ? 0 : N - 7, fy = y < 8 ? 0 : N - 7, dx = x - fx, dy = y - fy;
        on = dx >= 0 && dy >= 0 && dx <= 6 && dy <= 6 && (dx === 0 || dy === 0 || dx === 6 || dy === 6 || (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4));
      } else on = rnd() > 0.5;
      if (!on) c.className = 'o';
      qr.appendChild(c);
    }
  }

  /* ---------- portals ---------- */
  const doors = $$('.door');
  doors.forEach((d) => {
    const open = () => { doors.forEach((o) => o.classList.toggle('is-open', o === d)); };
    if (fine) d.addEventListener('pointerenter', open);
    d.addEventListener('click', (e) => { if (!d.classList.contains('is-open')) { e.preventDefault(); open(); } });
  });

  /* ---------- investors ---------- */
  $$('.idea-bot button').forEach((b) => b.addEventListener('click', () => {
    b.classList.toggle('done'); b.textContent = b.classList.contains('done') ? 'Backed ✓' : 'Back idea';
  }));

  /* ---------- live countdowns ---------- */
  const cds = $$('.countdown').map((el) => {
    const m = el.textContent.match(/(\d+)d (\d+)h (\d+)m/);
    return { el, s: m ? (+m[1] * 86400 + +m[2] * 3600 + +m[3] * 60 + 37) : 0 };
  });
  const pad = (n) => String(n).padStart(2, '0');
  setInterval(() => cds.forEach((c) => {
    c.s = Math.max(0, c.s - 1);
    const d = Math.floor(c.s / 86400), h = Math.floor((c.s % 86400) / 3600), m = Math.floor((c.s % 3600) / 60), s = c.s % 60;
    c.el.textContent = `${d}d ${pad(h)}h ${pad(m)}m ${pad(s)}s`;
  }), 1000);

  window.orbit = { lenis, splitEl };
})();
