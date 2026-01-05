import express from "express";
import dotenv from "dotenv";
import connectDB from "./config/db.js";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";

// ✅ Routes
import authRoutes from "./routes/auth.js";
import artifactRoutes from "./routes/artifacts.js";
// هنا يمكنك إضافة المزيد من الـ routes لاحقاً
// import heritageRoutes from "./routes/heritage.js";
// import categoryRoutes from "./routes/category.js";

dotenv.config();

// ✅ الاتصال بقاعدة البيانات
await connectDB();

const app = express();

// ✅ Middleware
app.use(cors());
app.use(express.json({ limit: "10mb" }));


// ✅ Routes
app.get("/", (req, res) => res.send("Yemeni Heritage Backend is up"));

app.use("/api/auth", authRoutes);
app.use("/api/artifacts", artifactRoutes);
// app.use("/api/heritage", heritageRoutes);
// app.use("/api/category", categoryRoutes);

// ✅ HTTP Server + Socket.io
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

io.on("connection", (socket) => {
  console.log("✅ User connected:", socket.id);

  // استقبال سؤال من العميل
  socket.on("ask_question", (data) => {
    console.log("📩 Question received:", data);

    // 🧠 رد تجريبي
    const answer = { reply: "📜 هذا رد تجريبي من السيرفر باستخدام Socket.io!" };
    socket.emit("answer", answer);
  });

  socket.on("disconnect", () => {
    console.log("❌ User disconnected:", socket.id);
  });
});

// ✅ تشغيل السيرفر
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
});
