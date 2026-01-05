const Tesseract = require("tesseract.js");

module.exports = async function runMusnadOCR(imageFile) {
  try {
    const buffer = imageFile.data;

    const result = await Tesseract.recognize(buffer, "ara", {
      logger: (m) => console.log(m)
    });

    return result.data.text;
  } catch (error) {
    console.error("Musnad OCR Error:", error);
    throw error;
  }
};
