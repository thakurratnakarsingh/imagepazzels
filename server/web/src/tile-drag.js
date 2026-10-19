// One pointer owns one tile. Render the clipped tile as the drag preview rather
// than letting the browser snapshot its oversized puzzle-image child.
let active = null;

export function cancelTileDrag() {
  if (!active) return;
  const { tile, pointerId, preview } = active;
  active = null;
  preview?.remove();
  tile.classList.remove('is-dragging');
  if (tile.hasPointerCapture(pointerId)) tile.releasePointerCapture(pointerId);
}

export function bindPuzzleTile(tile, { onTap, onSwap, canPlay }) {
  tile.addEventListener('dragstart', (event) => event.preventDefault());
  tile.addEventListener('click', (event) => {
    // Pointer taps are handled below; retain keyboard activation.
    if (event.detail === 0 && !active && canPlay()) onTap(Number(tile.dataset.position));
    else event.preventDefault();
  });
  tile.addEventListener('pointerdown', (event) => {
    if (active || !event.isPrimary || event.button !== 0 || !canPlay()) return;
    event.preventDefault();
    tile.focus({ preventScroll: true });
    active = {
      tile, pointerId: event.pointerId,
      position: Number(tile.dataset.position),
      x: event.clientX, y: event.clientY, preview: null,
    };
    tile.setPointerCapture(event.pointerId);
  });
  tile.addEventListener('pointermove', (event) => {
    if (!active || active.tile !== tile || active.pointerId !== event.pointerId) return;
    const dx = event.clientX - active.x;
    const dy = event.clientY - active.y;
    if (!active.preview && Math.hypot(dx, dy) < 6) return;
    event.preventDefault();
    if (!active.preview) {
      const rect = tile.getBoundingClientRect();
      const preview = tile.cloneNode(true);
      preview.removeAttribute('id');
      preview.removeAttribute('data-action');
      preview.setAttribute('aria-hidden', 'true');
      preview.classList.add('tile-drag-preview');
      Object.assign(preview.style, {
        position: 'fixed', left: `${rect.left}px`, top: `${rect.top}px`,
        width: `${rect.width}px`, height: `${rect.height}px`, margin: '0',
      });
      document.body.append(preview);
      active.preview = preview;
      tile.classList.add('is-dragging');
    }
    active.preview.style.transform = `translate(${dx}px, ${dy}px)`;
  });
  tile.addEventListener('pointerup', (event) => {
    if (!active || active.tile !== tile || active.pointerId !== event.pointerId) return;
    event.preventDefault();
    const { position, preview } = active;
    const target = document.elementFromPoint(event.clientX, event.clientY)?.closest('[data-action="tile"]');
    const sameBoard = target?.closest('.board') === tile.closest('.board');
    cancelTileDrag();
    if (!canPlay()) return;
    if (!preview) onTap(position);
    else if (target && sameBoard) onSwap(position, Number(target.dataset.position));
  });
  for (const name of ['pointercancel', 'lostpointercapture']) {
    tile.addEventListener(name, (event) => {
      if (active?.pointerId === event.pointerId) cancelTileDrag();
    });
  }
}
