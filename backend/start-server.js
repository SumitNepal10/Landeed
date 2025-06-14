const { spawn } = require('child_process');
const path = require('path');

// Use the server.js file in the root directory
const server = spawn('node', ['server.js'], {
  stdio: 'inherit',
  shell: true,
  env: {
    ...process.env,
    NODE_ENV: 'development',
  },
});

server.on('error', (err) => {
  console.error('Failed to start server:', err);
});

process.on('SIGINT', () => {
  server.kill('SIGINT');
  process.exit();
}); 