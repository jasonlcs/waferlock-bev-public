import React, { useState } from 'react';
import { ServerStackIcon } from './icons';
import { ApiCredentials } from '../types';

interface ApiFormProps {
  onApiSubmit: (credentials: ApiCredentials, month: string) => void;
  isLoading: boolean;
}

const FileUpload: React.FC<ApiFormProps> = ({ onApiSubmit, isLoading }) => {
  const [apiCreds, setApiCreds] = useState<ApiCredentials>({ projectId: 'WFLK_CTSP', id: '', password: '' });
  
  // Set default to current month in YYYY-MM format
  const [month, setMonth] = useState<string>(new Date().toISOString().slice(0, 7));

  const handleApiSubmit = () => {
    onApiSubmit(apiCreds, month);
  }

  const handleCredsChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setApiCreds({...apiCreds, [e.target.name]: e.target.value});
  }

  const handleMonthChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setMonth(e.target.value);
  }

  const isApiFormValid = apiCreds.id && apiCreds.password && apiCreds.projectId && month;

  return (
    <div className="max-w-xl mx-auto text-center bg-surface p-8 rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-4">開始分析</h2>
      <p className="text-subtle mb-6">輸入您的 API 憑證和查詢月份以直接從伺服器獲取販賣機的出貨記錄。</p>
      
      <div className="text-left space-y-4">
          <div className="flex items-center justify-center gap-2 text-lg font-semibold text-brand-primary mb-6">
            <ServerStackIcon className="w-6 h-6" />
            <h3>從 API 取得資料</h3>
          </div>
          <div>
              <label className="block text-sm font-medium text-gray-700" htmlFor="projectId">Project ID</label>
              <input type="text" name="projectId" id="projectId" value={apiCreds.projectId} onChange={handleCredsChange} disabled={isLoading} className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-brand-primary focus:border-brand-primary sm:text-sm disabled:bg-gray-100" />
          </div>
            <div>
              <label className="block text-sm font-medium text-gray-700" htmlFor="id">ID</label>
              <input type="text" name="id" id="id" value={apiCreds.id} onChange={handleCredsChange} disabled={isLoading} placeholder="請輸入登入 ID" className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-brand-primary focus:border-brand-primary sm:text-sm disabled:bg-gray-100" />
          </div>
            <div>
              <label className="block text-sm font-medium text-gray-700" htmlFor="password">Password</label>
              <input type="password" name="password" id="password" value={apiCreds.password} onChange={handleCredsChange} disabled={isLoading} placeholder="請輸入密碼" className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-brand-primary focus:border-brand-primary sm:text-sm disabled:bg-gray-100" />
          </div>
          <div>
              <label className="block text-sm font-medium text-gray-700" htmlFor="month">查詢月份</label>
              <input type="month" name="month" id="month" value={month} onChange={handleMonthChange} disabled={isLoading} className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-brand-primary focus:border-brand-primary sm:text-sm disabled:bg-gray-100" />
          </div>
          <div className="text-center pt-2">
                <button
                  onClick={handleApiSubmit}
                  className="w-full bg-brand-primary hover:bg-brand-secondary text-white font-bold py-2.5 px-6 rounded-lg transition-colors duration-200 disabled:bg-gray-400 disabled:cursor-not-allowed"
                  disabled={!isApiFormValid || isLoading}
                  >
                  {isLoading ? '讀取中...' : '取得資料'}
              </button>
          </div>
      </div>
    </div>
  );
};

export default FileUpload;