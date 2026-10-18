// Keep the ad outside #app: tile moves re-render the game, never the ad.
const slot = document.querySelector('#juicy-ad-slot');
const zones = [
  { id: 1129382, width: 908, height: 258 },
  { id: 1129383, width: 632, height: 190 },
  { id: 1129384, width: 308, height: 286 },
];
const zone = zones.find(({ width }) => width <= slot.clientWidth) || zones[2];
const ad = document.createElement('ins');
ad.id = String(zone.id);
ad.dataset.width = String(zone.width);
ad.dataset.height = String(zone.height);
ad.style.display = 'block';
ad.style.width = `${zone.width}px`;
ad.style.height = `${zone.height}px`;
ad.style.transformOrigin = 'top left';
slot.append(ad);

// Fit a previously loaded creative after rotation without requesting more ads.
new ResizeObserver(() => {
  const scale = Math.min(1, slot.clientWidth / zone.width);
  ad.style.transform = `scale(${scale})`;
  ad.style.marginLeft = `${Math.max(0, (slot.clientWidth - zone.width) / 2)}px`;
  slot.style.height = `${zone.height * scale}px`;
}).observe(slot);

window.adsbyjuicy = window.adsbyjuicy || [];
window.adsbyjuicy.push({ adzone: zone.id });
const loader = document.createElement('script');
loader.src = 'https://poweredby.jads.co/js/jads.js';
loader.async = true;
loader.dataset.cfasync = 'false';
document.head.append(loader);
