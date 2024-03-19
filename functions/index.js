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

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Import the necessary Firebase modules
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Import other necessary libraries
const stripe = require("stripe")(functions.config().stripe.secret);
const express = require("express");
const cors = require("cors");

// Initialize an Express app
const app = express();

// Automatically allow cross-origin requests
app.use(cors({origin: true}));

app.post("/create-payment-intent", async (req, res) => {
  const {amount} = req.body;
  // Check if amount is a number and is an integer
  if (typeof amount !== "number" || !Number.isInteger(amount)) {
    return res.status(400).send("Invalid amount. Amount must be an integer.");
  }
  try {
    // Create or use an existing Customer ID if this is a returning customer.
    // Adjust as needed for existing customers
    const customer = await stripe.customers.create();
    const ephemeralKey = await stripe.ephemeralKeys.create(
        {customer: customer.id},
        {apiVersion: "2023-10-16"},
    );
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: "usd",
      customer: customer.id,
      automatic_payment_methods: {enabled: true},
    });

    res.json({
      paymentIntent: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer.id,
    });
  } catch (error) {
    console.error("Error creating payment intent:", error);
    res.status(500).send("Internal Server Error");
  }
});

exports.api = functions.https.onRequest(app);
