// Multi-tab Dashboard — Frontend
// Hace fetch a /api/tabs y renderiza pestañas dinámicamente.
// Renderizado simple, sin frameworks. Templates por tipo de section.

(function () {
  'use strict';

  const tabsEl = document.getElementById('tabs');
  const contentEl = document.getElementById('content');
  const projectNameEl = document.getElementById('project-name');
  const projectMetaEl = document.getElementById('project-meta');
  const footerInfoEl = document.getElementById('footer-info');
  const btnRefresh = document.getElementById('btn-refresh');

  let state = {
    project_name: '',
    deployed_packages: [],
    tabs: [],
    active_tab_id: null,
  };

  // ============================================
  // Fetch + render
  // ============================================

  async function fetchTabs() {
    try {
      const response = await fetch('/api/tabs');
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      const data = await response.json();
      state.project_name = data.project_name;
      state.deployed_packages = data.deployed_packages || [];
      state.tabs = data.tabs || [];

      // Mantener pestaña activa si todavía existe, si no, primera
      const currentActive = state.active_tab_id;
      const stillExists = state.tabs.some((t) => t.tab_id === currentActive);
      if (!stillExists && state.tabs.length > 0) {
        state.active_tab_id = state.tabs[0].tab_id;
      } else if (state.tabs.length === 0) {
        state.active_tab_id = null;
      }

      renderHeader();
      renderTabs();
      renderActiveContent();
      renderFooter(data);
    } catch (err) {
      contentEl.innerHTML = `<div class="content-empty">⚠️ Error al cargar /api/tabs: ${escapeHtml(err.message)}</div>`;
    }
  }

  function renderHeader() {
    projectNameEl.textContent = state.project_name || 'Dashboard';
    const count = state.deployed_packages.length;
    if (count === 0) {
      projectMetaEl.textContent = 'Sin paquetes desplegados';
    } else {
      projectMetaEl.textContent = `${count} paquete${count === 1 ? '' : 's'} desplegado${count === 1 ? '' : 's'}: ${state.deployed_packages.join(', ')}`;
    }
  }

  function renderTabs() {
    if (state.tabs.length === 0) {
      tabsEl.innerHTML = `
        <div class="tabs-inner">
          <div class="tabs-empty">No hay pestañas. Despliega al menos un paquete: <code>bash &lt;arquitecto&gt;/exports/&lt;paquete&gt;/deploy.sh "$(pwd)"</code></div>
        </div>
      `;
      return;
    }

    const tabsHtml = state.tabs
      .map((tab) => {
        const isActive = tab.tab_id === state.active_tab_id;
        const icon = tab.tab_icon ? `<span class="tab-icon">${escapeHtml(tab.tab_icon)}</span>` : '';
        const count = (tab.sections || []).length;
        return `
          <button class="tab ${isActive ? 'active' : ''}" data-tab-id="${escapeHtml(tab.tab_id)}">
            ${icon}${escapeHtml(tab.tab_label)}
            ${count > 0 ? `<span class="tab-count">${count}</span>` : ''}
          </button>
        `;
      })
      .join('');

    tabsEl.innerHTML = `<div class="tabs-inner">${tabsHtml}</div>`;

    tabsEl.querySelectorAll('.tab').forEach((btn) => {
      btn.addEventListener('click', () => {
        state.active_tab_id = btn.dataset.tabId;
        renderTabs();
        renderActiveContent();
      });
    });
  }

  function renderActiveContent() {
    if (!state.active_tab_id) {
      contentEl.innerHTML = `
        <div class="content-empty">
          <p>👋 Bienvenido al dashboard de <strong>${escapeHtml(state.project_name)}</strong>.</p>
          <p>Despliega algún paquete del arquitecto para empezar:</p>
          <pre><code>bash /ruta/AgentArchitect/exports/&lt;paquete&gt;/deploy.sh "$(pwd)"</code></pre>
        </div>
      `;
      return;
    }

    const tab = state.tabs.find((t) => t.tab_id === state.active_tab_id);
    if (!tab) return;

    const sections = tab.sections || [];
    if (sections.length === 0) {
      contentEl.innerHTML = `<div class="content-empty">Esta pestaña no tiene secciones definidas en <code>${escapeHtml(tab.source_file || '?')}</code>.</div>`;
      return;
    }

    contentEl.innerHTML = sections.map(renderSection).join('');
  }

  function renderSection(section) {
    const header = `
      <div class="section-header">
        <div class="section-title">${escapeHtml(section.label)}</div>
        <div class="section-meta">
          ${section.source ? `<code>${escapeHtml(section.source)}</code>` : ''}
          ${section.exists === false ? ` <span class="badge" style="color: var(--warning);">no existe</span>` : ''}
        </div>
      </div>
    `;

    let body = '';
    if (section.error) {
      body = `<div class="section-error">⚠️ ${escapeHtml(section.error)}</div>`;
    } else if (section.exists === false) {
      body = `<div class="section-empty">El archivo <code>${escapeHtml(section.source || '?')}</code> no existe en el proyecto. Crea ese archivo para ver contenido aquí.</div>`;
    } else if (section.content === null || section.content === undefined) {
      body = `<div class="section-empty">(sin contenido)</div>`;
    } else {
      // Renderizar según tipo
      switch (section.type) {
        case 'markdown':
          body = `<div class="markdown-content">${renderMarkdownSimple(section.content)}</div>`;
          break;
        case 'list':
          body = renderListType(section.content);
          break;
        case 'kanban':
          body = renderKanbanType(section);
          break;
        case 'tree':
          body = `<div class="tree-placeholder">📁 Tree view: lectura de directorio pendiente (TODO).</div>`;
          break;
        default:
          body = `<pre style="color: var(--text-2); font-family: var(--mono); white-space: pre-wrap;">${escapeHtml(section.content)}</pre>`;
      }
    }

    return `
      <div class="section">
        ${header}
        <div class="section-body">${body}</div>
      </div>
    `;
  }

  // ============================================
  // Renderers por tipo
  // ============================================

  function renderListType(content) {
    // Cada línea no vacía es un item. Marca de lista markdown (- o *) opcional.
    const lines = content.split('\n').filter((l) => l.trim() && !l.startsWith('#'));
    if (lines.length === 0) {
      return `<div class="section-empty">(vacío)</div>`;
    }
    const items = lines
      .map((l) => {
        const cleaned = l.replace(/^[-*]\s+/, '').trim();
        return `<li>${renderMarkdownInline(cleaned)}</li>`;
      })
      .join('');
    return `<ul class="list-items">${items}</ul>`;
  }

  function renderKanbanType(section) {
    // Estados (columnas) vienen de section.extra.states o se infieren del contenido.
    const states = (section.extra && section.extra.states) || [
      { id: 'todo', label: 'Por hacer' },
      { id: 'doing', label: 'En curso' },
      { id: 'done', label: 'Hecho' },
    ];

    // Parsear contenido buscando líneas con [estado] item
    // Formato esperado: cada item es una línea con prefix opcional de estado
    // Ej: "[todo] Investigar tema X"  o  "## estado\n- item"
    // Versión simple: agrupar por ## heading
    const groups = {};
    let currentState = states[0].id;
    section.content.split('\n').forEach((line) => {
      const headingMatch = line.match(/^##+\s+(.+)/);
      if (headingMatch) {
        // Try to map heading text to a state by label or id
        const headingText = headingMatch[1].trim().toLowerCase();
        const matched = states.find(
          (s) =>
            s.id.toLowerCase() === headingText ||
            (s.label && s.label.toLowerCase() === headingText)
        );
        if (matched) {
          currentState = matched.id;
        }
        return;
      }
      const itemMatch = line.match(/^[-*]\s+(.+)/);
      if (itemMatch) {
        if (!groups[currentState]) groups[currentState] = [];
        groups[currentState].push(itemMatch[1].trim());
      }
    });

    const columns = states
      .map((st) => {
        const items = groups[st.id] || [];
        const cards = items.map((it) => `<div class="kanban-card">${renderMarkdownInline(it)}</div>`).join('');
        return `
          <div class="kanban-column">
            <div class="kanban-column-title">${escapeHtml(st.label)} <span style="color: var(--text-3); font-weight: normal;">(${items.length})</span></div>
            ${cards || '<div class="section-empty" style="font-size: 0.85em;">(vacío)</div>'}
          </div>
        `;
      })
      .join('');

    return `<div class="kanban">${columns}</div>`;
  }

  // ============================================
  // Markdown rendering (minimalista)
  // ============================================

  function renderMarkdownSimple(md) {
    let html = escapeHtml(md);

    // Code blocks
    html = html.replace(/```([\s\S]*?)```/g, (m, code) => `<pre><code>${code}</code></pre>`);

    // Inline code
    html = html.replace(/`([^`]+)`/g, '<code>$1</code>');

    // Headings
    html = html.replace(/^####\s+(.+)$/gm, '<h4>$1</h4>');
    html = html.replace(/^###\s+(.+)$/gm, '<h3>$1</h3>');
    html = html.replace(/^##\s+(.+)$/gm, '<h2>$1</h2>');
    html = html.replace(/^#\s+(.+)$/gm, '<h1>$1</h1>');

    // Bold/italic
    html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    html = html.replace(/\*(.+?)\*/g, '<em>$1</em>');

    // Links
    html = html.replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2" target="_blank">$1</a>');

    // Lists
    html = html.replace(/^[-*]\s+(.+)$/gm, '<li>$1</li>');
    html = html.replace(/(<li>.*<\/li>\n?)+/g, (m) => `<ul>${m}</ul>`);

    // Paragraphs (líneas no procesadas como otros bloques)
    html = html
      .split('\n\n')
      .map((para) => {
        if (
          para.startsWith('<h') ||
          para.startsWith('<ul') ||
          para.startsWith('<pre') ||
          para.startsWith('<blockquote') ||
          para.trim() === ''
        )
          return para;
        return `<p>${para.replace(/\n/g, ' ')}</p>`;
      })
      .join('\n');

    return html;
  }

  function renderMarkdownInline(text) {
    let html = escapeHtml(text);
    html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
    html = html.replace(/\*(.+?)\*/g, '<em>$1</em>');
    html = html.replace(/`([^`]+)`/g, '<code>$1</code>');
    html = html.replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2" target="_blank">$1</a>');
    return html;
  }

  // ============================================
  // Utilities
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

  function renderFooter(data) {
    const ts = data.generated_at || new Date().toISOString();
    footerInfoEl.textContent = `Actualizado: ${ts}`;
  }

  // ============================================
  // Init
  // ============================================

  btnRefresh.addEventListener('click', fetchTabs);

  // Refresco automático cada 30s (configurable desde pm/config.json en el futuro)
  setInterval(fetchTabs, 30000);

  // Primera carga
  fetchTabs();
})();
