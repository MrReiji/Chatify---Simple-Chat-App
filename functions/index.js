const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// Trigger for new messages added to a specific group chat in Firestore
exports.sendGroupChatNotification = onDocumentCreated("groups/{groupId}/messages/{messageId}", async (event) => {
    const messageData = event.data.data();
    const groupId = event.params.groupId;

    // Fetch sender details, including the name and avatar URL
    let senderName = messageData.senderName;
    let senderAvatar = messageData.senderImageUrl;
    if (!senderName || !senderAvatar) {
        const userDoc = await admin.firestore().collection('users').doc(messageData.senderId).get();
        if (userDoc.exists) {
            const userData = userDoc.data();
            senderName = senderName || userData.username || 'Unknown';
            senderAvatar = senderAvatar || userData.image_url || ''; // Default URL if not available
        }
    }

    // Prepare notification payload with custom image (avatar)
    const payload = {
        data: {
            title: senderName,
            body: messageData.text,
            image: senderAvatar || '', // URL awatara
            groupId: groupId,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        topic: `group_${groupId}`, // Unikalny temat dla każdej grupy
    };

    // Send the notification to the specific topic
    await admin.messaging().send(payload);
    return;
});
