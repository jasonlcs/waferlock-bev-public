import React, { useState, useMemo, useCallback } from 'react';
import * as XLSX from 'xlsx';
import { ConsumptionRecord } from './types';
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

  const handleFileParse = useCallback(async (file: File) => {
    const processRows = (rows: any[][]) => {
      if (rows.length <= 1) {
        throw new Error("檔案是空的或只包含標頭。");
      }
      
      const header = rows[0].map(h => String(h).trim());
      const requiredHeaders = ['事件時間', '人臉辨識ID', '使用者名稱', '品名', '金額'];
      const missingHeaders = requiredHeaders.filter(h => !header.includes(h));

      if (missingHeaders.length > 0) {
        throw new Error(`檔案缺少必要的標頭: ${missingHeaders.join(', ')}`);
      }

      const timeIndex = header.indexOf('事件時間');
      const userIdIndex = header.indexOf('人臉辨識ID');
      const userNameIndex = header.indexOf('使用者名稱');
      const beverageNameIndex = header.indexOf('品名');
      const priceIndex = header.indexOf('金額');
      
      const data = rows.slice(1).map((row, index) => {
          if (row.every(cell => cell === null || cell === undefined || String(cell).trim() === '')) {
              return null;
          }

          const price = parseFloat(row[priceIndex]);
          if (isNaN(price)) {
              throw new Error(`第 ${index + 2} 行的金額無效: ${row[priceIndex]}`);
          }
          
          const timestamp = new Date(row[timeIndex]);
          if (isNaN(timestamp.getTime())) {
              throw new Error(`第 ${index + 2} 行的時間戳無效: ${row[timeIndex]}`);
          }

          return {
              timestamp: timestamp,
              userId: String(row[userIdIndex]),
              userName: String(row[userNameIndex]),
              beverageName: String(row[beverageNameIndex]),
              price: price,
          };
      }).filter(Boolean);
      
      setRecords(data as ConsumptionRecord[]);
      setFileName(file.name);
      setError(null);
      setSearchQuery('');
    };
    
    try {
      if (file.name.endsWith('.xlsx')) {
        const buffer = await file.arrayBuffer();
        const workbook = XLSX.read(buffer, { type: 'array', cellDates: true });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        const rows: any[][] = XLSX.utils.sheet_to_json(worksheet, { header: 1, defval: '' });
        processRows(rows);
      } else {
        const text = await file.text();
        const lines = text.split(/\r?\n/).filter(line => line.trim() !== '');
        const rows = lines.map(line => line.split('\t'));
        processRows(rows);
      }
    } catch (e: any) {
        setError(e.message || "解析檔案失敗。請確保檔案格式正確。");
        setRecords([]);
        setFileName(null);
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
    // Treat userName as the primary identifier. The userId is still needed for the User type and React key,
    // so we use the unique userName for it.
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
        {records.length === 0 ? (
          <FileUpload onFileSelect={handleFileParse} />
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
                    上傳新檔案
                </button>
            </div>
            <UserSearch
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              users={allUsers}
              onUserSelect={(userName) => setSearchQuery(userName)}
            />
            <ResultsDisplay records={filteredRecords} query={searchQuery} />
          </div>
        )}
      </main>
      <Footer />
    </div>
  );
};

export default App;