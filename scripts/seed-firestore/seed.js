// Seeds the real dawafind Firestore project with demo data matching the
// ERD, so there's something to test against and demo before the app's own
// sign-up/inventory screens are wired up. Safe to re-run — every write
// uses a deterministic doc ID (set/merge), and Auth user creation falls
// back to the existing account if one already has that email.
//
// Setup (not run automatically — see the chat instructions for details):
//   1. Firebase Console -> Project settings -> Service accounts ->
//      "Generate new private key". Save the file as
//      serviceAccountKey.json in this same folder. Never commit it.
//   2. npm install
//   3. npm run seed

const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");

const serviceAccount = require("./serviceAccountKey.json");

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();
const auth = getAuth();

// Mirrors AuthRemoteDataSource.emailFromPhone in the Flutter app exactly,
// so signing in through the app with this phone + password matches.
function emailFromPhone(phone) {
  const digits = phone.replace(/[^0-9]/g, "");
  return `${digits}@dawafind.app`;
}

const pharmacies = [
  {
    id: "dawa-pharmacy",
    name: "Dawa Pharmacy",
    address: "2 Avenue de l'Allemagne, Bwiza, Bujumbura",
    latitude: -3.3822,
    longitude: 29.3644,
    phone: "+25722234501",
    openingHours: { monFri: "8:00-21:00", sat: "9:00-18:00", sun: "Closed" },
    averageRating: 4.7,
    ratingCount: 32,
    isVisible: true,
    status: "approved",
  },
  {
    id: "health-plus-pharmacy",
    name: "Health Plus Pharmacy",
    address: "KN 3 Rd, Rohero, Bujumbura",
    latitude: -3.39,
    longitude: 29.37,
    phone: "+25722234502",
    openingHours: { monFri: "8:00-20:00", sat: "9:00-17:00", sun: "Closed" },
    averageRating: 4.5,
    ratingCount: 18,
    isVisible: true,
    status: "approved",
  },
  {
    // Left pending on purpose, so there's something for the Admin
    // dashboard's approve/reject flow to actually show and act on.
    id: "city-pharma-kigali",
    name: "City Pharma Kigali",
    address: "KK 7 Ave, Kimihurura, Bujumbura",
    latitude: -3.395,
    longitude: 29.36,
    phone: "+25722234503",
    openingHours: { monFri: "8:00-20:00", sat: "9:00-18:00", sun: "Closed" },
    averageRating: 0,
    ratingCount: 0,
    isVisible: false,
    status: "pending",
  },
];

const medicines = [
  { id: "amoxicillin-500mg-capsules", name: "Amoxicillin", dosage: "500mg", form: "Capsules", brandName: "Amoxil" },
  { id: "paracetamol-500mg-tablets", name: "Paracetamol", dosage: "500mg", form: "Tablets", brandName: "" },
  { id: "artemether-20mg-tablets", name: "Artemether", dosage: "20mg", form: "Tablets", brandName: "" },
  { id: "metformin-850mg-tablets", name: "Metformin", dosage: "850mg", form: "Tablets", brandName: "" },
  { id: "omeprazole-20mg-capsules", name: "Omeprazole", dosage: "20mg", form: "Capsules", brandName: "" },
];

// One deliberately out-of-stock and one deliberately low-stock item, so
// both InventoryItemEntity.isOutOfStock/isLowStock have something to show.
const stock = [
  { pharmacyId: "dawa-pharmacy", medicineId: "amoxicillin-500mg-capsules", price: 2400, quantity: 24, packSize: "16 caps/pack" },
  { pharmacyId: "dawa-pharmacy", medicineId: "paracetamol-500mg-tablets", price: 800, quantity: 40, packSize: "20 tabs/pack" },
  { pharmacyId: "dawa-pharmacy", medicineId: "artemether-20mg-tablets", price: 4200, quantity: 15, packSize: "6 tabs/pack" },
  { pharmacyId: "dawa-pharmacy", medicineId: "metformin-850mg-tablets", price: 2200, quantity: 0, packSize: "30 tabs/pack" },
  { pharmacyId: "dawa-pharmacy", medicineId: "omeprazole-20mg-capsules", price: 1600, quantity: 18, packSize: "14 caps/pack" },
  { pharmacyId: "health-plus-pharmacy", medicineId: "amoxicillin-500mg-capsules", price: 2800, quantity: 10, packSize: "16 caps/pack" },
  { pharmacyId: "health-plus-pharmacy", medicineId: "paracetamol-500mg-tablets", price: 900, quantity: 3, packSize: "20 tabs/pack" },
];

// There's no self-registration path for pharmacist or admin accounts —
// they're the two roles this script has to create by hand.
const demoAccounts = [
  {
    kind: "pharmacist",
    fullName: "Pascal Uwizera",
    phone: "+25761234567",
    password: "Pharmacy123!",
    pharmacyId: "dawa-pharmacy",
  },
  {
    kind: "patient",
    fullName: "Marie Uwimana",
    phone: "+25762345678",
    password: "Patient123!",
  },
  {
    kind: "admin",
    fullName: "DawaFind Admin",
    phone: "+25700000001",
    password: "Admin12345!",
  },
];

async function getOrCreateAuthUser(email, password, displayName) {
  try {
    return await auth.getUserByEmail(email);
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
    return auth.createUser({ email, password, displayName });
  }
}

async function seedPharmacies() {
  for (const pharmacy of pharmacies) {
    const { id, ...data } = pharmacy;
    await db.collection("pharmacies").doc(id).set({ pharmacyId: id, ...data }, { merge: true });
    console.log(`pharmacies/${id} (${data.status})`);
  }
}

async function seedMedicines() {
  for (const medicine of medicines) {
    const { id, ...data } = medicine;
    const nameLower = data.name.trim().toLowerCase();
    await db
      .collection("medicines")
      .doc(id)
      .set({ medicineId: id, nameLower, ...data }, { merge: true });
    console.log(`medicines/${id}`);
  }
}

async function seedStock() {
  for (const item of stock) {
    const stockId = `${item.pharmacyId}_${item.medicineId}`;
    await db
      .collection("stock")
      .doc(stockId)
      .set(
        {
          stockId,
          pharmacyId: item.pharmacyId,
          medicineId: item.medicineId,
          price: item.price,
          quantity: item.quantity,
          packSize: item.packSize,
          lastUpdated: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    console.log(`stock/${stockId} (qty ${item.quantity})`);
  }
}

async function seedAccounts() {
  for (const account of demoAccounts) {
    const email = emailFromPhone(account.phone);
    const user = await getOrCreateAuthUser(email, account.password, account.fullName);

    if (account.kind === "pharmacist") {
      await db
        .collection("pharmacyStaff")
        .doc(user.uid)
        .set(
          {
            uid: user.uid,
            pharmacyId: account.pharmacyId,
            fullName: account.fullName,
            email,
            createdAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
    } else if (account.kind === "admin") {
      await db
        .collection("admins")
        .doc(user.uid)
        .set(
          { uid: user.uid, fullName: account.fullName, email, createdAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
    } else {
      await db
        .collection("users")
        .doc(user.uid)
        .set(
          { uid: user.uid, fullName: account.fullName, email, createdAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
    }
    console.log(`${account.kind} account ready — phone ${account.phone} / password ${account.password} (uid ${user.uid})`);
  }
}

async function main() {
  await seedPharmacies();
  await seedMedicines();
  await seedStock();
  await seedAccounts();
  console.log("\nDone. Sign in through the app using the phone numbers/passwords logged above.");
  process.exit(0);
}

main().catch((error) => {
  console.error("Seeding failed:", error);
  process.exit(1);
});
