/* ==========================================================
   "The Touch" — two hands built from thousands of dots that
   assemble, reach toward each other and touch as you scroll.
   On contact, shockwave rings of dots ripple outward.
   ========================================================== */
(function () {
  const TAU = Math.PI * 2;
  const clamp = (v, a = 0, b = 1) => Math.min(b, Math.max(a, v));
  const ease = (x) => 1 - Math.pow(1 - x, 3);
  const easeIO = (x) => (x < 0.5 ? 4 * x * x * x : 1 - Math.pow(-2 * x + 2, 3) / 2);
  const TIP = { x: 588, y: 166 }; // fingertip in hand-space (640x320)

  function drawHand(c) {
    c.fillStyle = '#fff'; c.strokeStyle = '#fff';
    c.lineCap = 'round'; c.lineJoin = 'round';
    const L = (pts, w) => { c.lineWidth = w; c.beginPath(); c.moveTo(pts[0][0], pts[0][1]); for (let i = 1; i < pts.length; i++) c.lineTo(pts[i][0], pts[i][1]); c.stroke(); };
    const Q = (a, b, e, w) => { c.lineWidth = w; c.beginPath(); c.moveTo(a[0], a[1]); c.quadraticCurveTo(b[0], b[1], e[0], e[1]); c.stroke(); };
    // each finger first carves a thin gap (destination-out) so fingers read as separate forms
    const cut = (fn, w) => { c.globalCompositeOperation = 'destination-out'; fn(w + 6); c.globalCompositeOperation = 'source-over'; fn(w); };
    // forearm tapers toward the elbow
    c.beginPath(); c.moveTo(-90, 200); c.quadraticCurveTo(80, 186, 200, 160); c.lineTo(214, 222); c.quadraticCurveTo(80, 248, -90, 272); c.closePath(); c.fill();
    c.beginPath(); c.ellipse(222, 190, 34, 33, 0, 0, TAU); c.fill();            // wrist
    c.beginPath(); c.ellipse(288, 180, 74, 48, -0.12, 0, TAU); c.fill();        // palm
    cut((w) => Q([328, 222], [384, 230], [372, 254], w), 19);                    // pinky (curled)
    cut((w) => Q([342, 206], [414, 210], [400, 242], w), 22);                    // ring
    cut((w) => Q([350, 188], [430, 190], [416, 228], w), 24);                    // middle
    cut((w) => { L([[322, 166], [432, 152]], w); }, 27);                         // index – proximal
    cut((w) => { L([[432, 152], [512, 156]], w); }, 23);                         // index – middle
    cut((w) => { L([[512, 156], [588, 168]], w); }, 19);                         // index – tip (slight droop)
    cut((w) => Q([262, 150], [330, 116], [384, 132], w), 26);                    // thumb
  }

  function sampleHand(step) {
    const cv = document.createElement('canvas'); cv.width = 640; cv.height = 320;
    const c = cv.getContext('2d'); drawHand(c);
    const d = c.getImageData(0, 0, 640, 320).data;
    const a = (x, y) => (x < 0 || y < 0 || x >= 640 || y >= 320 ? 0 : d[(y * 640 + x) * 4 + 3]);
    const pts = [];
    for (let y = 0; y < 320; y += step) {
      for (let x = (Math.round(y / step) % 2) * step / 2; x < 640; x += step) {
        const xi = x | 0, yi = y | 0;
        if (a(xi, yi) < 128) continue;
        const s = step * 1.2;
        const edge = a(xi + s | 0, yi) < 128 || a(xi - s | 0, yi) < 128 || a(xi, yi + s | 0) < 128 || a(xi, yi - s | 0) < 128;
        // cylindrical shading: measure distance to the top and bottom of the form in this column
        let up = 0, dn = 0;
        while (a(xi, yi - up - 1) >= 128 && up < 200) up++;
        while (a(xi, yi + dn + 1) >= 128 && dn < 200) dn++;
        const v = (up + 0.5) / (up + dn + 1);                  // 0 = top rim, 1 = bottom rim
        const light = Math.pow(Math.sin(Math.PI * Math.min(v * 1.15, 1)), 0.6) * (1 - 0.55 * v);
        pts.push({ x, y, edge, shade: light, fade: clamp((x + 60) / 220) });
      }
    }
    return pts;
  }

  window.TouchHands = function (section, canvas, opts = {}) {
    const ctx = canvas.getContext('2d');
    const accent = opts.accent || '#7fd1bd';
    const ink = opts.ink || '#ecebe6';
    const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    let W, H, scale, P = [], t = 0, prog = 0, sp = 0, touched = false, rings = [], lastRing = 0, visible = true;
    const m = { x: -9999, y: -9999, tx: -9999, ty: -9999 };
    const base = sampleHand(window.innerWidth < 700 ? 7 : 5.5);

    function build() {
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      W = canvas.clientWidth; H = canvas.clientHeight;
      canvas.width = W * dpr; canvas.height = H * dpr; ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      scale = Math.min((W * (W < 700 ? 0.95 : 0.5)) / 640, (H * 0.55) / 320);
      P = [];
      [0, 1].forEach((side) => {
        base.forEach((b) => {
          const ang = Math.random() * TAU, rad = Math.max(W, H) * (0.35 + Math.random() * 0.6);
          P.push({
            side, hx: b.x, hy: b.y, edge: b.edge, shade: b.shade, fade: b.fade,
            sx: W / 2 + Math.cos(ang) * rad + (side ? W * 0.25 : -W * 0.25),
            sy: H / 2 + Math.sin(ang) * rad * 0.6,
            delay: Math.random() * 0.45 + (b.x / 640) * 0.15,
            ph: Math.random() * TAU,
            r0: 0.5 + Math.random() * 0.6,
          });
        });
      });
    }

    function handPos(p, side, gap, slide) {
      // map hand-space to screen with rotation about the fingertip
      const rot = side ? -0.07 : 0.05;
      let lx = (p.hx - TIP.x) * scale, ly = (p.hy - TIP.y) * scale;
      const c = Math.cos(rot), s = Math.sin(rot);
      let x = lx * c - ly * s, y = lx * s + ly * c;
      const cx = W / 2, cy = H * 0.52;
      if (side === 0) return [cx - gap / 2 + x - slide, cy + y];
      return [cx + gap / 2 - x + slide, cy - y * -1 - 10 * scale]; // mirrored
    }

    function frame(now) {
      requestAnimationFrame(frame);
      const r = section.getBoundingClientRect();
      const target = clamp(-r.top / (r.height - window.innerHeight));
      sp += (target - sp) * 0.09; prog = sp;
      if (!visible) return;
      t += reduce ? 0.004 : 0.016;
      m.x += (m.tx - m.x) * 0.1; m.y += (m.ty - m.y) * 0.1;

      const assemble = clamp(prog / 0.42);
      const reach = easeIO(clamp((prog - 0.38) / 0.4));
      const gap = (1 - reach) * W * 0.26 + reach * 4 * scale;
      const slide = (1 - ease(assemble)) * W * 0.12;
      const touch = clamp((prog - 0.78) / 0.06);
      section.style.setProperty('--p', prog.toFixed(4));
      section.classList.toggle('is-touched', touch > 0.5);

      if (touch > 0.5 && !touched) { touched = true; burst(now); }
      if (touch < 0.2) touched = false;
      if (touched && now - lastRing > 1100) burst(now);

      ctx.clearRect(0, 0, W, H);
      const cx = W / 2, cy = H * 0.52 - 2 * scale;

      // glow at contact
      if (reach > 0.6) {
        const gl = clamp((reach - 0.6) / 0.4) * (0.35 + touch * 0.65);
        const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, 220 * scale + touch * 120);
        g.addColorStop(0, `rgba(127,209,189,${0.55 * gl})`);
        g.addColorStop(0.4, `rgba(127,209,189,${0.12 * gl})`);
        g.addColorStop(1, 'rgba(127,209,189,0)');
        ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);
      }

      ctx.fillStyle = ink;
      ctx.beginPath();
      const accentPts = [];
      for (let i = 0; i < P.length; i++) {
        const p = P[i];
        const a = ease(clamp((assemble * 1.6 - p.delay) / 1.0));
        const [hx, hy] = handPos(p, p.side, gap, slide);
        const wob = (1 - a) * 18 + 0.8;
        let x = p.sx + (hx - p.sx) * a + Math.sin(t * 1.3 + p.ph) * wob;
        let y = p.sy + (hy - p.sy) * a + Math.cos(t * 1.1 + p.ph) * wob;
        let rad = (p.r0 * 0.45 + p.shade * 1.7 + (p.edge ? 0.35 : 0)) * scale * 1.45 * (0.35 + 0.65 * a);
        rad *= 0.4 + 0.6 * p.fade;
        // cursor disturbs the dots
        const dx = x - m.x, dy = y - m.y, d2 = dx * dx + dy * dy;
        if (d2 < 14400) { const d = Math.sqrt(d2) || 1, k = 1 - d / 120; x += (dx / d) * k * k * 30; y += (dy / d) * k * k * 30; rad *= 1 + k; }
        if (rad < 0.25) continue;
        // fingertip region lights up on touch
        const nearTip = p.hx > 520 && touch > 0;
        if (nearTip) { accentPts.push(x, y, rad * (1 + touch * 0.4)); continue; }
        ctx.moveTo(x + rad, y); ctx.arc(x, y, rad, 0, TAU);
      }
      ctx.fill();

      if (accentPts.length) {
        ctx.fillStyle = accent; ctx.beginPath();
        for (let i = 0; i < accentPts.length; i += 3) { ctx.moveTo(accentPts[i] + accentPts[i + 2], accentPts[i + 1]); ctx.arc(accentPts[i], accentPts[i + 1], accentPts[i + 2], 0, TAU); }
        ctx.fill();
      }

      // shockwave rings of dots
      rings = rings.filter((rg) => now - rg.t0 < 2600);
      rings.forEach((rg) => {
        const k = (now - rg.t0) / 2600, R = 10 + ease(k) * Math.max(W, H) * 0.55, n = Math.floor(40 + R * 0.25);
        ctx.fillStyle = `rgba(127,209,189,${(1 - k) * 0.9})`; ctx.beginPath();
        for (let j = 0; j < n; j++) {
          const ang = (j / n) * TAU + rg.rot;
          const px = cx + Math.cos(ang) * R, py = cy + Math.sin(ang) * R * 0.62;
          const rr = (1 - k) * 2.6 + 0.4;
          ctx.moveTo(px + rr, py); ctx.arc(px, py, rr, 0, TAU);
        }
        ctx.fill();
      });
    }

    function burst(now) { lastRing = now; rings.push({ t0: now, rot: Math.random() }); }

    section.addEventListener('pointermove', (e) => { const r = canvas.getBoundingClientRect(); m.tx = e.clientX - r.left; m.ty = e.clientY - r.top; if (m.x < -999) { m.x = m.tx; m.y = m.ty; } });
    section.addEventListener('pointerleave', () => { m.tx = m.ty = m.x = m.y = -9999; });
    new IntersectionObserver(([e]) => { visible = e.isIntersecting; }).observe(section);
    let rt; window.addEventListener('resize', () => { clearTimeout(rt); rt = setTimeout(build, 150); });
    build(); requestAnimationFrame(frame);
  };
})();
