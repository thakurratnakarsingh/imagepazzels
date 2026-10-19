// Outside #app so result updates do not reload the same completion ad.
const slot = document.querySelector('#juicy-ad-slot');
const section = slot.closest('.ad-section');
const zones = [
  { id: 1129382, width: 908, height: 258 },
  { id: 1129383, width: 632, height: 190 },
  { id: 1129384, width: 308, height: 286 },
];
let completionKey = null;
let observer = null;
let loaderAdded = false;

export function syncCompletionAd(key) {
  if (key === completionKey) return;
  completionKey = key;
  observer?.disconnect();
  slot.replaceChildren();
  slot.style.height = '';
  section.hidden = !key;
  if (!key) return;

  const zone = zones.find(({ width }) => width <= slot.clientWidth) || zones[2];
  const ad = document.createElement('ins');
  ad.id = String(zone.id);
  ad.dataset.width = String(zone.width);
  ad.dataset.height = String(zone.height);
  Object.assign(ad.style, {
    display: 'block', width: `${zone.width}px`, height: `${zone.height}px`,
    transformOrigin: 'top left',
  });
  slot.append(ad);
  const fit = () => {
    const scale = Math.min(1, slot.clientWidth / zone.width);
    ad.style.transform = `scale(${scale})`;
    ad.style.marginLeft = `${Math.max(0, (slot.clientWidth - zone.width) / 2)}px`;
    slot.style.height = `${zone.height * scale}px`;
  };
  fit();
  observer = new ResizeObserver(fit);
  observer.observe(slot);

  window.adsbyjuicy = window.adsbyjuicy || [];
  window.adsbyjuicy.push({ adzone: zone.id });
  if (!loaderAdded) {
    const loader = document.createElement('script');
    loader.src = 'https://poweredby.jads.co/js/jads.js';
    loader.async = true;
    loader.dataset.cfasync = 'false';
    document.head.append(loader);
    loaderAdded = true;
  }
  document.querySelector('.completion-panel')?.scrollIntoView({ block: 'start', behavior: 'smooth' });
}
