/**
 * @jest-environment node
 */
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { readFileSync } = require('fs');
const {
  doc,
  getDoc,
  setDoc,
  updateDoc,
} = require('firebase/firestore');

let testEnv;

const PHARMACY = {
  name: 'Kaze Pharmacy',
  address: '2 Avenue de l Allemagne, Bujumbura',
  phone: '+257788123456',
  averageRating: 4.5,
  ratingCount: 2,
  isVisible: true,
};

const STOCK = {
  pharmacyId: 'ph_kaze',
  medicineId: 'med_001',
  price: 3500,
  quantity: 24,
  packSize: '16 caps/pack',
};

beforeAll(async () => {
  try{
    testEnv = await initializeTestEnvironment({
      projectId: 'dawafind-rules-test',
      firestore: {
        rules: readFileSync('firestore.rules', 'utf8'),
        host: '127.0.0.1',
        port: 8080,
      },
    });
  } catch (e) {
    console.error('Setup Failed', e);
    throw e; // Rethrow the error to ensure the test suite fails
  }
}, 30000);

afterAll(async () => {
  if (testEnv) await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();

  // Seed with rules bypassed, the same way the Data tab would.
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'pharmacies/ph_kaze'), PHARMACY);
    await setDoc(doc(db, 'pharmacyStaff/staff_pascal'), { pharmacyId: 'ph_kaze' });
    await setDoc(doc(db, 'pharmacyStaff/staff_rival'), { pharmacyId: 'ph_other' });
    await setDoc(doc(db, 'stock/stk_001'), STOCK);
    await setDoc(doc(db, 'users/patient_1'), { fullName: 'Test patient' });
  });
});

// Convenience accessors
const anon = () => testEnv.unauthenticatedContext().firestore();
const as = (uid) => testEnv.authenticatedContext(uid).firestore();

describe('public read access', () => {
  test('signed-out user can read stock', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'stock/stk_001')));
  });

  test('signed-out user can read a pharmacy', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'pharmacies/ph_kaze')));
  });
});

describe('private user data', () => {
  test('signed-out user cannot read a user document', async () => {
    await assertFails(getDoc(doc(anon(), 'users/patient_1')));
  });

  test('a user cannot read another user document', async () => {
    await assertFails(getDoc(doc(as('patient_2'), 'users/patient_1')));
  });

  test('a user can read their own document', async () => {
    await assertSucceeds(getDoc(doc(as('patient_1'), 'users/patient_1')));
  });

  test('a user can write their own saved pharmacies subcollection', async () => {
    await assertSucceeds(
      setDoc(doc(as('patient_1'), 'users/patient_1/savedPharmacies/sp_1'), {
        pharmacyId: 'ph_kaze',
      })
    );
  });

  test('a user cannot write another user saved pharmacies', async () => {
    await assertFails(
      setDoc(doc(as('patient_2'), 'users/patient_1/savedPharmacies/sp_1'), {
        pharmacyId: 'ph_kaze',
      })
    );
  });
});

describe('stock ownership', () => {
  test('staff can update their own pharmacy stock', async () => {
    await assertSucceeds(
      updateDoc(doc(as('staff_pascal'), 'stock/stk_001'), { quantity: 10 })
    );
  });

  test('staff of another pharmacy cannot update this stock', async () => {
    await assertFails(
      updateDoc(doc(as('staff_rival'), 'stock/stk_001'), { quantity: 0 })
    );
  });

  test('a patient cannot update stock', async () => {
    await assertFails(
      updateDoc(doc(as('patient_1'), 'stock/stk_001'), { quantity: 0 })
    );
  });

  test('stock cannot be reassigned to another pharmacy', async () => {
    await assertFails(
      updateDoc(doc(as('staff_pascal'), 'stock/stk_001'), { pharmacyId: 'ph_other' })
    );
  });

  test('negative quantity is rejected', async () => {
    await assertFails(
      updateDoc(doc(as('staff_pascal'), 'stock/stk_001'), { quantity: -5 })
    );
  });
});

describe('rating aggregates on the pharmacy document', () => {
  test('a patient may update only the two aggregate fields', async () => {
    await assertSucceeds(
      updateDoc(doc(as('patient_1'), 'pharmacies/ph_kaze'), {
        averageRating: 4.7,
        ratingCount: 3,
      })
    );
  });

  test('a patient may not change the pharmacy name', async () => {
    await assertFails(
      updateDoc(doc(as('patient_1'), 'pharmacies/ph_kaze'), {
        name: 'Hacked Pharmacy',
      })
    );
  });

  test('a patient may not change the name alongside the aggregates', async () => {
    await assertFails(
      updateDoc(doc(as('patient_1'), 'pharmacies/ph_kaze'), {
        averageRating: 4.7,
        ratingCount: 3,
        name: 'Hacked Pharmacy',
      })
    );
  });

  test('an out of range average is rejected', async () => {
    await assertFails(
      updateDoc(doc(as('patient_1'), 'pharmacies/ph_kaze'), {
        averageRating: 9,
        ratingCount: 3,
      })
    );
  });

  test('staff may edit their own pharmacy details', async () => {
    await assertSucceeds(
      updateDoc(doc(as('staff_pascal'), 'pharmacies/ph_kaze'), {
        phone: '+257788999888',
      })
    );
  });
});

describe('ratings subcollection', () => {
  test('a user can create a rating at their own uid', async () => {
    await assertSucceeds(
      setDoc(doc(as('patient_1'), 'pharmacies/ph_kaze/ratings/patient_1'), {
        score: 4,
        createdAt: new Date(),
      })
    );
  });

  test('a user cannot create a rating under another uid', async () => {
    await assertFails(
      setDoc(doc(as('patient_2'), 'pharmacies/ph_kaze/ratings/patient_1'), {
        score: 4,
        createdAt: new Date(),
      })
    );
  });

  test('a score above five is rejected', async () => {
    await assertFails(
      setDoc(doc(as('patient_1'), 'pharmacies/ph_kaze/ratings/patient_1'), {
        score: 7,
        createdAt: new Date(),
      })
    );
  });

  test('anyone can read ratings', async () => {
    await assertSucceeds(
      getDoc(doc(anon(), 'pharmacies/ph_kaze/ratings/patient_1'))
    );
  });
});

describe('pharmacy staff records', () => {
  test('staff can read their own record', async () => {
    await assertSucceeds(getDoc(doc(as('staff_pascal'), 'pharmacyStaff/staff_pascal')));
  });

  test('staff cannot read another staff record', async () => {
    await assertFails(getDoc(doc(as('staff_rival'), 'pharmacyStaff/staff_pascal')));
  });

  test('a patient cannot read staff records', async () => {
    await assertFails(getDoc(doc(as('patient_1'), 'pharmacyStaff/staff_pascal')));
  });

  test('staff cannot reassign themselves to another pharmacy', async () => {
    await assertFails(
      updateDoc(doc(as('staff_pascal'), 'pharmacyStaff/staff_pascal'), {
        pharmacyId: 'ph_other',
      })
    );
  });
});

describe('medicines catalogue', () => {
  test('anyone can read the catalogue', async () => {
    await assertSucceeds(getDoc(doc(anon(), 'medicines/med_001')));
  });

  test('staff can create a catalogue entry', async () => {
    await assertSucceeds(
      setDoc(doc(as('staff_pascal'), 'medicines/med_002'), {
        name: 'Paracetamol 500mg',
        nameLower: 'paracetamol 500mg',
        dosage: '500mg',
        form: 'Tablets',
      })
    );
  });

  test('a patient cannot create a catalogue entry', async () => {
    await assertFails(
      setDoc(doc(as('patient_1'), 'medicines/med_003'), {
        name: 'Ibuprofen 400mg',
        nameLower: 'ibuprofen 400mg',
      })
    );
  });

  test('a mismatched nameLower is rejected', async () => {
    await assertFails(
      setDoc(doc(as('staff_pascal'), 'medicines/med_004'), {
        name: 'Metformin 850mg',
        nameLower: 'WRONG',
      })
    );
  });
});
