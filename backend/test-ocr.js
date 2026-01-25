const runMusnadOCR = require("./ai/ocr/musnadOCR");
const fs = require("fs");
const path = require("path");

console.log("=".repeat(60));
console.log(" اختبار Tesseract OCR للخط المسند");
console.log("=".repeat(60));

async function testOCR() {
  try {
    const uploadsDir = path.join(__dirname, "uploads");
    
    if (!fs.existsSync(uploadsDir)) {
      console.log(" مجلد uploads غير موجود!");
      return;
    }

    const files = fs.readdirSync(uploadsDir).filter(f => 
      f.endsWith(".jpg") || f.endsWith(".png") || f.endsWith(".jpeg")
    );

    if (files.length === 0) {
      console.log(" لا توجد صور في مجلد uploads!");
      console.log(" ضع صورة بها نص عربي في مجلد uploads");
      return;
    }

    console.log(`\n تم العثور على ${files.length} صورة`);
    console.log(` سيتم اختبار أول صورة: ${files[0]}\n`);

    const testImagePath = path.join(uploadsDir, files[0]);
    
    console.log(" الاختبار 1: قراءة من مسار الملف");
    console.log("-".repeat(60));
    const result1 = await runMusnadOCR(testImagePath, { lang: "ara" });
    displayResults(result1);

    console.log("\n" + "=".repeat(60));
    console.log(" الاختبار 2: قراءة من Buffer");
    console.log("-".repeat(60));
    const imageBuffer = fs.readFileSync(testImagePath);
    const result2 = await runMusnadOCR(imageBuffer, { lang: "ara+eng" });
    displayResults(result2);

  } catch (error) {
    console.error("\n خطأ في الاختبار:", error);
  }
}

function displayResults(result) {
  console.log("\n النتائج:");
  console.log("-".repeat(60));
  
  if (result.success) {
    console.log(` الحالة: نجحت العملية`);
    console.log(`  الوقت المستغرق: ${result.processingTime}`);
    console.log(` مستوى الثقة: ${result.confidence}%`);
    console.log(` عدد الكلمات: ${result.statistics.totalWords}`);
    console.log(` عدد الأسطر: ${result.statistics.totalLines}`);
    console.log(` عدد الفقرات: ${result.statistics.totalParagraphs}`);
    
    console.log("\n النص المستخرج:");
    console.log("-".repeat(60));
    if (result.text) {
      console.log(result.text);
    } else {
      console.log("(لا يوجد نص مكتشف)");
    }
    console.log("-".repeat(60));
    
    if (result.details && result.details.words.length > 0) {
      console.log("\n أول 10 كلمات مع مستوى الثقة:");
      result.details.words.slice(0, 10).forEach((word, index) => {
        console.log(`  ${index + 1}. "${word.text}" - ثقة: ${word.confidence}%`);
      });
    }
  } else {
    console.log(` الحالة: فشلت العملية`);
    console.log(`  الخطأ: ${result.error}`);
  }
  
  console.log("\n");
}

testOCR().then(() => {
  console.log("=".repeat(60));
  console.log(" انتهى الاختبار");
  console.log("=".repeat(60));
  process.exit(0);
}).catch(error => {
  console.error(" خطأ غير متوقع:", error);
  process.exit(1);
});
