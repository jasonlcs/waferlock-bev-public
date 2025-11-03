
import React, { useState, useMemo, useCallback } from 'react';
import { ConsumptionRecord, ApiCredentials } from './types';
import FileUpload from './components/FileUpload';
import UserSearch from './components/UserSearch';
import ResultsDisplay from './components/ResultsDisplay';
import { Header } from './components/Header';
import { Footer } from './components/Footer';

const App: React.FC = () => {
  const [records, setRecords] = useState<ConsumptionRecord[]>([]);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [error, setError] = useState<string | null>(null);
  const [fileName, setFileName] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [loadingMessage, setLoadingMessage] = useState<string>('資料讀取中，請稍候...');
  
  const handleApiFetch = useCallback(async (credentials: ApiCredentials, month: string) => {
    setIsLoading(true);
    setError(null);
    setLoadingMessage('正在登入...');
    try {
        const year = parseInt(month.substring(0, 4), 10);
        const monthNum = parseInt(month.substring(5, 7), 10);
        
        // Create start date (first day of the selected month)
        const startDate = new Date(year, monthNum - 1, 1);
        // Create end date (last day of the selected month)
        const endDate = new Date(year, monthNum, 0); 
        
        const formatDate = (date: Date) => date.toISOString().split('T')[0];

        // 1. Login to get token
        const loginResponse = await fetch("https://liveamcore1.waferlock.com:10001/api/Auth/login", {
            method: 'POST',
            headers: { 'Content-Type': 'application/json-patch+json', 'accept': 'text/plain' },
            body: JSON.stringify(credentials)
        });
        
        if (!loginResponse.ok) {
            const errorText = await loginResponse.text();
            throw new Error(`登入失敗: ${loginResponse.status} - ${errorText || loginResponse.statusText}`);
        }
        const token = await loginResponse.text();
        setLoadingMessage('登入成功！正在取得資料...');

        // 2. Fetch data with token
        const dataResponse = await fetch("https://liveamcore1.waferlock.com:10001/api/EventVendingMaching/range", {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json-patch+json',
                'accept': 'text/plain',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                startDate: formatDate(startDate),
                endDate: formatDate(endDate),
                eventCount: 2000 // Set a high limit
            })
        });

        if (!dataResponse.ok) {
            const errorText = await dataResponse.text();
            throw new Error(`取得資料失敗: ${dataResponse.status} - ${errorText || dataResponse.statusText}`);
        }
        const apiData = await dataResponse.json();
        
        if (!Array.isArray(apiData)) {
             throw new Error("API 回應格式不正確，預期為陣列。");
        }

        // 3. Process API data
        const processedData: ConsumptionRecord[] = apiData.map((record: any) => {
            const timestamp = new Date(record.eventTime);
            if (isNaN(timestamp.getTime())) {
                console.warn("Skipping record with invalid timestamp:", record);
                return null;
            }
            return {
                timestamp: timestamp,
                userId: String(record.fid),
                userName: record.targetUserName,
                beverageName: record.productName || `Channel ${record.channel}` || '未知品項',
                price: record.amount,
            };
        }).filter((record): record is ConsumptionRecord => record !== null);
        
        if (processedData.length === 0) {
            setError("在指定月份內找不到任何消費記錄。");
        }

        setRecords(processedData);
        setFileName(`API 資料 (${month})`);
        setSearchQuery('');

    } catch (e: any) {
        setError(e.message || "從 API 取得資料時發生未知的錯誤。");
        setRecords([]);
        setFileName(null);
    } finally {
        setIsLoading(false);
        setLoadingMessage('資料讀取中，請稍候...');
    }
  }, []);

  const handleReset = () => {
    setRecords([]);
    setFileName(null);
    setError(null);
    setSearchQuery('');
  };

  const filteredRecords = useMemo(() => {
    if (!searchQuery) return [];
    const lowercasedQuery = searchQuery.toLowerCase();
    return records.filter(
      (record) =>
        record.userId.toLowerCase().includes(lowercasedQuery) ||
        record.userName.toLowerCase().includes(lowercasedQuery)
    );
  }, [records, searchQuery]);

  const allUsers = useMemo(() => {
    const userNames = new Set<string>();
    records.forEach(r => {
        if(r.userName) {
            userNames.add(r.userName);
        }
    });
    return Array.from(userNames).sort().map(name => ({ userId: name, userName: name }));
  }, [records]);


  return (
    <div className="min-h-screen flex flex-col bg-background">
      <Header />
      <main className="flex-grow container mx-auto p-4 md:p-8">
        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-6" role="alert">
            <strong className="font-bold">錯誤: </strong>
            <span className="block sm:inline">{error}</span>
          </div>
        )}
        {records.length === 0 && !isLoading ? (
          <FileUpload onApiSubmit={handleApiFetch} isLoading={isLoading}/>
        ) : isLoading ? (
            <div className="text-center p-8">
                <div className="flex justify-center items-center gap-3">
                    <svg className="animate-spin h-5 w-5 text-brand-primary" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <p className="text-lg text-subtle">{loadingMessage}</p>
                </div>
            </div>
        ) : (
          <div className="space-y-8">
            <div className="p-6 bg-surface rounded-lg shadow-md flex flex-col md:flex-row justify-between items-center gap-4">
                <p className="text-lg">
                    已載入資料來源: <span className="font-semibold text-brand-primary">{fileName}</span>
                </p>
                <button 
                    onClick={handleReset} 
                    className="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-lg transition-colors duration-200"
                >
                    查詢新資料
                </button>
            </div>
            <UserSearch
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              users={allUsers}
              onUserSelect={(userName) => setSearchQuery(userName)}
            />
            <ResultsDisplay records={filteredRecords} allRecords={records} query={searchQuery} />
          </div>
        )}
      </main>
      <Footer />
    </div>
  );
};

export default App;