// "The Admin Dashboard is connected directly to MongoDB Atlas using Mongoose.
// We implemented real-time statistics by querying the database dynamically, ensuring scalability and centralized data management."



import React from 'react'

const Card = ({ color, value, label }) => (
  <div style={{
    backgroundColor: '#fff',
    padding: '30px',
    borderRadius: '12px',
    boxShadow: '0 5px 20px rgba(0,0,0,0.08)',
    flex: '1',
    minWidth: '250px',
    textAlign: 'center',
    borderTop: `6px solid ${color}`,
  }}>
    <div style={{
      fontSize: '48px',
      fontWeight: 'bold',
      color,
      marginBottom: '10px',
    }}>
      {value}
    </div>

    <div style={{
      color: '#555',
      fontSize: '18px',
      fontWeight: 'bold',
    }}>
      {label}
    </div>
  </div>
)

const Dashboard = ({ usersCount = 0, contentCount = 0, feedbackCount = 0 }) => {
  return (
    <div style={{ padding: '40px', fontFamily: 'sans-serif', direction: 'rtl' }}>
      <div style={{
        marginBottom: '30px',
        backgroundColor: '#fff',
        padding: '25px',
        borderRadius: '12px',
        boxShadow: '0 4px 15px rgba(0,0,0,0.05)',
      }}>
        <h1 style={{ margin: 0, color: '#3040D6', fontSize: '28px' }}>
          👋 مرحباً بك في لوحة تحكم تراث اليمن الذكي
        </h1>
        <p style={{ color: '#888', marginTop: '10px', fontSize: '16px' }}>
          نظرة عامة سريعة على إحصائيات التطبيق
        </p>
      </div>

      <div style={{ display: 'flex', gap: '25px', flexWrap: 'wrap' }}>
        <Card color="#3040D6" value={usersCount} label="مستخدم مسجل" />
        <Card color="#28A745" value={contentCount} label="محتوى سياحي" />
        <Card color="#FFC107" value={feedbackCount} label="تقييم وملاحظة" />
      </div>
    </div>
  )
}

export default Dashboard
