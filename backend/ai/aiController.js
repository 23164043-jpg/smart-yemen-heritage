const musnadOCR = require("./ocr/musnadOCR");
const assistantService = require("./assistant/assistantService");
const runPy = require("./python/runPythonModel");


// اختبار بسيط
const test = (req, res) => {
  res.json({ message: "AI API is working" });
};


// ---------------------- OCR ------------------------
const runOCR = async (req, res) => {
  try {
    if (!req.files || !req.files.image) {
      return res.status(400).json({ message: "Image is required" });
    }

    const result = await musnadOCR(req.files.image);
    res.json({ text: result });
  } catch (error) {
    console.error("OCR Error:", error);
    res.status(500).json({ message: "OCR Failed" });
  }
};


// ---------------------- Assistant / Chatbot ------------------------
const runAssistant = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ message: "Message is required" });
    }

    const reply = await assistantService.ask(message);
    res.json({ response: reply });

  } catch (error) {
    console.error("AI Assistant Error:", error);
    res.status(500).json({ message: "Assistant Error" });
  }
};


// ---------------------- Python Model ------------------------
const runPythonModel = async (req, res) => {
  try {
    const output = await runPy();
    res.json({ result: output });
  } catch (error) {
    console.error("Python Error:", error);
    res.status(500).json({ message: "Python Model Error" });
  }
};


module.exports = {
  test,
  runOCR,
  runAssistant,
  runPythonModel
};
