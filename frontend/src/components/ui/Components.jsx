import React, { useState, useCallback } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';

// ── Tab icons (emoji fallback — swap for SVG icons later) ────
const TAB_ICONS = {
  leads:         '🎯',
  accounts:      '🏢',
  contacts:      '👤',
  opportunities: '💼',
  contracts:     '📄',
};

// ═══════════════════════════════════════════════════════════
// APP SHELL — NavBar + TabBar + content area
// ═══════════════════════════════════════════════════════════
export function AppShell({ children }) {
  const tabs = [
    { path: '/leads',         label: 'Leads' },
    { path: '/accounts',      label: 'Accounts' },
    { path: '/contacts',      label: 'Contacts' },
    { path: '/opportunities', label: 'Opportunities' },
    { path: '/contracts',     label: 'Contracts' },
  ];

  return (
    <>
      <nav className="nav-bar">
        <div className="nav-logo">CRM <span>Revenue Platform</span></div>
      </nav>

      <div className="tab-bar">
        {tabs.map(t => (
          <NavLink
            key={t.path}
            to={t.path}
            className={({ isActive }) => `tab-item${isActive ? ' active' : ''}`}
          >
            <span>{TAB_ICONS[t.path.slice(1)]}</span>
            {t.label}
          </NavLink>
        ))}
      </div>

      <main className="main-content">
        {children}
      </main>
    </>
  );
}

// ═══════════════════════════════════════════════════════════
// LIST VIEW SHELL — title, search, table, pagination
// ═══════════════════════════════════════════════════════════
export function ListViewShell({ title, total, search, onSearch, children, loading }) {
  return (
    <>
      <div className="page-header">
        <div>
          <span className="page-title">{title}</span>
          {total != null && (
            <span className="record-count">{total.toLocaleString()} record{total !== 1 ? 's' : ''}</span>
          )}
        </div>
      </div>

      <div className="search-bar">
        <input
          className="search-input"
          placeholder={`Search ${title.toLowerCase()}…`}
          value={search}
          onChange={e => onSearch(e.target.value)}
        />
      </div>

      <div className="data-table-wrap">
        {loading ? (
          <div className="loading-wrap">
            <div className="spinner" /> Loading…
          </div>
        ) : children}
      </div>
    </>
  );
}

// ═══════════════════════════════════════════════════════════
// PAGINATION
// ═══════════════════════════════════════════════════════════
export function Pagination({ page, totalPages, onPageChange }) {
  if (totalPages <= 1) return null;
  const pages = Array.from({ length: Math.min(totalPages, 7) }, (_, i) => i);
  return (
    <div className="pagination">
      <button className="page-btn" disabled={page === 0} onClick={() => onPageChange(page - 1)}>‹</button>
      {pages.map(p => (
        <button
          key={p}
          className={`page-btn${p === page ? ' active' : ''}`}
          onClick={() => onPageChange(p)}
        >{p + 1}</button>
      ))}
      {totalPages > 7 && <span>…</span>}
      <button className="page-btn" disabled={page >= totalPages - 1} onClick={() => onPageChange(page + 1)}>›</button>
      <span style={{ marginLeft: 4 }}>Page {page + 1} of {totalPages}</span>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// BACK BUTTON
// ═══════════════════════════════════════════════════════════
export function BackButton({ label }) {
  const navigate = useNavigate();
  return (
    <button className="back-btn" onClick={() => navigate(-1)}>
      ← {label}
    </button>
  );
}

// ═══════════════════════════════════════════════════════════
// DETAIL SECTION
// ═══════════════════════════════════════════════════════════
export function DetailSection({ title, children }) {
  return (
    <div className="detail-section">
      {title && <div className="detail-section-title">{title}</div>}
      <div className="detail-fields">{children}</div>
    </div>
  );
}

export function DetailField({ label, value, link, fullWidth }) {
  const isEmpty = value == null || value === '';
  return (
    <div className="detail-field" style={fullWidth ? { gridColumn: '1 / -1' } : {}}>
      <div className="field-label">{label}</div>
      <div className={`field-value${isEmpty ? ' empty' : ''}`}>
        {isEmpty ? '—' : link ? <a href={link} target="_blank" rel="noreferrer">{value}</a> : String(value)}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// SHORT UUID display helper
// ═══════════════════════════════════════════════════════════
export function ShortId({ id }) {
  return <span title={id}>{id ? id.slice(0, 8) + '…' : '—'}</span>;
}

// ═══════════════════════════════════════════════════════════
// STAGE / STATUS BADGES
// ═══════════════════════════════════════════════════════════
const STAGE_CLASSES = {
  'Prospecting':           'badge-gray',
  'Qualification':         'badge-blue',
  'Needs Analysis':        'badge-blue',
  'Value Proposition':     'badge-blue',
  'Id. Decision Makers':   'badge-purple',
  'Perception Analysis':   'badge-purple',
  'Proposal/Price Quote':  'badge-amber',
  'Negotiation/Review':    'badge-amber',
  'Closed Won':            'badge-green',
  'Closed Lost':           'badge-red',
};

const STATUS_CLASSES = {
  'Open - Not Contacted':     'badge-gray',
  'Working - Contacted':      'badge-blue',
  'Closed - Converted':       'badge-green',
  'Closed - Not Converted':   'badge-red',
  'Draft':                    'badge-gray',
  'In Approval Process':      'badge-amber',
  'Activated':                'badge-green',
  'Expired':                  'badge-red',
  'Terminated':               'badge-red',
};

export function StageBadge({ stage }) {
  const cls = STAGE_CLASSES[stage] || 'badge-gray';
  return <span className={`badge ${cls}`}>{stage}</span>;
}

export function StatusBadge({ status }) {
  const cls = STATUS_CLASSES[status] || 'badge-gray';
  return <span className={`badge ${cls}`}>{status}</span>;
}

// ═══════════════════════════════════════════════════════════
// CURRENCY formatter
// ═══════════════════════════════════════════════════════════
export function formatCurrency(amount, currency = 'USD') {
  if (amount == null) return '—';
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatDate(date) {
  if (!date) return '—';
  return new Date(date).toLocaleDateString('en-GB', {
    day: '2-digit', month: 'short', year: 'numeric'
  });
}

// ═══════════════════════════════════════════════════════════
// useListView hook — handles search, pagination, fetch
// ═══════════════════════════════════════════════════════════
export function useListView(fetchFn) {
  const [data, setData]     = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError]   = React.useState(null);
  const [page, setPage]     = React.useState(0);
  const [search, setSearch] = React.useState('');
  const [searchInput, setSearchInput] = React.useState('');

  // Debounce search
  React.useEffect(() => {
    const t = setTimeout(() => { setSearch(searchInput); setPage(0); }, 350);
    return () => clearTimeout(t);
  }, [searchInput]);

  React.useEffect(() => {
    let cancelled = false;
    setLoading(true);
    fetchFn(page, 25, search)
      .then(d => { if (!cancelled) { setData(d); setError(null); } })
      .catch(e => { if (!cancelled) setError(e.message); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [page, search]);

  return { data, loading, error, page, setPage, searchInput, setSearchInput };
}
