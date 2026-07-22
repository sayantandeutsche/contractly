import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import './styles/globals.css';
import { AuthProvider } from './context/AuthContext';
import ProtectedRoute from './components/auth/ProtectedRoute';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import AppShell from './components/layout/AppShell';
import LeadsPage from './pages/LeadsPage';
import AccountsPage from './pages/AccountsPage';
import ContactsPage from './pages/ContactsPage';
import OpportunitiesPage from './pages/OpportunitiesPage';
import ContractsPage from './pages/ContractsPage';
import ProductsPage     from './pages/ProductsPage';

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login"  element={<LoginPage />} />
          <Route path="/signup" element={<SignupPage />} />

          <Route element={<ProtectedRoute />}>
            <Route path="/" element={<AppShell />}>
              <Route index element={<Navigate to="/accounts" replace />} />
              <Route path="leads"         element={<LeadsPage />} />
              <Route path="accounts"      element={<AccountsPage />} />
              <Route path="contacts"      element={<ContactsPage />} />
              <Route path="opportunities" element={<OpportunitiesPage />} />
              <Route path="contracts"     element={<ContractsPage />} />
              <Route path="products"       element={<ProductsPage />} />
            </Route>
          </Route>
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}
