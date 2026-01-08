import React from 'react'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer
} from 'recharts'

const StatCard = ({ title, value, color }) => (
  <div
    style={{
      background: '#fff',
      borderRadius: '14px',
      padding: '25px',
      boxShadow: '0 6px 18px rgba(0,0,0,0.08)',
      flex: 1,
      minWidth: '240px',
      borderTop: `6px solid ${color}`,
    }}
  >
    <div style={{ color: '#777', fontSize: '15px' }}>{title}</div>
    <div
      style={{
        fontSize: '42px',
        fontWeight: 'bold',
        color,
        marginTop: '10px',
      }}
    >
      {value}
    </div>
  </div>
)

const Dashboard = ({
  usersCount = 0,
  contentCount = 0,
  feedbackCount = 0,
  stats = [],
}) => {
  return (
    <div style={{ padding: '40px', direction: 'rtl', fontFamily: 'sans-serif' }}>
      {/* Header */}
      <div
        style={{
          background: '#fff',
          padding: '30px',
          borderRadius: '16px',
          marginBottom: '30px',
          boxShadow: '0 4px 14px rgba(0,0,0,0.06)',
        }}
      >
        <h1 style={{ margin: 0, color: '#3040D6' }}>
          📊 لوحة التحكم – تراث اليمن الذكي
        </h1>
        <p style={{ color: '#777', marginTop: '10px' }}>
          نظرة عامة على إحصائيات النظام
        </p>
      </div>

      {/* Cards */}
      <div style={{ display: 'flex', gap: '25px', flexWrap: 'wrap' }}>
        <StatCard title="عدد المستخدمين" value={usersCount} color="#3040D6" />
        <StatCard title="عدد المحتوى السياحي" value={contentCount} color="#28A745" />
        <StatCard title="عدد التقييمات" value={feedbackCount} color="#FFC107" />
      </div>

      {/* Chart */}
      <div
        style={{
          background: '#fff',
          marginTop: '40px',
          padding: '30px',
          borderRadius: '16px',
          boxShadow: '0 6px 18px rgba(0,0,0,0.08)',
        }}
      >
        <h3 style={{ marginBottom: '20px' }}>📈 نمو المستخدمين</h3>

        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={stats}>
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Line
              type="monotone"
              dataKey="users"
              stroke="#3040D6"
              strokeWidth={3}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}

export default Dashboard
