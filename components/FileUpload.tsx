import React, { useCallback, useState } from 'react';
import { UploadIcon, ClipboardIcon } from './icons';

interface FileUploadProps {
  onFileSelect: (file: File) => void;
  onTextSubmit: (text: string) => void;
}

const FileUpload: React.FC<FileUploadProps> = ({ onFileSelect, onTextSubmit }) => {
  const [isDragging, setIsDragging] = useState(false);
  const [activeTab, setActiveTab] = useState('upload');
  const [pastedText, setPastedText] = useState('');

  const handleDragEnter = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  };
  
  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDrop = useCallback((e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      onFileSelect(e.dataTransfer.files[0]);
    }
  }, [onFileSelect]);
  
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      onFileSelect(e.target.files[0]);
    }
  };

  const handleTextAnalyze = () => {
    onTextSubmit(pastedText);
  };

  return (
    <div className="max-w-3xl mx-auto text-center bg-surface p-8 rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-4">開始分析</h2>
      <p className="text-subtle mb-6">上傳檔案或直接貼上您自動販賣機的出貨記錄來查看使用者消費明細和統計。</p>
      
      <div className="flex border-b mb-6 justify-center">
        <button 
          onClick={() => setActiveTab('upload')} 
          className={`flex items-center gap-2 px-4 py-2 font-semibold transition-colors duration-200 ${activeTab === 'upload' ? 'border-b-2 border-brand-primary text-brand-primary' : 'text-subtle hover:text-on-surface'}`}
          aria-pressed={activeTab === 'upload'}
        >
          <UploadIcon className="w-5 h-5" />
          上傳檔案
        </button>
        <button 
          onClick={() => setActiveTab('paste')} 
          className={`flex items-center gap-2 px-4 py-2 font-semibold transition-colors duration-200 ${activeTab === 'paste' ? 'border-b-2 border-brand-primary text-brand-primary' : 'text-subtle hover:text-on-surface'}`}
          aria-pressed={activeTab === 'paste'}
        >
          <ClipboardIcon className="w-5 h-5" />
          貼上文字
        </button>
      </div>

      {activeTab === 'upload' && (
        <div 
          onDragEnter={handleDragEnter}
          onDragLeave={handleDragLeave}
          onDragOver={handleDragOver}
          onDrop={handleDrop}
          className={`relative border-2 border-dashed rounded-lg p-12 transition-colors duration-200 ${isDragging ? 'border-brand-primary bg-blue-50' : 'border-gray-300'}`}
        >
          <input 
            type="file" 
            id="file-upload" 
            className="absolute inset-0 w-full h-full opacity-0 cursor-pointer" 
            onChange={handleFileChange}
            accept=".xlsx,.csv,.tsv,.txt"
          />
          <label htmlFor="file-upload" className="flex flex-col items-center justify-center space-y-4 cursor-pointer">
            <UploadIcon className="w-12 h-12 text-subtle" />
            <p className="text-lg font-semibold text-on-surface">
              拖曳檔案至此或 <span className="text-brand-primary">點擊上傳</span>
            </p>
            <p className="text-sm text-subtle">支援 XLSX, CSV, TSV, TXT 檔案</p>
          </label>
        </div>
      )}
      
      {activeTab === 'paste' && (
        <div className="text-left">
          <p className="text-subtle mb-4 text-center">直接從 Email 或文件中複製資料並貼到下方文字框中。</p>
          <textarea
            className="w-full h-48 p-3 border border-gray-300 rounded-lg focus:ring-brand-primary focus:border-brand-primary"
            placeholder="在此貼上 Tab 分隔的資料..."
            value={pastedText}
            onChange={(e) => setPastedText(e.target.value)}
            aria-label="Paste data here"
          />
          <div className="text-center">
            <button
              onClick={handleTextAnalyze}
              className="mt-4 bg-brand-primary hover:bg-brand-secondary text-white font-bold py-2 px-6 rounded-lg transition-colors duration-200 disabled:bg-gray-400 disabled:cursor-not-allowed"
              disabled={!pastedText.trim()}
            >
              分析貼上內容
            </button>
          </div>
        </div>
      )}

      <div className="mt-8 text-left bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-2">檔案格式要求:</h3>
          <p className="text-sm text-subtle">您的檔案或貼上內容必須包含以下欄位 (header):</p>
          <code className="block bg-gray-200 text-gray-800 p-2 rounded mt-2 text-sm">
            裝置名稱	使用者名稱	卡片UID	事件時間	人臉辨識ID	倉道	品名	金額
          </code>
          <p className="text-sm text-subtle mt-2">範例資料 (Tab 分隔):</p>
           <code className="block bg-gray-200 text-gray-800 p-2 rounded mt-2 text-sm whitespace-pre">
4F自動販賣機-2	Ming Lin		2025-10-23 18:02:36	362	10	八寶粥	25
          </code>
      </div>
    </div>
  );
};

export default FileUpload;
