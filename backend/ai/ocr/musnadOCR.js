const Tesseract = require("tesseract.js");
const fs = require("fs");

/**
 * دالة محسّنة للتعرف على النصوص في الخط المسند
 */
async function runMusnadOCR(imageFile, options = {}) {
  try {
    console.log("🔍 بدء عملية OCR للخط المسند...");
    
    let imageBuffer;
    
    // التحقق من نوع المدخل
    if (Buffer.isBuffer(imageFile)) {
      imageBuffer = imageFile;
      console.log("✅ تم استلام صورة كـ Buffer");
    } else if (typeof imageFile === 'string') {
      if (!fs.existsSync(imageFile)) {
        throw new Error(`الملف غير موجود: ${imageFile}`);
      }
      imageBuffer = fs.readFileSync(imageFile);
      console.log(`✅ تم قراءة الصورة من: ${imageFile}`);
    } else if (imageFile && imageFile.data) {
      imageBuffer = imageFile.data;
      console.log("✅ تم استلام صورة من multer");
    } else {
      throw new Error("نوع الصورة غير مدعوم");
    }

    const config = {
      lang: options.lang || "ara+eng",
      
      logger: (m) => {
        if (m.status === 'recognizing text') {
          const progress = Math.round(m.progress * 100);
          console.log(`⏳ جاري التعرف على النص: ${progress}%`);
        }
      },
    };

    console.log(`🔧 إعدادات OCR: اللغة = ${config.lang}`);

    const startTime = Date.now();
    const result = await Tesseract.recognize(imageBuffer, config.lang, config);
    const processingTime = ((Date.now() - startTime) / 1000).toFixed(2);

    console.log(`✅ تمت عملية OCR بنجاح في ${processingTime} ثانية`);
    console.log(`📊 مستوى الثقة: ${(result.data.confidence).toFixed(2)}%`);

    const extractedText = result.data.text ? result.data.text.trim() : "";
    
    // التحقق من وجود words و lines
    const words = (result.data.words || []).map(word => ({
      text: word.text,
      confidence: parseFloat(word.confidence.toFixed(2)),
    }));

    const lines = (result.data.lines || []).map(line => ({
      text: line.text,
      confidence: parseFloat(line.confidence.toFixed(2)),
    }));

    console.log(`📝 عدد الكلمات المكتشفة: ${words.length}`);
    console.log(`📄 عدد الأسطر المكتشفة: ${lines.length}`);

    return {
      success: true,
      text: extractedText,
      confidence: parseFloat(result.data.confidence.toFixed(2)),
      processingTime: `${processingTime}s`,
      statistics: {
        totalWords: words.length,
        totalLines: lines.length,
        totalParagraphs: (result.data.paragraphs || []).length
      },
      details: {
        words: words,
        lines: lines
      }
    };

  } catch (error) {
    console.error("❌ خطأ في OCR:", error.message);
    return {
      success: false,
      error: error.message,
      text: "",
      confidence: 0
    };
  }
}

module.exports = runMusnadOCR;
