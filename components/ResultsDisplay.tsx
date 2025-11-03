import React, { useMemo } from 'react';
import { ConsumptionRecord } from '../types';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell, Sector } from 'recharts';
import { ChartIcon, ListIcon, MoneyIcon, TagIcon, TrophyIcon, ClockIcon, UsersIcon } from './icons';

interface ResultsDisplayProps {
  records: ConsumptionRecord[];
  allRecords: ConsumptionRecord[];
  query: string;
}

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884d8', '#82ca9d'];

const renderActiveShape = (props: any) => {
  const RADIAN = Math.PI / 180;
  const { cx, cy, midAngle, innerRadius, outerRadius, startAngle, endAngle, fill, payload, percent, value } = props;
  const sin = Math.sin(-RADIAN * midAngle);
  const cos = Math.cos(-RADIAN * midAngle);
  const sx = cx + (outerRadius + 10) * cos;
  const sy = cy + (outerRadius + 10) * sin;
  const mx = cx + (outerRadius + 30) * cos;
  const my = cy + (outerRadius + 30) * sin;
  const ex = mx + (cos >= 0 ? 1 : -1) * 22;
  const ey = my;
  const textAnchor = cos >= 0 ? 'start' : 'end';

  return (
    <g>
      <text x={cx} y={cy} dy={8} textAnchor="middle" fill={fill}>
        {payload.name}
      </text>
      <Sector
        cx={cx}
        cy={cy}
        innerRadius={innerRadius}
        outerRadius={outerRadius}
        startAngle={startAngle}
        endAngle={endAngle}
        fill={fill}
      />
      <Sector
        cx={cx}
        cy={cy}
        startAngle={startAngle}
        endAngle={endAngle}
        innerRadius={outerRadius + 6}
        outerRadius={outerRadius + 10}
        fill={fill}
      />
      <path d={`M${sx},${sy}L${mx},${my}L${ex},${ey}`} stroke={fill} fill="none" />
      <circle cx={ex} cy={ey} r={2} fill={fill} stroke="none" />
      <text x={ex + (cos >= 0 ? 1 : -1) * 12} y={ey} textAnchor={textAnchor} fill="#333">{`${value} 次`}</text>
      <text x={ex + (cos >= 0 ? 1 : -1) * 12} y={ey} dy={18} textAnchor={textAnchor} fill="#999">
        {`(佔 ${(percent * 100).toFixed(2)}%)`}
      </text>
    </g>
  );
};

const RankedListItem: React.FC<{rank: number, text: string, value: number}> = ({ rank, text, value }) => (
  <li className="flex items-center justify-between p-2 rounded-md transition-colors hover:bg-gray-100">
    <div className="flex items-center gap-3">
      <span className={`flex items-center justify-center w-6 h-6 rounded-full font-bold text-white ${
        rank === 1 ? 'bg-yellow-400' : rank === 2 ? 'bg-gray-400' : 'bg-yellow-600'
      }`}>{rank}</span>
      <span className="font-medium text-on-surface">{text}</span>
    </div>
    <span className="font-semibold text-subtle">{value} 次</span>
  </li>
);


const ResultsDisplay: React.FC<ResultsDisplayProps> = ({ records, allRecords, query }) => {
    const [activeIndex, setActiveIndex] = React.useState(0);
    const onPieEnter = (_: any, index: number) => {
        setActiveIndex(index);
    };

    const calculateStats = (data: ConsumptionRecord[]) => {
        if (data.length === 0) return null;

        const totalSpent = data.reduce((sum, record) => sum + record.price, 0);
        const totalItems = data.length;
        const uniqueUsers = new Set(data.map(r => r.userName)).size;

        const beverageCounts: Record<string, number> = {};
        data.forEach(record => {
            beverageCounts[record.beverageName] = (beverageCounts[record.beverageName] || 0) + 1;
        });

        const chartData = Object.entries(beverageCounts)
            .map(([name, value]) => ({ name, value }))
            .sort((a, b) => b.value - a.value);

        const topBeverages = chartData.slice(0, 3).map(item => ({
            name: item.name,
            count: item.value
        }));

        const hourCounts: number[] = Array(24).fill(0);
        data.forEach(record => {
            const hour = record.timestamp.getHours();
            hourCounts[hour]++;
        });

        const popularTimes = hourCounts
            .map((count, hour) => ({ hour, count }))
            .filter(item => item.count > 0)
            .sort((a, b) => b.count - a.count)
            .slice(0, 3)
            .map(item => ({
                timeSlot: `${String(item.hour).padStart(2, '0')}:00 - ${String(item.hour).padStart(2, '0')}:59`,
                count: item.count
            }));
        
        return { totalSpent, totalItems, uniqueUsers, chartData, topBeverages, popularTimes };
    };

  const userStats = useMemo(() => calculateStats(records), [records]);
  const globalStats = useMemo(() => calculateStats(allRecords), [allRecords]);


  if (!query) {
    if (allRecords.length > 0 && globalStats) {
        return (
             <div className="space-y-8">
                <div className="p-6 bg-surface rounded-lg shadow-md">
                    <h3 className="text-xl font-semibold mb-4 text-on-surface">
                    全站數據總覽
                    </h3>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <StatCard icon={<UsersIcon/>} title="總使用者數" value={`${globalStats.uniqueUsers} 人`} />
                        <StatCard icon={<MoneyIcon/>} title="總銷售金額" value={`NT$ ${globalStats.totalSpent.toLocaleString()}`} />
                        <StatCard icon={<TagIcon/>} title="總銷售品項" value={`${globalStats.totalItems} 項`} />
                    </div>
                </div>
                <div className="p-6 bg-surface rounded-lg shadow-md">
                    <h3 className="text-xl font-semibold mb-4 text-on-surface">熱門分析 (全站)</h3>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                        <div>
                            <h4 className="font-semibold text-lg mb-3 flex items-center gap-2 text-on-surface">
                                <TrophyIcon className="w-6 h-6 text-yellow-500" />
                                熱門飲料 Top 3
                            </h4>
                            <ul className="space-y-2">
                                {globalStats.topBeverages.length ? globalStats.topBeverages.map((item, index) => (
                                    <RankedListItem 
                                        key={item.name} 
                                        rank={index + 1} 
                                        text={item.name} 
                                        value={item.count} 
                                    />
                                )) : <p className="text-subtle">無足夠資料</p>}
                            </ul>
                        </div>
                        <div>
                            <h4 className="font-semibold text-lg mb-3 flex items-center gap-2 text-on-surface">
                                <ClockIcon className="w-6 h-6 text-blue-500" />
                                熱門時段 Top 3
                            </h4>
                            <ul className="space-y-2">
                                {globalStats.popularTimes.length ? globalStats.popularTimes.map((item, index) => (
                                    <RankedListItem 
                                        key={item.timeSlot} 
                                        rank={index + 1} 
                                        text={item.timeSlot} 
                                        value={item.count} 
                                    />
                                )) : <p className="text-subtle">無足夠資料</p>}
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        )
    }
    return (
      <div className="text-center p-8 bg-surface rounded-lg shadow-md">
        <p className="text-subtle">請在上方搜尋框輸入使用者名稱或 ID 以查看其消費記錄。</p>
      </div>
    );
  }

  if (records.length === 0) {
    return (
      <div className="text-center p-8 bg-surface rounded-lg shadow-md">
        <p className="text-subtle">找不到符合 "{query}" 的使用者記錄。</p>
      </div>
    );
  }
  
  const userName = records[0]?.userName;
  const userId = records[0]?.userId;

  return (
    <div className="space-y-8">
      <div className="p-6 bg-surface rounded-lg shadow-md">
        <h3 className="text-xl font-semibold mb-4 text-on-surface">
          {userName} ({userId}) 的消費總覽
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <StatCard icon={<MoneyIcon/>} title="總消費金額" value={`NT$ ${userStats?.totalSpent.toLocaleString()}`} />
          <StatCard icon={<TagIcon/>} title="總購買品項" value={`${userStats?.totalItems} 項`} />
          <StatCard icon={<ChartIcon/>} title="最愛品項" value={userStats?.chartData[0]?.name || 'N/A'} />
        </div>
      </div>
      
      <div className="p-6 bg-surface rounded-lg shadow-md">
        <h3 className="text-xl font-semibold mb-4 text-on-surface">熱門分析</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div>
                <h4 className="font-semibold text-lg mb-3 flex items-center gap-2 text-on-surface">
                    <TrophyIcon className="w-6 h-6 text-yellow-500" />
                    熱門飲料 Top 3
                </h4>
                <ul className="space-y-2">
                    {userStats?.topBeverages.length ? userStats.topBeverages.map((item, index) => (
                        <RankedListItem 
                            key={item.name} 
                            rank={index + 1} 
                            text={item.name} 
                            value={item.count} 
                        />
                    )) : <p className="text-subtle">無足夠資料</p>}
                </ul>
            </div>
            <div>
                <h4 className="font-semibold text-lg mb-3 flex items-center gap-2 text-on-surface">
                    <ClockIcon className="w-6 h-6 text-blue-500" />
                    熱門時段 Top 3
                </h4>
                <ul className="space-y-2">
                    {userStats?.popularTimes.length ? userStats.popularTimes.map((item, index) => (
                        <RankedListItem 
                            key={item.timeSlot} 
                            rank={index + 1} 
                            text={item.timeSlot} 
                            value={item.count} 
                        />
                    )) : <p className="text-subtle">無足夠資料</p>}
                </ul>
            </div>
        </div>
      </div>

      <div className="p-6 bg-surface rounded-lg shadow-md">
        <h3 className="text-xl font-semibold mb-4 text-on-surface">品項分佈</h3>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 h-[400px]">
            <ResponsiveContainer width="100%" height="100%">
                <BarChart data={userStats?.chartData} margin={{ top: 5, right: 20, left: -10, bottom: 5 }}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis allowDecimals={false} />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="value" fill="#3B82F6" name="購買次數" />
                </BarChart>
            </ResponsiveContainer>
            <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                    <Pie
                        activeIndex={activeIndex}
                        activeShape={renderActiveShape}
                        data={userStats?.chartData}
                        cx="50%"
                        cy="50%"
                        innerRadius={60}
                        outerRadius={80}
                        fill="#8884d8"
                        dataKey="value"
                        onMouseEnter={onPieEnter}
                    >
                        {userStats?.chartData.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                        ))}
                    </Pie>
                </PieChart>
            </ResponsiveContainer>
        </div>
      </div>
      
      <div className="p-6 bg-surface rounded-lg shadow-md">
        <h3 className="text-xl font-semibold mb-4 flex items-center gap-2 text-on-surface">
          <ListIcon/> 消費記錄
        </h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="p-4 font-semibold">時間</th>
                <th className="p-4 font-semibold">品名</th>
                <th className="p-4 font-semibold text-right">價格</th>
              </tr>
            </thead>
            <tbody>
              {records.map((record, index) => (
                <tr key={index} className="border-b hover:bg-gray-50">
                  <td className="p-4 text-subtle">{record.timestamp.toLocaleString()}</td>
                  <td className="p-4">{record.beverageName}</td>
                  <td className="p-4 text-right">NT$ {record.price}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

const StatCard: React.FC<{icon: React.ReactNode; title: string; value: string}> = ({icon, title, value}) => (
    <div className="bg-gray-100 p-4 rounded-lg flex items-center gap-4">
        <div className="bg-brand-secondary/20 text-brand-primary p-3 rounded-full">
            {icon}
        </div>
        <div>
            <p className="text-sm text-subtle">{title}</p>
            <p className="text-2xl font-bold text-on-surface">{value}</p>
        </div>
    </div>
);

export default ResultsDisplay;