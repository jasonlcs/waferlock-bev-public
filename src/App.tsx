
import React, { useState, useMemo, useCallback } from 'react';
import { ConsumptionRecord, ApiCredentials } from './types';
import FileUpload from './components/FileUpload';
import UserSearch from './components/UserSearch';
import ResultsDisplay from './components/ResultsDisplay';
import { Header } from './components/Header';
import { Footer } from './components/Footer';

const DEFAULT_API_BASE = 'https://liveamcore1.waferlock.com:10001';
const API_BASE_URL = (
  import.meta.env.VITE_API_BASE_URL ??
  (import.meta.env.DEV ? '/__waferlock' : DEFAULT_API_BASE)
).replace(/\/$/, '');

type UiError = {
  summary: string;
  detail?: string;
  step?: string;
};

type ApiError = Error & {
  detail?: string;
  step?: string;
  status?: number;
  tokenUsed?: string;
};

const App: React.FC = () => {
  const [records, setRecords] = useState<ConsumptionRecord[]>([]);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [error, setError] = useState<UiError | null>(null);
  const [fileName, setFileName] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [loadingMessage, setLoadingMessage] = useState<string>('資料讀取中，請稍候...');
  const [authToken, setAuthToken] = useState<string | null>(null);
  const [cachedCredentials, setCachedCredentials] = useState<ApiCredentials | null>(null);
  
  const handleApiFetch = useCallback(async (credentials: ApiCredentials, month: string) => {
    setIsLoading(true);
    setError(null);

    const loginUrl = `${API_BASE_URL}/api/Auth/login`;
    const dataUrl = `${API_BASE_URL}/api/EventVendingMaching/range`;

    const effectiveCredentials = credentials ?? cachedCredentials ?? credentials;
    let currentStep = authToken ? `事件資料 API (${dataUrl})` : `登入 API (${loginUrl})`;
    let requestPayload: Record<string, unknown> | null = null;
    let token: string | null = authToken;
    let tokenForDebug = token ?? '';
    let loginResponseBody: string | null = null;

    const readErrorBody = async (response: Response) => {
      const contentType = response.headers.get('content-type') || '';
      try {
        if (contentType.includes('application/json')) {
          const jsonBody = await response.clone().json();
          if (typeof jsonBody === 'string') return jsonBody;
          return JSON.stringify(jsonBody, null, 2);
        }
        const textBody = await response.clone().text();
        return textBody.trim() || '(伺服器未返回內容)';
      } catch (parseError) {
        console.error('解析伺服器錯誤內容失敗', parseError);
        return '(無法解析伺服器回傳內容)';
      }
    };

    try {
      const year = parseInt(month.substring(0, 4), 10);
      const monthNum = parseInt(month.substring(5, 7), 10);

      const startDate = new Date(year, monthNum - 1, 1);
      const endDate = new Date(year, monthNum, 0);

      const formatDate = (date: Date) => date.toISOString().split('T')[0];

      if (!token) {
        setLoadingMessage('正在登入...');
        const loginResponse = await fetch(loginUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json-patch+json', accept: 'text/plain' },
          body: JSON.stringify(effectiveCredentials),
        });

        if (!loginResponse.ok) {
          const errorDetails = await readErrorBody(loginResponse);
          const error = new Error(`登入 API 呼叫失敗 (${loginResponse.status} ${loginResponse.statusText})`) as ApiError;
          error.detail = errorDetails;
          error.step = currentStep;
          error.status = loginResponse.status;
          throw error;
        }
        const loginBody = await loginResponse.text();
        loginResponseBody = loginBody;
        let extractedToken = '';
        try {
          const parsed = JSON.parse(loginBody);
          if (parsed && typeof parsed === 'object') {
            const candidate =
              (parsed as any).token ??
              (parsed as any).Token ??
              (parsed as any).accessToken ??
              (parsed as any).access_token ??
              null;
            if (typeof candidate === 'string') {
              extractedToken = candidate;
            } else if (typeof (parsed as any).data === 'string') {
              extractedToken = (parsed as any).data;
            }
          } else if (typeof parsed === 'string') {
            extractedToken = parsed;
          }
        } catch {
          extractedToken = loginBody;
        }

        token = (extractedToken || loginBody).trim().replace(/^"+|"+$/g, '');
        if (!token) {
          const error = new Error('登入 API 回傳的 token 為空，請檢查憑證是否正確。') as ApiError;
          error.detail = `原始回應: ${loginBody || '(空字串)'}`;
          error.step = currentStep;
          error.status = 401;
          throw error;
        }
        setAuthToken(token);
        setCachedCredentials(effectiveCredentials);
        tokenForDebug = token;
        currentStep = `事件資料 API (${dataUrl})`;
        setLoadingMessage('登入成功！正在取得資料...');
      } else {
        tokenForDebug = token;
        if (!cachedCredentials) {
          setCachedCredentials(effectiveCredentials);
        }
        setLoadingMessage('使用既有權杖取得資料...');
        currentStep = `事件資料 API (${dataUrl})`;
      }

      requestPayload = {
        startDate: formatDate(startDate),
        endDate: formatDate(endDate),
        eventCount: 2000,
      };

      const dataResponse = await fetch(dataUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json-patch+json',
          accept: 'text/plain',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(requestPayload),
      });

      if (!dataResponse.ok) {
        const errorDetails = await readErrorBody(dataResponse);
        const error = new Error(`事件資料 API 呼叫失敗 (${dataResponse.status} ${dataResponse.statusText})`) as ApiError;
        error.detail = errorDetails;
        error.step = currentStep;
        error.status = dataResponse.status;
        error.tokenUsed = token ?? undefined;
        throw error;
      }
      const apiData = await dataResponse.json();

      if (!Array.isArray(apiData)) {
        console.error('Unexpected API response format', apiData);
        throw new Error(`事件資料 API 回應格式不正確，預期為陣列，實際為 ${typeof apiData}`);
      }

      const processedData: ConsumptionRecord[] = apiData
        .map((record: any) => {
          const timestamp = new Date(record.eventTime);
          if (isNaN(timestamp.getTime())) {
            console.warn("Skipping record with invalid timestamp:", record);
            return null;
          }

          const amount = Number(record.amount);
          if (!Number.isFinite(amount) || amount <= 0) {
            return null;
          }

          const channelValue = record.channel;
          if (channelValue !== undefined && channelValue !== null) {
            const channelNumber = Number(channelValue);
            if (!Number.isNaN(channelNumber) && channelNumber === 0) {
              return null;
            }
          }

          return {
            timestamp,
            userId: String(record.fid),
            userName: record.targetUserName,
            beverageName: record.productName || `Channel ${record.channel}` || '未知品項',
            price: amount,
          };
        })
        .filter((record): record is ConsumptionRecord => record !== null);

      if (processedData.length === 0) {
        setError({ summary: "在指定月份內找不到任何消費記錄。" });
      }

      setRecords(processedData);
      setFileName(`API 資料 (${month})`);
      setSearchQuery('');
    } catch (err: unknown) {
      console.error('取得資料失敗', err);
      const apiError = err as ApiError;
      let summary = "從 API 取得資料時發生未知的錯誤。";
      const step = apiError?.step ?? currentStep;
      const detailSections: string[] = [];

      if (apiError?.detail) {
        detailSections.push(`伺服器回應:\n${apiError.detail}`);
      } else if (loginResponseBody) {
        detailSections.push(`登入 API 回應:\n${loginResponseBody}`);
      }

      if (err instanceof Error) {
        if (err.message.includes('Failed to fetch')) {
          summary = `${currentStep} 請求被瀏覽器阻擋（常見原因為未開放 CORS 或 HTTPS 憑證設定）。`;
          detailSections.push(
            [
              `原始訊息: ${err.message}`,
              '請開啟瀏覽器開發者工具的 Network/Console 檢查對應請求，可看到更完整的瀏覽器錯誤說明。',
            ].join('\n')
          );
        } else if (err.message) {
          summary = err.message;
        }
      }

      if (tokenForDebug) {
        detailSections.push(`Authorization 標頭:\nBearer ${tokenForDebug}`);
      }
      if (requestPayload) {
        detailSections.push(`Request Body:\n${JSON.stringify(requestPayload, null, 2)}`);
      }
      if (apiError?.status === 401 || apiError?.status === 403) {
        detailSections.push('權杖可能已失效，已重新顯示登入表單。');
        setAuthToken(null);
        setCachedCredentials(null);
      }

      const detailString = detailSections.length ? detailSections.join('\n\n---\n\n') : undefined;
      setError({ summary, detail: detailString, step });
      setRecords([]);
      setFileName(null);
    } finally {
      setIsLoading(false);
      setLoadingMessage('資料讀取中，請稍候...');
    }
  }, [authToken, cachedCredentials]);

  const handleReset = () => {
    setRecords([]);
    setFileName(null);
    setError(null);
    setSearchQuery('');
  };

  const handleLogout = useCallback(() => {
    setAuthToken(null);
    setCachedCredentials(null);
    setRecords([]);
    setFileName(null);
    setError(null);
    setSearchQuery('');
  }, []);

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
            <span className="block sm:inline">
              {error.step ? `[${error.step}] ` : ''}
              {error.summary}
            </span>
            {error.detail && (
              <pre className="mt-3 p-3 bg-white border border-red-200 rounded text-sm text-red-800 whitespace-pre-wrap break-words">
                {error.detail}
              </pre>
            )}
          </div>
        )}
        {records.length === 0 && !isLoading ? (
          <FileUpload
            onApiSubmit={handleApiFetch}
            isLoading={isLoading}
            hasActiveToken={Boolean(authToken)}
            initialCredentials={cachedCredentials ?? undefined}
            onLogout={handleLogout}
          />
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
