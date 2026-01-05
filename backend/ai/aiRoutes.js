const express = require("express");
const router = express.Router();
const aiController = require("./aiController"); // <--- هذا مهم

// Test route
router.get("/test", aiController.test);

// OCR route
router.post("/ocr", aiController.runOCR);

// AI Assistant Chatbot
router.post("/chat", aiController.runAssistant);

// Run Python model
router.post("/run-model", aiController.runPythonModel);

module.exports = router;
