import React from 'react';
import './PageHeader.css';

export function PageHeader({ title, count, children }) {
    return (
        <div className="ph-bar">
            <div className="ph-left">
                <h1 className="ph-title">{title}</h1>
                {count !== undefined && <span className="ph-count">{count.toLocaleString()}</span>}
            </div>
            <div className="ph-actions">{children}</div>
        </div>
    );
}
