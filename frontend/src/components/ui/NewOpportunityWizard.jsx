import React, { useState } from 'react';
import { X, ChevronRight, ChevronLeft, Check, TrendingUp } from 'lucide-react';
import { opportunitiesApi } from '../../api/client';
import './NewAccountWizard.css';
import './NewContactWizard.css';

const STEPS = ['Opportunity Information', 'Financials', 'Dates'];

const OPP_TYPES     = ['NEW_BUSINESS','UPGRADE','WINBACK','RENEWAL','UPSELL','RENEWAL_UPSELL'];
const STAGES        = ['New','Discovery','Activation','Value Realisation','Solution Development',
  'Product Presentation','Offer sent','Offer Creation','Quoting Process',
  'Negotiation','Verbal Confirmation','Finalisation','Closed Won','Closed Lost'];
const FORECAST_CATS = ['Pipeline','BestCase','MostLikely','Forecast','Closed','Omitted'];
const LEAD_SOURCES  = ['Webform','Cold Call','Cold Mailing','Inbound','Outbound',
  'Linkedin','LinkedIn Lead Gen','Zoominfo','Seamless.AI','Clay','Apollo',
  'Partnership','Reference','Webinar','Other'];
const PRODUCTS      = ['CORPORATE_ACCOUNT','ENTERPRISE_ACCOUNT','CAMPUS_LICENSE_INT',
  'BASIC_ACCOUNT','SINGLE_ACCOUNT','PROJECT_ACCOUNT','None'];
const PLATFORMS     = ['ENGLISH','GERMAN','FRENCH','SPANISH','EcommerceDB'];
const PROFIT_CTRS   = ['US','Asia','EMEA','CE','ECDB','AskStatista'];
const CLEARING      = ['GMBH','INC','LTD','PLC','SARL','KK','PTY','INDIA'];
const BIZ_LANG      = ['DE','UK','FR','ES','IT','NL','RU'];
const DEAL_TYPES    = ['Single','Revenue Split','Underutilized Global','Global'];
const CURRENCIES    = ['USD','EUR','GBP','AUD','INR','JPY','SGD'];
const BILL_FREQ     = ['All Upfront','Yearly','Custom'];
const PAY_TERMS     = ['010_00_00','030_00_00','045_00_00','060_00_00','090_00_00'];
const AGMT_FORMS    = ['Contract','Mail','PO'];
const AUTO_RENEW    = ['Yes','No'];

function Field({ label, required, wide, children }) {
  return (
    <div className={`wiz-field${wide?'  wiz-field-wide':''}`}>
      <label className="wiz-label">{label}{required&&<span className="wiz-req">*</span>}</label>
      {children}
    </div>
  );
}
const Inp = ({value,onChange,placeholder,type='text'}) => (
  <input type={type} className="wiz-input" value={value||''} onChange={e=>onChange(e.target.value)} placeholder={placeholder}/>
);
const Sel = ({value,onChange,options,placeholder}) => (
  <select className="wiz-select" value={value||''} onChange={e=>onChange(e.target.value)}>
    <option value="">{placeholder||'Select…'}</option>
    {options.map(o=><option key={o} value={o}>{o.replace(/_/g,' ')}</option>)}
  </select>
);

export default function NewOpportunityWizard({ onClose, onCreated }) {
  const [step, setStep]     = useState(0);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved]   = useState(null);
  const [error, setError]   = useState('');
  const [form, setForm]     = useState({
    name:'', type:'', stageName:'New', forecastCategory:'Pipeline',
    probability:'', leadSource:'', primaryProduct:'', productOfInterest:'',
    platform:'', profitCenter:'', clearingHouse:'', businessLanguage:'',
    dealType:'', accountId:'', nextStep:'', description:'',
    amount:'', annualRecurringRevenue:'', monthlyRecurringRevenue:'',
    expectedRevenue:'', currencyIsoCode:'USD', billingFrequency:'',
    paymentTerms:'', agreementForm:'', poNumber:'', termInMonths:'',
    noticePeriodInDays:'', autoRenewal:'', billingEmail:'',
    closeDate:'', startDate:'', endDate:'', forecastDate:'', quoteValidityDate:'',
  });
  const set = k => v => setForm(f=>({...f,[k]:v}));

  const validate = () => {
    if (step===0 && !form.name.trim()) { setError('Opportunity name is required.'); return false; }
    if (step===2 && !form.closeDate)   { setError('Close date is required.'); return false; }
    setError(''); return true;
  };

  const toNum = v => v !== '' && v != null ? parseFloat(v) : null;
  const toDate = v => v || null;

  const save = async () => {
    if (!validate()) return;
    setSaving(true); setError('');
    try {
      const created = await opportunitiesApi.create({
        name: form.name, type: form.type || null,
        stageName: form.stageName || 'New',
        forecastCategory: form.forecastCategory || 'Pipeline',
        probability: toNum(form.probability),
        leadSource: form.leadSource || null,
        primaryProduct: form.primaryProduct || null,
        productOfInterest: form.productOfInterest || null,
        platform: form.platform || null,
        profitCenter: form.profitCenter || null,
        clearingHouse: form.clearingHouse || null,
        businessLanguage: form.businessLanguage || null,
        dealType: form.dealType || null,
        accountId: form.accountId || null,
        nextStep: form.nextStep || null,
        description: form.description || null,
        amount: toNum(form.amount),
        annualRecurringRevenue: toNum(form.annualRecurringRevenue),
        monthlyRecurringRevenue: toNum(form.monthlyRecurringRevenue),
        expectedRevenue: toNum(form.expectedRevenue),
        currencyIsoCode: form.currencyIsoCode || 'USD',
        billingFrequency: form.billingFrequency || null,
        paymentTerms: form.paymentTerms || null,
        agreementForm: form.agreementForm || null,
        poNumber: form.poNumber || null,
        termInMonths: toNum(form.termInMonths),
        noticePeriodInDays: toNum(form.noticePeriodInDays),
        autoRenewal: form.autoRenewal || null,
        billingEmail: form.billingEmail || null,
        closeDate: toDate(form.closeDate),
        startDate: toDate(form.startDate),
        endDate: toDate(form.endDate),
        forecastDate: toDate(form.forecastDate),
        quoteValidityDate: toDate(form.quoteValidityDate),
      });
      setSaved(created); setStep(3); onCreated?.();
    } catch(e) {
      setError(e.message || 'Failed to save. Please try again.');
    } finally { setSaving(false); }
  };

  return (
    <div className="wiz-overlay" onClick={e=>e.target===e.currentTarget&&onClose()}>
      <div className="wiz-modal wiz-modal-wide">

        <div className="wiz-header">
          <div className="wiz-header-left">
            <TrendingUp size={18} className="wiz-header-icon"/>
            <span className="wiz-title">New Opportunity</span>
          </div>
          <button className="wiz-close" onClick={onClose}><X size={16}/></button>
        </div>

        {step<3 && (
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

          {/* ── Step 0: Opportunity Information ─── */}
          {step===0 && (
            <div className="wiz-grid">
              <Field label="Opportunity Name" required wide><Inp value={form.name} onChange={set('name')} placeholder="e.g. Acme Corp Enterprise Deal"/></Field>
              <Field label="Type"><Sel value={form.type} onChange={set('type')} options={OPP_TYPES}/></Field>
              <Field label="Stage"><Sel value={form.stageName} onChange={set('stageName')} options={STAGES}/></Field>
              <Field label="Forecast Category"><Sel value={form.forecastCategory} onChange={set('forecastCategory')} options={FORECAST_CATS}/></Field>
              <Field label="Probability (%)"><Inp value={form.probability} onChange={set('probability')} placeholder="70" type="number"/></Field>
              <Field label="Lead Source"><Sel value={form.leadSource} onChange={set('leadSource')} options={LEAD_SOURCES}/></Field>
              <Field label="Primary Product"><Sel value={form.primaryProduct} onChange={set('primaryProduct')} options={PRODUCTS}/></Field>
              <Field label="Product of Interest"><Sel value={form.productOfInterest} onChange={set('productOfInterest')} options={PRODUCTS}/></Field>
              <Field label="Platform"><Sel value={form.platform} onChange={set('platform')} options={PLATFORMS}/></Field>
              <Field label="Profit Center"><Sel value={form.profitCenter} onChange={set('profitCenter')} options={PROFIT_CTRS}/></Field>
              <Field label="Clearing House"><Sel value={form.clearingHouse} onChange={set('clearingHouse')} options={CLEARING}/></Field>
              <Field label="Business Language"><Sel value={form.businessLanguage} onChange={set('businessLanguage')} options={BIZ_LANG}/></Field>
              <Field label="Deal Type"><Sel value={form.dealType} onChange={set('dealType')} options={DEAL_TYPES}/></Field>
              <Field label="Account ID"><Inp value={form.accountId} onChange={set('accountId')} placeholder="UUID of linked account"/></Field>
              <Field label="Next Step" wide><Inp value={form.nextStep} onChange={set('nextStep')} placeholder="What happens next?"/></Field>
              <Field label="Description" wide>
                <textarea className="wiz-textarea" value={form.description||''} onChange={e=>set('description')(e.target.value)} placeholder="Brief description…" rows={2}/>
              </Field>
            </div>
          )}

          {/* ── Step 1: Financials ─── */}
          {step===1 && (
            <div className="wiz-grid">
              <Field label="Amount"><Inp value={form.amount} onChange={set('amount')} placeholder="50000" type="number"/></Field>
              <Field label="ARR (Annual Recurring Revenue)"><Inp value={form.annualRecurringRevenue} onChange={set('annualRecurringRevenue')} placeholder="50000" type="number"/></Field>
              <Field label="MRR (Monthly Recurring Revenue)"><Inp value={form.monthlyRecurringRevenue} onChange={set('monthlyRecurringRevenue')} placeholder="4167" type="number"/></Field>
              <Field label="Expected Revenue"><Inp value={form.expectedRevenue} onChange={set('expectedRevenue')} placeholder="45000" type="number"/></Field>
              <Field label="Currency"><Sel value={form.currencyIsoCode} onChange={set('currencyIsoCode')} options={CURRENCIES}/></Field>
              <Field label="Billing Frequency"><Sel value={form.billingFrequency} onChange={set('billingFrequency')} options={BILL_FREQ}/></Field>
              <Field label="Payment Terms"><Sel value={form.paymentTerms} onChange={set('paymentTerms')} options={PAY_TERMS}/></Field>
              <Field label="Agreement Form"><Sel value={form.agreementForm} onChange={set('agreementForm')} options={AGMT_FORMS}/></Field>
              <Field label="Auto Renewal"><Sel value={form.autoRenewal} onChange={set('autoRenewal')} options={AUTO_RENEW}/></Field>
              <Field label="Term (months)"><Inp value={form.termInMonths} onChange={set('termInMonths')} placeholder="12" type="number"/></Field>
              <Field label="Notice Period (days)"><Inp value={form.noticePeriodInDays} onChange={set('noticePeriodInDays')} placeholder="30" type="number"/></Field>
              <Field label="PO Number"><Inp value={form.poNumber} onChange={set('poNumber')} placeholder="PO-12345"/></Field>
              <Field label="Billing Email" wide><Inp value={form.billingEmail} onChange={set('billingEmail')} placeholder="billing@company.com" type="email"/></Field>
            </div>
          )}

          {/* ── Step 2: Dates ─── */}
          {step===2 && (
            <div className="wiz-grid">
              <Field label="Close Date" required><Inp value={form.closeDate} onChange={set('closeDate')} type="date"/></Field>
              <Field label="Start Date"><Inp value={form.startDate} onChange={set('startDate')} type="date"/></Field>
              <Field label="End Date"><Inp value={form.endDate} onChange={set('endDate')} type="date"/></Field>
              <Field label="Forecast Date"><Inp value={form.forecastDate} onChange={set('forecastDate')} type="date"/></Field>
              <Field label="Quote Validity Date"><Inp value={form.quoteValidityDate} onChange={set('quoteValidityDate')} type="date"/></Field>
            </div>
          )}

          {/* ── Step 3: Success ─── */}
          {step===3 && (
            <div className="wiz-success">
              <div className="wiz-success-icon"><Check size={32}/></div>
              <h2 className="wiz-success-title">Opportunity Created</h2>
              <p className="wiz-success-name">{saved?.name}</p>
              <p className="wiz-success-sub">The opportunity has been saved and will appear in the list.</p>
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
                     <button className="wiz-btn wiz-btn-primary" onClick={save} disabled={saving}>{saving?'Saving…':'Save Opportunity'}</button></>
                }
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
