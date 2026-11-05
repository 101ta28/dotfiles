import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const original = readFileSync(join(ROOT, 'SKILL.md'), 'utf8');
const currentVersion = /const VERSION = '([^']+)'/.exec(readFileSync(join(ROOT, 'scripts', 'theme.mjs'), 'utf8'))[1];
const withoutVersion = original.replace(/^  version:.*\n/m, '');

function check(source) {
  const temporary = mkdtempSync(join(tmpdir(), 'hallmark-refcheck-test-'));
  try {
    const skill = join(temporary, 'hallmark');
    cpSync(ROOT, skill, { recursive: true });
    writeFileSync(join(skill, 'SKILL.md'), source);
    const result = spawnSync(process.execPath, [join(skill, 'scripts', 'refcheck.mjs'), '--json'], {
      cwd: temporary,
      encoding: 'utf8',
      timeout: 30000,
    });
    assert.ifError(result.error);
    assert.equal(result.stderr, '');
    return { status: result.status, ...JSON.parse(result.stdout) };
  } finally {
    rmSync(temporary, { recursive: true, force: true });
  }
}

test('metadata version passes all reference and fixture checks', () => {
  const result = check(original);
  assert.equal(result.status, 0, JSON.stringify(result.findings));
  assert.equal(result.errors, 0);
  assert.equal(result.warns, 0);
});

test('legacy upstream version remains supported', () => {
  const result = check(withoutVersion.replace('metadata:\n', `version: ${currentVersion}\nmetadata:\n`));
  assert.equal(result.status, 0, JSON.stringify(result.findings));
  assert.equal(result.errors, 0);
});

test('metadata version takes precedence and detects a script version mismatch', () => {
  const source = original.replace(/^  version:.*$/m, '  version: "999.0.0"')
    .replace('metadata:\n', `version: ${currentVersion}\nmetadata:\n`);
  const result = check(source);
  assert.equal(result.status, 1);
  assert.ok(result.findings.some((finding) => finding.file === 'scripts/theme.mjs' && finding.rule === 'version'));
});

test('a version in the body cannot replace missing frontmatter metadata', () => {
  const result = check(`${withoutVersion}\nversion: ${currentVersion}\n`);
  assert.equal(result.status, 1);
  assert.ok(result.findings.some((finding) => finding.rule === 'frontmatter' && finding.msg.includes('version')));
});

test('malformed metadata does not silently fall back to a legacy version', () => {
  const source = original.replace(/^  version:.*$/m, '  version: "invalid"')
    .replace('metadata:\n', `version: ${currentVersion}\nmetadata:\n`);
  const result = check(source);
  assert.equal(result.status, 1);
  assert.ok(result.findings.some((finding) => finding.rule === 'frontmatter' && finding.msg.includes('version')));
});

test('the entrypoint size limit still rejects oversized instructions', () => {
  const result = check(`${original}\n${'x'.repeat(19001)}`);
  assert.equal(result.status, 1);
  assert.ok(result.findings.some((finding) => finding.rule === 'size'));
});
