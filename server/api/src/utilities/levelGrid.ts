export const gridSizeForLevel = (levelNumber: number): number => {
  if (levelNumber <= 25) return 3;
  if (levelNumber <= 50) return 4;
  return 5;
};
