// Architect Console — Frontend
// 3 vistas fijas: packages, propagations, audits.

(function () {
  'use strict';

  const navEl = document.getElementById('nav');
  const contentEl = document.getElementById('content');
  const footerInfoEl = document.getElementById('footer-info');
  const btnRefresh = document.getElementById('btn-refresh');
  const countPackages = document.getElementById('count-packages');
  const countPropagations = document.getElementById('count-propagations');
  const countAudits = document.getElementById('count-audits');

  let state = {
    view: 'packages',
    data: {
      packages: null,
      propagations: null,
      audits: null,
    },
  };

  // ============================================
  // Fetch helpers
  // ============================================

  async function fetchView(view) {
    try {
      const endpoint = `/api/${view}`;
      const response = await fetch(endpoint);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      state.data[view] = await response.json();
    } catch (err) {
      contentEl.innerHTML = `<div class="content-empty">⚠️ Error al cargar ${endpoint}: ${escapeHtml(err.message)}</div>`;
    }
  }

  async function fetchHealth() {
    try {
      const resp = await fetch('/api/health');
      if (!resp.ok) return null;
      return await resp.json();
    } catch (err) {
      return null;
    }
  }

  // ============================================
  // Init + nav
  // ============================================

  function setupNav() {
    navEl.querySelectorAll('.nav-item').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const view = btn.dataset.view;
        state.view = view;
        navEl.querySelectorAll('.nav-item').forEach((b) => b.classList.toggle('active', b === btn));
        await loadCurrentView();
      });
    });
  }

  async function loadCurrentView() {
    contentEl.innerHTML = '<div class="content-loading">Cargando…</div>';
    await fetchView(state.view);
    renderCurrentView();
  }

  function renderCurrentView() {
    const data = state.data[state.view];
    if (!data) {
      contentEl.innerHTML = '<div class="content-empty">Sin datos.</div>';
      return;
    }
    switch (state.view) {
      case 'packages':
        renderPackages(data);
        break;
      case 'propagations':
        renderPropagations(data);
        break;
      case 'audits':
        renderAudits(data);
        break;
    }
  }

  // ============================================
  // Renderers
  // ============================================

  function renderPackages(data) {
    const packages = data.packages || [];
    if (packages.length === 0) {
      contentEl.innerHTML = `
        <div class="content-empty">
          <p>📦 No hay paquetes desplegables todavía.</p>
          <p>Crea uno con:</p>
          <pre><code>cd ${escapeHtml(getCurrentRoot())}<br>/arc-new-package</code></pre>
        </div>
      `;
      return;
    }

    const cardsHtml = packages
      .map((p) => {
        const description = p.description || '(sin descripción en agent.yaml)';
        return `
          <div class="card">
            <div class="card-header">
              <div class="card-title">${escapeHtml(p.name)}</div>
              <div class="card-version">v${escapeHtml(p.version || '?')}</div>
            </div>
            ${p.prefix ? `<div class="card-meta"><span class="label">Prefix:</span> <code>${escapeHtml(p.prefix)}</code></div>` : ''}
            ${p.domain ? `<div class="card-meta"><span class="label">Dominio:</span> <code>${escapeHtml(p.domain)}</code></div>` : ''}
            <div class="card-description">${escapeHtml(description.length > 200 ? description.slice(0, 200) + '…' : description)}</div>
            <div class="card-footer">
              <span class="badge ${p.has_git ? 'success' : 'warning'}">${p.has_git ? '✓ git init' : '⚠ sin git'}</span>
              <span class="badge ${p.has_system_overview ? 'success' : 'warning'}">${p.has_system_overview ? '✓ overview' : '⚠ sin overview'}</span>
              ${typeof p.agents_count === 'number' ? `<span class="badge">${p.agents_count} agentes</span>` : ''}
              <span class="badge">${p.ledger_entries || 0} entradas ledger</span>
            </div>
          </div>
        `;
      })
      .join('');

    let extra = '';
    if (data.exports_readme) {
      extra = `
        <div class="section-block" style="margin-top: 2rem;">
          <div class="section-block-header">
            <div class="section-block-title">exports/README.md (catálogo)</div>
            <div class="section-block-meta"><code>exports/README.md</code></div>
          </div>
          <div class="section-block-body">
            <pre style="white-space: pre-wrap; color: var(--text-2); font-size: 0.9em;">${escapeHtml(data.exports_readme)}</pre>
          </div>
        </div>
      `;
    }

    contentEl.innerHTML = `<div class="cards">${cardsHtml}</div>${extra}`;
  }

  function renderPropagations(data) {
    if (!data.exists) {
      contentEl.innerHTML = `
        <div class="content-empty">
          <p>No hay <code>changelog/propagations.md</code> todavía.</p>
          <p>Se generará automáticamente al ejecutar <code>/arc-propagate</code>.</p>
        </div>
      `;
      return;
    }

    const entries = data.entries || [];
    if (entries.length === 0) {
      if (data.raw) {
        contentEl.innerHTML = `
          <div class="section-block">
            <div class="section-block-header">
              <div class="section-block-title">changelog/propagations.md (raw)</div>
              <div class="section-block-meta">no se detectaron entradas estructuradas</div>
            </div>
            <div class="section-block-body">
              <pre style="white-space: pre-wrap; color: var(--text-2); font-size: 0.9em;">${escapeHtml(data.raw)}</pre>
            </div>
          </div>
        `;
      } else {
        contentEl.innerHTML = `<div class="content-empty">Archivo vacío.</div>`;
      }
      return;
    }

    const entriesHtml = entries
      .map(
        (e) => `
        <div class="entry">
          <div class="entry-header">
            <div class="entry-title">${escapeHtml(e.header)}</div>
          </div>
          <div class="entry-body">${escapeHtml(e.body)}</div>
        </div>
      `
      )
      .join('');

    contentEl.innerHTML = `<div class="entry-list">${entriesHtml}</div>`;
  }

  function renderAudits(data) {
    if (!data.exists) {
      contentEl.innerHTML = `
        <div class="content-empty">
          <p>No hay <code>docs/architect/audits/</code> todavía.</p>
          <p>Se generará al ejecutar <code>/arc-audit</code>.</p>
        </div>
      `;
      return;
    }

    const audits = data.audits || [];
    if (audits.length === 0) {
      contentEl.innerHTML = `<div class="content-empty">No hay reportes de auditoría.</div>`;
      return;
    }

    const entriesHtml = audits
      .map(
        (a) => `
        <div class="entry">
          <div class="entry-header">
            <div class="entry-title">${escapeHtml(a.filename)}</div>
            <div class="entry-meta"><code>${escapeHtml(a.path)}</code> · ${a.size_bytes || 0} bytes</div>
          </div>
          <div class="entry-body">${escapeHtml(a.preview || '(sin preview)')}</div>
        </div>
      `
      )
      .join('');

    contentEl.innerHTML = `<div class="entry-list">${entriesHtml}</div>`;
  }

  // ============================================
  // Helpers
  // ============================================

  function escapeHtml(s) {
    if (s === null || s === undefined) return '';
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function getCurrentRoot() {
    const health = state.data._health;
    return health && health.root ? health.root : '<arquitecto>';
  }

  async function updateCounts() {
    const health = await fetchHealth();
    if (health) {
      state.data._health = health;
      const c = health.counts || {};
      countPackages.textContent = c.packages || 0;
      countPropagations.textContent = c.propagations_recent || 0;
      countAudits.textContent = c.audits || 0;
      footerInfoEl.textContent = `Actualizado: ${health.now}`;
    }
  }

  btnRefresh.addEventListener('click', async () => {
    await updateCounts();
    await loadCurrentView();
  });

  setInterval(async () => {
    await updateCounts();
    await loadCurrentView();
  }, 60000);

  // Inicio
  setupNav();
  (async () => {
    await updateCounts();
    await loadCurrentView();
  })();
})();
