import React, { useState } from 'react';
import { X, ChevronRight, ChevronLeft, Check, Building2 } from 'lucide-react';
import { accountsApi } from '../../api/client';
import './NewAccountWizard.css';

const STEPS = ['Account Details', 'Billing Info', 'Additional Info'];

const ACCOUNT_TYPES = [
  'Master Service Agreement (MSA)', 'Global Deal', 'Global Testballoon',
  'OFAC (Restricted)', 'Competitor (Banned)',
];
const INDUSTRIES = [
  'AGENCIES', 'AUTOMOTIVE', 'CHEMICALS', 'CONSULTING', 'CONSUMER_GOODS',
  'E_COMMERCE', 'EDUCATION', 'ENERGY', 'ENTERTAINMENT___EVENT',
  'FINANCIAL_SERVICES___INSURANCE', 'FOOD___BEVERAGE', 'GOVERNMENT___PUBLIC',
  'LEGAL', 'MANUFACTURING', 'MARKET_RESEARCH', 'MEDIA___PUBLISHING', 'NGO',
  'OTHER', 'PHARMA___HEALTH', 'TELECOMMUNICATION___IT', 'TOURISM___LEISURE',
  'TRANSPORTATION___LOGISTICS', 'UTILITY_SERVICES',
];
const CUSTOMER_STATUSES = [
  'Prospect', 'Client', 'Ex-Client', 'Indirect Prospect',
  'Indirect Client', 'New Customer', 'Paid Customer', 'Competitor',
];
const SEGMENTS = ['Academia', 'Base', 'Scale', 'Key', 'Named'];
const PROFIT_CENTERS = ['US', 'Asia', 'EMEA', 'CE'];
const CURRENCIES = ['USD', 'EUR', 'GBP', 'AUD', 'INR', 'JPY', 'SGD'];
const EMPLOYEE_RANGES = [
  '1-10', '11-50', '51-200', '201-500', '501-1000',
  '1001-5000', '5.001-10.000', '10.001-30.000', '>30.000', 'Unknown',
];
const OWNERSHIPS = ['Public', 'Private', 'Subsidiary', 'Other'];
const RATINGS = ['Hot', 'Warm', 'Cold'];
const SUB_STATUSES = [
  'subscriber', 'free subscriber', 'former subscriber', 'non-subscriber', 'write-off',
];

function Field({ label, required, children }) {
  return (
      <div className="wiz-field">
        <label className="wiz-label">{label}{required && <span className="wiz-req">*</span>}</label>
        {children}
      </div>
  );
}

function Input({ value, onChange, placeholder, type = 'text' }) {
  return (
      <input
          type={type}
          className="wiz-input"
          value={value || ''}
          onChange={e => onChange(e.target.value)}
          placeholder={placeholder}
      />
  );
}

function Select({ value, onChange, options, placeholder }) {
  return (
      <select className="wiz-select" value={value || ''} onChange={e => onChange(e.target.value)}>
        <option value="">{placeholder || 'Select…'}</option>
        {options.map(o => (
            <option key={o} value={o}>
              {o.replace(/___/g, ' / ').replace(/_/g, ' ')}
            </option>
        ))}
      </select>
  );
}

export default function NewAccountWizard({ onClose, onCreated }) {
  const [step, setStep] = useState(0);
  const [saving, setSaving] = useState(false);
  const [savedAccount, setSavedAccount] = useState(null);
  const [error, setError] = useState('');
  const [form, setForm] = useState({
    name: '', type: '', industry: '', customerStatus: '', segment: '',
    profitCenter: '', phone: '', accountEmail: '', website: '', accountNumber: '',
    currencyIsoCode: 'USD',
    billingStreet: '', billingCity: '', billingState: '',
    billingPostalCode: '', billingCountry: '', billingCountryCode: '',
    numberOfEmployees: '', numberOfEmployeesRange: '', annualRevenue: '',
    ownership: '', rating: '', subscriptionStatus: '', description: '',
  });

  const set = (key) => (val) => setForm(f => ({ ...f, [key]: val }));

  const validateStep = () => {
    if (step === 0 && !form.name.trim()) {
      setError('Account name is required.');
      return false;
    }
    setError('');
    return true;
  };

  const next = () => { if (validateStep()) setStep(s => s + 1); };
  const back = () => { setError(''); setStep(s => s - 1); };

  const save = async () => {
    if (!validateStep()) return;
    setSaving(true);
    setError('');
    try {
      const payload = {
        ...form,
        numberOfEmployees: form.numberOfEmployees ? parseInt(form.numberOfEmployees, 10) : null,
        annualRevenue: form.annualRevenue ? parseFloat(form.annualRevenue) : null,
      };
      const created = await accountsApi.create(payload);
      setSavedAccount(created);
      setStep(3); // success screen
      onCreated?.();
    } catch (e) {
      setError(e.message || 'Failed to save account. Please try again.');
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
              <Building2 size={18} className="wiz-header-icon" />
              <span className="wiz-title">New Account</span>
            </div>
            <button className="wiz-close" onClick={onClose}><X size={16} /></button>
          </div>

          {/* Step indicator (hidden on success screen) */}
          {step < 3 && (
              <div className="wiz-steps">
                {STEPS.map((label, i) => (
                    <React.Fragment key={label}>
                      <div className={`wiz-step ${i === step ? 'active' : ''} ${i < step ? 'done' : ''}`}>
                        <div className="wiz-step-circle">
                          {i < step ? <Check size={12} /> : i + 1}
                        </div>
                        <span className="wiz-step-label">{label}</span>
                      </div>
                      {i < STEPS.length - 1 && <div className={`wiz-step-line ${i < step ? 'done' : ''}`} />}
                    </React.Fragment>
                ))}
              </div>
          )}

          {/* Body */}
          <div className="wiz-body">

            {/* ── Step 0: Account Details ─────────────────────── */}
            {step === 0 && (
                <div className="wiz-grid">
                  <Field label="Account Name" required>
                    <Input value={form.name} onChange={set('name')} placeholder="e.g. Acme Corp" />
                  </Field>
                  <Field label="Account Number">
                    <Input value={form.accountNumber} onChange={set('accountNumber')} placeholder="e.g. ACC-001" />
                  </Field>
                  <Field label="Type">
                    <Select value={form.type} onChange={set('type')} options={ACCOUNT_TYPES} />
                  </Field>
                  <Field label="Industry">
                    <Select value={form.industry} onChange={set('industry')} options={INDUSTRIES} />
                  </Field>
                  <Field label="Customer Status">
                    <Select value={form.customerStatus} onChange={set('customerStatus')} options={CUSTOMER_STATUSES} />
                  </Field>
                  <Field label="Segment">
                    <Select value={form.segment} onChange={set('segment')} options={SEGMENTS} />
                  </Field>
                  <Field label="Profit Center">
                    <Select value={form.profitCenter} onChange={set('profitCenter')} options={PROFIT_CENTERS} />
                  </Field>
                  <Field label="Currency">
                    <Select value={form.currencyIsoCode} onChange={set('currencyIsoCode')} options={CURRENCIES} />
                  </Field>
                  <Field label="Phone">
                    <Input value={form.phone} onChange={set('phone')} placeholder="+1-555-000-0000" />
                  </Field>
                  <Field label="Email">
                    <Input value={form.accountEmail} onChange={set('accountEmail')} placeholder="billing@company.com" type="email" />
                  </Field>
                  <Field label="Website">
                    <Input value={form.website} onChange={set('website')} placeholder="https://example.com" />
                  </Field>
                </div>
            )}

            {/* ── Step 1: Billing Info ────────────────────────── */}
            {step === 1 && (
                <div className="wiz-grid">
                  <Field label="Street">
                    <Input value={form.billingStreet} onChange={set('billingStreet')} placeholder="123 Main St" />
                  </Field>
                  <Field label="City">
                    <Input value={form.billingCity} onChange={set('billingCity')} placeholder="Berlin" />
                  </Field>
                  <Field label="State / Province">
                    <Input value={form.billingState} onChange={set('billingState')} placeholder="Brandenburg" />
                  </Field>
                  <Field label="Postal Code">
                    <Input value={form.billingPostalCode} onChange={set('billingPostalCode')} placeholder="10115" />
                  </Field>
                  <Field label="Country">
                    <Input value={form.billingCountry} onChange={set('billingCountry')} placeholder="Germany" />
                  </Field>
                  <Field label="Country Code">
                    <Input value={form.billingCountryCode} onChange={set('billingCountryCode')} placeholder="DE" />
                  </Field>
                </div>
            )}

            {/* ── Step 2: Additional Info ─────────────────────── */}
            {step === 2 && (
                <div className="wiz-grid">
                  <Field label="Annual Revenue">
                    <Input value={form.annualRevenue} onChange={set('annualRevenue')} placeholder="1000000" type="number" />
                  </Field>
                  <Field label="Number of Employees">
                    <Input value={form.numberOfEmployees} onChange={set('numberOfEmployees')} placeholder="500" type="number" />
                  </Field>
                  <Field label="Employee Range">
                    <Select value={form.numberOfEmployeesRange} onChange={set('numberOfEmployeesRange')} options={EMPLOYEE_RANGES} />
                  </Field>
                  <Field label="Ownership">
                    <Select value={form.ownership} onChange={set('ownership')} options={OWNERSHIPS} />
                  </Field>
                  <Field label="Rating">
                    <Select value={form.rating} onChange={set('rating')} options={RATINGS} />
                  </Field>
                  <Field label="Subscription Status">
                    <Select value={form.subscriptionStatus} onChange={set('subscriptionStatus')} options={SUB_STATUSES} />
                  </Field>
                  <Field label="Description">
                <textarea
                    className="wiz-textarea"
                    value={form.description || ''}
                    onChange={e => set('description')(e.target.value)}
                    placeholder="Brief description of the account…"
                    rows={3}
                />
                  </Field>
                </div>
            )}

            {/* ── Step 3: Success ─────────────────────────────── */}
            {step === 3 && (
                <div className="wiz-success">
                  <div className="wiz-success-icon">
                    <Check size={32} />
                  </div>
                  <h2 className="wiz-success-title">Account Created</h2>
                  <p className="wiz-success-name">{savedAccount?.name}</p>
                  <p className="wiz-success-sub">
                    The account has been saved and will appear in the list.
                  </p>
                </div>
            )}

            {error && <div className="wiz-error">{error}</div>}
          </div>

          {/* Footer */}
          <div className="wiz-footer">
            {step === 3 ? (
                <button className="wiz-btn wiz-btn-primary" onClick={onClose}>
                  OK
                </button>
            ) : (
                <>
                  <button className="wiz-btn wiz-btn-ghost" onClick={step === 0 ? onClose : back}>
                    {step === 0 ? 'Cancel' : <><ChevronLeft size={14} /> Back</>}
                  </button>
                  <div className="wiz-footer-right">
                    {step < 2 ? (
                        <button className="wiz-btn wiz-btn-primary" onClick={next}>
                          Next <ChevronRight size={14} />
                        </button>
                    ) : (
                        <>
                          <button className="wiz-btn wiz-btn-ghost" onClick={onClose}>Cancel</button>
                          <button className="wiz-btn wiz-btn-primary" onClick={save} disabled={saving}>
                            {saving ? 'Saving…' : 'Save Account'}
                          </button>
                        </>
                    )}
                  </div>
                </>
            )}
          </div>

        </div>
      </div>
  );
}
