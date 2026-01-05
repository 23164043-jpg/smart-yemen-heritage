import mongoose from "mongoose";

const artifactSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  location: { type: String }, // اسم المدينة أو الإحداثيات
  images: [{ type: String }], // روابط الصور (Cloud storage URLs)
  model3D: { type: String }, // رابط ملف 3D (glTF/GLB) مخزن في سحابة
  audio: [{ type: String }], // روابط ملفات صوتية
  tags: [{ type: String }],
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model("Artifact", artifactSchema);
