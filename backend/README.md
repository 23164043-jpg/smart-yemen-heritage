# Smart Yemen Encyclopedia - Backend

## التشغيل محلياً
1. انسخ المجلد `backend` إلى جهازك (أو فك الضغط عن الملف المرفق).
2. انسخ `.env.example` إلى `.env` وعدّل القيم (MONGO_URI, JWT_SECRET).
3. ثبّت الحزم:
   ```bash
   npm install
   ```
4. شغّل المشروع في وضع التطوير:
   ```bash
   npm run start
   ```
5. افتح Postman واستخدم Base URL:
   ```
   http://localhost:5000/api
   ```

## Endpoints أساسية لاختبار سريع
- POST /api/users/register
- POST /api/users/login
- GET  /api/users/me  (حماية: يتطلب Authorization Bearer token)
- CRUD لكل من: /api/content, /api/services, /api/arview, /api/banner, /api/feedback, /api/contenttypes, /api/notification

## ملاحظات
- الملفات مُهيّئة للعمل محليًا مع MongoDB على localhost. يمكنك تغيير MONGO_URI في `.env`.
- لتحميل ملفات (3D models, images) ينصح بالربط مع Cloudinary أو S3 لاحقًا.
