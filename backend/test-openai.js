require('dotenv').config();
const axios = require('axios');

async function testOpenAI() {
  try {
    const apiKey = process.env.OPENAI_API_KEY;
    console.log('Testing OpenAI API...');
    console.log('API Key:', apiKey ? 'Found' : 'Missing');
    
    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions',
      {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'user', content: 'قل مرحبا' }
        ],
        max_tokens: 50
      },
      {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout: 15000
      }
    );
    
    console.log('✅ Success!');
    console.log('Response:', response.data.choices[0].message.content);
  } catch (error) {
    console.error('❌ Error:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    } else if (error.code === 'ECONNABORTED') {
      console.error('Timeout - no response from API');
    } else {
      console.error('Message:', error.message);
    }
  }
}

testOpenAI();
