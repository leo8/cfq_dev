/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

// Initialisation de Firebase Admin SDK
admin.initializeApp();

// Fonction planifiée pour s'exécuter toutes les 10 minutes
exports.updateUserIsActive = functions.pubsub
    .schedule("*/5 * * * *")
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
          const userData = doc.data();
          const currentIsActive = userData.isActive || false;
          batch.update(doc.ref, {isActive: !currentIsActive});
        });

        await batch.commit();

        console.log("Mise à jour réussie pour tous les utilisateurs.");
        return null;
      } catch (error) {
        console.error("Erreur lors de la mise à jour :", error);
        throw new Error("Erreur lors de la mise à jour des utilisateurs.");
      }
    });


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
