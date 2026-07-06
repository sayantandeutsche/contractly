import React, { useState, useCallback } from 'react';
import { leadsApi } from '../api/client';
import { useList, useRecord } from '../hooks/useList';
import { DataTable, RecordId, Badge } from '../components/ui/DataTable';
import { RecordDetail } from '../components/ui/RecordDetail';
import { PageHeader } from '../components/ui/PageHeader';

// Updated for 04b_lead_table_updated.sql
// status: 'Unqualified','New','MQL','Screening','Qualification','Outreach','Converted'
// leadSource: 'Zoominfo','Seamless.AI','Clay','Webform','Cold Call', etc.
// industry: uppercase codes e.g. MEDIA___PUBLISHING

const STATUS_COLOR = {
  'New':           'gray',
  'MQL':           'blue',
  'Screening':     'blue',
  'Qualification': 'purple',
  'Outreach':      'amber',
  'Converted':     'green',
  'Unqualified':   'red',
};

function fmtIndustry(val) {
  if (!val) return null;
  return val.replace(/___/g, ' / ').replace(/_/g, ' ');
}

const COLS = [
  { key: 'id',         label: 'ID',          width: 110 },
  { key: 'name',       label: 'Name' },
  { key: 'company',    label: 'Company',      width: 180 },
  { key: 'status',     label: 'Status',       width: 130 },
  { key: 'leadSource', label: 'Lead Source',  width: 140 },
  { key: 'email',      label: 'Email',        width: 200 },
  { key: 'phone',      label: 'Phone',        width: 140 },
];

export default function LeadsPage() {
  const [selectedId, setSelectedId] = useState(null);
  const listFn = useCallback(p => leadsApi.list(p), []);
  const { content, loading, error, totalElements, totalPages, params, setParams } = useList(listFn);
  const { data: r, loading: recLoading, error: recError } = useRecord(
    useCallback(id => leadsApi.detail(id), []), selectedId
  );

  if (selectedId) return (
    <RecordDetail onBack={() => setSelectedId(null)} loading={recLoading} error={recError}
      title={r?.name || '…'} subtitle={r?.company}
      badge={r?.status &&
        <Badge text={r.status} color={STATUS_COLOR[r.status] || 'gray'} />}
      sections={[
        { title: 'Lead Information', fields: [
          { label: 'Lead ID',          value: r?.id },
          { label: 'First Name',       value: r?.firstName },
          { label: 'Last Name',        value: r?.lastName },
          { label: 'Salutation',       value: r?.salutation },
          { label: 'Company',          value: r?.company },
          { label: 'Title',            value: r?.title },
          { label: 'Status',           value: r?.status },
          { label: 'Lead Source',      value: r?.leadSource },
          { label: 'Lead Category',    value: r?.leadCategory },
          { label: 'Rating',           value: r?.rating },
          { label: 'Industry',         value: fmtIndustry(r?.industry) },
          { label: 'Department',       value: r?.department },
          { label: 'Role Level',       value: r?.roleLevel },
          { label: 'Profit Center',    value: r?.profitCenter },
          { label: 'Platform',         value: r?.platform },
          { label: 'Converted',        value: r?.converted ? 'Yes' : 'No' },
          { label: 'Converted Date',   value: r?.convertedDate },
          { label: 'Unqualify Reason', value: r?.unqualifyReason },
          { label: 'CDP Status',       value: r?.leadStatusCdp },
        ]},
        { title: 'Contact Information', fields: [
          { label: 'Email',            value: r?.email },
          { label: 'Phone',            value: r?.phone },
          { label: 'Mobile',           value: r?.mobilePhone },
          { label: 'Website',          value: r?.website },
          { label: 'City',             value: r?.city },
          { label: 'State',            value: r?.state },
          { label: 'Country',          value: r?.country },
          { label: 'Country Code',     value: r?.countryCode },
        ]},
        { title: 'Company & Financials', fields: [
          { label: 'Annual Revenue',   value: r?.annualRevenue?.toLocaleString() },
          { label: 'Employees',        value: r?.numberOfEmployees?.toLocaleString() },
          { label: 'Employee Range',   value: r?.numberOfEmployeesRange },
          { label: 'Revenue Range',    value: r?.revenueRange },
          { label: 'Company Score',    value: r?.companyScore },
          { label: 'Person Score',     value: r?.personScore },
        ]},
        { title: 'Outreach', fields: [
          { label: 'In Sequence',      value: r?.outreachActivelySequenced ? 'Yes' : 'No' },
          { label: 'Sequence Name',    value: r?.outreachCurrentSequenceName },
          { label: 'Sequence Status',  value: r?.outreachCurrentSequenceStatus },
          { label: 'Enriched',         value: r?.enriched ? 'Yes' : 'No' },
          { label: 'Enriched Date',    value: r?.enrichedDate },
          { label: 'Domain',           value: r?.domain },
          { label: 'Next Steps',       value: r?.nextSteps },
          { label: 'Last Activity',    value: r?.lastActivityDate },
          { label: 'Last MC',          value: r?.lastMeaningfulConnect },
        ]},
        { title: 'Timestamps', fields: [
          { label: 'Timestamp New',    value: r?.timestampNew ? new Date(r.timestampNew).toLocaleString() : null },
          { label: 'Timestamp MQL',    value: r?.timestampMql ? new Date(r.timestampMql).toLocaleString() : null },
          { label: 'Timestamp Qual',   value: r?.timestampQualification ? new Date(r.timestampQualification).toLocaleString() : null },
        ]},
        { title: 'System', fields: [
          { label: 'Description',      value: r?.description },
          { label: 'Created',          value: r?.createdAt ? new Date(r.createdAt).toLocaleString() : null },
          { label: 'Modified',         value: r?.updatedAt ? new Date(r.updatedAt).toLocaleString() : null },
        ]},
      ]} />
  );

  const cols = COLS.map(c => {
    if (c.key === 'id') return { ...c,
      render: val => <RecordId id={val} onClick={() => setSelectedId(val)} /> };
    if (c.key === 'status') return { ...c,
      render: val => <Badge text={val || '—'} color={STATUS_COLOR[val] || 'gray'} /> };
    return c;
  });

  return (
    <>
      <PageHeader title="Leads" count={totalElements} />
      <DataTable columns={cols} rows={content} loading={loading} error={error}
        page={params.page} totalPages={totalPages}
        onPageChange={p => setParams(s => ({ ...s, page: p }))}
        onRowClick={row => setSelectedId(row.id)} />
    </>
  );
}
