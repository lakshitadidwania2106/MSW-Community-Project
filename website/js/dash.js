/* =========================================================
   MSW Community — dashboard engine
   Shell (sidebar, topbar, router), ⌘K palette, notifications,
   and UI helpers: stats, charts, donuts, rings, kanban, modals,
   drawers, toasts. Each role page calls Dash.init({...}).
   ========================================================= */
(function () {
  const $ = (s, c = document) => c.querySelector(s);
  const $$ = (s, c = document) => [...c.querySelectorAll(s)];
  const clamp = (v, a = 0, b = 1) => Math.min(b, Math.max(a, v));
  const fine = matchMedia('(hover: hover) and (pointer: fine)').matches;

  const P = {
    home: 'M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z',
    feed: 'M4 5h16M4 12h16M4 19h10',
    book: 'M4 19V5a2 2 0 0 1 2-2h14v16H6a2 2 0 0 0-2 2zm0 0a2 2 0 0 0 2 2h14',
    trophy: 'M8 4h8v5a4 4 0 0 1-8 0zM8 6H4a3 3 0 0 0 4 4M16 6h4a3 3 0 0 1-4 4M12 13v4M8 21h8M9 17h6',
    briefcase: 'M3 8h18v11H3zM8 8V5h8v3M3 13h18',
    task: 'M9 11l3 3 8-8M20 12v7H4V5h11',
    brain: 'M12 5a3 3 0 0 0-5.6-1.5A3 3 0 0 0 4 8a3 3 0 0 0 0 5 3 3 0 0 0 3 4.5A3 3 0 0 0 12 19zM12 5a3 3 0 0 1 5.6-1.5A3 3 0 0 1 20 8a3 3 0 0 1 0 5 3 3 0 0 1-3 4.5A3 3 0 0 1 12 19z',
    id: 'M3 5h18v14H3zM7 10a2 2 0 1 0 4 0 2 2 0 1 0-4 0M6 16c1-2 5-2 6 0M14 9h4M14 13h4',
    gift: 'M3 9h18v4H3zM5 13v8h14v-8M12 9v12M12 9C10 5 6 5 6 8s6 1 6 1zm0 0c2-4 6-4 6-1s-6 1-6 1z',
    users: 'M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM2 21c0-4 3-6 7-6s7 2 7 6M17 11a3 3 0 1 0 0-6M22 21c0-3-2-5-5-5.5',
    chart: 'M4 20V10M10 20V4M16 20v-7M22 20H2',
    plus: 'M12 5v14M5 12h14',
    search: 'M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14zM21 21l-5-5',
    bell: 'M6 16v-5a6 6 0 1 1 12 0v5l2 2H4zM10 21h4',
    settings: 'M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM19.4 15a1.6 1.6 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.6 1.6 0 0 0-2.7 1.1V21a2 2 0 1 1-4 0v-.1a1.6 1.6 0 0 0-2.7-1.1l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1A1.6 1.6 0 0 0 3.1 14H3a2 2 0 1 1 0-4h.1a1.6 1.6 0 0 0 1.1-2.7l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1A1.6 1.6 0 0 0 10 3.1V3a2 2 0 1 1 4 0v.1a1.6 1.6 0 0 0 2.7 1.1l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.6 1.6 0 0 0 1.1 2.7H21a2 2 0 1 1 0 4h-.1a1.6 1.6 0 0 0-1.5 1z',
    logout: 'M15 4h4v16h-4M10 8l-4 4 4 4M6 12h10',
    arrow: 'M5 12h14M13 6l6 6-6 6',
    shield: 'M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z',
    flag: 'M5 21V4h11l-2 4 2 4H5',
    calendar: 'M4 6h16v14H4zM4 10h16M8 3v4M16 3v4',
    wallet: 'M3 7h16v12H3zM3 7l12-4v4M16 13h2',
    trend: 'M3 17l6-6 4 4 8-8M15 7h6v6',
    eye: 'M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12zM12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z',
    x: 'M6 6l12 12M18 6L6 18',
    star: 'M12 3l2.7 5.6 6.3.9-4.5 4.4 1 6.1-5.5-2.9L6.5 20l1-6.1L3 9.5l6.3-.9z',
    layers: 'M12 3l9 5-9 5-9-5zM3 13l9 5 9-5',
    sparkle: 'M12 3c.8 5 3.2 7.4 9 9-5.8 1.6-8.2 4-9 9-.8-5-3.2-7.4-9-9 5.8-1.6 8.2-4 9-9z',
    link: 'M10 14a5 5 0 0 0 7 0l3-3a5 5 0 0 0-7-7l-1 1M14 10a5 5 0 0 0-7 0l-3 3a5 5 0 0 0 7 7l1-1',
    check: 'M5 12l5 5 9-10',
    msg: 'M4 5h16v11H8l-4 4z',
    grid: 'M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z',
    menu: 'M4 7h16M4 12h16M4 17h16',
    coin: 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM15 9h-4.5a2 2 0 0 0 0 4h3a2 2 0 0 1 0 4H9M12 6v2M12 17v2',
    globe: 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18',
    upload: 'M12 16V4M7 9l5-5 5 5M4 20h16',
    bookmark: 'M6 3h12v18l-6-4-6 4z',
    play: 'M7 4l13 8-13 8z',
    doc: 'M6 3h9l4 4v14H6zM14 3v5h5M9 13h7M9 17h5',
  };
  const icon = (n, cls = 'ic') => `<svg class="${cls}" viewBox="0 0 24 24"><path d="${P[n] || ''}"/></svg>`;
  const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const fmt = (n, dec = 0) => Number(n).toLocaleString('en-IN', { minimumFractionDigits: dec, maximumFractionDigits: dec });

  const Dash = (window.Dash = { $, $$, icon, esc, fmt, P });

  /* ---------------- components ---------------- */
  Dash.spark = (pts) => {
    const max = Math.max(...pts), min = Math.min(...pts), n = pts.length;
    const xy = pts.map((v, i) => [(i / (n - 1)) * 100, 36 - ((v - min) / (max - min || 1)) * 32]);
    const d = xy.map((p, i) => (i ? 'L' : 'M') + p[0].toFixed(1) + ' ' + p[1].toFixed(1)).join(' ');
    return `<svg class="spark" viewBox="0 0 100 40" preserveAspectRatio="none"><path class="a" d="${d} L100 40 L0 40Z"/><path class="l" pathLength="1" d="${d}"/></svg>`;
  };

  Dash.stat = ({ label, value, prefix = '', suffix = '', delta, down, spark, dec = 0, i = 0, ic }) => `
    <div class="d-card stat rv" style="--i:${i}">
      <span class="lbl">${ic ? icon(ic) : ''}${label}</span>
      <span class="val">${prefix}<span class="count" data-to="${value}" data-dec="${dec}">0</span>${suffix}</span>
      ${delta ? `<span class="delta ${down ? 'down' : ''}">${down ? '↓' : '↑'} ${delta}</span>` : ''}
      ${spark ? Dash.spark(spark) : ''}
    </div>`;

  function smooth(pts) {
    let d = `M${pts[0][0]} ${pts[0][1]}`;
    for (let i = 0; i < pts.length - 1; i++) {
      const p0 = pts[i - 1] || pts[i], p1 = pts[i], p2 = pts[i + 1], p3 = pts[i + 2] || p2;
      const c1 = [p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6];
      const c2 = [p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6];
      d += ` C${c1[0].toFixed(1)} ${c1[1].toFixed(1)} ${c2[0].toFixed(1)} ${c2[1].toFixed(1)} ${p2[0].toFixed(1)} ${p2[1].toFixed(1)}`;
    }
    return d;
  }
  let gid = 0;
  Dash.chart = (series, labels, { unit = '' } = {}) => {
    const W = 600, H = 240, max = Math.max(...series.flatMap((s) => s.data)) * 1.15;
    const id = 'g' + gid++;
    const paths = series.map((s, si) => {
      const pts = s.data.map((v, i) => [(i / (s.data.length - 1)) * W, H - (v / max) * H]);
      const d = smooth(pts);
      return (si === 0 ? `<path class="ar" fill="url(#${id})" d="${d} L${W} ${H} L0 ${H}Z"/>` : '') +
        `<path class="ln ${si ? 'b' : ''}" pathLength="1" stroke="${s.color}" d="${d}"/>`;
    }).join('');
    const grid = [0.25, 0.5, 0.75].map((k) => `<line x1="0" x2="${W}" y1="${H * k}" y2="${H * k}"/>`).join('');
    const data = esc(JSON.stringify({ series: series.map((s) => ({ n: s.name, d: s.data })), labels, max, unit }));
    const step = Math.ceil(labels.length / 7);
    return `<div class="chart" data-chart="${data}">
      <svg viewBox="0 0 ${W} ${H}" preserveAspectRatio="none"><defs><linearGradient id="${id}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${series[0].color}" stop-opacity=".28"/><stop offset="1" stop-color="${series[0].color}" stop-opacity="0"/></linearGradient></defs><g class="grid">${grid}</g>${paths}</svg>
      <div class="tip"><i></i><b></b><span></span></div>
      <div class="xl">${labels.filter((_, i) => i % step === 0).map((l) => `<span>${l}</span>`).join('')}</div>
    </div>`;
  };

  Dash.bars = (items, suffix = '') => {
    const max = Math.max(...items.map((x) => x.value));
    return `<div class="bars">${items.map((x, i) => `<div class="bar-row" style="--i:${i}"><span>${x.label}</span><div class="tr"><i style="--w:${Math.max(4, Math.sqrt(x.value / max) * 100)}%;${x.color ? `background:${x.color}` : ''}"></i></div><b>${fmt(x.value)}${suffix}</b></div>`).join('')}</div>`;
  };

  Dash.donut = (segs, ctr, sub) => {
    const total = segs.reduce((a, s) => a + s.value, 0), C = 2 * Math.PI * 60;
    let acc = 0;
    const circles = segs.map((s) => {
      const len = (s.value / total) * C, off = -acc;
      acc += len;
      return `<circle r="60" cx="80" cy="80" stroke="${s.color}" stroke-dasharray="0 ${C}" stroke-dashoffset="${off}" data-len="${len}" data-c="${C}"/>`;
    }).join('');
    return `<div class="donut"><div class="donut-c"><svg viewBox="0 0 160 160"><circle r="60" cx="80" cy="80" stroke="var(--bg-2)"/>${circles}</svg><div class="ctr"><b>${ctr}</b><small>${sub}</small></div></div>
      <ul>${segs.map((s) => `<li><i style="background:${s.color}"></i>${s.label}<b>${s.display || fmt(s.value)}</b></li>`).join('')}</ul></div>`;
  };

  Dash.ring = (p, big, small) => `<div class="ring2" data-p="${p}"><svg viewBox="0 0 120 120"><circle class="bgc" cx="60" cy="60" r="50"/><circle class="fg" cx="60" cy="60" r="50"/></svg><div class="ctr"><b>${big}</b><small>${small}</small></div></div>`;

  Dash.kanban = (cols) => `<div class="kb" style="--cols:${cols.length}">${cols.map((c) => `
    <div class="kb-col" data-col="${c.id}"><h6>${c.title}<b>${c.cards.length}</b></h6>${c.cards.join('')}</div>`).join('')}</div>`;

  Dash.dnd = (root, onMove) => {
    let dragged = null;
    root.addEventListener('dragstart', (e) => { const c = e.target.closest('.kb-card'); if (!c) return; dragged = c; c.classList.add('dragging'); e.dataTransfer.effectAllowed = 'move'; try { e.dataTransfer.setData('text/plain', ''); } catch (_) {} });
    root.addEventListener('dragend', () => { if (dragged) dragged.classList.remove('dragging'); dragged = null; $$('.kb-col', root).forEach((c) => c.classList.remove('over')); });
    $$('.kb-col', root).forEach((col) => {
      col.addEventListener('dragover', (e) => { e.preventDefault(); col.classList.add('over'); });
      col.addEventListener('dragleave', (e) => { if (!col.contains(e.relatedTarget)) col.classList.remove('over'); });
      col.addEventListener('drop', (e) => {
        e.preventDefault(); col.classList.remove('over');
        if (!dragged || dragged.parentElement === col) return;
        const from = dragged.parentElement;
        const card = dragged; card.remove(); col.appendChild(card);
        card.style.animation = 'none'; void card.offsetWidth; card.style.animation = '';
        [from, col].forEach((c) => { const b = $('h6 b', c); if (b) b.textContent = $$('.kb-card', c).length; });
        onMove && onMove(card, col.dataset.col, from.dataset.col);
      });
    });
  };

  /* ---------------- overlays ---------------- */
  Dash.modal = (html, { wide = false, onOpen } = {}) => {
    const ov = document.createElement('div');
    ov.className = 'd-ov';
    ov.innerHTML = `<div class="d-modal ${wide ? 'wide' : ''}" style="position:relative"><button class="d-icon-btn m-close" aria-label="Close">${icon('x')}</button>${html}</div>`;
    document.body.appendChild(ov);
    const close = () => { ov.classList.remove('open'); document.removeEventListener('keydown', onKey); setTimeout(() => ov.remove(), 400); };
    const onKey = (e) => { if (e.key === 'Escape') close(); };
    ov.addEventListener('click', (e) => { if (e.target === ov || e.target.closest('.m-close') || e.target.closest('[data-close]')) close(); });
    document.addEventListener('keydown', onKey);
    requestAnimationFrame(() => ov.classList.add('open'));
    const m = $('.d-modal', ov);
    hydrate(m);
    onOpen && onOpen(m, close);
    return { el: m, close };
  };

  Dash.drawer = (html, onOpen) => {
    const ov = document.createElement('div'); ov.className = 'd-ov';
    const dr = document.createElement('aside'); dr.className = 'd-drawer';
    dr.innerHTML = `<button class="d-icon-btn m-close" style="position:absolute;top:20px;right:20px">${icon('x')}</button>${html}`;
    document.body.append(ov, dr);
    const close = () => { ov.classList.remove('open'); dr.classList.remove('open'); setTimeout(() => { ov.remove(); dr.remove(); }, 600); };
    ov.addEventListener('click', close);
    dr.addEventListener('click', (e) => { if (e.target.closest('.m-close') || e.target.closest('[data-close]')) close(); });
    requestAnimationFrame(() => { ov.classList.add('open'); dr.classList.add('open'); });
    hydrate(dr);
    onOpen && onOpen(dr, close);
    return { el: dr, close };
  };

  Dash.toast = (msg, ic = '✓') => {
    let box = $('.toasts'); if (!box) { box = document.createElement('div'); box.className = 'toasts'; document.body.appendChild(box); }
    const t = document.createElement('div'); t.className = 'toast'; t.innerHTML = `<i>${ic}</i><span>${msg}</span>`;
    box.appendChild(t);
    setTimeout(() => { t.classList.add('out'); setTimeout(() => t.remove(), 400); }, 2800);
  };

  Dash.flyOut = (el, left) => new Promise((r) => {
    el.style.height = el.offsetHeight + 'px';
    el.classList.add('fly-out'); if (left) el.classList.add('left');
    setTimeout(() => { el.remove(); r(); }, 600);
  });

  Dash.detect = (url) => {
    const t = (url || '').toLowerCase();
    if (/(^|\/\/|\.)(x|twitter)\.com/.test(t)) return { name: 'X', color: '#000', short: 'X' };
    if (t.includes('linkedin.com')) return { name: 'LinkedIn', color: '#0a66c2', short: 'in' };
    if (t.includes('reddit.com')) return { name: 'Reddit', color: '#ff4500', short: 'r/' };
    if (/^https?:\/\//.test(t)) return { name: 'Link', color: '#2f8f7a', short: '↗' };
    return null;
  };

  /* ---------------- hydrate (animate new content) ---------------- */
  function countUp(el) {
    if (el.dataset.done) return; el.dataset.done = 1;
    const to = +el.dataset.to, dec = +(el.dataset.dec || 0), start = performance.now(), dur = 1500;
    (function f(now) {
      const k = clamp((now - start) / dur), e = 1 - Math.pow(1 - k, 4);
      el.textContent = fmt(to * e, dec);
      if (k < 1) requestAnimationFrame(f);
    })(start);
  }
  function hydrate(root) {
    $$('.count', root).forEach(countUp);
    requestAnimationFrame(() => requestAnimationFrame(() => {
      $$('.ring2', root).forEach((r) => { $('.fg', r).style.strokeDashoffset = 314 - 314 * clamp(+r.dataset.p); });
      $$('.donut circle[data-len]', root).forEach((c, i) => setTimeout(() => { c.style.strokeDasharray = `${c.dataset.len} ${c.dataset.c}`; }, i * 120));
    }));
    $$('.chart[data-chart]', root).forEach((ch) => {
      const d = JSON.parse(ch.dataset.chart), tip = $('.tip', ch), dot = $('b', tip), lab = $('span', tip), svg = $('svg', ch);
      ch.addEventListener('mousemove', (e) => {
        const r = svg.getBoundingClientRect(), n = d.labels.length;
        const i = Math.round(clamp((e.clientX - r.left) / r.width) * (n - 1));
        const v = d.series[0].d[i];
        tip.style.left = `${(i / (n - 1)) * r.width}px`;
        dot.style.top = `${r.height - (v / d.max) * r.height}px`;
        lab.innerHTML = `<b style="all:unset;opacity:.6">${d.labels[i]}</b>&nbsp; ${d.series.map((s) => `${s.n}: ${fmt(s.d[i])}${d.unit}`).join(' · ')}`;
      });
    });
    $$('.d-banner canvas', root).forEach((cv) => { if (!cv.dataset.on && window.Halftone) { cv.dataset.on = 1; Halftone(cv, { color: '#ecebe6', swirlX: 1.02, swirlY: 0.5 }); } });
  }
  Dash.hydrate = hydrate;

  /* ---------------- shell ---------------- */
  Dash.init = (cfg) => {
    document.documentElement.style.setProperty('--rc', cfg.color);
    document.title = `${cfg.roleName} dashboard — MSW Community`;
    const app = $('#app');
    let group = null;
    const navHtml = cfg.nav.map((n) => {
      let h = '';
      if (n.group && n.group !== group) { group = n.group; h += `<div class="d-nav-label">${n.group}</div>`; }
      return h + `<a href="#${n.id}" data-v="${n.id}">${icon(n.icon)}<span>${n.label}</span>${n.badge ? `<span class="badge-n">${n.badge}</span>` : ''}</a>`;
    }).join('');
    const u = cfg.user;
    app.innerHTML = `
      <svg width="0" height="0" style="position:absolute"><defs><linearGradient id="sparkFill" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${cfg.color}" stop-opacity=".22"/><stop offset="1" stop-color="${cfg.color}" stop-opacity="0"/></linearGradient></defs></svg>
      <div class="d-shell">
        <aside class="d-side">
          <a href="index.html" class="d-logo">MSW <em>Community</em><i>.</i></a>
          <span class="d-role"><b></b>${cfg.roleName} portal</span>
          <nav class="d-nav"><span class="d-ind"></span>${navHtml}</nav>
          <div class="d-side-foot">
            <a class="lnk" href="login.html">${icon('users')}Switch portal</a>
            <a class="lnk" href="index.html">${icon('logout')}Back to website</a>
            <div class="d-me"><div class="av" style="background:${u.grad}">${u.initials}</div><div><b>${u.name}</b><small>${u.sub}</small></div></div>
          </div>
        </aside>
        <main class="d-main">
          <header class="d-top">
            <button class="d-icon-btn d-burger" aria-label="Menu">${icon('menu')}</button>
            <div><div class="d-crumb"></div><h1 class="d-title"></h1></div>
            <div class="d-top-r">
              <button class="d-search">${icon('search')}<span>Search or jump to…</span><kbd>⌘K</kbd></button>
              <div style="position:relative">
                <button class="d-icon-btn d-bell" aria-label="Notifications">${icon('bell')}<span class="dot"></span></button>
                <div class="d-notif"><h5>Notifications</h5>${(cfg.notifications || []).map((n) => `<button class="n" style="width:100%"><span class="n-ic">${n.ic}</span><span>${n.t}<small>${n.s}</small></span></button>`).join('')}</div>
              </div>
              <div class="av" style="background:${u.grad}">${u.initials}</div>
            </div>
          </header>
          <div class="d-views">${cfg.nav.map((n) => `<section class="view" data-view="${n.id}"></section>`).join('')}</div>
        </main>
      </div>
      <div class="cursor" aria-hidden="true"><div class="c-dot"></div><div class="c-ring"><span class="c-label"></span></div></div>`;

    const ind = $('.d-ind'), title = $('.d-title'), crumb = $('.d-crumb');
    const rendered = new Set();
    function show(id) {
      if (!cfg.views[id]) id = cfg.nav[0].id;
      const v = cfg.views[id], sec = $(`.view[data-view="${id}"]`);
      $$('.view').forEach((s) => s.classList.toggle('on', s === sec));
      $$('.d-nav a').forEach((a) => a.classList.toggle('on', a.dataset.v === id));
      const a = $(`.d-nav a[data-v="${id}"]`);
      if (a) { ind.style.transform = `translateY(${a.offsetTop}px)`; ind.style.height = `${a.offsetHeight}px`; }
      crumb.textContent = `${cfg.roleName} · ${v.crumb || a?.textContent || ''}`;
      title.innerHTML = `${v.title[0]}<em>${v.title[1] || ''}</em>`;
      if (!rendered.has(id)) {
        rendered.add(id);
        sec.innerHTML = v.render();
        $$('.rv', sec).forEach((el, i) => { if (!el.style.getPropertyValue('--i')) el.style.setProperty('--i', i); });
        hydrate(sec);
        v.mount && v.mount(sec);
      } else {
        // replay entrance animations on revisit
        $$('.rv', sec).forEach((el) => { el.style.animation = 'none'; void el.offsetWidth; el.style.animation = ''; });
      }
      document.body.classList.remove('side-open');
      window.scrollTo({ top: 0, behavior: 'instant' in window ? 'instant' : 'auto' });
    }
    Dash.go = (id) => { if (location.hash === '#' + id) show(id); else location.hash = id; };
    addEventListener('hashchange', () => show(location.hash.slice(1)));
    show(location.hash.slice(1) || cfg.nav[0].id);
    addEventListener('resize', () => { const a = $('.d-nav a.on'); if (a) ind.style.transform = `translateY(${a.offsetTop}px)`; });

    // card spotlight
    document.addEventListener('pointermove', (e) => {
      const c = e.target.closest && e.target.closest('.d-card'); if (!c) return;
      const r = c.getBoundingClientRect(); c.style.setProperty('--mx', `${e.clientX - r.left}px`); c.style.setProperty('--my', `${e.clientY - r.top}px`);
    });

    // burger
    $('.d-burger').addEventListener('click', () => document.body.classList.toggle('side-open'));

    // notifications
    const bell = $('.d-bell'), notif = $('.d-notif');
    bell.addEventListener('click', (e) => { e.stopPropagation(); notif.classList.toggle('open'); $('.dot', bell)?.remove(); });
    document.addEventListener('click', (e) => { if (!e.target.closest('.d-notif')) notif.classList.remove('open'); });

    // ⌘K palette
    const items = [
      ...cfg.nav.map((n) => ({ label: n.label, ic: n.icon, kind: 'Go to', run: () => Dash.go(n.id) })),
      ...(cfg.actions || []).map((a) => ({ ...a, kind: 'Action' })),
      { label: 'Switch portal', ic: 'users', kind: 'Account', run: () => (location.href = 'login.html') },
      { label: 'Back to website', ic: 'globe', kind: 'Account', run: () => (location.href = 'index.html') },
    ];
    function palette() {
      if ($('.cmdk')) return;
      const ov = document.createElement('div'); ov.className = 'd-ov';
      ov.innerHTML = `<div class="cmdk"><input placeholder="Type a command or search…" /><ul></ul></div>`;
      document.body.appendChild(ov);
      const inp = $('input', ov), ul = $('ul', ov);
      let sel = 0, list = items;
      const draw = () => {
        const q = inp.value.toLowerCase();
        list = items.filter((x) => x.label.toLowerCase().includes(q));
        sel = Math.min(sel, Math.max(0, list.length - 1));
        ul.innerHTML = list.map((x, i) => `<li class="${i === sel ? 'sel' : ''}" data-i="${i}">${icon(x.ic || 'arrow')}${x.label}<small>${x.kind}</small></li>`).join('') || '<li>No results</li>';
      };
      const close = () => { ov.classList.remove('open'); setTimeout(() => ov.remove(), 350); };
      const run = (i) => { const x = list[i]; if (!x) return; close(); setTimeout(x.run, 120); };
      inp.addEventListener('input', () => { sel = 0; draw(); });
      inp.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowDown') { sel = Math.min(list.length - 1, sel + 1); draw(); e.preventDefault(); }
        if (e.key === 'ArrowUp') { sel = Math.max(0, sel - 1); draw(); e.preventDefault(); }
        if (e.key === 'Enter') run(sel);
        if (e.key === 'Escape') close();
      });
      ul.addEventListener('click', (e) => { const li = e.target.closest('li[data-i]'); if (li) run(+li.dataset.i); });
      ov.addEventListener('click', (e) => { if (e.target === ov) close(); });
      draw(); requestAnimationFrame(() => { ov.classList.add('open'); inp.focus(); });
    }
    $('.d-search').addEventListener('click', palette);
    document.addEventListener('keydown', (e) => { if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') { e.preventDefault(); palette(); } });

    // cursor
    const cur = $('.cursor');
    if (cur && fine) {
      const dot = $('.c-dot'), ring = $('.c-ring'); let mx = -100, my = -100, rx = -100, ry = -100;
      addEventListener('pointermove', (e) => { mx = e.clientX; my = e.clientY; });
      (function loop() { rx += (mx - rx) * 0.18; ry += (my - ry) * 0.18; dot.style.transform = `translate(${mx}px,${my}px)`; ring.style.transform = `translate(${rx}px,${ry}px)`; requestAnimationFrame(loop); })();
      document.addEventListener('pointerover', (e) => cur.classList.toggle('is-link', !!e.target.closest('a,button,input,select,textarea,.kb-card,.day')));
    }
  };
})();
