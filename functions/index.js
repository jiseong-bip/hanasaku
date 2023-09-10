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

const functions = require("firebase-functions");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");

initializeApp({
  serviceAccountId:
    "firebase-adminsdk-a09zo@hanasaku-abc.iam.gserviceaccount.com",
});


exports.createFirebaseToken = functions.https.onRequest(async (req, res) => {
  const uid = req.body.access_token;

  if (!uid) {
    res.status(400).send("Missing UID parameter.");
    return;
  }

  try {
    // Firebase custom token 생성
    const customToken = await getAuth().createCustomToken(uid);
    res.json({
      firebase_token: customToken,
    });
  } catch (error) {
    console.log("Error creating custom token:", error);
    res.status(500).send(error);
  }
});
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
