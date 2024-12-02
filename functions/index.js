const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

// Initialisation de Firebase Admin SDK
admin.initializeApp();

// Fonction planifiée pour s'exécuter toutes les 10 minutes


exports.updateUserIsActive2PM = functions
    .region("europe-west2")
    .pubsub
    .schedule("00 14 * * *")
    .onRun(async (context) => {
      try {
        const usersRef = admin.firestore().collection("users");
        const snapshot = await usersRef.get();

        if (snapshot.empty) {
          console.log("Aucun utilisateur trouvé.");
          return null;
        }

        const batch = admin.firestore().batch();
        snapshot.forEach((doc) => {
          batch.update(doc.ref, {isActive: false});
        });

        await batch.commit();

        console.log("Mise à jour réussie pour tous les utilisateurs.");
        return null;
      } catch (error) {
        console.error("Erreur lors de la mise à jour :", error);
        throw new Error("Erreur lors de la mise à jour des utilisateurs.");
      }
    });

exports.sendScheduledDataMessageIsTurnTonight6PM = functions
    .region("europe-west2")
    .pubsub
    .schedule("00 14 * * *")
    .onRun(async (context) => {
      const dataMessage = {
        data: {
          event: "daily_ask_turn",
          timestamp: new Date().toISOString(),
          message: "Ca turn ce soir ?",
        },
        topic: "daily_ask_turn",
      };

      try {
        await admin.messaging().send(dataMessage);
        console.log("Message de données envoyé avec succès.");
      } catch (error) {
        console.error("Erreur lors de l’envoi du message de données :", error);
      }

      return null;
    });

exports.sendScheduledMessage3AMIfTurnAlready = functions
    .region("europe-west2")
    .pubsub
    .schedule("00 3 * * *")
    .onRun(async (context) => {
      const activeUsersSnapshot = await admin
          .firestore()
          .collection("users")
          .where("isActive", "==", true)
          .get();

      for (const doc of activeUsersSnapshot.docs) {
        const userData = doc.data();
        if (userData.tokenFCM) {
          const personalizedMessage = {
            data: {
              event: "daily_ask_turn_already",
              timestamp: new Date().toISOString(),
            },
            token: userData.tokenFCM,
          };

          try {
            const response = await admin.messaging().send(personalizedMessage);
            console.log(`Message envoyé à ${userData.username} avec succès :`,
                response);
          } catch (error) {
            console.error(`Erreur pour ${userData.username} :`, error);
          }
        }
      }
    });

exports.onNotificationCreated = functions
    .region("europe-west2")
    .firestore
    .document("notifications/{docId}/userNotifications/{subDocId}")
    .onCreate(async (snap, context) => {
      try {
        const newNotification = snap.data();
        const docId = context.params.docId;
        const notificationDoc = await admin
            .firestore()
            .collection("notifications")
            .doc(docId)
            .get();
        const userId = notificationDoc.data().userId;
        const userData = await admin
            .firestore()
            .collection("users")
            .doc(userId)
            .get();
        const tokenFCM = userData.data().tokenFCM;
        // Determine notification content based on type
        let title = "";
        let body = "";
        const content = newNotification.content;
        switch (newNotification.type) {
          case "message": {
            title = `Messages sur ${content.conversationName || "CFQ ?"}`;
            const words = content.messageContent.split(" ");
            const messagePreview = words.length > 3 ?
                words.slice(0, 3).join(" ") + "..." :
                content.messageContent;
            body = `${content.senderUsername}: ${messagePreview}`;
            break;
          }
          case "teamRequest":
            title = "Nouvelle Team";
            body = `T'es invité à rejoindre la team ${content.teamName}`;
            break;
          case "friendRequest":
            title = "Demande d'ajout";
            body = `${content.requesterUsername} veut t'ajouter`;
            break;
          case "eventInvitation":
            if (content.isTurn) {
              title = content.eventName;
              body = `${content.organizerUsername} t'invite à son turn`;
            } else {
              title = content.eventName || "CFQ ?";
              body = `${content.organizerUsername} a posté un CFQ`;
            }
            break;
          case "attending":
            title = content.turnName;
            body = `${content.attendingUsername} vient à ${content.turnName}`;
            break;
          case "followUp":
            title = content.cfqName || "CFQ ?";
            body = `${content.followerUsername} suit ${content.cfqName || "CFQ"}`;
            break;
          case "acceptedTeamRequest":
            title = content.teamName;
            body = `${content.accepterUsername} a rejoint la team`;
            break;
          case "acceptedFriendRequest":
            title = "Ami";
            body = `${content.accepterUsername} t'a ajouté a ses amis`;
            break;
        }
        const message = {
          notification: {
            title: title,
            body: body,
          },
          token: tokenFCM,
        };
        console.log("message", message);
        const response = await admin.messaging().send(message);
        return {success: true, messageId: response};
      } catch (error) {
        console.error("Erreur :", error);
        return Promise.reject(error);
      }
    });
