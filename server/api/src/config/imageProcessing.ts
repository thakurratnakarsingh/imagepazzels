import sharp from 'sharp';

const parsePositiveInteger = (value: string | undefined, fallback: number) => {
  const parsed = Number.parseInt(value || '', 10);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : fallback;
};

export const configureImageProcessing = () => {
  sharp.concurrency(parsePositiveInteger(process.env.SHARP_CONCURRENCY, 1));
  sharp.cache({
    files: 0,
    memory: parsePositiveInteger(process.env.SHARP_CACHE_MEMORY_MB, 32),
    items: 64,
  });
};
