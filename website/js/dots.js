/* ==========================================================
   Halftone dot field — a living, cursor-reactive dot canvas.
   Fine diagonal "ribbon" of tiny dots + coarse swirling field
   of big dots on the right, inspired by halftone print.
   Usage: Halftone(canvas, { color, band:true, swirl:true })
   ========================================================== */
(function () {
  const TAU = Math.PI * 2;
  const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  window.Halftone = function (canvas, opts = {}) {
    const o = Object.assign({ color: 'auto', band: true, swirl: true, speed: 1, swirlX: 1.05, swirlY: 0.45 }, opts);
    const ctx = canvas.getContext('2d');
    const resolve = () => (o.color === 'auto' ? getComputedStyle(document.documentElement).getPropertyValue('--ink').trim() || '#121212' : o.color);
    let fill = resolve();
    document.addEventListener('themechange', () => { fill = resolve(); });
    let W = 0, H = 0, fine = [], coarse = [], t = Math.random() * 100, running = true, visible = true;
    const m = { x: -9999, y: -9999, tx: -9999, ty: -9999, boost: 0 };

    function build() {
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      W = canvas.clientWidth; H = canvas.clientHeight;
      canvas.width = W * dpr; canvas.height = H * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      fine = []; coarse = [];
      const s1 = W < 700 ? 10 : 12;
      for (let y = -s1, r = 0; y < H + s1; y += s1, r++)
        for (let x = -s1; x < W + s1; x += s1) fine.push(x + (r % 2) * s1 / 2, y);
      const s2 = W < 700 ? 24 : 32;
      for (let y = -s2, r = 0; y < H + s2; y += s2, r++)
        for (let x = -s2; x < W + s2; x += s2) coarse.push(x + (r % 2) * s2 / 2, y);
    }

    function warp(x, y, r) {
      // cursor lens: push dots away + enlarge them
      const dx = x - m.x, dy = y - m.y, d2 = dx * dx + dy * dy, R = 150 + m.boost * 60;
      if (d2 < R * R) {
        const d = Math.sqrt(d2) || 1, k = 1 - d / R, e = k * k;
        return [x + (dx / d) * e * 26, y + (dy / d) * e * 26, r * (1 + e * 1.6) + e * 1.2];
      }
      return [x, y, r];
    }

    function frame() {
      if (!running) return;
      requestAnimationFrame(frame);
      if (!visible) return;
      t += (reduce ? 0.002 : 0.012) * o.speed;
      m.x += (m.tx - m.x) * 0.12; m.y += (m.ty - m.y) * 0.12; m.boost *= 0.94;
      ctx.clearRect(0, 0, W, H);
      ctx.fillStyle = fill;
      ctx.beginPath();

      if (o.band) {
        // diagonal ribbon from upper-left toward lower-right
        const p0x = W * 0.22, p0y = -H * 0.05;
        let dx = W * 0.42, dy = H, L = Math.hypot(dx, dy); dx /= L; dy /= L;
        const nx = -dy, ny = dx, bw0 = Math.max(W * 0.1, 90);
        for (let i = 0; i < fine.length; i += 2) {
          const x = fine[i], y = fine[i + 1];
          const rx = x - p0x, ry = y - p0y;
          const u = rx * dx + ry * dy;
          let v = rx * nx + ry * ny;
          v += Math.sin(u * 0.005 + t * 0.6) * W * 0.06 + Math.sin(u * 0.011 - t * 0.45) * W * 0.022;
          const bw = bw0 * (0.75 + 0.35 * Math.sin(u * 0.004 + t * 0.35));
          if (v > bw * 2.3 || v < -bw * 2.3) continue;
          const inten = Math.exp(-(v / bw) * (v / bw));
          let r = inten * 2.1 * (0.85 + 0.15 * Math.sin(u * 0.05 - t * 2));
          if (r < 0.28) continue;
          const w = warp(x, y, r);
          ctx.moveTo(w[0] + w[2], w[1]); ctx.arc(w[0], w[1], w[2], 0, TAU);
        }
      }

      if (o.swirl) {
        const cx = W * o.swirlX, cy = H * o.swirlY, maxR = Math.max(W < 700 ? 7 : 9, 4);
        for (let i = 0; i < coarse.length; i += 2) {
          const x = coarse[i], y = coarse[i + 1];
          const mask = Math.min(Math.max((x - W * 0.42) / (W * 0.55), 0), 1);
          if (mask <= 0.02) continue;
          const ddx = x - cx, ddy = y - cy, rr = Math.hypot(ddx, ddy), a = Math.atan2(ddy, ddx);
          const ring = 0.5 + 0.5 * Math.sin(rr * 0.011 - t * 0.9 + a * 2.0);
          const ring2 = 0.5 + 0.5 * Math.sin(rr * 0.02 + t * 0.5 - a * 3.0);
          let r = mask * mask * (0.6 + maxR * (0.55 * ring + 0.45 * ring2) * mask);
          if (r < 0.7) continue;
          const w = warp(x, y, r);
          ctx.moveTo(w[0] + w[2], w[1]); ctx.arc(w[0], w[1], w[2], 0, TAU);
        }
      }
      ctx.fill();
    }

    const host = canvas.parentElement;
    function onMove(e) {
      const r = canvas.getBoundingClientRect();
      const nx = e.clientX - r.left, ny = e.clientY - r.top;
      if (m.tx < -999) { m.x = nx; m.y = ny; }
      m.tx = nx; m.ty = ny;
    }
    host.addEventListener('pointermove', onMove);
    host.addEventListener('pointerleave', () => { m.tx = -9999; m.ty = -9999; m.x = -9999; m.y = -9999; });
    host.addEventListener('pointerdown', () => { m.boost = 1.4; });

    new IntersectionObserver(([e]) => { visible = e.isIntersecting; }).observe(canvas);
    let rt; window.addEventListener('resize', () => { clearTimeout(rt); rt = setTimeout(build, 120); });
    build(); frame();
    return { destroy() { running = false; } };
  };
})();
