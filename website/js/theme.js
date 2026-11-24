/* MSW Community — light / dark theme.
   Loaded in <head> so the right theme paints first (no flash).
   Any element with [data-theme-toggle] flips the theme; the choice is remembered. */
(function () {
  var KEY = 'msw-theme', root = document.documentElement;
  var saved = null;
  try { saved = localStorage.getItem(KEY); } catch (e) {}
  var sys = window.matchMedia && matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  root.setAttribute('data-theme', saved || sys);

  window.mswToggleTheme = function () {
    var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    root.classList.add('theme-anim');
    root.setAttribute('data-theme', next);
    try { localStorage.setItem(KEY, next); } catch (e) {}
    document.dispatchEvent(new CustomEvent('themechange', { detail: next }));
    setTimeout(function () { root.classList.remove('theme-anim'); }, 500);
  };
  document.addEventListener('click', function (e) {
    var b = e.target.closest && e.target.closest('[data-theme-toggle]');
    if (b) { e.preventDefault(); window.mswToggleTheme(); }
  });
})();
