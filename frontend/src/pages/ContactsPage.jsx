import React, { useState, useCallback } from 'react';
import { contactsApi } from '../api/client';
import { useList, useRecord } from '../hooks/useList';
import { DataTable, RecordId, Badge } from '../components/ui/DataTable';
import { RecordDetail } from '../components/ui/RecordDetail';
import { PageHeader } from '../components/ui/PageHeader';
import NewContactWizard from '../components/ui/NewContactWizard';

const USER_STATUS_COLOR = { 'PaidUser':'green','User':'blue' };

const COLS = [
  { key:'id',              label:'ID',           width:110 },
  { key:'name',            label:'Name' },
  { key:'accountName',     label:'Account',      width:180 },
  { key:'phone',           label:'Phone',        width:150 },
  { key:'email',           label:'Email',        width:210 },
  { key:'title',           label:'Title',        width:160 },
  { key:'subscriptionStatus', label:'Subscription', width:130 },
];

export default function ContactsPage() {
  const [selectedId, setSelectedId]   = useState(null);
  const [showWizard, setShowWizard]   = useState(false);
  const listFn = useCallback(p => contactsApi.list(p), []);
  const { content, loading, error, totalElements, totalPages, params, setParams, refresh } = useList(listFn);
  const { data: r, loading: recLoading, error: recError } = useRecord(
    useCallback(id => contactsApi.detail(id), []), selectedId
  );

  if (selectedId) return (
    <RecordDetail onBack={() => setSelectedId(null)} loading={recLoading} error={recError}
      title={r?.name || '…'} subtitle={r?.title}
      badge={r?.userStatus && <Badge text={r.userStatus} color={USER_STATUS_COLOR[r.userStatus]||'gray'}/>}
      sections={[
        { title:'Contact Information', fields:[
          {label:'Contact ID',value:r?.id},{label:'Salutation',value:r?.salutation},
          {label:'First Name',value:r?.firstName},{label:'Last Name',value:r?.lastName},
          {label:'Title',value:r?.title},{label:'Title Type',value:r?.titleType},
          {label:'Department',value:r?.departmentPicklist||r?.department},
          {label:'Role Level',value:r?.roleLevel},{label:'Account',value:r?.accountName},
          {label:'Lead Source',value:r?.leadSource},{label:'Platform',value:r?.platform},
        ]},
        { title:'Contact Details', fields:[
          {label:'Email',value:r?.email},{label:'Email 2',value:r?.email2},
          {label:'Phone',value:r?.phone},{label:'Mobile',value:r?.mobilePhone},
          {label:'Home Phone',value:r?.homePhone},
          {label:'Do Not Call',value:r?.doNotCall?'Yes':'No'},
          {label:'Email Opt Out',value:r?.hasOptedOutOfEmail?'Yes':'No'},
          {label:'Unsubscribed',value:r?.unsubscribed?'Yes':'No'},
          {label:'LinkedIn',value:r?.linkedin},
          {label:'Product Interest',value:r?.productOfInterest},
        ]},
        { title:'License & Access', fields:[
          {label:'User Status',value:r?.userStatus},{label:'License Active',value:r?.licenseIsActive?'Yes':'No'},
          {label:'License Type',value:r?.licenseType},{label:'Subscription',value:r?.subscriptionStatus},
        ]},
        { title:'Engagement', fields:[
          {label:'Active Days (90d)',value:r?.activeDaysLast90},
          {label:'Content Views (90d)',value:r?.contentViewsLast90},
          {label:'Active Last 90 Days',value:r?.wasActiveLast90?'Yes':'No'},
          {label:'Last Active',value:r?.lastActiveDate},
        ]},
        { title:'Address', fields:[
          {label:'Street',value:r?.mailingStreet},{label:'City',value:r?.mailingCity},
          {label:'State',value:r?.mailingState},{label:'Postal Code',value:r?.mailingPostalCode},
          {label:'Country',value:r?.mailingCountry},{label:'Country Code',value:r?.mailingCountryCode},
        ]},
        { title:'System', fields:[
          {label:'Description',value:r?.description},
          {label:'Converted from Lead',value:r?.convertedFromLead?'Yes':'No'},
          {label:'Created',value:r?.createdAt?new Date(r.createdAt).toLocaleString():null},
          {label:'Modified',value:r?.updatedAt?new Date(r.updatedAt).toLocaleString():null},
        ]},
      ]}/>
  );

  const cols = COLS.map(c => {
    if (c.key==='id') return {...c, render: val => <RecordId id={val} onClick={()=>setSelectedId(val)}/>};
    if (c.key==='subscriptionStatus') return {...c, render: val => val?<Badge text={val} color={val==='subscriber'?'green':'gray'}/>:'—'};
    return c;
  });

  return (
    <>
      <PageHeader title="Contacts" count={totalElements}>
        <button className="ph-new-btn" onClick={() => setShowWizard(true)}>+ New</button>
      </PageHeader>
      <DataTable columns={cols} rows={content} loading={loading} error={error}
        page={params.page} totalPages={totalPages}
        onPageChange={p => setParams(s=>({...s,page:p}))}
        onRowClick={row => setSelectedId(row.id)}/>
      {showWizard && <NewContactWizard onClose={() => setShowWizard(false)} onCreated={() => { refresh(); }}/>}
    </>
  );
}
