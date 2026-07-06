import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ListViewShell, Pagination, BackButton,
  DetailSection, DetailField, ShortId,
  StageBadge, StatusBadge,
  formatCurrency, formatDate, useListView
} from '../components/ui/Components';
import {
  accountsApi, contactsApi, leadsApi,
  opportunitiesApi, contractsApi
} from '../api/client';

// ═══════════════════════════════════════════════════════════
// ACCOUNTS
// ═══════════════════════════════════════════════════════════
export function AccountsListPage() {
  const nav = useNavigate();
  const { data, loading, error, page, setPage, searchInput, setSearchInput }
    = useListView(accountsApi.list);

  return (
    <ListViewShell
      title="Accounts"
      total={data?.totalElements}
      search={searchInput}
      onSearch={setSearchInput}
      loading={loading}
    >
      {error && <div className="error-banner">⚠ {error}</div>}
      {data?.content?.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">🏢</div>
          <div className="empty-state-text">No accounts found</div>
        </div>
      ) : (
        <>
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Country</th>
                <th>Phone</th>
                <th>Type</th>
                <th>Industry</th>
              </tr>
            </thead>
            <tbody>
              {data?.content?.map(a => (
                <tr key={a.id}>
                  <td>
                    <span className="id-link" onClick={() => nav(`/accounts/${a.id}`)}>
                      <ShortId id={a.id} />
                    </span>
                  </td>
                  <td>
                    <span className="name-link" onClick={() => nav(`/accounts/${a.id}`)}>
                      {a.name}
                    </span>
                  </td>
                  <td>{a.billingCountry || '—'}</td>
                  <td>{a.phone || '—'}</td>
                  <td>{a.type ? <span className="badge badge-teal">{a.type}</span> : '—'}</td>
                  <td>{a.industry || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination page={page} totalPages={data?.totalPages} onPageChange={setPage} />
        </>
      )}
    </ListViewShell>
  );
}

export function AccountDetailPage() {
  const { id } = useParams();
  const [data, setData] = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState(null);

  React.useEffect(() => {
    accountsApi.detail(id)
      .then(d => { setData(d); setLoading(false); })
      .catch(e => { setError(e.message); setLoading(false); });
  }, [id]);

  if (loading) return <div className="loading-wrap"><div className="spinner" /> Loading account…</div>;
  if (error)   return <div className="error-banner">⚠ {error}</div>;

  return (
    <div className="detail-page">
      <BackButton label="Back to Accounts" />
      <div className="detail-header">
        <div className="detail-icon">🏢</div>
        <div>
          <div className="detail-title">{data.name}</div>
          <div className="detail-subtitle">{data.type} · {data.industry}</div>
        </div>
      </div>

      <DetailSection title="Account Information">
        <DetailField label="Account Name"   value={data.name} />
        <DetailField label="Account Number" value={data.accountNumber} />
        <DetailField label="Type"           value={data.type} />
        <DetailField label="Industry"       value={data.industry} />
        <DetailField label="Phone"          value={data.phone} />
        <DetailField label="Website"        value={data.website} link={data.website} />
        <DetailField label="Annual Revenue" value={formatCurrency(data.annualRevenue, data.currencyIsoCode)} />
        <DetailField label="Employees"      value={data.numberOfEmployees?.toLocaleString()} />
      </DetailSection>

      <DetailSection title="Billing Address">
        <DetailField label="Street"      value={data.billingStreet} />
        <DetailField label="City"        value={data.billingCity} />
        <DetailField label="State"       value={data.billingState} />
        <DetailField label="Postal Code" value={data.billingPostalCode} />
        <DetailField label="Country"     value={data.billingCountry} />
      </DetailSection>

      <DetailSection title="Additional Information">
        <DetailField label="Description" value={data.description} fullWidth />
        <DetailField label="Created"     value={formatDate(data.createdAt)} />
        <DetailField label="Last Modified" value={formatDate(data.updatedAt)} />
      </DetailSection>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// CONTACTS
// ═══════════════════════════════════════════════════════════
export function ContactsListPage() {
  const nav = useNavigate();
  const { data, loading, error, page, setPage, searchInput, setSearchInput }
    = useListView(contactsApi.list);

  return (
    <ListViewShell
      title="Contacts"
      total={data?.totalElements}
      search={searchInput}
      onSearch={setSearchInput}
      loading={loading}
    >
      {error && <div className="error-banner">⚠ {error}</div>}
      {data?.content?.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">👤</div>
          <div className="empty-state-text">No contacts found</div>
        </div>
      ) : (
        <>
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Account</th>
                <th>Phone</th>
                <th>Email</th>
                <th>Title</th>
              </tr>
            </thead>
            <tbody>
              {data?.content?.map(c => (
                <tr key={c.id}>
                  <td>
                    <span className="id-link" onClick={() => nav(`/contacts/${c.id}`)}>
                      <ShortId id={c.id} />
                    </span>
                  </td>
                  <td>
                    <span className="name-link" onClick={() => nav(`/contacts/${c.id}`)}>
                      {c.name}
                    </span>
                  </td>
                  <td>{c.accountName || '—'}</td>
                  <td>{c.phone || '—'}</td>
                  <td>{c.email || '—'}</td>
                  <td>{c.title || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination page={page} totalPages={data?.totalPages} onPageChange={setPage} />
        </>
      )}
    </ListViewShell>
  );
}

export function ContactDetailPage() {
  const { id } = useParams();
  const [data, setData] = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState(null);
  const nav = useNavigate();

  React.useEffect(() => {
    contactsApi.detail(id)
      .then(d => { setData(d); setLoading(false); })
      .catch(e => { setError(e.message); setLoading(false); });
  }, [id]);

  if (loading) return <div className="loading-wrap"><div className="spinner" /> Loading contact…</div>;
  if (error)   return <div className="error-banner">⚠ {error}</div>;

  return (
    <div className="detail-page">
      <BackButton label="Back to Contacts" />
      <div className="detail-header">
        <div className="detail-icon">👤</div>
        <div>
          <div className="detail-title">{data.name}</div>
          <div className="detail-subtitle">{data.title} {data.accountName && `· ${data.accountName}`}</div>
        </div>
      </div>

      <DetailSection title="Contact Information">
        <DetailField label="First Name"  value={data.firstName} />
        <DetailField label="Last Name"   value={data.lastName} />
        <DetailField label="Title"       value={data.title} />
        <DetailField label="Department"  value={data.department} />
        <DetailField label="Email"       value={data.email} link={`mailto:${data.email}`} />
        <DetailField label="Phone"       value={data.phone} />
        <DetailField label="Mobile"      value={data.mobilePhone} />
        <DetailField label="Lead Source" value={data.leadSource} />
      </DetailSection>

      <DetailSection title="Account">
        <DetailField label="Account Name" value={data.accountName} />
        <DetailField label="Account ID"   value={data.accountId} />
      </DetailSection>

      <DetailSection title="Address">
        <DetailField label="City"    value={data.mailingCity} />
        <DetailField label="Country" value={data.mailingCountry} />
      </DetailSection>

      <DetailSection title="Additional Information">
        <DetailField label="Description"  value={data.description} fullWidth />
        <DetailField label="Created"      value={formatDate(data.createdAt)} />
        <DetailField label="Last Modified" value={formatDate(data.updatedAt)} />
      </DetailSection>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// LEADS
// ═══════════════════════════════════════════════════════════
export function LeadsListPage() {
  const nav = useNavigate();
  const { data, loading, error, page, setPage, searchInput, setSearchInput }
    = useListView(leadsApi.list);

  return (
    <ListViewShell
      title="Leads"
      total={data?.totalElements}
      search={searchInput}
      onSearch={setSearchInput}
      loading={loading}
    >
      {error && <div className="error-banner">⚠ {error}</div>}
      {data?.content?.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">🎯</div>
          <div className="empty-state-text">No leads found</div>
        </div>
      ) : (
        <>
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Company</th>
                <th>Status</th>
                <th>Lead Source</th>
                <th>Email</th>
                <th>Phone</th>
              </tr>
            </thead>
            <tbody>
              {data?.content?.map(l => (
                <tr key={l.id}>
                  <td>
                    <span className="id-link" onClick={() => nav(`/leads/${l.id}`)}>
                      <ShortId id={l.id} />
                    </span>
                  </td>
                  <td>
                    <span className="name-link" onClick={() => nav(`/leads/${l.id}`)}>
                      {l.name}
                    </span>
                  </td>
                  <td>{l.company}</td>
                  <td><StatusBadge status={l.status} /></td>
                  <td>{l.leadSource || '—'}</td>
                  <td>{l.email || '—'}</td>
                  <td>{l.phone || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination page={page} totalPages={data?.totalPages} onPageChange={setPage} />
        </>
      )}
    </ListViewShell>
  );
}

export function LeadDetailPage() {
  const { id } = useParams();
  const [data, setData] = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState(null);

  React.useEffect(() => {
    leadsApi.detail(id)
      .then(d => { setData(d); setLoading(false); })
      .catch(e => { setError(e.message); setLoading(false); });
  }, [id]);

  if (loading) return <div className="loading-wrap"><div className="spinner" /> Loading lead…</div>;
  if (error)   return <div className="error-banner">⚠ {error}</div>;

  return (
    <div className="detail-page">
      <BackButton label="Back to Leads" />
      <div className="detail-header">
        <div className="detail-icon">🎯</div>
        <div>
          <div className="detail-title">{data.name}</div>
          <div className="detail-subtitle">{data.company}</div>
        </div>
      </div>

      <DetailSection title="Lead Information">
        <DetailField label="First Name"  value={data.firstName} />
        <DetailField label="Last Name"   value={data.lastName} />
        <DetailField label="Company"     value={data.company} />
        <DetailField label="Title"       value={data.title} />
        <DetailField label="Status"      value={<StatusBadge status={data.status} />} />
        <DetailField label="Lead Source" value={data.leadSource} />
        <DetailField label="Industry"    value={data.industry} />
        <DetailField label="Converted"   value={data.isConverted ? 'Yes' : 'No'} />
      </DetailSection>

      <DetailSection title="Contact Information">
        <DetailField label="Email"   value={data.email} link={`mailto:${data.email}`} />
        <DetailField label="Phone"   value={data.phone} />
        <DetailField label="Mobile"  value={data.mobilePhone} />
        <DetailField label="Website" value={data.website} link={data.website} />
        <DetailField label="City"    value={data.city} />
        <DetailField label="Country" value={data.country} />
      </DetailSection>

      <DetailSection title="Company Information">
        <DetailField label="Annual Revenue" value={formatCurrency(data.annualRevenue)} />
        <DetailField label="Employees"      value={data.numberOfEmployees?.toLocaleString()} />
      </DetailSection>

      <DetailSection title="Additional Information">
        <DetailField label="Description"   value={data.description} fullWidth />
        <DetailField label="Created"       value={formatDate(data.createdAt)} />
        <DetailField label="Last Modified" value={formatDate(data.updatedAt)} />
      </DetailSection>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// OPPORTUNITIES
// ═══════════════════════════════════════════════════════════
export function OpportunitiesListPage() {
  const nav = useNavigate();
  const { data, loading, error, page, setPage, searchInput, setSearchInput }
    = useListView(opportunitiesApi.list);

  return (
    <ListViewShell
      title="Opportunities"
      total={data?.totalElements}
      search={searchInput}
      onSearch={setSearchInput}
      loading={loading}
    >
      {error && <div className="error-banner">⚠ {error}</div>}
      {data?.content?.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">💼</div>
          <div className="empty-state-text">No opportunities found</div>
        </div>
      ) : (
        <>
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Account</th>
                <th>Stage</th>
                <th>Close Date</th>
                <th>Amount</th>
              </tr>
            </thead>
            <tbody>
              {data?.content?.map(o => (
                <tr key={o.id}>
                  <td>
                    <span className="id-link" onClick={() => nav(`/opportunities/${o.id}`)}>
                      <ShortId id={o.id} />
                    </span>
                  </td>
                  <td>
                    <span className="name-link" onClick={() => nav(`/opportunities/${o.id}`)}>
                      {o.name}
                    </span>
                  </td>
                  <td>{o.accountName || '—'}</td>
                  <td><StageBadge stage={o.stageName} /></td>
                  <td>{formatDate(o.closeDate)}</td>
                  <td>{formatCurrency(o.amount, o.currencyIsoCode)}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination page={page} totalPages={data?.totalPages} onPageChange={setPage} />
        </>
      )}
    </ListViewShell>
  );
}

export function OpportunityDetailPage() {
  const { id } = useParams();
  const [data, setData] = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState(null);

  React.useEffect(() => {
    opportunitiesApi.detail(id)
      .then(d => { setData(d); setLoading(false); })
      .catch(e => { setError(e.message); setLoading(false); });
  }, [id]);

  if (loading) return <div className="loading-wrap"><div className="spinner" /> Loading opportunity…</div>;
  if (error)   return <div className="error-banner">⚠ {error}</div>;

  return (
    <div className="detail-page">
      <BackButton label="Back to Opportunities" />
      <div className="detail-header">
        <div className="detail-icon">💼</div>
        <div>
          <div className="detail-title">{data.name}</div>
          <div className="detail-subtitle">
            <StageBadge stage={data.stageName} />
            {data.accountName && ` · ${data.accountName}`}
          </div>
        </div>
      </div>

      <DetailSection title="Opportunity Information">
        <DetailField label="Opportunity Name" value={data.name} />
        <DetailField label="Account"          value={data.accountName} />
        <DetailField label="Stage"            value={<StageBadge stage={data.stageName} />} />
        <DetailField label="Close Date"       value={formatDate(data.closeDate)} />
        <DetailField label="Amount"           value={formatCurrency(data.amount, data.currencyIsoCode)} />
        <DetailField label="Expected Revenue" value={formatCurrency(data.expectedRevenue, data.currencyIsoCode)} />
        <DetailField label="Probability"      value={data.probability ? `${data.probability}%` : '—'} />
        <DetailField label="Forecast Category" value={data.forecastCategory} />
        <DetailField label="Type"             value={data.type} />
        <DetailField label="Lead Source"      value={data.leadSource} />
        <DetailField label="Won"              value={data.isWon ? '✓ Yes' : 'No'} />
        <DetailField label="Closed"           value={data.isClosed ? 'Yes' : 'No'} />
      </DetailSection>

      <DetailSection title="Additional Information">
        <DetailField label="Description"   value={data.description} fullWidth />
        <DetailField label="Created"       value={formatDate(data.createdAt)} />
        <DetailField label="Last Modified" value={formatDate(data.updatedAt)} />
      </DetailSection>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════
// CONTRACTS
// ═══════════════════════════════════════════════════════════
export function ContractsListPage() {
  const nav = useNavigate();
  const { data, loading, error, page, setPage, searchInput, setSearchInput }
    = useListView(contractsApi.list);

  return (
    <ListViewShell
      title="Contracts"
      total={data?.totalElements}
      search={searchInput}
      onSearch={setSearchInput}
      loading={loading}
    >
      {error && <div className="error-banner">⚠ {error}</div>}
      {data?.content?.length === 0 ? (
        <div className="empty-state">
          <div className="empty-state-icon">📄</div>
          <div className="empty-state-text">No contracts found</div>
        </div>
      ) : (
        <>
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Account</th>
                <th>Status</th>
                <th>Amount</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Term</th>
              </tr>
            </thead>
            <tbody>
              {data?.content?.map(c => (
                <tr key={c.id}>
                  <td>
                    <span className="id-link" onClick={() => nav(`/contracts/${c.id}`)}>
                      <ShortId id={c.id} />
                    </span>
                  </td>
                  <td>
                    <span className="name-link" onClick={() => nav(`/contracts/${c.id}`)}>
                      {c.name}
                    </span>
                  </td>
                  <td>{c.accountName || '—'}</td>
                  <td><StatusBadge status={c.status} /></td>
                  <td>{formatCurrency(c.totalContractValue, c.currencyIsoCode)}</td>
                  <td>{formatDate(c.startDate)}</td>
                  <td>{formatDate(c.endDate)}</td>
                  <td>{c.contractTerm ? `${c.contractTerm}mo` : '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination page={page} totalPages={data?.totalPages} onPageChange={setPage} />
        </>
      )}
    </ListViewShell>
  );
}

export function ContractDetailPage() {
  const { id } = useParams();
  const [data, setData] = React.useState(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState(null);

  React.useEffect(() => {
    contractsApi.detail(id)
      .then(d => { setData(d); setLoading(false); })
      .catch(e => { setError(e.message); setLoading(false); });
  }, [id]);

  if (loading) return <div className="loading-wrap"><div className="spinner" /> Loading contract…</div>;
  if (error)   return <div className="error-banner">⚠ {error}</div>;

  return (
    <div className="detail-page">
      <BackButton label="Back to Contracts" />
      <div className="detail-header">
        <div className="detail-icon">📄</div>
        <div>
          <div className="detail-title">{data.name}</div>
          <div className="detail-subtitle">
            <StatusBadge status={data.status} />
            {data.accountName && ` · ${data.accountName}`}
          </div>
        </div>
      </div>

      <DetailSection title="Contract Information">
        <DetailField label="Contract Name"   value={data.name} />
        <DetailField label="Contract Number" value={data.contractNumber} />
        <DetailField label="Account"         value={data.accountName} />
        <DetailField label="Opportunity"     value={data.opportunityName} />
        <DetailField label="Status"          value={<StatusBadge status={data.status} />} />
        <DetailField label="Billing Type"    value={data.billingType} />
      </DetailSection>

      <DetailSection title="Term & Dates">
        <DetailField label="Start Date"    value={formatDate(data.startDate)} />
        <DetailField label="End Date"      value={formatDate(data.endDate)} />
        <DetailField label="Term (months)" value={data.contractTerm} />
        <DetailField label="Auto Renew"    value={data.autoRenew ? 'Yes' : 'No'} />
      </DetailSection>

      <DetailSection title="Financial">
        <DetailField label="Total Contract Value"    value={formatCurrency(data.totalContractValue, data.currencyIsoCode)} />
        <DetailField label="Annual Contract Value"   value={formatCurrency(data.annualContractValue, data.currencyIsoCode)} />
        <DetailField label="Monthly Recurring Revenue" value={formatCurrency(data.monthlyRecurringRevenue, data.currencyIsoCode)} />
        <DetailField label="Currency"               value={data.currencyIsoCode} />
      </DetailSection>

      <DetailSection title="Additional Information">
        <DetailField label="Description"   value={data.description} fullWidth />
        <DetailField label="Special Terms" value={data.specialTerms} fullWidth />
        <DetailField label="Created"       value={formatDate(data.createdAt)} />
        <DetailField label="Last Modified" value={formatDate(data.updatedAt)} />
      </DetailSection>
    </div>
  );
}
