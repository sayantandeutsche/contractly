import React, { useState } from 'react';
import { X, Check, Package } from 'lucide-react';
import { productsApi } from '../../api/client';
import './NewAccountWizard.css';
import './NewProductWizard.css';

// Single-page wizard (no multi-step needed — product is a simple object)
const FAMILIES = [
  'Subscription', 'Software', 'Hardware', 'Services',
  'Support', 'Training', 'Add-On', 'Other',
];
const UOM = [
  'User/Month', 'User/Year', 'License', 'Seat',
  'Hours', 'Units', 'GB', 'API Call', 'Other',
];

function Field({ label, required, children }) {
  return (
    <div className="wiz-field">
      <label className="wiz-label">
        {label}{required && <span className="wiz-req">*</span>}
      </label>
      {children}
    </div>
  );
}
const Inp = ({ value, onChange, placeholder, type = 'text' }) => (
  <input type={type} className="wiz-input" value={value || ''}
    onChange={e => onChange(e.target.value)} placeholder={placeholder} />
);
const Sel = ({ value, onChange, options }) => (
  <select className="wiz-select" value={value || ''} onChange={e => onChange(e.target.value)}>
    <option value="">Select…</option>
    {options.map(o => <option key={o} value={o}>{o}</option>)}
  </select>
);

export default function NewProductWizard({ onClose, onCreated }) {
  const [saving, setSaving]   = useState(false);
  const [saved, setSaved]     = useState(null);
  const [error, setError]     = useState('');
  const [form, setForm]       = useState({
    name: '', productCode: '', family: '', description: '',
    quantityUnitOfMeasure: '', stockKeepingUnit: '',
    displayUrl: '', externalId: '', isActive: true,
  });
  const set = k => v => setForm(f => ({ ...f, [k]: v }));

  const save = async () => {
    if (!form.name.trim()) { setError('Product name is required.'); return; }
    setSaving(true); setError('');
    try {
      const created = await productsApi.create(form);
      setSaved(created);
      onCreated?.();
    } catch (e) {
      setError(e.message || 'Failed to save. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="wiz-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="wiz-modal">

        {/* Header */}
        <div className="wiz-header">
          <div className="wiz-header-left">
            <Package size={18} className="wiz-header-icon" />
            <span className="wiz-title">Add Product</span>
          </div>
          <button className="wiz-close" onClick={onClose}><X size={16} /></button>
        </div>

        {/* Body */}
        <div className="wiz-body">
          {!saved ? (
            <div className="wiz-grid">
              <Field label="Product Name" required>
                <Inp value={form.name} onChange={set('name')} placeholder="e.g. CRM Platform — Enterprise" />
              </Field>
              <Field label="Product Code">
                <Inp value={form.productCode} onChange={set('productCode')} placeholder="e.g. CRM-ENT-001" />
              </Field>
              <Field label="Product Family">
                <Sel value={form.family} onChange={set('family')} options={FAMILIES} />
              </Field>
              <Field label="Unit of Measure">
                <Sel value={form.quantityUnitOfMeasure} onChange={set('quantityUnitOfMeasure')} options={UOM} />
              </Field>
              <Field label="SKU">
                <Inp value={form.stockKeepingUnit} onChange={set('stockKeepingUnit')} placeholder="Stock keeping unit" />
              </Field>
              <Field label="External ID">
                <Inp value={form.externalId} onChange={set('externalId')} placeholder="ID in external system" />
              </Field>
              <Field label="Display URL">
                <Inp value={form.displayUrl} onChange={set('displayUrl')} placeholder="https://..." />
              </Field>
              <div className="wiz-field">
                <label className="wiz-label">Active</label>
                <label className="prod-toggle">
                  <input type="checkbox" checked={form.isActive}
                    onChange={e => set('isActive')(e.target.checked)} />
                  <span className="prod-toggle-track" />
                  <span className="prod-toggle-label">{form.isActive ? 'Active' : 'Inactive'}</span>
                </label>
              </div>
              <Field label="Description" >
                <textarea className="wiz-textarea"
                  value={form.description || ''}
                  onChange={e => set('description')(e.target.value)}
                  placeholder="Describe this product…" rows={3}
                  style={{ gridColumn: '1/-1' }} />
              </Field>
            </div>
          ) : (
            /* Success */
            <div className="wiz-success">
              <div className="wiz-success-icon"><Check size={32} /></div>
              <h2 className="wiz-success-title">Product Added</h2>
              <p className="wiz-success-name">{saved.name}</p>
              {saved.productCode &&
                <p className="wiz-success-sub">Code: {saved.productCode}</p>}
              <p className="wiz-success-sub">
                The product has been saved and will appear in the list.
              </p>
            </div>
          )}
          {error && <div className="wiz-error">{error}</div>}
        </div>

        {/* Footer */}
        <div className="wiz-footer">
          {saved ? (
            <button className="wiz-btn wiz-btn-primary" onClick={onClose}>OK</button>
          ) : (
            <>
              <button className="wiz-btn wiz-btn-ghost" onClick={onClose}>Cancel</button>
              <div className="wiz-footer-right">
                <button className="wiz-btn wiz-btn-primary" onClick={save} disabled={saving}>
                  {saving ? 'Saving…' : 'Save Product'}
                </button>
              </div>
            </>
          )}
        </div>

      </div>
    </div>
  );
}
