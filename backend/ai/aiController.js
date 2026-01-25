const musnadOCR = require("./ocr/musnadOCR");
const assistantService = require("./assistant/assistantService");
const runPy = require("./python/runPythonModel");


// اختبار بسيط
const test = (req, res) => {
  res.json({ 
    message: "AI API is working",
    endpoints: {
      ocr: "POST /api/ai/ocr",
      chat: "POST /api/ai/chat",
      model: "POST /api/ai/run-model"
    }
  });
};


// ---------------------- OCR محسّن ------------------------
const runOCR = async (req, res) => {
  try {
    console.log("📸 تم استلام طلب OCR...");
    
    if (!req.file) {
      return res.status(400).json({ 
        success: false,
        message: "يجب إرفاق صورة" 
      });
    }

    const imageFile = req.file; // multer file object
    console.log(`📄 الملف: ${imageFile.originalname} (${(imageFile.size / 1024).toFixed(2)} KB)`);

    // خيارات OCR من الطلب
    const options = {
      lang: req.body.lang || "ara+eng"
    };

    // تشغيل OCR
    const result = await musnadOCR(imageFile.buffer, options);

    if (result.success) {
      console.log(`✅ نجح OCR: ${result.statistics.totalWords} كلمة`);
      
      // إرجاع النتيجة بتنسيق يتوافق مع Flutter
      res.json({
        success: true,
        data: {
          text: result.text,
          confidence: result.confidence,
          wordCount: result.statistics.totalWords,
          lineCount: result.statistics.totalLines,
          processingTime: parseFloat(result.processingTime)
        }
      });
    } else {
      console.error(`❌ فشل OCR: ${result.error}`);
      res.status(500).json(result);
    }

  } catch (error) {
    console.error("❌ خطأ في OCR API:", error);
    res.status(500).json({ 
      success: false,
      message: "حدث خطأ في معالجة الصورة",
      error: error.message 
    });
  }
};


// ---------------------- Assistant / Chatbot ------------------------
const runAssistant = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ 
        success: false,
        message: "الرسالة مطلوبة" 
      });
    }

    console.log(`💬 رسالة المستخدم: ${message}`);
    const reply = await assistantService.ask(message);
    
    res.json({ 
      success: true,
      response: reply 
    });

  } catch (error) {
    console.error("❌ خطأ في المساعد الذكي:", error);
    res.status(500).json({ 
      success: false,
      message: "حدث خطأ في المساعد الذكي",
      error: error.message 
    });
  }
};


// ---------------------- Python Model ------------------------
const runPythonModel = async (req, res) => {
  try {
    console.log("🐍 تشغيل نموذج Python...");
    const output = await runPy();
    
    res.json({ 
      success: true,
      result: output 
    });
    
  } catch (error) {
    console.error("❌ خطأ في Python:", error);
    res.status(500).json({ 
      success: false,
      message: "حدث خطأ في تشغيل النموذج",
      error: error.message 
    });
  }
};


module.exports = {
  test,
  runOCR,
  runAssistant,
  runPythonModel
};
