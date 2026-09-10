import fs from 'fs';
import fsp from 'fs/promises';
import path from 'path';
import { createHash } from 'crypto';
import { Request } from 'express';

const API_ROOT = path.resolve(__dirname, '..', '..');

const isErrnoException = (error: unknown): error is NodeJS.ErrnoException => (
  error instanceof Error && 'code' in error
);

const isInsideUploadRoot = (filePath: string, rootPath: string) => {
  const normalizedFile = path.resolve(filePath);
  const normalizedRoot = path.resolve(rootPath);
  const comparableFile = process.platform === 'win32' ? normalizedFile.toLowerCase() : normalizedFile;
  const comparableRoot = process.platform === 'win32' ? normalizedRoot.toLowerCase() : normalizedRoot;
  const rootPrefix = comparableRoot.endsWith(path.sep) ? comparableRoot : `${comparableRoot}${path.sep}`;

  return comparableFile === comparableRoot || comparableFile.startsWith(rootPrefix);
};

export const getUploadRoot = () => {
  const configuredRoot = process.env.UPLOAD_ROOT?.trim();
  if (!configuredRoot) {
    return path.join(API_ROOT, 'uploads');
  }

  return path.isAbsolute(configuredRoot)
    ? path.normalize(configuredRoot)
    : path.resolve(API_ROOT, configuredRoot);
};

export const getUploadTempDir = () => path.join(getUploadRoot(), '.tmp');

export const uploadPath = (...segments: string[]) => path.join(getUploadRoot(), ...segments);

export const toUploadRelativePath = (...segments: string[]) => (
  segments
    .map((segment) => segment.replace(/^[/\\]+|[/\\]+$/g, ''))
    .filter(Boolean)
    .join('/')
);

export const cleanRelativeUploadPath = (relativePath: string) => (
  relativePath.replace(/^[/\\]+/g, '').replace(/\\/g, '/')
);

export const resolveUploadPath = (relativePath: string) => {
  const cleanPath = cleanRelativeUploadPath(relativePath);
  const resolvedPath = path.resolve(getUploadRoot(), cleanPath.split('/').join(path.sep));
  const uploadRoot = getUploadRoot();

  if (!isInsideUploadRoot(resolvedPath, uploadRoot)) {
    throw new Error(`Refusing to access path outside upload root: ${relativePath}`);
  }

  return resolvedPath;
};

export const ensureUploadDir = async (...segments: string[]) => {
  const directory = uploadPath(...segments);
  await fsp.mkdir(directory, { recursive: true });
  return directory;
};

export const deleteFileIfExists = async (filePath: string | null | undefined) => {
  if (!filePath) return;

  try {
    await fsp.unlink(filePath);
  } catch (error) {
    if (!isErrnoException(error) || error.code !== 'ENOENT') {
      console.warn(`Could not delete file ${filePath}`, error);
    }
  }
};

export const deleteUploadFileIfExists = async (relativePath: string | null | undefined) => {
  if (!relativePath) return;
  await deleteFileIfExists(resolveUploadPath(relativePath));
};

export const hashFile = (filePath: string) => new Promise<string>((resolve, reject) => {
  const hash = createHash('sha256');
  const input = fs.createReadStream(filePath);

  input.on('error', reject);
  input.on('data', (chunk) => hash.update(chunk));
  input.on('end', () => resolve(hash.digest('hex')));
});

const fileExists = async (filePath: string) => {
  try {
    await fsp.access(filePath);
    return true;
  } catch (error) {
    if (isErrnoException(error) && error.code === 'ENOENT') {
      return false;
    }
    throw error;
  }
};

export const finalizeHashedUpload = async ({
  tempFilePath,
  targetDir,
  filenamePrefix,
  filenameSuffix = '',
  extension = '.webp',
}: {
  tempFilePath: string;
  targetDir: string;
  filenamePrefix: string;
  filenameSuffix?: string;
  extension?: string;
}) => {
  const contentHash = await hashFile(tempFilePath);
  const filename = `${filenamePrefix}-${contentHash}${filenameSuffix}${extension}`;
  const finalPath = path.join(targetDir, filename);

  await fsp.mkdir(targetDir, { recursive: true });

  if (await fileExists(finalPath)) {
    await deleteFileIfExists(tempFilePath);
  } else {
    try {
      await fsp.rename(tempFilePath, finalPath);
    } catch (error) {
      if (await fileExists(finalPath)) {
        await deleteFileIfExists(tempFilePath);
      } else {
        throw error;
      }
    }
  }

  const stat = await fsp.stat(finalPath);
  return { filename, filePath: finalPath, size: stat.size, hash: contentHash };
};

export const cleanupUploadedTempFiles = async (req: Request) => {
  const files: Express.Multer.File[] = [];

  if (req.file) {
    files.push(req.file);
  }

  const requestFiles = req.files;
  if (Array.isArray(requestFiles)) {
    files.push(...requestFiles);
  } else if (requestFiles) {
    files.push(...Object.values(requestFiles).flat());
  }

  await Promise.all(files.map((file) => deleteFileIfExists(file.path)));
};
