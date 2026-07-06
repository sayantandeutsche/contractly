import React, { useState } from 'react';
import { X, ChevronRight, ChevronLeft, Check, UserCircle } from 'lucide-react';
import { contactsApi } from '../../api/client';
import './NewAccountWizard.css'; /* reuse same modal/step styles */
import './NewContactWizard.css';

const STEPS = ['Contact Information', 'Contact Details', 'Address'];

const SALUTATIONS   = ['MR_', 'MRS_', 'MX_', 'Herr', 'Frau'];
const TITLE_TYPES   = ['ceo','executive','vp','directorOrManager','individualContributor'];
const DEPARTMENTS   = ['Executive & Leadership','Strategy & Business Development',
  'Marketing & Growth','Sales & Revenue Operations','Business Intelligence & Analytics',
  'Research & Insights','Product Management','Finance & Accounting','Operations',
  'Technology & Engineering','Communications & PR','Education & Training',
  'HR','Legal & Compliance','Other'];
const ROLE_LEVELS   = ['Student','Team Member','Manager','Director / VP','C-Level / Owner','External / Consultant'];
const LEAD_SOURCES  = ['Webform','Cold Call','Cold Mailing','Inbound','Outbound',
  'Linkedin','LinkedIn Lead Gen','Zoominfo','Seamless.AI','Clay','Apollo',
  'Partnership','Reference','Webinar','Other'];
const PLATFORMS     = ['ENGLISH','GERMAN','FRENCH','SPANISH','EcommerceDB'];
const SUB_STATUSES  = ['subscriber','free subscriber','former subscriber','non-subscriber','write-off'];
const CURRENCIES    = ['USD','EUR','GBP','AUD','INR','JPY','SGD'];
const PRODUCTS      = ['CORPORATE_ACCOUNT','ENTERPRISE_ACCOUNT','CAMPUS_LICENSE_INT',
  'BASIC_ACCOUNT','SINGLE_ACCOUNT','PROJECT_ACCOUNT','None','Other'];

function Field({ label, required, wide, children }) {
  return (
    <div className={`wiz-field${wide ? ' wiz-field-wide' : ''}`}>
      <label className="wiz-label">{label}{required && <span className="wiz-req">*</span>}</label>
      {children}
    </div>
  );
}
const Inp = ({ value, onChange, placeholder, type='text' }) => (
  <input type={type} className="wiz-input" value={value||''} onChange={e=>onChange(e.target.value)} placeholder={placeholder} />
);
const Sel = ({ value, onChange, options, placeholder }) => (
  <select className="wiz-select" value={value||''} onChange={e=>onChange(e.target.value)}>
    <option value="">{placeholder||'Select…'}</option>
    {options.map(o=><option key={o} value={o}>{o.replace(/_/g,' ')}</option>)}
  </select>
);
const Chk = ({ label, value, onChange }) => (
  <label className="wiz-checkbox">
    <input type="checkbox" checked={!!value} onChange={e=>onChange(e.target.checked)} />
    <span>{label}</span>
  </label>
);

export default function NewContactWizard({ onClose, onCreated }) {
  const [step, setStep]       = useState(0);
  const [saving, setSaving]   = useState(false);
  const [saved, setSaved]     = useState(null);
  const [error, setError]     = useState('');
  const [form, setForm]       = useState({
    salutation:'', firstName:'', lastName:'', title:'', titleType:'',
    departmentPicklist:'', roleLevel:'', leadSource:'', platform:'',
    subscriptionStatus:'', currencyIsoCode:'USD', accountId:'',
    email:'', email2:'', phone:'', mobilePhone:'', homePhone:'',
    doNotCall:false, hasOptedOutOfEmail:false, linkedin:'', productOfInterest:'',
    mailingStreet:'', mailingCity:'', mailingState:'', mailingPostalCode:'',
    mailingCountry:'', mailingCountryCode:'', description:'',
  });
  const set = k => v => setForm(f=>({...f,[k]:v}));

  const validate = () => {
    if (step===0 && !form.lastName.trim()) { setError('Last name is required.'); return false; }
    setError(''); return true;
  };

  const save = async () => {
    if (!validate()) return;
    setSaving(true); setError('');
    try {
      const created = await contactsApi.create({
        ...form,
        accountId: form.accountId || null,
      });
      setSaved(created); setStep(3); onCreated?.();
    } catch(e) {
      setError(e.message || 'Failed to save. Please try again.');
    } finally { setSaving(false); }
  };

  const displayName = [form.firstName, form.lastName].filter(Boolean).join(' ') || '…';

  return (
    <div className="wiz-overlay" onClick={e=>e.target===e.currentTarget&&onClose()}>
      <div className="wiz-modal">

        <div className="wiz-header">
          <div className="wiz-header-left">
            <UserCircle size={18} className="wiz-header-icon" />
            <span className="wiz-title">New Contact</span>
          </div>
          <button className="wiz-close" onClick={onClose}><X size={16}/></button>
        </div>

        {step < 3 && (
          <div className="wiz-steps">
            {STEPS.map((label,i)=>(
              <React.Fragment key={label}>
                <div className={`wiz-step ${i===step?'active':''} ${i<step?'done':''}`}>
                  <div className="wiz-step-circle">{i<step?<Check size={12}/>:i+1}</div>
                  <span className="wiz-step-label">{label}</span>
                </div>
                {i<STEPS.length-1&&<div className={`wiz-step-line ${i<step?'done':''}`}/>}
              </React.Fragment>
            ))}
          </div>
        )}

        <div className="wiz-body">

          {/* ── Step 0: Contact Information ─── */}
          {step===0 && (
            <div className="wiz-grid">
              <Field label="Salutation"><Sel value={form.salutation} onChange={set('salutation')} options={SALUTATIONS}/></Field>
              <Field label="First Name"><Inp value={form.firstName} onChange={set('firstName')} placeholder="First name"/></Field>
              <Field label="Last Name" required><Inp value={form.lastName} onChange={set('lastName')} placeholder="Last name"/></Field>
              <Field label="Title"><Inp value={form.title} onChange={set('title')} placeholder="Job Title"/></Field>
              <Field label="Seniority Level"><Sel value={form.titleType} onChange={set('titleType')} options={TITLE_TYPES}/></Field>
              <Field label="Department"><Sel value={form.departmentPicklist} onChange={set('departmentPicklist')} options={DEPARTMENTS}/></Field>
              <Field label="Role Level"><Sel value={form.roleLevel} onChange={set('roleLevel')} options={ROLE_LEVELS}/></Field>
              <Field label="Lead Source"><Sel value={form.leadSource} onChange={set('leadSource')} options={LEAD_SOURCES}/></Field>
              <Field label="Platform"><Sel value={form.platform} onChange={set('platform')} options={PLATFORMS}/></Field>
              <Field label="Subscription Status"><Sel value={form.subscriptionStatus} onChange={set('subscriptionStatus')} options={SUB_STATUSES}/></Field>
              <Field label="Currency"><Sel value={form.currencyIsoCode} onChange={set('currencyIsoCode')} options={CURRENCIES}/></Field>
              <Field label="Account ID"><Inp value={form.accountId} onChange={set('accountId')} placeholder="UUID of linked account"/></Field>
            </div>
          )}

          {/* ── Step 1: Contact Details ─── */}
          {step===1 && (
            <div className="wiz-grid">
              <Field label="Email"><Inp value={form.email} onChange={set('email')} placeholder="email@company.com" type="email"/></Field>
              <Field label="Email 2"><Inp value={form.email2} onChange={set('email2')} placeholder="alt@company.com" type="email"/></Field>
              <Field label="Phone"><Inp value={form.phone} onChange={set('phone')} placeholder="+1-555-000-0000"/></Field>
              <Field label="Mobile Phone"><Inp value={form.mobilePhone} onChange={set('mobilePhone')} placeholder="+1-555-000-0001"/></Field>
              <Field label="Home Phone"><Inp value={form.homePhone} onChange={set('homePhone')} placeholder="+1-555-000-0002"/></Field>
              <Field label="LinkedIn"><Inp value={form.linkedin} onChange={set('linkedin')} placeholder="https://linkedin.com/in/..."/></Field>
              <Field label="Product of Interest"><Sel value={form.productOfInterest} onChange={set('productOfInterest')} options={PRODUCTS}/></Field>
              <div className="wiz-field wiz-field-wide">
                <Chk label="Do Not Call" value={form.doNotCall} onChange={set('doNotCall')}/>
                <Chk label="Email Opt Out" value={form.hasOptedOutOfEmail} onChange={set('hasOptedOutOfEmail')}/>
              </div>
              <Field label="Description" wide>
                <textarea className="wiz-textarea" value={form.description||''} onChange={e=>set('description')(e.target.value)} placeholder="Notes about this contact…" rows={3}/>
              </Field>
            </div>
          )}

          {/* ── Step 2: Address ─── */}
          {step===2 && (
            <div className="wiz-grid">
              <Field label="Street" wide><Inp value={form.mailingStreet} onChange={set('mailingStreet')} placeholder="123 Main St"/></Field>
              <Field label="City"><Inp value={form.mailingCity} onChange={set('mailingCity')} placeholder="City"/></Field>
              <Field label="State / Province"><Inp value={form.mailingState} onChange={set('mailingState')} placeholder="State"/></Field>
              <Field label="Postal Code"><Inp value={form.mailingPostalCode} onChange={set('mailingPostalCode')} placeholder="12345"/></Field>
              <Field label="Country"><Inp value={form.mailingCountry} onChange={set('mailingCountry')} placeholder="Germany"/></Field>
              <Field label="Country Code"><Inp value={form.mailingCountryCode} onChange={set('mailingCountryCode')} placeholder="DE"/></Field>
            </div>
          )}

          {/* ── Step 3: Success ─── */}
          {step===3 && (
            <div className="wiz-success">
              <div className="wiz-success-icon"><Check size={32}/></div>
              <h2 className="wiz-success-title">Contact Created</h2>
              <p className="wiz-success-name">{saved?.name || displayName}</p>
              <p className="wiz-success-sub">The contact has been saved and will appear in the list.</p>
            </div>
          )}

          {error && <div className="wiz-error">{error}</div>}
        </div>

        <div className="wiz-footer">
          {step===3 ? (
            <button className="wiz-btn wiz-btn-primary" onClick={onClose}>OK</button>
          ) : (
            <>
              <button className="wiz-btn wiz-btn-ghost" onClick={step===0?onClose:()=>{setError('');setStep(s=>s-1);}}>
                {step===0?'Cancel':<><ChevronLeft size={14}/>Back</>}
              </button>
              <div className="wiz-footer-right">
                {step<2
                  ? <button className="wiz-btn wiz-btn-primary" onClick={()=>{if(validate())setStep(s=>s+1);}}>Next <ChevronRight size={14}/></button>
                  : <><button className="wiz-btn wiz-btn-ghost" onClick={onClose}>Cancel</button>
                     <button className="wiz-btn wiz-btn-primary" onClick={save} disabled={saving}>{saving?'Saving…':'Save Contact'}</button></>
                }
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
