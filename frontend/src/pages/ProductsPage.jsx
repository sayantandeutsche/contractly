import React, { useState, useCallback } from 'react';
import { productsApi } from '../api/client';
import { useList, useRecord } from '../hooks/useList';
import { DataTable, RecordId, Badge } from '../components/ui/DataTable';
import { RecordDetail } from '../components/ui/RecordDetail';
import { PageHeader } from '../components/ui/PageHeader';
import NewProductWizard from '../components/ui/NewProductWizard';

const COLS = [
  { key: 'id',                     label: 'ID',          width: 110 },
  { key: 'name',                   label: 'Product Name' },
  { key: 'productCode',            label: 'Code',        width: 140 },
  { key: 'family',                 label: 'Family',      width: 130 },
  { key: 'quantityUnitOfMeasure',  label: 'Unit',        width: 120 },
  { key: 'isActive',               label: 'Active',      width: 80  },
];

export default function ProductsPage() {
  const [selectedId, setSelectedId] = useState(null);
  const [showWizard, setShowWizard] = useState(false);

  const listFn = useCallback(p => productsApi.list(p), []);
  const {
    content, loading, error, totalElements,
    totalPages, params, setParams, refresh,
  } = useList(listFn);
  const { data: r, loading: recLoading, error: recError } = useRecord(
    useCallback(id => productsApi.detail(id), []), selectedId
  );

  // ── Detail view ────────────────────────────────────────────
  if (selectedId) return (
    <RecordDetail
      onBack={() => setSelectedId(null)}
      loading={recLoading} error={recError}
      title={r?.name || '…'}
      subtitle={r?.productCode}
      badge={r?.isActive != null &&
        <Badge text={r.isActive ? 'Active' : 'Inactive'}
               color={r.isActive ? 'green' : 'red'} />}
      sections={[
        { title: 'Product Information', fields: [
          { label: 'Product ID',       value: r?.id },
          { label: 'Product Name',     value: r?.name },
          { label: 'Product Code',     value: r?.productCode },
          { label: 'Product Family',   value: r?.family },
          { label: 'Unit of Measure',  value: r?.quantityUnitOfMeasure },
          { label: 'SKU',              value: r?.stockKeepingUnit },
          { label: 'Active',           value: r?.isActive ? 'Yes' : 'No' },
          { label: 'External ID',      value: r?.externalId },
          { label: 'Display URL',      value: r?.displayUrl },
        ]},
        { title: 'Description', fields: [
          { label: 'Description', value: r?.description },
        ]},
        { title: 'System', fields: [
          { label: 'Created',  value: r?.createdAt ? new Date(r.createdAt).toLocaleString() : null },
          { label: 'Modified', value: r?.updatedAt ? new Date(r.updatedAt).toLocaleString() : null },
        ]},
      ]}
    />
  );

  // ── List view ──────────────────────────────────────────────
  const cols = COLS.map(c => {
    if (c.key === 'id') return {
      ...c, render: val => <RecordId id={val} onClick={() => setSelectedId(val)} />,
    };
    if (c.key === 'isActive') return {
      ...c, render: val => <Badge
        text={val ? 'Active' : 'Inactive'}
        color={val ? 'green' : 'red'} />,
    };
    if (c.key === 'family') return {
      ...c, render: val => val ? <Badge text={val} color="blue" /> : '—',
    };
    return c;
  });

  return (
    <>
      <PageHeader title="Products" count={totalElements}>
        <button className="ph-new-btn" onClick={() => setShowWizard(true)}>
          + Add Product
        </button>
      </PageHeader>

      <DataTable
        columns={cols} rows={content} loading={loading} error={error}
        page={params.page} totalPages={totalPages}
        onPageChange={p => setParams(s => ({ ...s, page: p }))}
        onRowClick={row => setSelectedId(row.id)}
      />

      {showWizard && (
        <NewProductWizard
          onClose={() => setShowWizard(false)}
          onCreated={() => refresh()}
        />
      )}
    </>
  );
}
