import json
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin SDK
cred = credentials.Certificate("/Users/harshalghate/Documents/SC2006/FinalProject/finalcode/exercise_app/lib/boundary/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# Firestore DB instance
db = firestore.client()

# Load JSON data
with open("/Users/harshalghate/Documents/SC2006/FinalProject/finalcode/exercise_app/lib/boundary/exercises_with_specific_calories.json", "r") as f:
    exercises = json.load(f)


# Counterclear
updated_count = 0

for exercise in exercises:
    name = exercise["name"].strip().lower()
    calories_per_rep = exercise.get("calories_per_rep")

    query = db.collection("exercises").where("name", "==", name).get()

    if query:
        for doc in query:
            doc.reference.update({"calories_per_rep": calories_per_rep})
            updated_count += 1
            print(f"✅ Updated MET for '{name}' → {calories_per_rep}")
    else:
        print(f"❌ No match found for: {name}")

print(f"🎯 Finished updating {updated_count} documents.")