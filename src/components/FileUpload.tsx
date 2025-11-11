
import React, { useEffect, useState } from 'react';
import { ServerStackIcon } from './icons';
import { ApiCredentials } from '../types';

interface ApiFormProps {
  onApiSubmit: (credentials: ApiCredentials, month: string) => void;
  isLoading: boolean;
  hasActiveToken: boolean;
  initialCredentials?: ApiCredentials | null;
  onLogout?: () => void;
}

const DEFAULT_CREDS: ApiCredentials = { projectID: 'WFLK_CTSP', id: '', password: '' };

const FileUpload: React.FC<ApiFormProps> = ({ onApiSubmit, isLoading, hasActiveToken, initialCredentials, onLogout }) => {
  const [apiCreds, setApiCreds] = useState<ApiCredentials>(initialCredentials ?? DEFAULT_CREDS);
  
  useEffect(() => {
    if (initialCredentials) {
      setApiCreds(initialCredentials);
    } else {
      setApiCreds(DEFAULT_CREDS);
    }
  }, [initialCredentials]);

  // Set default to current month in YYYY-MM format
  const [month, setMonth] = useState<string>(new Date().toISOString().slice(0, 7));

  const handleApiSubmit = () => {
    const credsToSend = hasActiveToken && initialCredentials ? initialCredentials : apiCreds;
    onApiSubmit(credsToSend, month);
  }

  const handleCredsChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setApiCreds({...apiCreds, [e.target.name]: e.target.value});
  }

  const handleMonthChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setMonth(e.target.value);
  }

  const isApiFormValid = Boolean(month) && (hasActiveToken || (apiCreds.id && apiCreds.password && apiCreds.projectID));

  return (
    <div className="max-w-xl mx-auto text-center bg-surface p-8 rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-4">開始分析</h2>
      <p className="text-subtle mb-6">輸入您的連線憑證和查詢月份以直接從伺服器獲取販賣機的出貨記錄。</p>
      
      <div className="text-left space-y-4">
          <div className="flex items-center justify-center gap-2 text-lg font-semibold text-brand-primary mb-6">
            <ServerStackIcon className="w-6 h-6" />
            <h3>啟動資料擷取</h3>
          </div>
          {hasActiveToken ? (
            <div className="rounded-md border border-brand-primary/40 bg-blue-50 p-4 text-sm text-on-surface flex flex-col gap-3">
              <p>目前沿用既有登入授權。若需重新登入或切換帳號，請按下方按鈕。</p>
              {onLogout && (
                <button
                  type="button"
                  onClick={onLogout}
                  disabled={isLoading}
                  className="self-start rounded-md border border-brand-primary px-3 py-1.5 text-brand-primary hover:bg-brand-primary hover:text-white transition-colors disabled:opacity-60"
                >
                  重新登入
                </button>
              )}
            </div>
          ) : (
            <>
          <div>
              <label className="block text-sm font-medium text-gray-700" htmlFor="projectID">Project ID</label>
              <input type="text" name="projectID" id="projectID" value={apiCreds.projectID} onChange={handleCredsChange} disabled={isLoading} className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-brand-primary focus:border-brand-primary sm:text-sm disabled:bg-gray-100" />
          </div>
            <div>
              <label className="block text-sm font-medium text-gray-700" htmlFor="id">ID</label>
              <input type="text" name="id" id="id" value={apiCreds.id} onChange={handleCredsChange} disabled={isLoading} placeholder="請輸入登入 ID" className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-brand-primary focus:border-brand-primary sm:text-sm disabled:bg-gray-100" />
          </div>
            <div>
              <label className="block text-sm font-medium text-gray-700" htmlFor="password">Password</label>
              <input type="password" name="password" id="password" value={apiCreds.password} onChange={handleCredsChange} disabled={isLoading} placeholder="請輸入密碼" className="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-brand-primary focus:border-brand-primary sm:text-sm disabled:bg-gray-100" />
          </div>
            </>
          )}
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
