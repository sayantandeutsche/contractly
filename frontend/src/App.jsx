import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import './styles/globals.css';
import AppShell from './components/layout/AppShell';
import LeadsPage from './pages/LeadsPage';
import AccountsPage from './pages/AccountsPage';
import ContactsPage from './pages/ContactsPage';
import OpportunitiesPage from './pages/OpportunitiesPage';
import ContractsPage from './pages/ContractsPage';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<AppShell />}>
          <Route index element={<Navigate to="/accounts" replace />} />
          <Route path="leads"         element={<LeadsPage />} />
          <Route path="accounts"      element={<AccountsPage />} />
          <Route path="contacts"      element={<ContactsPage />} />
          <Route path="opportunities" element={<OpportunitiesPage />} />
          <Route path="contracts"     element={<ContractsPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
