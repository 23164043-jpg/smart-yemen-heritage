import React from 'react'

// مُكوّن فرعي (Helper Component) لبطاقة الإحصاء
function Card({ color, value, label }) {
  return React.createElement(
    'div',
    {
      key: label,
      style: {
        backgroundColor: '#fff',
        padding: '30px',
        borderRadius: '12px',
        boxShadow: '0 5px 20px rgba(0,0,0,0.08)',
        flex: '1',
        minWidth: '250px',
        textAlign: 'center',
        borderTop: `6px solid ${color}`,
      },
    },
    [
      React.createElement(
        'div',
        {
          key: 'value',
          style: {
            fontSize: '48px',
            fontWeight: 'bold',
            color,
            marginBottom: '10px',
          },
        },
        value
      ),

      React.createElement(
        'div',
        {
          key: 'label',
          style: {
            color: '#555',
            fontSize: '18px',
            fontWeight: 'bold',
          },
        },
        label
      ),
    ]
  )
}

const Dashboard = (props) => {
  const data = props || {}
  const { usersCount = 0, contentCount = 0, feedbackCount = 0 } = data

  return React.createElement(
    'div',
    {
      style: {
        padding: '40px',
        fontFamily: 'sans-serif',
        direction: 'rtl',
      },
    },
    [
      // عنوان الصفحة
      React.createElement(
        'div',
        {
          key: 'header',
          style: {
            marginBottom: '30px',
            backgroundColor: '#fff',
            padding: '25px',
            borderRadius: '12px',
            boxShadow: '0 4px 15px rgba(0,0,0,0.05)',
          },
        },
        [
          React.createElement(
            'h1',
            {
              key: 'title',
              style: {
                margin: 0,
                color: '#3040D6',
                fontSize: '28px',
              },
            },
            '👋 مرحباً بك في لوحة تحكم تراث اليمن الذكي'
          ),
          React.createElement(
            'p',
            {
              key: 'subtitle',
              style: { color: '#888', marginTop: '10px', fontSize: '16px' },
            },
            'نظرة عامة سريعة على إحصائيات التطبيق'
          ),
        ]
      ),

      // بطاقات الإحصائيات 
      React.createElement(
        'div',
        {
          key: 'cards-container',
          style: {
            display: 'flex',
            gap: '25px',
            flexWrap: 'wrap',
          },
        },
        [
          // بطاقة المستخدمين
          React.createElement(Card, { 
            color: '#3040D6',
            value: usersCount,
            label: 'مستخدم مسجل',
          }),

          // بطاقة المحتوى
          React.createElement(Card, { 
            color: '#28A745',
            value: contentCount,
            label: 'محتوى سياحي',
          }),

          // بطاقة التقييمات
          React.createElement(Card, { 
            color: '#FFC107',
            value: feedbackCount,
            label: 'تقييم وملاحظة',
          }),
        ]
      ),
    ]
  )
}

export default Dashboard