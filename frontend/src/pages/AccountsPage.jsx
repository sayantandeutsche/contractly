import React, { useState, useCallback } from 'react';
import { accountsApi } from '../api/client';
import { useList, useRecord } from '../hooks/useList';
import { DataTable, RecordId, Badge } from '../components/ui/DataTable';
import { RecordDetail } from '../components/ui/RecordDetail';
import { PageHeader } from '../components/ui/PageHeader';
import NewAccountWizard from '../components/ui/NewAccountWizard';

const CUSTOMER_STATUS_COLOR = {
  'Client':'green','Prospect':'gray','Ex-Client':'amber',
  'New Customer':'blue','Paid Customer':'green',
  'Indirect Client':'green','Competitor':'red',
};

const COLS = [
  { key: 'id',             label: 'ID',             width: 110 },
  { key: 'name',           label: 'Name' },
  { key: 'billingCountry', label: 'Country',         width: 130 },
  { key: 'phone',          label: 'Phone',           width: 150 },
  { key: 'accountEmail',   label: 'Email',           width: 200 },
  { key: 'customerStatus', label: 'Customer Status', width: 140 },
  { key: 'segment',        label: 'Segment',         width: 100 },
  { key: 'annualizedRevenue', label: 'ARR',          width: 110 },
];

function fmt(val, code = 'USD') {
  if (!val) return null;
  try { return new Intl.NumberFormat('en-US', { style:'currency', currency: code||'USD', notation:'compact' }).format(val); }
  catch { return val; }
}

function fmtIndustry(val) {
  if (!val) return null;
  return val.replace(/___/g,' / ').replace(/_/g,' ');
}

export default function AccountsPage() {
  const [selectedId, setSelectedId] = useState(null);
  const [showWizard, setShowWizard] = useState(false);

  const listFn = useCallback(p => accountsApi.list(p), []);
  const { content, loading, error, totalElements, totalPages, params, setParams, refresh } = useList(listFn);
  const { data: r, loading: recLoading, error: recError } = useRecord(
    useCallback(id => accountsApi.detail(id), []), selectedId
  );

  const handleCreated = () => refresh();

  if (selectedId) return (
    <RecordDetail
      onBack={() => setSelectedId(null)}
      loading={recLoading} error={recError}
      title={r?.name || '…'} subtitle={r?.type}
      badge={r?.customerStatus && <Badge text={r.customerStatus} color={CUSTOMER_STATUS_COLOR[r.customerStatus]||'gray'} />}
      sections={[
        { title:'Account Information', fields:[
          {label:'Account ID',value:r?.id},{label:'Account Name',value:r?.name},
          {label:'Account Number',value:r?.accountNumber},{label:'Type',value:r?.type},
          {label:'Industry',value:fmtIndustry(r?.industry)},{label:'Sub Industry',value:r?.subIndustry},
          {label:'Customer Status',value:r?.customerStatus},{label:'Segment',value:r?.segment},
          {label:'Healthscore',value:r?.healthscore},{label:'Profit Center',value:r?.profitCenter},
          {label:'Subscription',value:r?.subscriptionStatus},{label:'Rating',value:r?.rating},
        ]},
        { title:'Financials', fields:[
          {label:'Annual Revenue',value:fmt(r?.annualRevenue,r?.currencyIsoCode)},
          {label:'ARR',value:fmt(r?.annualizedRevenue,r?.currencyIsoCode)},
          {label:'MRR',value:fmt(r?.monthlyRevenue,r?.currencyIsoCode)},
          {label:'Currency',value:r?.currencyIsoCode},
          {label:'Employees',value:r?.numberOfEmployees?.toLocaleString()},
        ]},
        { title:'Contact', fields:[
          {label:'Phone',value:r?.phone},{label:'Email',value:r?.accountEmail},
          {label:'Website',value:r?.website},{label:'Domain',value:r?.domain},
        ]},
        { title:'Billing Address', fields:[
          {label:'Street',value:r?.billingStreet},{label:'City',value:r?.billingCity},
          {label:'State',value:r?.billingState},{label:'Postal Code',value:r?.billingPostalCode},
          {label:'Country',value:r?.billingCountry},{label:'Country Code',value:r?.billingCountryCode},
        ]},
        { title:'System', fields:[
          {label:'Description',value:r?.description},
          {label:'Created',value:r?.createdAt?new Date(r.createdAt).toLocaleString():null},
          {label:'Modified',value:r?.updatedAt?new Date(r.updatedAt).toLocaleString():null},
        ]},
      ]}
    />
  );

  const cols = COLS.map(c => {
    if (c.key==='id') return {...c, render: val => <RecordId id={val} onClick={()=>setSelectedId(val)} />};
    if (c.key==='annualizedRevenue') return {...c, render:(val,row)=>fmt(val,row.currencyIsoCode)||'—'};
    if (c.key==='customerStatus') return {...c, render: val=>val?<Badge text={val} color={CUSTOMER_STATUS_COLOR[val]||'gray'}/>:'—'};
    if (c.key==='segment') return {...c, render: val=>val?<Badge text={val} color="blue"/>:'—'};
    return c;
  });

  return (
    <>
      <PageHeader title="Accounts" count={totalElements}>
        <button className="ph-new-btn" onClick={() => setShowWizard(true)}>
          + New
        </button>
      </PageHeader>
      <DataTable columns={cols} rows={content} loading={loading} error={error}
        page={params.page} totalPages={totalPages}
        onPageChange={p => setParams(s=>({...s,page:p}))}
        onRowClick={row => setSelectedId(row.id)} />
      {showWizard && (
        <NewAccountWizard
          onClose={() => setShowWizard(false)}
          onCreated={handleCreated}
        />
      )}
    </>
  );
}
