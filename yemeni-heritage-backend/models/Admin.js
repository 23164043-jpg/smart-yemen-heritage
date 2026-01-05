import mongoose from "mongoose";

const adminSchema = new mongoose.Schema(
  {
    adminId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User", // كل أدمن هو مستخدم أساساً
      required: true,
    },
    department: {
      type: String, // مثلاً: إدارة محتوى، إدارة مستخدمين...
      required: true,
    },
    permissionsLevel: {
      type: Number,
      default: 1, // 1: عادي | 2: مدير قسم | 3: Super Admin
    },
  },
  { timestamps: true }
);

export default mongoose.model("Admin", adminSchema);
