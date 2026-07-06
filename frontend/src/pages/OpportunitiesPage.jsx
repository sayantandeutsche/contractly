import React, { useState, useCallback } from 'react';
import { opportunitiesApi } from '../api/client';
import { useList, useRecord } from '../hooks/useList';
import { DataTable, RecordId, Badge } from '../components/ui/DataTable';
import { RecordDetail } from '../components/ui/RecordDetail';
import { PageHeader } from '../components/ui/PageHeader';
import NewOpportunityWizard from '../components/ui/NewOpportunityWizard';

const STAGE_COLOR = {
  'New':'gray','Discovery':'blue','Activation':'blue','Value Realisation':'purple',
  'Solution Development':'purple','Product Presentation':'purple','Offer sent':'amber',
  'Offer Creation':'amber','Quoting Process':'amber','Negotiation':'amber',
  'Verbal Confirmation':'amber','Finalisation':'amber','Closed Won':'green','Closed Lost':'red',
};
const TYPE_LABEL = {
  'NEW_BUSINESS':'New Business','UPGRADE':'Upgrade','WINBACK':'Winback',
  'RENEWAL':'Renewal','UPSELL':'Upsell','RENEWAL_UPSELL':'Renewal + Upsell',
};
function fmt(val, code='USD') {
  if (!val) return '—';
  try { return new Intl.NumberFormat('en-US',{style:'currency',currency:code||'USD',notation:'compact'}).format(val); }
  catch { return val; }
}

const COLS = [
  { key:'id',          label:'ID',          width:110 },
  { key:'name',        label:'Name' },
  { key:'accountName', label:'Account',      width:160 },
  { key:'stageName',   label:'Stage',        width:180 },
  { key:'type',        label:'Type',         width:130 },
  { key:'closeDate',   label:'Close Date',   width:110 },
  { key:'annualRecurringRevenue', label:'ARR', width:110 },
  { key:'probability', label:'Prob %',        width:70  },
];

export default function OpportunitiesPage() {
  const [selectedId, setSelectedId]   = useState(null);
  const [showWizard, setShowWizard]   = useState(false);
  const listFn = useCallback(p => opportunitiesApi.list(p), []);
  const { content, loading, error, totalElements, totalPages, params, setParams, refresh } = useList(listFn);
  const { data: r, loading: recLoading, error: recError } = useRecord(
    useCallback(id => opportunitiesApi.detail(id), []), selectedId
  );

  if (selectedId) return (
    <RecordDetail onBack={()=>setSelectedId(null)} loading={recLoading} error={recError}
      title={r?.name||'…'} subtitle={r?.accountName}
      badge={r?.stageName&&<Badge text={r.stageName} color={STAGE_COLOR[r.stageName]||'gray'}/>}
      sections={[
        { title:'Opportunity Information', fields:[
          {label:'Opportunity ID',value:r?.id},{label:'Name',value:r?.name},
          {label:'Account',value:r?.accountName},{label:'Stage',value:r?.stageName},
          {label:'Type',value:TYPE_LABEL[r?.type]||r?.type},
          {label:'Forecast Category',value:r?.forecastCategory},
          {label:'Probability',value:r?.probability!=null?r.probability+'%':null},
          {label:'Lead Source',value:r?.leadSource},{label:'Primary Product',value:r?.primaryProduct},
          {label:'Platform',value:r?.platform},{label:'Profit Center',value:r?.profitCenter},
          {label:'Clearing House',value:r?.clearingHouse},{label:'Deal Type',value:r?.dealType},
          {label:'Sales Team',value:r?.salesTeamText},{label:'Next Step',value:r?.nextStep},
        ]},
        { title:'Financials', fields:[
          {label:'Amount',value:fmt(r?.amount,r?.currencyIsoCode)},
          {label:'ARR',value:fmt(r?.annualRecurringRevenue,r?.currencyIsoCode)},
          {label:'MRR',value:fmt(r?.monthlyRecurringRevenue,r?.currencyIsoCode)},
          {label:'Expected Revenue',value:fmt(r?.expectedRevenue,r?.currencyIsoCode)},
          {label:'Currency',value:r?.currencyIsoCode},
          {label:'Billing Frequency',value:r?.billingFrequency},
          {label:'Payment Terms',value:r?.paymentTerms},
          {label:'Agreement Form',value:r?.agreementForm},
          {label:'Auto Renewal',value:r?.autoRenewal},
          {label:'Term (months)',value:r?.termInMonths},
          {label:'PO Number',value:r?.poNumber},
        ]},
        { title:'Dates', fields:[
          {label:'Close Date',value:r?.closeDate},{label:'Start Date',value:r?.startDate},
          {label:'End Date',value:r?.endDate},{label:'Forecast Date',value:r?.forecastDate},
          {label:'Quote Valid Until',value:r?.quoteValidityDate},
          {label:'Date Won',value:r?.dateWon},
          {label:'Last Stage Change',value:r?.lastStageChangeDate?new Date(r.lastStageChangeDate).toLocaleString():null},
        ]},
        { title:'Status', fields:[
          {label:'Won',value:r?.won?'Yes':'No'},{label:'Closed',value:r?.closed?'Yes':'No'},
          {label:'Trial',value:r?.isTrial?'Yes':'No'},{label:'Win Back',value:r?.isWinBack?'Yes':'No'},
          {label:'Renewal Sentiment',value:r?.renewalSentiment},
          {label:'Approval Status',value:r?.approvalStatus},
          {label:'Closing Reason',value:r?.closingReason},
        ]},
        { title:'System', fields:[
          {label:'Description',value:r?.description},
          {label:'Created',value:r?.createdAt?new Date(r.createdAt).toLocaleString():null},
          {label:'Modified',value:r?.updatedAt?new Date(r.updatedAt).toLocaleString():null},
        ]},
      ]}/>
  );

  const cols = COLS.map(c => {
    if (c.key==='id') return {...c, render: val=><RecordId id={val} onClick={()=>setSelectedId(val)}/>};
    if (c.key==='stageName') return {...c, render: val=><Badge text={val||'—'} color={STAGE_COLOR[val]||'gray'}/>};
    if (c.key==='type') return {...c, render: val=>val?<Badge text={TYPE_LABEL[val]||val} color="blue"/>:'—'};
    if (c.key==='annualRecurringRevenue') return {...c, render:(val,row)=>fmt(val,row.currencyIsoCode)};
    if (c.key==='probability') return {...c, render: val=>val!=null?val+'%':'—'};
    return c;
  });

  return (
    <>
      <PageHeader title="Opportunities" count={totalElements}>
        <button className="ph-new-btn" onClick={() => setShowWizard(true)}>+ New</button>
      </PageHeader>
      <DataTable columns={cols} rows={content} loading={loading} error={error}
        page={params.page} totalPages={totalPages}
        onPageChange={p=>setParams(s=>({...s,page:p}))}
        onRowClick={row=>setSelectedId(row.id)}/>
      {showWizard && <NewOpportunityWizard onClose={()=>setShowWizard(false)} onCreated={()=>{refresh();}}/>}
    </>
  );
}
