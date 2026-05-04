#!/usr/bin/env node
/**
 * tools/audit-postflop.js — v1.0.0
 *
 * Node-CLI wrapper around postflop/postflop_audit_rules.js. Reuses the same
 * pure-function audit logic the browser viewer uses (postflop_audit.html).
 * One source of truth for audit rules; this file just feeds it from disk
 * and prints a report to stdout (with a Markdown export option).
 *
 * Usage (when Node is installed):
 *   node tools/audit-postflop.js                  # human-readable summary
 *   node tools/audit-postflop.js --markdown       # full markdown report to stdout
 *   node tools/audit-postflop.js --json           # machine-readable JSON
 *   node tools/audit-postflop.js --out report.md  # write markdown to file
 *
 * Exit codes:
 *   0 — audit passed (0 errors; warnings are allowed)
 *   1 — audit failed (>= 1 error)
 *   2 — could not load files / runtime error
 *
 * If Node is NOT installed: open postflop/postflop_audit.html in a browser
 * (best served via the project's local server: powershell -File .claude\serve.ps1).
 * Both paths run identical audit logic.
 *
 * This script must NEVER:
 *  - modify postflop_*.json files (Audit Subagent reads only; data fixes go via GTO Data Subagent)
 *  - modify index.html or service-worker.js
 *  - bump versions
 *  - commit or push
 */

'use strict';

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');
const PATHS = {
  scenarios: path.join(REPO_ROOT, 'postflop', 'postflop_scenarios.json'),
  taxonomy:  path.join(REPO_ROOT, 'postflop', 'postflop_taxonomy.json'),
  concepts:  path.join(REPO_ROOT, 'postflop', 'postflop_concepts.json'),
  auditRules: path.join(REPO_ROOT, 'postflop', 'postflop_audit_rules.js')
};

// ---------- CLI args ----------

const args = process.argv.slice(2);
const flags = {
  markdown: args.includes('--markdown') || args.includes('--md'),
  json:     args.includes('--json'),
  out:      null
};
const outIdx = args.indexOf('--out');
if (outIdx !== -1 && args[outIdx + 1]) flags.out = args[outIdx + 1];

// ---------- Load files ----------

function readJson(p) {
  try {
    return JSON.parse(fs.readFileSync(p, 'utf8'));
  } catch (err) {
    console.error(`ERROR: could not read ${p}`);
    console.error(err.message);
    process.exit(2);
  }
}

function loadAuditRules() {
  // The audit rules file uses a UMD-ish IIFE that attaches to either
  // `module.exports` (Node) or `window.PostflopAudit` (browser).
  // require() works because `module.exports = api` runs in the IIFE.
  try {
    return require(PATHS.auditRules);
  } catch (err) {
    console.error(`ERROR: could not load audit rules from ${PATHS.auditRules}`);
    console.error(err.message);
    process.exit(2);
  }
}

const data     = readJson(PATHS.scenarios);
const taxonomy = readJson(PATHS.taxonomy);
const concepts = readJson(PATHS.concepts);
const audit    = loadAuditRules();

// ---------- Run audit ----------

const report = audit.runAudit(data, taxonomy, concepts);

// ---------- Output ----------

if (flags.json) {
  const out = JSON.stringify(report, null, 2);
  if (flags.out) {
    fs.writeFileSync(flags.out, out);
    console.error(`Wrote ${flags.out}`);
  } else {
    process.stdout.write(out);
  }
} else if (flags.markdown) {
  const md = toMarkdown(report);
  if (flags.out) {
    fs.writeFileSync(flags.out, md);
    console.error(`Wrote ${flags.out}`);
  } else {
    process.stdout.write(md);
  }
} else {
  // Default: human-readable summary
  printSummary(report);
}

process.exit(report.stats.errorCount === 0 ? 0 : 1);

// ---------- Helpers ----------

function printSummary(r) {
  const st = r.stats;
  const status = st.errorCount === 0 ? '✅ PASS' : '❌ FAIL';
  console.log('============================================');
  console.log('Postflop Audit Report');
  console.log('============================================');
  console.log(`Schema version: ${r.schemaVersion}`);
  console.log(`Generated:      ${r.generatedAt}`);
  console.log(`Status:         ${status}`);
  console.log('');
  console.log(`Total scenarios: ${r.totalScenarios}`);
  console.log(`  Pass (no errors): ${st.passCount}`);
  console.log(`  Fail (>= 1 error): ${st.failCount}`);
  console.log(`  Approved: ${st.approvedCount}`);
  console.log(`  Drafts:   ${st.draftCount}`);
  console.log(`Errors:   ${st.errorCount}`);
  console.log(`Warnings: ${st.warningCount}`);
  console.log('');
  console.log('Distribution:');
  console.log(`  By module:           ${distLine(st.byModule)}`);
  console.log(`  By difficulty:       ${distLine(st.byDifficulty)}`);
  console.log(`  By high-card class:  ${distLine(st.byHighCardClass)}`);
  console.log(`  By suit texture:     ${distLine(st.bySuitTexture)}`);
  console.log(`  By range advantage:  ${distLine(st.byRangeAdvantage)}`);
  console.log(`  By nut advantage:    ${distLine(st.byNutAdvantage)}`);
  console.log(`  By audit status:     ${distLine(st.byAuditStatus)}`);
  console.log(`  By source confidence: ${distLine(st.bySourceConfidence)}`);

  if (st.conceptCoverageStarved.length > 0) {
    console.log('');
    console.log(`Starved concepts (< 3 scenarios): ${st.conceptCoverageStarved.length}`);
    for (const c of st.conceptCoverageStarved) {
      console.log(`  - ${c.tag} (${c.count})`);
    }
  }

  if (r.issues.length > 0) {
    console.log('');
    console.log('Issues:');
    for (const i of r.issues) {
      const tag = i.severity === 'error' ? '[ERR]' : '[WRN]';
      console.log(`  ${tag} ${i.rule} ${i.scenarioId} — ${i.message}`);
    }
  } else {
    console.log('');
    console.log('No issues. ✨');
  }
  console.log('============================================');
}

function distLine(obj) {
  return Object.entries(obj).sort((a, b) => b[1] - a[1])
    .map(([k, v]) => `${k}=${v}`).join(', ') || '(none)';
}

function toMarkdown(r) {
  const st = r.stats;
  let md = `# Postflop Audit Report\n\n`;
  md += `- **Schema version**: ${r.schemaVersion}\n`;
  md += `- **Generated**: ${r.generatedAt}\n`;
  md += `- **Total scenarios**: ${r.totalScenarios}\n`;
  md += `- **Errors**: ${st.errorCount}\n`;
  md += `- **Warnings**: ${st.warningCount}\n`;
  md += `- **Passing**: ${st.passCount} / ${r.totalScenarios}\n\n`;
  md += `## Distribution\n\n`;
  md += `### By module\n${objToMd(st.byModule)}\n\n`;
  md += `### By difficulty\n${objToMd(st.byDifficulty)}\n\n`;
  md += `### By high-card class\n${objToMd(st.byHighCardClass)}\n\n`;
  md += `### By suit texture\n${objToMd(st.bySuitTexture)}\n\n`;
  md += `### By range advantage\n${objToMd(st.byRangeAdvantage)}\n\n`;
  md += `### By nut advantage\n${objToMd(st.byNutAdvantage)}\n\n`;
  md += `### By audit status\n${objToMd(st.byAuditStatus)}\n\n`;
  md += `### By source confidence\n${objToMd(st.bySourceConfidence)}\n\n`;
  if (st.conceptCoverageStarved.length) {
    md += `## Starved concepts (< 3 scenarios)\n\n`;
    for (const c of st.conceptCoverageStarved) md += `- \`${c.tag}\`: ${c.count}\n`;
    md += `\n`;
  }
  if (r.issues.length === 0) {
    md += `## ✅ Issues — none\n\nAll scenarios pass.\n`;
  } else {
    md += `## Issues (${r.issues.length})\n\n`;
    for (const i of r.issues) {
      md += `- **${i.rule}** [${i.severity}] \`${i.scenarioId}\` — ${i.message}\n`;
    }
  }
  return md;
}

function objToMd(obj) {
  return Object.entries(obj).sort((a, b) => b[1] - a[1])
    .map(([k, v]) => `- \`${k}\`: ${v}`).join('\n') || '_(none)_';
}
