import React, { useState, useCallback } from 'react';
import { contractsApi } from '../api/client';
import { useList, useRecord } from '../hooks/useList';
import { DataTable, RecordId, Badge } from '../components/ui/DataTable';
import { RecordDetail } from '../components/ui/RecordDetail';
import { PageHeader } from '../components/ui/PageHeader';

// Updated for 05c_contract_table_updated.sql
// status: 'Cancelled','Terminated','Activated','Past','Current','Upcoming',
//         'Written-Off','Corrected'
// annualizedRevenue (ARR), monthlyRevenue (MRR) — not totalContractValue
// billingFrequency not billingType, isAutoRenewal not autoRenew

const STATUS_COLOR = {
  'Current':    'green',
  'Activated':  'green',
  'Upcoming':   'blue',
  'Past':       'gray',
  'Cancelled':  'red',
  'Terminated': 'red',
  'Written-Off':'red',
  'Corrected':  'amber',
};

function fmt(val, code = 'USD') {
  if (!val) return '—';
  try {
    return new Intl.NumberFormat('en-US', {
      style: 'currency', currency: code || 'USD', notation: 'compact',
    }).format(val);
  } catch { return val; }
}

const COLS = [
  { key: 'id',                label: 'ID',          width: 110 },
  { key: 'name',              label: 'Name' },
  { key: 'accountName',       label: 'Account',     width: 160 },
  { key: 'status',            label: 'Status',      width: 120 },
  { key: 'annualizedRevenue', label: 'ARR',         width: 110 },
  { key: 'startDate',         label: 'Start',       width: 100 },
  { key: 'endDate',           label: 'End',         width: 100 },
  { key: 'contractTerm',      label: 'Term (mo)',   width: 80 },
];

export default function ContractsPage() {
  const [selectedId, setSelectedId] = useState(null);
  const listFn = useCallback(p => contractsApi.list(p), []);
  const { content, loading, error, totalElements, totalPages, params, setParams } = useList(listFn);
  const { data: r, loading: recLoading, error: recError } = useRecord(
    useCallback(id => contractsApi.detail(id), []), selectedId
  );

  if (selectedId) return (
    <RecordDetail onBack={() => setSelectedId(null)} loading={recLoading} error={recError}
      title={r?.name || '…'} subtitle={r?.accountName}
      badge={r?.status &&
        <Badge text={r.status} color={STATUS_COLOR[r.status] || 'gray'} />}
      sections={[
        { title: 'Contract Information', fields: [
          { label: 'Contract ID',       value: r?.id },
          { label: 'Contract Number',   value: r?.contractNumber },
          { label: 'Name',              value: r?.name },
          { label: 'Offer Number',      value: r?.offerNumber },
          { label: 'Legacy ID',         value: r?.legacyId },
          { label: 'Account',           value: r?.accountName },
          { label: 'Status',            value: r?.status },
          { label: 'Status Code',       value: r?.statusCode },
          { label: 'Contract Active',   value: r?.contractActive ? 'Yes' : 'No' },
          { label: 'Primary Product',   value: r?.primaryProduct },
          { label: 'Service Level',     value: r?.serviceLevel },
          { label: 'Original SL',       value: r?.originalServiceLevel },
          { label: 'Deal Type',         value: r?.dealType },
          { label: 'Industry Type',     value: r?.industryType },
          { label: 'Profit Center',     value: r?.profitCenter },
          { label: 'Clearing House',    value: r?.clearingHouse },
          { label: 'Business Language', value: r?.businessLanguage },
          { label: 'Booking Status',    value: r?.accountBookingStatus },
          { label: 'Sales Team',        value: r?.salesTeamText },
          { label: 'Liable Office',     value: r?.liableOffice },
          { label: 'Healthscore',       value: r?.healthscore },
        ]},
        { title: 'Financials', fields: [
          { label: 'ARR',               value: fmt(r?.annualizedRevenue, r?.currencyIsoCode) },
          { label: 'Annual Revenue',    value: fmt(r?.annualRevenue, r?.currencyIsoCode) },
          { label: 'MRR',               value: fmt(r?.monthlyRevenue, r?.currencyIsoCode) },
          { label: 'New Biz Revenue',   value: fmt(r?.newBusinessRevenue, r?.currencyIsoCode) },
          { label: 'Existing Revenue',  value: fmt(r?.existingBusinessRevenue, r?.currencyIsoCode) },
          { label: 'Total Amount',      value: fmt(r?.totalAmount, r?.currencyIsoCode) },
          { label: 'Remaining Balance', value: fmt(r?.remainingBalance, r?.currencyIsoCode) },
          { label: 'Price Increase %',  value: r?.renewalPriceIncreasePct != null ? r.renewalPriceIncreasePct + '%' : null },
          { label: 'Currency',          value: r?.currencyIsoCode },
        ]},
        { title: 'Dates', fields: [
          { label: 'Start Date',        value: r?.startDate },
          { label: 'End Date',          value: r?.endDate },
          { label: 'Term (months)',     value: r?.contractTerm },
          { label: 'Activated Date',    value: r?.activatedDate ? new Date(r.activatedDate).toLocaleString() : null },
          { label: 'Company Signed',    value: r?.companySignedDate },
          { label: 'Customer Signed',   value: r?.customerSignedDate },
          { label: 'Cancellation Date', value: r?.cancellationDate },
          { label: 'Termination Date',  value: r?.terminationDate },
          { label: 'Notice Period Start',value: r?.noticePeriodStart },
          { label: 'Notice Period (days)',value: r?.noticePeriodInDays },
        ]},
        { title: 'Billing & Payment', fields: [
          { label: 'Billing Frequency', value: r?.billingFrequency },
          { label: 'Billing Cycle',     value: r?.billingCycle },
          { label: 'Billing Email',     value: r?.billingEmail },
          { label: 'Payment Terms',     value: r?.paymentTerms },
          { label: 'Payment Status',    value: r?.paymentStatus },
          { label: 'PO Number',         value: r?.poNumber },
          { label: 'PO Needed',         value: r?.poNeeded },
          { label: 'Agreement Form',    value: r?.agreementForm },
          { label: 'Auto Renewal',      value: r?.isAutoRenewal ? 'Yes' : 'No' },
        ]},
        { title: 'Seats & Usage', fields: [
          { label: 'Seats',             value: r?.seats },
          { label: 'Number of Users',   value: r?.numberOfUser },
          { label: 'Purchased Hours',   value: r?.totalPurchasedHours },
          { label: 'Remaining Hours',   value: r?.totalRemainingHours },
          { label: 'Purchased Credit',  value: r?.totalPurchasedCredit },
          { label: 'Remaining Credit',  value: r?.totalRemainingCredit },
          { label: 'Content Views (90d)',value: r?.contentViewsLast90 },
          { label: 'Downloads (90d)',   value: r?.downloadsLast90 },
          { label: 'Active Users (90d)',value: r?.activeUsersLast90 },
        ]},
        { title: 'Cancellation / Termination', fields: [
          { label: 'Cancellation Status', value: r?.cancellationStatus },
          { label: 'Cancellation Reason', value: r?.cancellationReason },
          { label: 'Termination Status',  value: r?.terminationStatus },
          { label: 'Termination Reason',  value: r?.terminationReason },
          { label: 'Termination Comments',value: r?.terminationComments },
        ]},
        { title: 'Billing Address', fields: [
          { label: 'Street',            value: r?.billingStreet },
          { label: 'City',              value: r?.billingCity },
          { label: 'State',             value: r?.billingState },
          { label: 'Postal Code',       value: r?.billingPostalCode },
          { label: 'Country',           value: r?.billingCountry },
          { label: 'Country Code',      value: r?.billingCountryCode },
        ]},
        { title: 'People', fields: [
          { label: 'Primary Contact',   value: r?.primaryContactName },
          { label: 'CS Manager',        value: r?.primaryCsManagerName },
          { label: 'Customer Signed Title', value: r?.customerSignedTitle },
          { label: 'Open Renewal Opps', value: r?.openRenewalOpps },
          { label: 'Won Renewal Opps',  value: r?.closedWonRenewalOpps },
          { label: 'Lost Renewal Opps', value: r?.closedLostRenewalOpps },
        ]},
        { title: 'System', fields: [
          { label: 'Description',       value: r?.description },
          { label: 'Special Terms',     value: r?.specialTerms },
          { label: 'Has Connect',       value: r?.hasConnect ? 'Yes' : 'No' },
          { label: 'Trial',             value: r?.isTrial ? 'Yes' : 'No' },
          { label: 'Global',            value: r?.isGlobal ? 'Yes' : 'No' },
          { label: 'Created',           value: r?.createdAt ? new Date(r.createdAt).toLocaleString() : null },
          { label: 'Modified',          value: r?.updatedAt ? new Date(r.updatedAt).toLocaleString() : null },
        ]},
      ]} />
  );

  const cols = COLS.map(c => {
    if (c.key === 'id') return { ...c,
      render: val => <RecordId id={val} onClick={() => setSelectedId(val)} /> };
    if (c.key === 'status') return { ...c,
      render: val => <Badge text={val || '—'} color={STATUS_COLOR[val] || 'gray'} /> };
    if (c.key === 'annualizedRevenue') return { ...c,
      render: (val, row) => fmt(val, row.currencyIsoCode) };
    return c;
  });

  return (
    <>
      <PageHeader title="Contracts" count={totalElements} />
      <DataTable columns={cols} rows={content} loading={loading} error={error}
        page={params.page} totalPages={totalPages}
        onPageChange={p => setParams(s => ({ ...s, page: p }))}
        onRowClick={row => setSelectedId(row.id)} />
    </>
  );
}
