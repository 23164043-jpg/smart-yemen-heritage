import json
import firebase_admin
from firebase_admin import credentials, firestore

# ✅ تحميل مفاتيح Firebase
if not firebase_admin._apps:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

# ✅ إنشاء اتصال بقاعدة Firestore
db = firestore.client()

# ✅ المجموعات التي تريد تصديرها
collections_to_export = [
    "roles",
    "users",
    "content_types",
    "content",
    "content_details",
    "knowledge_base",
    "ai_interactions",
    "ar_assets",
    "feedback"
]

backup_data = {}

print("🚀 بدء عملية النسخ الاحتياطي من Firestore ...")

for collection_name in collections_to_export:
    print(f"📂 Exporting collection: {collection_name}")
    docs = db.collection(collection_name).stream()
    backup_data[collection_name] = []
    for doc in docs:
        doc_data = doc.to_dict()
        doc_data["id"] = doc.id  # حفظ المعرف (Document ID)
        backup_data[collection_name].append(doc_data)

# ✅ حفظ النسخة إلى ملف JSON
with open("firestore_backup.json", "w", encoding="utf-8") as f:
    json.dump(backup_data, f, ensure_ascii=False, indent=4)

print("\n🎉 تم إنشاء النسخة الاحتياطية بنجاح: firestore_backup.json")
