/**
 * postflop_audit_rules.js — v1.0.0
 *
 * Pure-function audit rules for postflop_scenarios.json. Loaded by
 * postflop_audit.html (browser) — also runnable in Node by attaching
 * `module.exports = ...`. No DOM dependencies; no app-state coupling.
 *
 * Each rule is a function: (scenario, context) -> Issue[]
 *   Issue = { rule: string, severity: 'error'|'warning', message: string, scenarioId?: string }
 *
 * `context` carries cross-scenario data (taxonomy, concepts, all scenarios)
 * so rules like "no duplicate IDs" can reach across the dataset.
 */

(function (root) {
  'use strict';

  // ---------- Helpers ----------

  function isObj(x) { return x !== null && typeof x === 'object' && !Array.isArray(x); }
  function isStr(x) { return typeof x === 'string'; }
  function isNum(x) { return typeof x === 'number' && !isNaN(x); }
  function isArr(x) { return Array.isArray(x); }
  function nonEmptyStr(x) { return isStr(x) && x.trim().length > 0; }

  function parseCard(card) {
    if (!isStr(card) || card.length !== 2) return null;
    const rank = card[0];
    const suit = card[1];
    return { rank, suit, str: card };
  }

  function rankIndex(rank) {
    return ['2','3','4','5','6','7','8','9','T','J','Q','K','A'].indexOf(rank);
  }

  function topRank(cards) {
    let best = -1;
    let bestRank = null;
    for (const c of cards) {
      const idx = rankIndex(c.rank);
      if (idx > best) { best = idx; bestRank = c.rank; }
    }
    return bestRank;
  }

  // ---------- The 17 rules ----------

  /**
   * R01 — Required top-level fields exist.
   */
  function R01_requiredFields(s) {
    const required = [
      'id', 'version', 'schemaVersion', 'game', 'module', 'street',
      'spot', 'board', 'actionHistory', 'question', 'answer',
      'scoring', 'explanation', 'conceptTags', 'difficulty',
      'sourceConfidence', 'auditStatus'
    ];
    const issues = [];
    for (const f of required) {
      if (!(f in s)) issues.push({
        rule: 'R01', severity: 'error',
        message: `Missing required field: ${f}`,
        scenarioId: s.id || '<unknown>'
      });
    }
    return issues;
  }

  /**
   * R02 — Board cards valid.
   *  - flop: exactly 3 cards
   *  - all from the 52-card deck (rank A K Q J T 9-2; suit s h d c)
   *  - no duplicates
   *  - highCardClass matches the highest rank actually on the board
   */
  function R02_boardCardsValid(s, ctx) {
    const issues = [];
    if (!s.board || !isArr(s.board.cards)) {
      return [{ rule: 'R02', severity: 'error', scenarioId: s.id, message: 'board.cards missing or not an array' }];
    }
    const expectedLen = { flop: 3, turn: 4, river: 5 }[s.street];
    if (expectedLen && s.board.cards.length !== expectedLen) {
      issues.push({ rule: 'R02', severity: 'error', scenarioId: s.id,
        message: `Board has ${s.board.cards.length} cards but street=${s.street} requires ${expectedLen}` });
    }
    const validRanks = ctx && ctx.taxonomy ? ctx.taxonomy.validRanks : ['A','K','Q','J','T','9','8','7','6','5','4','3','2'];
    const validSuits = ctx && ctx.taxonomy ? ctx.taxonomy.validSuits : ['s','h','d','c'];
    const seen = new Set();
    const parsed = [];
    for (const cardStr of s.board.cards) {
      const c = parseCard(cardStr);
      if (!c) {
        issues.push({ rule: 'R02', severity: 'error', scenarioId: s.id, message: `Invalid card string: "${cardStr}"` });
        continue;
      }
      if (!validRanks.includes(c.rank)) {
        issues.push({ rule: 'R02', severity: 'error', scenarioId: s.id, message: `Invalid rank in card "${cardStr}"` });
      }
      if (!validSuits.includes(c.suit)) {
        issues.push({ rule: 'R02', severity: 'error', scenarioId: s.id, message: `Invalid suit in card "${cardStr}"` });
      }
      if (seen.has(c.str)) {
        issues.push({ rule: 'R02', severity: 'error', scenarioId: s.id, message: `Duplicate board card: "${cardStr}"` });
      }
      seen.add(c.str);
      parsed.push(c);
    }
    // highCardClass derivation check
    if (parsed.length > 0 && ctx && ctx.taxonomy && ctx.taxonomy.highCardDerivation) {
      const expectedClass = ctx.taxonomy.highCardDerivation[topRank(parsed)];
      if (expectedClass && s.board.highCardClass !== expectedClass) {
        issues.push({ rule: 'R02', severity: 'error', scenarioId: s.id,
          message: `highCardClass="${s.board.highCardClass}" but top board rank derives "${expectedClass}"` });
      }
    }
    // hero hand collision check
    if (isArr(s.heroHand)) {
      for (const cardStr of s.heroHand) {
        const c = parseCard(cardStr);
        if (c && seen.has(c.str)) {
          issues.push({ rule: 'R02', severity: 'error', scenarioId: s.id,
            message: `Hero hand card "${cardStr}" duplicates a board card` });
        }
      }
    }
    return issues;
  }

  /**
   * R03 — No duplicate scenario IDs.
   * Uses ctx.idCounts populated by the runner.
   */
  function R03_noDuplicateIds(s, ctx) {
    if (!ctx || !ctx.idCounts) return [];
    if (ctx.idCounts[s.id] > 1) {
      return [{ rule: 'R03', severity: 'error', scenarioId: s.id,
        message: `Duplicate id appears ${ctx.idCounts[s.id]} times in dataset` }];
    }
    return [];
  }

  /**
   * R04 — Question choices include all answer keys.
   * Every id referenced in answer.{best,acceptable,bad,critical} must be
   * a real choice id from question.choices.
   */
  function R04_choicesIncludeAnswers(s) {
    const issues = [];
    if (!s.question || !isArr(s.question.choices)) {
      return [{ rule: 'R04', severity: 'error', scenarioId: s.id, message: 'question.choices missing' }];
    }
    const choiceIds = new Set(s.question.choices.map(c => c && c.id));
    if (!s.answer) return [{ rule: 'R04', severity: 'error', scenarioId: s.id, message: 'answer missing' }];
    for (const tier of ['best','acceptable','bad','critical']) {
      const list = s.answer[tier];
      if (!isArr(list)) {
        issues.push({ rule: 'R04', severity: 'error', scenarioId: s.id, message: `answer.${tier} must be an array` });
        continue;
      }
      for (const id of list) {
        if (!choiceIds.has(id)) {
          issues.push({ rule: 'R04', severity: 'error', scenarioId: s.id,
            message: `answer.${tier} references unknown choice id "${id}"` });
        }
      }
    }
    return issues;
  }

  /**
   * R05 — At least one `best` answer exists.
   */
  function R05_bestExists(s) {
    if (!s.answer || !isArr(s.answer.best) || s.answer.best.length === 0) {
      return [{ rule: 'R05', severity: 'error', scenarioId: s.id,
        message: 'answer.best must be a non-empty array' }];
    }
    return [];
  }

  /**
   * R06 — explanation.short exists and is non-empty.
   */
  function R06_shortExplanationExists(s) {
    if (!s.explanation || !nonEmptyStr(s.explanation.short)) {
      return [{ rule: 'R06', severity: 'error', scenarioId: s.id,
        message: 'explanation.short must be a non-empty string' }];
    }
    return [];
  }

  /**
   * R07 — All conceptTags exist in concepts.
   */
  function R07_conceptTagsExist(s, ctx) {
    if (!isArr(s.conceptTags)) {
      return [{ rule: 'R07', severity: 'error', scenarioId: s.id, message: 'conceptTags must be an array' }];
    }
    if (!ctx || !ctx.knownConcepts) return [];
    const issues = [];
    for (const tag of s.conceptTags) {
      if (!ctx.knownConcepts.has(tag)) {
        issues.push({ rule: 'R07', severity: 'error', scenarioId: s.id,
          message: `Unknown concept tag: "${tag}"` });
      }
    }
    return issues;
  }

  /**
   * R08 — difficulty is integer 1-5.
   */
  function R08_difficultyValid(s) {
    if (!isNum(s.difficulty) || s.difficulty < 1 || s.difficulty > 5 || s.difficulty !== Math.floor(s.difficulty)) {
      return [{ rule: 'R08', severity: 'error', scenarioId: s.id,
        message: `difficulty must be integer 1-5, got ${s.difficulty}` }];
    }
    return [];
  }

  /**
   * R09 — All board.textureTags exist in taxonomy.
   */
  function R09_textureTagsValid(s, ctx) {
    if (!s.board || !isArr(s.board.textureTags)) {
      return [{ rule: 'R09', severity: 'error', scenarioId: s.id, message: 'board.textureTags must be an array' }];
    }
    if (!ctx || !ctx.taxonomy || !isArr(ctx.taxonomy.textureTags)) return [];
    const issues = [];
    const valid = new Set(ctx.taxonomy.textureTags);
    for (const tag of s.board.textureTags) {
      if (!valid.has(tag)) {
        issues.push({ rule: 'R09', severity: 'error', scenarioId: s.id,
          message: `Unknown textureTag: "${tag}"` });
      }
    }
    return issues;
  }

  /**
   * R10 — board.rangeAdvantage and board.nutAdvantage are valid enums.
   */
  function R10_advantageEnumsValid(s, ctx) {
    if (!s.board) return [];
    const issues = [];
    if (!ctx || !ctx.taxonomy) return [];
    const validRA = new Set(ctx.taxonomy.rangeAdvantage || []);
    const validNA = new Set(ctx.taxonomy.nutAdvantage || []);
    if (!validRA.has(s.board.rangeAdvantage)) {
      issues.push({ rule: 'R10', severity: 'error', scenarioId: s.id,
        message: `Invalid board.rangeAdvantage: "${s.board.rangeAdvantage}"` });
    }
    if (!validNA.has(s.board.nutAdvantage)) {
      issues.push({ rule: 'R10', severity: 'error', scenarioId: s.id,
        message: `Invalid board.nutAdvantage: "${s.board.nutAdvantage}"` });
    }
    return issues;
  }

  /**
   * R11 — Scoring tier values are valid.
   */
  function R11_scoringTiersValid(s) {
    if (!s.scoring) return [{ rule: 'R11', severity: 'error', scenarioId: s.id, message: 'scoring missing' }];
    const issues = [];
    if (s.scoring.best !== 1.0) {
      issues.push({ rule: 'R11', severity: 'error', scenarioId: s.id,
        message: `scoring.best must be 1.0, got ${s.scoring.best}` });
    }
    if (![0.25, 0.5, 0.75].includes(s.scoring.acceptable)) {
      issues.push({ rule: 'R11', severity: 'error', scenarioId: s.id,
        message: `scoring.acceptable must be 0.25, 0.5, or 0.75; got ${s.scoring.acceptable}` });
    }
    if (s.scoring.bad !== 0) {
      issues.push({ rule: 'R11', severity: 'error', scenarioId: s.id,
        message: `scoring.bad must be 0, got ${s.scoring.bad}` });
    }
    if (s.scoring.critical !== 0) {
      issues.push({ rule: 'R11', severity: 'error', scenarioId: s.id,
        message: `scoring.critical must be 0, got ${s.scoring.critical}` });
    }
    return issues;
  }

  /**
   * R12 — Critical answers should have a commonMistake explanation
   * (so the player learns WHY it's a critical leak).
   */
  function R12_criticalsHaveExplanation(s) {
    if (!s.answer || !isArr(s.answer.critical) || s.answer.critical.length === 0) return [];
    if (!s.explanation || !nonEmptyStr(s.explanation.commonMistake)) {
      return [{ rule: 'R12', severity: 'warning', scenarioId: s.id,
        message: 'Scenario has critical answers but explanation.commonMistake is empty' }];
    }
    return [];
  }

  /**
   * R13 — No contradictory board tags (e.g., monotone+rainbow).
   */
  function R13_noContradictoryTags(s, ctx) {
    if (!s.board || !isArr(s.board.textureTags)) return [];
    if (!ctx || !ctx.taxonomy || !isArr(ctx.taxonomy.contradictoryPairs)) return [];
    const tagSet = new Set(s.board.textureTags);
    const issues = [];
    for (const pair of ctx.taxonomy.contradictoryPairs) {
      if (tagSet.has(pair[0]) && tagSet.has(pair[1])) {
        issues.push({ rule: 'R13', severity: 'error', scenarioId: s.id,
          message: `Contradictory textureTags: "${pair[0]}" + "${pair[1]}"` });
      }
    }
    // suitTexture vs textureTags consistency
    const st = s.board.suitTexture;
    if (st === 'monotone' && tagSet.has('rainbow'))      issues.push({ rule: 'R13', severity: 'error', scenarioId: s.id, message: 'suitTexture=monotone but textureTags include rainbow' });
    if (st === 'monotone' && tagSet.has('two_tone'))     issues.push({ rule: 'R13', severity: 'error', scenarioId: s.id, message: 'suitTexture=monotone but textureTags include two_tone' });
    if (st === 'rainbow' && tagSet.has('monotone'))      issues.push({ rule: 'R13', severity: 'error', scenarioId: s.id, message: 'suitTexture=rainbow but textureTags include monotone' });
    if (st === 'rainbow' && tagSet.has('two_tone'))      issues.push({ rule: 'R13', severity: 'error', scenarioId: s.id, message: 'suitTexture=rainbow but textureTags include two_tone' });
    if (st === 'two_tone' && tagSet.has('rainbow'))      issues.push({ rule: 'R13', severity: 'error', scenarioId: s.id, message: 'suitTexture=two_tone but textureTags include rainbow' });
    if (st === 'two_tone' && tagSet.has('monotone'))     issues.push({ rule: 'R13', severity: 'error', scenarioId: s.id, message: 'suitTexture=two_tone but textureTags include monotone' });
    // suit derivation from cards
    if (isArr(s.board.cards) && s.board.cards.length >= 3) {
      const suits = s.board.cards.map(c => parseCard(c)).filter(Boolean).map(c => c.suit);
      const unique = new Set(suits);
      let derived = unique.size === 1 ? 'monotone' : (unique.size === 2 ? 'two_tone' : 'rainbow');
      if (st !== derived) {
        issues.push({ rule: 'R13', severity: 'error', scenarioId: s.id,
          message: `suitTexture="${st}" but board cards derive "${derived}"` });
      }
    }
    return issues;
  }

  /**
   * R14 — Heuristic plausibility:
   *   - Dry A-high boards with rangeAdvantage=preflop_raiser should NOT have
   *     check_heavy as `best` answer for a frequency_strategy question.
   *   - Wet low-connected boards with rangeAdvantage=caller should NOT have
   *     range_small as `best`.
   * Warnings only — flags potentially mis-keyed scenarios.
   */
  function R14_boardActionPlausibility(s) {
    if (!s.board || !s.question || !s.answer) return [];
    const issues = [];
    const isFreqQ = s.question.type === 'frequency_strategy' || s.question.type === 'sizing_family';
    if (!isFreqQ) return [];
    const ra = s.board.rangeAdvantage;
    const tags = new Set(s.board.textureTags || []);
    const best = new Set(s.answer.best || []);
    const isDryHighCard = (s.board.highCardClass === 'A_high' || s.board.highCardClass === 'K_high') &&
                         (tags.has('dry') || tags.has('semi_dry')) && tags.has('disconnected');
    const isWetLow = s.board.highCardClass === 'low' &&
                    (tags.has('wet') || tags.has('very_wet')) &&
                    (tags.has('highly_connected') || tags.has('connected') || tags.has('low_connected'));
    if (isDryHighCard && ra === 'preflop_raiser' && best.has('check_heavy')) {
      issues.push({ rule: 'R14', severity: 'warning', scenarioId: s.id,
        message: 'Dry high-card board with raiser range adv should not be check_heavy as best' });
    }
    if (isWetLow && ra === 'caller' && best.has('range_small')) {
      issues.push({ rule: 'R14', severity: 'warning', scenarioId: s.id,
        message: 'Wet low-connected board favoring caller should not be range_small as best' });
    }
    return issues;
  }

  /**
   * R15 — A choice cannot be in `critical` AND in `best`/`acceptable`.
   */
  function R15_criticalNotMixed(s) {
    if (!s.answer) return [];
    const issues = [];
    const crit = new Set(s.answer.critical || []);
    for (const id of (s.answer.best || [])) {
      if (crit.has(id)) {
        issues.push({ rule: 'R15', severity: 'error', scenarioId: s.id,
          message: `Choice "${id}" is in both best and critical` });
      }
    }
    for (const id of (s.answer.acceptable || [])) {
      if (crit.has(id)) {
        issues.push({ rule: 'R15', severity: 'error', scenarioId: s.id,
          message: `Choice "${id}" is in both acceptable and critical` });
      }
    }
    // best and bad must not overlap either
    const bad = new Set(s.answer.bad || []);
    for (const id of (s.answer.best || [])) {
      if (bad.has(id)) {
        issues.push({ rule: 'R15', severity: 'error', scenarioId: s.id,
          message: `Choice "${id}" is in both best and bad` });
      }
    }
    return issues;
  }

  /**
   * R16 — auditStatus="approved" requires zero R01-R15 errors.
   * This rule runs as a finalizer — it inspects all other issues for
   * the scenario, so it's invoked after R01-R15.
   */
  function R16_approvedHasNoErrors(s, ctx, otherIssues) {
    if (s.auditStatus !== 'approved') return [];
    const errors = (otherIssues || []).filter(i => i.severity === 'error');
    if (errors.length > 0) {
      return [{ rule: 'R16', severity: 'error', scenarioId: s.id,
        message: `Scenario marked auditStatus=approved but has ${errors.length} error(s) from R01-R15` }];
    }
    return [];
  }

  /**
   * R17 — sourceConfidence is in the enum.
   * Special: experimental + approved is a warning (not an error) so author
   * sees it but isn't blocked — useful for review queues.
   */
  function R17_sourceConfidenceValid(s, ctx) {
    if (!ctx || !ctx.taxonomy || !isArr(ctx.taxonomy.sourceConfidenceLevels)) return [];
    const valid = new Set(ctx.taxonomy.sourceConfidenceLevels);
    const issues = [];
    if (!valid.has(s.sourceConfidence)) {
      issues.push({ rule: 'R17', severity: 'error', scenarioId: s.id,
        message: `Invalid sourceConfidence: "${s.sourceConfidence}"` });
    }
    if (s.sourceConfidence === 'experimental' && s.auditStatus === 'approved') {
      issues.push({ rule: 'R17', severity: 'warning', scenarioId: s.id,
        message: 'sourceConfidence=experimental + auditStatus=approved — needs justification' });
    }
    return issues;
  }

  // ---------- Runner ----------

  /**
   * Run all rules over every scenario. Returns aggregate report.
   *   data:      { schemaVersion, scenarios: [...] }
   *   taxonomy:  { ... } from postflop_taxonomy.json
   *   concepts:  { ... } from postflop_concepts.json
   */
  function runAudit(data, taxonomy, concepts) {
    const issues = [];
    const scenarios = (data && isArr(data.scenarios)) ? data.scenarios : [];

    // Build context
    const idCounts = {};
    for (const s of scenarios) {
      if (s && isStr(s.id)) idCounts[s.id] = (idCounts[s.id] || 0) + 1;
    }
    const knownConcepts = new Set(
      (concepts && isArr(concepts.concepts)) ? concepts.concepts.map(c => c.key) : []
    );
    const ctx = { taxonomy, concepts, knownConcepts, idCounts, allScenarios: scenarios };

    // R01-R15 + R17 per scenario, then R16 finalizer
    const perScenario = {};
    for (const s of scenarios) {
      const sid = s && s.id ? s.id : '<unknown>';
      perScenario[sid] = perScenario[sid] || [];
      const before = [];
      [
        R01_requiredFields, R02_boardCardsValid, R03_noDuplicateIds,
        R04_choicesIncludeAnswers, R05_bestExists, R06_shortExplanationExists,
        R07_conceptTagsExist, R08_difficultyValid, R09_textureTagsValid,
        R10_advantageEnumsValid, R11_scoringTiersValid, R12_criticalsHaveExplanation,
        R13_noContradictoryTags, R14_boardActionPlausibility, R15_criticalNotMixed,
        R17_sourceConfidenceValid
      ].forEach(rule => {
        const result = rule(s, ctx);
        if (isArr(result)) before.push(...result);
      });
      const r16 = R16_approvedHasNoErrors(s, ctx, before);
      perScenario[sid] = before.concat(r16);
      issues.push(...perScenario[sid]);
    }

    // Aggregate stats
    const stats = computeStats(scenarios, perScenario);
    return {
      schemaVersion: data && data.schemaVersion ? data.schemaVersion : null,
      generatedAt:   new Date().toISOString(),
      totalScenarios: scenarios.length,
      issues,
      perScenario,
      stats
    };
  }

  function computeStats(scenarios, perScenario) {
    const stats = {
      byModule: {}, byDifficulty: {}, byHighCardClass: {}, bySuitTexture: {},
      byRangeAdvantage: {}, byNutAdvantage: {}, byAuditStatus: {}, bySourceConfidence: {},
      conceptCoverage: {}, conceptCoverageStarved: [],
      passCount: 0, failCount: 0, warningCount: 0, errorCount: 0,
      approvedCount: 0, draftCount: 0
    };
    for (const s of scenarios) {
      if (!s || !s.id) continue;
      const issues = perScenario[s.id] || [];
      const errs = issues.filter(i => i.severity === 'error').length;
      const warns = issues.filter(i => i.severity === 'warning').length;
      stats.errorCount += errs;
      stats.warningCount += warns;
      if (errs === 0) stats.passCount++; else stats.failCount++;

      stats.byModule[s.module]                = (stats.byModule[s.module] || 0) + 1;
      stats.byDifficulty[s.difficulty]        = (stats.byDifficulty[s.difficulty] || 0) + 1;
      stats.byAuditStatus[s.auditStatus]      = (stats.byAuditStatus[s.auditStatus] || 0) + 1;
      stats.bySourceConfidence[s.sourceConfidence] = (stats.bySourceConfidence[s.sourceConfidence] || 0) + 1;
      if (s.auditStatus === 'approved') stats.approvedCount++;
      if (s.auditStatus === 'draft')    stats.draftCount++;

      if (s.board) {
        stats.byHighCardClass[s.board.highCardClass] = (stats.byHighCardClass[s.board.highCardClass] || 0) + 1;
        stats.bySuitTexture[s.board.suitTexture]     = (stats.bySuitTexture[s.board.suitTexture] || 0) + 1;
        stats.byRangeAdvantage[s.board.rangeAdvantage] = (stats.byRangeAdvantage[s.board.rangeAdvantage] || 0) + 1;
        stats.byNutAdvantage[s.board.nutAdvantage]     = (stats.byNutAdvantage[s.board.nutAdvantage] || 0) + 1;
      }
      if (isArr(s.conceptTags)) {
        for (const tag of s.conceptTags) {
          stats.conceptCoverage[tag] = (stats.conceptCoverage[tag] || 0) + 1;
        }
      }
    }
    // Concepts with <3 scenarios are "starved"
    for (const tag in stats.conceptCoverage) {
      if (stats.conceptCoverage[tag] < 3) stats.conceptCoverageStarved.push({ tag, count: stats.conceptCoverage[tag] });
    }
    return stats;
  }

  // ---------- Export ----------

  const api = {
    runAudit,
    rules: {
      R01_requiredFields, R02_boardCardsValid, R03_noDuplicateIds,
      R04_choicesIncludeAnswers, R05_bestExists, R06_shortExplanationExists,
      R07_conceptTagsExist, R08_difficultyValid, R09_textureTagsValid,
      R10_advantageEnumsValid, R11_scoringTiersValid, R12_criticalsHaveExplanation,
      R13_noContradictoryTags, R14_boardActionPlausibility, R15_criticalNotMixed,
      R16_approvedHasNoErrors, R17_sourceConfidenceValid
    },
    helpers: { parseCard, rankIndex, topRank }
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = api;
  } else {
    root.PostflopAudit = api;
  }
})(typeof window !== 'undefined' ? window : this);
