import json
import firebase_admin
from firebase_admin import credentials, firestore

# تحميل مفاتيح Firebase
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# الاتصال بقاعدة Firestore
db = firestore.client()

# قراءة ملف JSON
with open("firestore_seed.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# دالة لإضافة البيانات
def import_collection(collection_name, documents):
    print(f"🚀 Importing {collection_name} ...")
    for doc in documents:
        doc_id = doc.pop("id", None)
        if doc_id:
            db.collection(collection_name).document(doc_id).set(doc)
        else:
            db.collection(collection_name).add(doc)
    print(f"✅ Done: {collection_name}")

# استيراد جميع المجموعات
for collection, docs in data.items():
    import_collection(collection, docs)

print("\n🎉 تم استيراد جميع البيانات بنجاح إلى Firestore!")
