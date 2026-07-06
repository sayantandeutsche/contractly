import React from 'react';
import { ArrowLeft, Loader2, AlertCircle } from 'lucide-react';
import './RecordDetail.css';

export function RecordDetail({ title, subtitle, badge, sections, onBack, loading, error }) {
  if (loading) return (
    <div className="rd-state"><Loader2 size={20} className="rd-spinner" /><span>Loading record…</span></div>
  );
  if (error) return (
    <div className="rd-state rd-error"><AlertCircle size={20} /><span>{error}</span></div>
  );

  return (
    <div className="rd-container">
      <div className="rd-header">
        <button className="rd-back" onClick={onBack}>
          <ArrowLeft size={15} />
          <span>Back to list</span>
        </button>
        <div className="rd-title-row">
          <div className="rd-title-text">
            <h1 className="rd-title">{title}</h1>
            {subtitle && <p className="rd-subtitle">{subtitle}</p>}
          </div>
          {badge}
        </div>
      </div>

      <div className="rd-body">
        {sections.map(section => (
          <div key={section.title} className="rd-section">
            <h2 className="rd-section-title">{section.title}</h2>
            <div className="rd-fields">
              {section.fields.map(f => f.value !== undefined && f.value !== null && (
                <div key={f.label} className="rd-field">
                  <span className="rd-field-label">{f.label}</span>
                  <span className="rd-field-value">{f.value || <em className="rd-empty">—</em>}</span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
