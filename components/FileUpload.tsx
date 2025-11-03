import React, { useCallback, useState } from 'react';
import { UploadIcon } from './icons';

interface FileUploadProps {
  onFileSelect: (file: File) => void;
}

const FileUpload: React.FC<FileUploadProps> = ({ onFileSelect }) => {
  const [isDragging, setIsDragging] = useState(false);

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

  return (
    <div className="max-w-3xl mx-auto text-center bg-surface p-8 rounded-lg shadow-md">
      <h2 className="text-2xl font-bold mb-4">開始分析</h2>
      <p className="text-subtle mb-6">請上傳您的自動販賣機出貨記錄 (XLSX 或 Tab分隔格式) 來查看使用者消費明細和統計。</p>
      
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
      <div className="mt-8 text-left bg-gray-50 p-4 rounded-lg">
          <h3 className="font-semibold mb-2">檔案格式要求:</h3>
          <p className="text-sm text-subtle">您的檔案第一頁/檔案內容必須包含以下欄位 (header):</p>
          <code className="block bg-gray-200 text-gray-800 p-2 rounded mt-2 text-sm">
            裝置名稱	使用者名稱	卡片UID	事件時間	人臉辨識ID	倉道	品名	金額
          </code>
          <p className="text-sm text-subtle mt-2">範例資料:</p>
           <code className="block bg-gray-200 text-gray-800 p-2 rounded mt-2 text-sm whitespace-pre">
4F自動販賣機-2	Ming Lin		2025-10-23 18:02:36	362	10	八寶粥	25
          </code>
      </div>
    </div>
  );
};

export default FileUpload;