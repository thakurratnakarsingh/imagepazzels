module.exports = {
  apps: [
    {
      name: 'actress-api',
      cwd: './api',
      script: './dist/server.js',
      env: {
        NODE_ENV: 'production',
        PORT: 5000,
      },
    },
    {
      name: 'actress-admin',
      cwd: './admin',
      script: 'npm.cmd',
      args: 'start',
      interpreter: 'none',
      env: {
        NODE_ENV: 'production',
      },
    },
  ],
};