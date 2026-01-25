const express = require("express");
const multer = require('multer');
const router = express.Router();
const aiController = require("./aiController"); // <--- هذا مهم

// إعداد multer للذاكرة المؤقتة
const upload = multer({ storage: multer.memoryStorage() });

// Test route
router.get("/test", aiController.test);

// OCR route - استخدام multer
router.post("/ocr", upload.single('image'), aiController.runOCR);

// AI Assistant Chatbot
router.post("/chat", aiController.runAssistant);

// Run Python model
router.post("/run-model", aiController.runPythonModel);

module.exports = router;
