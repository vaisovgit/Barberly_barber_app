// firestore-seed/seed.js
const admin = require('firebase-admin')
const serviceAccount = require('./serviceAccountKey.json')

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount),
})

const db = admin.firestore()

async function seed() {
	const barberId = '14'
	const date = new Date('2025-11-16T08:01:20+00:00')

	// 1. Barber
	await db
		.collection('barbers')
		.doc(barberId)
		.set({
			firebase_uid: '2lfmxVo9lscyNrtPxETNddlh2cQ2',
			name: 'Steel Huffman',
			email: 'john@example.com',
			phone: '+998909876546',
			imageUrl: 'https://i.pravatar.cc/150?img=3',
			bio: 'Professional barber with 10 years experience',
			role: 'barber',
			workingHours: {
				Monday: { startTime: '09:00', endTime: '18:00', isWorking: true },
				Tuesday: { startTime: '09:00', endTime: '18:00', isWorking: true },
				Wednesday: { startTime: '09:00', endTime: '18:00', isWorking: true },
				Thursday: { startTime: '09:00', endTime: '18:00', isWorking: true },
				Friday: { startTime: '09:00', endTime: '18:00', isWorking: true },
				Saturday: { startTime: '10:00', endTime: '16:00', isWorking: true },
				Sunday: { startTime: '09:00', endTime: '18:00', isWorking: false },
			},
			services: [
				{
					id: 'service3',

					name: 'Halla Alston',
					price: 653,
					durationMinutes: 51,
					description: 'Standard service',
				},
			],
			createdAt: date.toISOString(),
		})

	console.log('✅ Barber created')

	console.log('\n🎉 Firestore seeded successfully!')
	console.log('\n📊 Created:')
	console.log('  - 1 Barber (John Doe)')
	console.log('  - 4 Bookings (today, tomorrow, yesterday)')
	console.log('  - 1 Chat room with 4 messages')
	console.log('\n🔐 Login credentials:')
	console.log('  Email: john@example.com')
	console.log('  Password: (create manually in Firebase Auth)')
}

seed()
	.then(() => process.exit(0))
	.catch(error => {
		console.error('❌ Error seeding Firestore:', error)
		process.exit(1)
	})
