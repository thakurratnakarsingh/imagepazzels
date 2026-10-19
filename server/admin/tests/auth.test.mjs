import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import vm from 'node:vm';
import ts from 'typescript';

function loadAuth(stored = {}) {
  const values = new Map(Object.entries(stored));
  const localStorage = {
    getItem: key => values.get(key) ?? null,
    setItem: (key, value) => values.set(key, value),
    removeItem: key => values.delete(key),
  };
  const source = readFileSync(new URL('../src/store/authSlice.ts', import.meta.url), 'utf8');
  const compiled = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 },
  }).outputText;
  const context = { exports: {}, require: createRequire(import.meta.url), localStorage };
  vm.runInNewContext(compiled, context);
  return { ...context.exports, values };
}

test('malformed stored profile does not crash authentication initialization', () => {
  const auth = loadAuth({ adminProfile: '{broken' });
  const state = auth.default(undefined, { type: 'init' });
  assert.equal(state.admin, null);
  assert.equal(state.token, null);
});

test('login persists credentials, refresh keeps profile, logout removes credentials', () => {
  const auth = loadAuth();
  const admin = { id: 1, email: 'admin@example.test', name: 'Admin' };
  let state = auth.default(undefined, auth.setCredentials({ admin, accessToken: 'access', refreshToken: 'refresh' }));
  assert.equal(state.token, 'access');
  assert.equal(auth.values.get('adminRefreshToken'), 'refresh');
  state = auth.default(state, auth.setAccessToken('replacement'));
  assert.equal(state.admin.email, admin.email);
  assert.equal(state.refreshToken, 'refresh');
  assert.equal(auth.values.get('adminToken'), 'replacement');
  state = auth.default(state, auth.logout());
  assert.equal(state.token, null);
  assert.equal(state.refreshToken, null);
  assert.equal(state.admin, null);
  assert.equal(auth.values.size, 0);
});
