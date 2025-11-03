import React from 'react';

export const Header: React.FC = () => {
    return (
        <header className="bg-surface shadow-md">
            <div className="container mx-auto px-4 md:px-8 py-4">
                <h1 className="text-2xl md:text-3xl font-bold text-brand-primary">
                    自動販賣機消費追蹤系統
                </h1>
                <p className="text-subtle mt-1">
                    上傳銷售記錄，即時分析使用者消費習慣
                </p>
            </div>
        </header>
    );
}