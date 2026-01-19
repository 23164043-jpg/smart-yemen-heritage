const path = require('path');
// تأكد من أن المسار يؤدي إلى ملف .env في مجلد backend
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
const axios = require('axios');

// نظام تحديد معدل الطلبات (Rate Limiting)
const rateLimitMap = new Map();
const RATE_LIMIT_WINDOW = 60000; // دقيقة واحدة
const MAX_REQUESTS_PER_WINDOW = 15;

function checkRateLimit(userId = 'default') {
  const now = Date.now();
  const userRequests = rateLimitMap.get(userId) || [];
  const recentRequests = userRequests.filter(time => now - time < RATE_LIMIT_WINDOW);
  
  if (recentRequests.length >= MAX_REQUESTS_PER_WINDOW) {
    return false;
  }
  
  recentRequests.push(now);
  rateLimitMap.set(userId, recentRequests);
  return true;
}

module.exports = {
  ask: async function (message, userId = 'default') {
    try {
      // 1. فحص حدود الطلبات
      if (!checkRateLimit(userId)) {
        console.log("⚠️ تجاوز حد الطلبات للمستخدم:", userId);
        return "⚠️ عذراً، لقد تجاوزت الحد المسموح من الأسئلة. يرجى الانتظار دقيقة والمحاولة مرة أخرى.";
      }

      const apiKey = process.env.GEMINI_API_KEY;
      if (!apiKey) {
        throw new Error("API Key (OpenRouter) is missing in .env file");
      }

      // 2. قائمة الموديلات المجانية البديلة لضمان الاستمرارية
      const models = [
        "google/gemini-2.0-flash-exp:free",    // الخيار الأول (الأقوى)
        "mistralai/mistral-7b-instruct:free",  // الخيار الثاني (سريع جداً)
        "google/gemini-flash-1.5-8b:free"      // الخيار الثالث (مستقر)
      ];

      let lastError = "";

      // 3. محاولة الاتصال بالموديلات بالتوالي
      for (const modelName of models) {
        try {
          console.log(`📡 محاولة الاتصال عبر: ${modelName}...`);
          
          const response = await axios.post(
            "https://openrouter.ai/api/v1/chat/completions",
            {
              model: modelName,
              messages: [
                {
                  role: "system",
                  content: "أنت مساعد ذكي خبير في تاريخ اليمن القديم والتراث اليمني. أجب باللغة العربية بأسلوب مشوق ومختصر جداً مع استخدام الإيموجي المناسب."
                },
                {
                  role: "user",
                  content: message
                }
              ],
              temperature: 0.7,
              max_tokens: 800
            },
            {
              headers: {
                "Authorization": `Bearer ${apiKey}`,
                "Content-Type": "application/json",
                "HTTP-Referer": "http://localhost:3000",
                "X-Title": "Smart Yemen Heritage"
              },
              timeout: 20000 // مهلة 20 ثانية لكل محاولة
            }
          );

          const text = response.data.choices?.[0]?.message?.content;
          
          if (text) {
            console.log(`✅ نجح الأمر باستخدام الموديل: ${modelName}`);
            return text;
          }
        } catch (err) {
          lastError = err.response?.data?.error?.message || err.message;
          console.warn(`❌ فشل الموديل ${modelName}:`, lastError);
          // استمرار الحلقة لتجربة الموديل التالي تلقائياً
        }
      }

      // إذا وصلنا هنا، فهذا يعني أن جميع الموديلات فشلت
      throw new Error(`كافة الموديلات تواجه ضغطاً حالياً. آخر خطأ: ${lastError}`);

    } catch (error) {
      console.error("❌ خطأ نهائي في نظام الذكاء الاصطناعي:", error.message);
      return `❌ عذراً، السيرفرات العالمية تواجه ضغطاً كبيراً حالياً. يرجى المحاولة مرة أخرى بعد قليل.`;
    }
  }
};