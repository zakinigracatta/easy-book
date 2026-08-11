const API_KEY = 'AIzaSyApbJ5knQAHW9wCBMeKq8Z4CrfQYWgsMCM';
const PROJECT_ID = 'easy-book-zaki';
const AUTH_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`;
const SIGNIN_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`;
const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

const ownerEmail = 'dev.owner.b1@executivebarber.com';
const ownerPassword = 'DevOwnerPassword123!';

async function run() {
  console.log('--- Starting Firestore Seeding ---');
  let idToken = '';
  let localId = '';

  // 1. Try login as owner
  let res = await fetch(SIGNIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: ownerEmail, password: ownerPassword, returnSecureToken: true }),
  });
  let data = await res.json();

  if (data.idToken) {
    idToken = data.idToken;
    localId = data.localId;
    console.log(`Signed in owner user: ${localId}`);
  } else {
    // Register owner
    res = await fetch(AUTH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: ownerEmail, password: ownerPassword, returnSecureToken: true }),
    });
    data = await res.json();
    if (!data.idToken) {
      console.error('Failed to authenticate owner:', data);
      process.exit(1);
    }
    idToken = data.idToken;
    localId = data.localId;
    console.log(`Registered new owner user: ${localId}`);
  }

  // 2. Ensure users/{localId} document has role = 'owner'
  const userDocUrl = `${FIRESTORE_BASE}/users/${localId}`;
  await fetch(userDocUrl, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${idToken}`
    },
    body: JSON.stringify({
      fields: {
        id: { stringValue: localId },
        email: { stringValue: ownerEmail },
        full_name: { stringValue: 'Executive Barber Owner' },
        phone: { stringValue: '+971501234567' },
        role: { stringValue: 'owner' },
        wallet_balance: { doubleValue: 0.0 },
        favorite_business_ids: { arrayValue: { values: [] } },
        created_at: { timestampValue: new Date().toISOString() },
        updated_at: { timestampValue: new Date().toISOString() }
      }
    })
  });
  console.log('Owner user profile set in Firestore.');

  // 3. Write Business b1
  const bizUrl = `${FIRESTORE_BASE}/businesses/b1`;
  await fetch(bizUrl, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${idToken}`
    },
    body: JSON.stringify({
      fields: {
        id: { stringValue: 'b1' },
        name: { stringValue: 'Executive Barber Lounge' },
        category: { stringValue: 'Barber' },
        address: { stringValue: 'Downtown Dubai, UAE' },
        description: { stringValue: 'Premium men\'s grooming and luxury barber services.' },
        rating: { doubleValue: 4.9 },
        review_count: { integerValue: '328' },
        image_url: { stringValue: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80' },
        is_verified: { booleanValue: true },
        owner_id: { stringValue: localId },
        latitude: { doubleValue: 25.1972 },
        longitude: { doubleValue: 55.2744 }
      }
    })
  });
  console.log('Business b1 set.');

  // 4. Write Services (s1, s2, s3)
  const services = [
    {
      id: 's1',
      name: 'Classic Haircut',
      price: 80.0,
      duration: '30 mins',
      durationMinutes: 30,
      description: 'Precision haircut, hair wash, hot towel wrap and luxury styling.'
    },
    {
      id: 's2',
      name: 'Haircut & Beard',
      price: 120.0,
      duration: '45 mins',
      durationMinutes: 45,
      description: 'Signature haircut combined with bespoke beard sculpt and skin treatment.'
    },
    {
      id: 's3',
      name: 'Premium Grooming',
      price: 180.0,
      duration: '60 mins',
      durationMinutes: 60,
      description: 'Full haircut, beard sculpt, deep facial treatment and head massage.'
    }
  ];

  for (const s of services) {
    const sUrl = `${FIRESTORE_BASE}/businesses/b1/services/${s.id}`;
    await fetch(sUrl, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      body: JSON.stringify({
        fields: {
          id: { stringValue: s.id },
          business_id: { stringValue: 'b1' },
          salon_id: { stringValue: 'b1' },
          name: { stringValue: s.name },
          price: { doubleValue: s.price },
          duration: { stringValue: s.duration },
          duration_minutes: { integerValue: s.durationMinutes.toString() },
          description: { stringValue: s.description },
          active: { booleanValue: true }
        }
      })
    });
    console.log(`Service ${s.id} set.`);
  }

  // 5. Write Staff (st1, st2, st3)
  const staffMembers = [
    {
      id: 'st1',
      name: 'Marcus Vance',
      role_title: 'Master Barber & Stylist',
      avatar_url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      rating: 4.9
    },
    {
      id: 'st2',
      name: 'David Kim',
      role_title: 'Senior Barber',
      avatar_url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80',
      rating: 4.8
    },
    {
      id: 'st3',
      name: 'Adam Kareem',
      role_title: 'Barber',
      avatar_url: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
      rating: 4.7
    }
  ];

  for (const st of staffMembers) {
    const stUrl = `${FIRESTORE_BASE}/businesses/b1/staff/${st.id}`;
    await fetch(stUrl, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      body: JSON.stringify({
        fields: {
          id: { stringValue: st.id },
          business_id: { stringValue: 'b1' },
          name: { stringValue: st.name },
          role_title: { stringValue: st.role_title },
          avatar_url: { stringValue: st.avatar_url },
          rating: { doubleValue: st.rating },
          active: { booleanValue: true }
        }
      })
    });
    console.log(`Staff ${st.id} set.`);
  }

  // 6. Verify Read Access (Unauthenticated)
  const readRes = await fetch(`${FIRESTORE_BASE}/businesses/b1`);
  const readData = await readRes.json();
  console.log('--- Verification Read for businesses/b1 ---');
  console.log('Document ID:', readData.name ? readData.name.split('/').pop() : 'NOT FOUND');
  console.log('Business Name:', readData.fields?.name?.stringValue);
  console.log('--- Firestore Seeding Completed Successfully! ---');
}

run().catch(err => console.error('Seeding error:', err));
