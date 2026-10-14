// spz-carspawner — NUI
// Client sends { action: 'open', vehicles: [{ model, label, className, classId, isAddon, image? }] }.
// `image` is only present when the server found one (ui/img or uz_AutoShot);
// cars without it, or whose image fails to load, get the placeholder.

const RES = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'spz-carspawner';
const $ = (id) => document.getElementById(id);
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const post = (name, data = {}) => fetch(`https://${RES}/${name}`, {
  method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data),
}).catch(() => null);

const CLASS_ICON = { 0: 'car-side', 1: 'car', 2: 'truck-pickup', 3: 'car-side', 4: 'gauge-high', 5: 'car-rear',
  6: 'flag-checkered', 7: 'bolt', 9: 'mountain', 12: 'van-shuttle', 22: 'circle-dot' };

let vehicles = [];
let cat = 'all';
let q = '';

function categories() {
  const byClass = new Map();
  for (const v of vehicles) {
    const c = byClass.get(v.className) || { id: 'c:' + v.className, name: v.className, classId: v.classId, n: 0 };
    c.n++; byClass.set(v.className, c);
  }
  const top = [{ id: 'all', name: 'All vehicles', icon: 'layer-group', n: vehicles.length }];
  const addons = vehicles.filter((v) => v.isAddon).length;
  if (addons) top.push({ id: 'addon', name: 'Custom mods', icon: 'star', n: addons });
  const classes = [...byClass.values()].sort((a, b) => a.classId - b.classId)
    .map((c) => ({ ...c, icon: CLASS_ICON[c.classId] || 'car' }));
  return { top, classes };
}

function renderCats() {
  const { top, classes } = categories();
  const row = (c) => `<button class="cat ${cat === c.id ? 'on' : ''}" data-cat="${esc(c.id)}">
    <i class="fa-solid fa-${c.icon}"></i><span>${esc(c.name)}</span><b>${c.n}</b></button>`;
  $('cats').innerHTML = top.map(row).join('') + '<div class="h sep">Classes</div>' + classes.map(row).join('');
  $('total').textContent = `${vehicles.length} vehicles`;
}

function filtered() {
  const s = q.trim().toLowerCase();
  return vehicles.filter((v) => {
    if (cat === 'addon' && !v.isAddon) return false;
    if (cat.startsWith('c:') && v.className !== cat.slice(2)) return false;
    return !s || v.label.toLowerCase().includes(s) || v.model.includes(s);
  });
}

const placeholder = '<div class="none"><i class="fa-solid fa-car-side"></i>No image</div>';

function renderGrid() {
  const list = filtered();
  const { top, classes } = categories();
  const c = [...top, ...classes].find((x) => x.id === cat) || top[0];
  $('cat-title').textContent = c.name;
  const withImg = list.filter((v) => v.image).length;
  $('cat-sub').textContent = `${list.length} shown · ${withImg} with photo`;

  $('grid').innerHTML = list.length ? list.map((v) => `
    <button class="card" data-model="${esc(v.model)}">
      <div class="pic">
        ${v.image ? `<img src="${esc(v.image)}" loading="lazy" alt="">` : placeholder}
        ${v.isAddon ? '<span class="badge">Mod</span>' : ''}
      </div>
      <div class="info"><div class="nm">${esc(v.label)}</div><div class="md">${esc(v.model)} · ${esc(v.className)}</div></div>
    </button>`).join('') : '<div class="empty">No vehicles match.</div>';

  // An image that is mapped but fails to load falls back to the placeholder too.
  $('grid').querySelectorAll('img').forEach((img) => {
    img.onerror = () => { img.parentElement.insertAdjacentHTML('afterbegin', placeholder); img.remove(); };
  });
}

function render() { renderCats(); renderGrid(); }

document.addEventListener('click', (e) => {
  const c = e.target.closest('[data-cat]');
  if (c) { cat = c.dataset.cat; render(); $('grid').scrollTop = 0; return; }
  const card = e.target.closest('[data-model]');
  if (card) post('spawn', { model: card.dataset.model });
});

$('q').addEventListener('input', (e) => { q = e.target.value; renderGrid(); });
$('x').onclick = () => post('close');
$('by-model').addEventListener('submit', (e) => {
  e.preventDefault();
  const m = $('model-in').value.trim();
  if (m) { post('spawn', { model: m }); $('model-in').value = ''; }
});

document.addEventListener('keydown', (e) => { if (e.key === 'Escape') post('close'); });

function applyTheme(t) {
  if (!t) return;
  const r = document.documentElement.style;
  if (t.accent) r.setProperty('--accent', t.accent);
  if (t.bg) r.setProperty('--bg', t.bg);
  if (t.bg2) r.setProperty('--bg2', t.bg2);
}

window.addEventListener('message', ({ data }) => {
  if (!data) return;
  if (data.action === 'theme') applyTheme(data.theme);
  if (data.action === 'open') {
    vehicles = data.vehicles || [];
    const { top, classes } = categories();
    if (![...top, ...classes].some((c) => c.id === cat)) cat = 'all';
    $('app').classList.remove('hidden');
    render();
    $('q').focus();
  }
  if (data.action === 'close') $('app').classList.add('hidden');
});

post('uiReady');

// Browser preview outside FiveM.
if (typeof GetParentResourceName !== 'function') {
  window.postMessage({ action: 'open', vehicles: [
    { model: 'adder', label: 'Truffade Adder', className: 'Super', classId: 7 },
    { model: 'sultan', label: 'Karin Sultan', className: 'Sports', classId: 6, image: 'img/missing.png' },
    { model: 'gtr', label: 'Nissan GT-R', className: 'Sports', classId: 6, isAddon: true },
  ] }, '*');
}
