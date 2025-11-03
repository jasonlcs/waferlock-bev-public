
import React, { useState } from 'react';
import { User } from '../types';
import { SearchIcon } from './icons';

interface UserSearchProps {
  value: string;
  onChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  users: User[];
  onUserSelect: (userName: string) => void;
}

const UserSearch: React.FC<UserSearchProps> = ({ value, onChange, users, onUserSelect }) => {
  return (
    <div className="p-6 bg-surface rounded-lg shadow-md">
      <h3 className="text-xl font-semibold mb-4 text-on-surface">查詢使用者消費記錄</h3>
      <div className="flex flex-col md:flex-row gap-4">
        <div className="relative flex-grow">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <SearchIcon className="h-5 w-5 text-subtle" />
          </div>
          <input
            type="text"
            placeholder="搜尋使用者名稱或 ID..."
            value={value}
            onChange={onChange}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-brand-primary focus:border-brand-primary"
          />
        </div>
        <div className="flex-shrink-0">
          <select 
            onChange={(e) => onUserSelect(e.target.value)} 
            className="w-full h-full px-4 py-2 border border-gray-300 rounded-lg bg-white focus:ring-brand-primary focus:border-brand-primary"
            value=""
          >
            <option value="" disabled>或從列表中選擇</option>
            {users.map(user => (
              <option key={user.userName} value={user.userName}>
                {user.userName}
              </option>
            ))}
          </select>
        </div>
      </div>
    </div>
  );
};

export default UserSearch;