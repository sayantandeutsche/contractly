import React from 'react';
import { ChevronLeft, ChevronRight, Loader2, AlertCircle } from 'lucide-react';
import './DataTable.css';

export function DataTable({ columns, rows, loading, error, page, totalPages, onPageChange, onRowClick }) {
  if (error) return (
    <div className="dt-state">
      <AlertCircle size={20} className="dt-err-icon" />
      <span>{error}</span>
    </div>
  );

  return (
    <div className="dt-wrapper">
      <div className="dt-scroll">
        <table className="dt">
          <thead>
            <tr>
              {columns.map(c => (
                <th key={c.key} style={{ width: c.width }} className="dt-th">{c.label}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan={columns.length} className="dt-loading">
                <Loader2 size={18} className="dt-spinner" />
                <span>Loading…</span>
              </td></tr>
            ) : rows.length === 0 ? (
              <tr><td colSpan={columns.length} className="dt-empty">No records found</td></tr>
            ) : rows.map((row, i) => (
              <tr key={row.id ?? i} className={`dt-row ${onRowClick ? 'dt-row-clickable' : ''}`}
                  onClick={() => onRowClick?.(row)}>
                {columns.map(c => (
                  <td key={c.key} className="dt-td">
                    {c.render ? c.render(row[c.key], row) : (row[c.key] ?? '—')}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="dt-pagination">
          <button className="pg-btn" disabled={page === 0} onClick={() => onPageChange(page - 1)}>
            <ChevronLeft size={14} />
          </button>
          <span className="pg-info">Page {page + 1} of {totalPages}</span>
          <button className="pg-btn" disabled={page >= totalPages - 1} onClick={() => onPageChange(page + 1)}>
            <ChevronRight size={14} />
          </button>
        </div>
      )}
    </div>
  );
}

export function Badge({ text, color }) {
  return <span className={`badge badge-${color || 'default'}`}>{text}</span>;
}

export function RecordId({ id, onClick }) {
  if (!id) return <span>—</span>;
  const short = id.toString().substring(0, 8).toUpperCase();
  return (
    <button className="record-id-btn" onClick={e => { e.stopPropagation(); onClick?.(id); }}>
      {short}
    </button>
  );
}
