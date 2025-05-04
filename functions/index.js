const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.autoCheckInOut = functions.pubsub.schedule('every day 17:30')
  .timeZone('Asia/Vientiane')
  .onRun(async (context) => {
    const now = new Date();
    const todayDate = now.toLocaleDateString('th-TH', { day: '2-digit', month: 'long', year: 'numeric' });
    const employeeRef = admin.firestore().collection('Employee');
    const snapshot = await employeeRef.get();

    const promises = snapshot.docs.map(async (doc) => {
      const employeeId = doc.id;
      const recordRef = employeeRef.doc(employeeId).collection('Record').doc(todayDate);
      const recordSnapshot = await recordRef.get();
   console.log('Processing employee ID : ${employeeId}')
      if (!recordSnapshot.exists) {
        let status = 'ວັນພັກ';
        const isWeekend = now.getDay() === 6 || now.getDay() === 0;

        if (!isWeekend) {
          status = 'ຂາດວຽກ';
        }

        await recordRef.set({
          date: admin.firestore.Timestamp.now(),
          checkIn: "----/----",
          checkOut: "----/----",
          status: status
        });
      }
    });

    await Promise.all(promises); // รอให้ทุก Promise เสร็จสิ้น
    return null;
  });

// Daily notification at 08:00
exports.dailyNotification = functions.pubsub.schedule('every day 08:00')
  .timeZone('Asia/Vientiane')
  .onRun(async (context) => {
    const payload = {
      notification: {
        title: 'ອີກ 5 ນາທີ',
        body: 'ຢ່າລືມເຊັດອີນ!',
        sound: 'default',
      }
    };

    const tokensSnapshot = await admin.firestore().collection('Employee').get();
    const tokensList = tokensSnapshot.docs.map(doc => doc.data().token).filter(token => token); // กรองเฉพาะ token ที่ไม่ว่าง

    if (tokensList.length > 0) {
      await admin.messaging().sendToDevice(tokensList, payload);
    }

    return null;
  });

// Daily notification at 17:00
exports.dailyNotificationEvening = functions.pubsub.schedule('every day 17:00')
  .timeZone('Asia/Vientiane')
  .onRun(async (context) => {
    const payload = {
      notification: {
        title: 'ອີກ 5 ນາທີ',
        body: 'ຢ່າລືມເຊັດເອົາ!',
        sound: 'default',
      }
    };
    const tokensSnapshot = await admin.firestore().collection('Employee').get();
    const tokensList = tokensSnapshot.docs.map(doc => doc.data().token).filter(token => token); // กรองเฉพาะ token ที่ไม่ว่าง

    if (tokensList.length > 0) {
      await admin.messaging().sendToDevice(tokensList, payload);
    }

    return null;
  });
