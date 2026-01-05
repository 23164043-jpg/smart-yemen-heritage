const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
const axios = require('axios');

module.exports = {
  ask: async function (message) {
    try {
      console.log("📡 إرسال السؤال إلى Gemini...");
      console.log("💬 السؤال:", message);

      const prompt = `أنت مساعد ذكي متخصص في تاريخ اليمن القديم والتراث اليمني. 
أجب باللغة العربية بأسلوب مشوق ومختصر.
استخدم الإيموجي لجعل الإجابة أكثر تفاعلية.

السؤال: ${message}`;

      const apiKey = process.env.GEMINI_API_KEY;
      
      const response = await axios.post(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`,
        {
          contents: [{
            parts: [{ text: prompt }]
          }],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 1024,
          }
        },
        {
          headers: { 'Content-Type': 'application/json' },
          timeout: 60000
        }
      );

      const text = response.data.candidates?.[0]?.content?.parts?.[0]?.text;
      
      if (text) {
        console.log("✅ Gemini أجاب بنجاح!");
        return text;
      }
      
      throw new Error("لم يتم الحصول على رد");

    } catch (error) {
      console.error("❌ خطأ:", error.response?.data?.error?.message || error.message);
      return `❌ عذراً، حدث خطأ: ${error.response?.data?.error?.message || error.message}`;
    }
  }
};