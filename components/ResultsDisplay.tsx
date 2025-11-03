import React, { useMemo } from 'react';
import { ConsumptionRecord } from '../types';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell, Sector } from 'recharts';
import { ChartIcon, ListIcon, MoneyIcon, TagIcon } from './icons';

interface ResultsDisplayProps {
  records: ConsumptionRecord[];
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


const ResultsDisplay: React.FC<ResultsDisplayProps> = ({ records, query }) => {
    const [activeIndex, setActiveIndex] = React.useState(0);
    const onPieEnter = (_: any, index: number) => {
        setActiveIndex(index);
    };

  const stats = useMemo(() => {
    if (records.length === 0) return null;
    
    const totalSpent = records.reduce((sum, record) => sum + record.price, 0);
    const totalItems = records.length;
    
    // FIX: Refactored beverageCounts calculation to use a forEach loop for clearer type inference, which resolves the arithmetic operation error.
    const beverageCounts: Record<string, number> = {};
    records.forEach(record => {
      beverageCounts[record.beverageName] = (beverageCounts[record.beverageName] || 0) + 1;
    });
    
    const chartData = Object.entries(beverageCounts)
      .map(([name, value]) => ({ name, value }))
      .sort((a, b) => b.value - a.value);
      
    return { totalSpent, totalItems, chartData };
  }, [records]);

  if (!query) {
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
          <StatCard icon={<MoneyIcon/>} title="總消費金額" value={`NT$ ${stats?.totalSpent.toLocaleString()}`} />
          <StatCard icon={<TagIcon/>} title="總購買品項" value={`${stats?.totalItems} 項`} />
          <StatCard icon={<ChartIcon/>} title="最愛品項" value={stats?.chartData[0]?.name || 'N/A'} />
        </div>
      </div>

      <div className="p-6 bg-surface rounded-lg shadow-md">
        <h3 className="text-xl font-semibold mb-4 text-on-surface">品項分佈</h3>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 h-[400px]">
            <ResponsiveContainer width="100%" height="100%">
                <BarChart data={stats?.chartData} margin={{ top: 5, right: 20, left: -10, bottom: 5 }}>
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
                        data={stats?.chartData}
                        cx="50%"
                        cy="50%"
                        innerRadius={60}
                        outerRadius={80}
                        fill="#8884d8"
                        dataKey="value"
                        onMouseEnter={onPieEnter}
                    >
                        {stats?.chartData.map((entry, index) => (
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
