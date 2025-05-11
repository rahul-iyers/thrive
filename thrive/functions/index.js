const { onSchedule } = require("firebase-functions/v2/scheduler");
const { setGlobalOptions } = require("firebase-functions/v2/options");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { VertexAI } = require("@google-cloud/vertexai");

admin.initializeApp();
setGlobalOptions({ region: "us-central1" });

const vertexAI = new VertexAI({
  project: "thrive-c29b6",
  location: "us-central1",
});

const model = vertexAI.getGenerativeModel({
  model: "gemini-2.0-flash-001",
});

// 🔁 Shared logic
async function generateWeeklyInsightsForAllUsers() {
  const usersSnapshot = await admin.firestore().collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;
    console.log(`🔍 Generating insights for user: ${userId}`);

    const habitsSnapshot = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("habits")
      .orderBy("timestamp", "desc")
      .limit(7)
      .get();

    const recentData = habitsSnapshot.docs.map((doc) => doc.data());
    console.log(`📦 Retrieved ${recentData.length} habit entries for ${userId}`);
    console.log(`📝 Recent data preview: ${JSON.stringify(recentData, null, 2)}`);

    if (recentData.length === 0) {
      console.warn(`⚠️ No habits found for ${userId}. Check if 'timestamp' is set and correctly formatted.`);
      continue;
    }

    const prompt = `
You are an AI health and performance coach.

Review the user’s habit data from the past 7 days and generate 2–4 meaningful, growth-focused insights. Focus on patterns that relate to wellness, consistency, or positive/negative habits. Be brief and impactful. Do not mention specific notes from days but rather emphasize how the meaning of the note correlates to associated behaviors.

Data:
${JSON.stringify(recentData, null, 2)}

Respond using clear, concise bullet points. Avoid repeating the data. Highlight cause-effect relationships or opportunities for improvement (e.g., • Sleep decreased on workout days. Consider adjusting intensity.).

    `.trim();

    try {
      const result = await model.generateContent({
        contents: [{ role: "user", parts: [{ text: prompt }] }],
      });

      const text = result.response.candidates[0].content.parts[0].text;

      await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .collection("insights")
        .doc("weekly")
        .set({
          generatedText: text,
          timestamp: admin.firestore.Timestamp.now(),
          type: "week",
        });

      console.log(`✅ Weekly insights saved for ${userId}`);
    } catch (err) {
      console.error(`❌ Error generating insights for ${userId}:`, err);
    }
  }
}

// ⏰ Scheduled every Sunday
exports.generateWeeklyInsights = onSchedule(
  {
    schedule: "every sunday 03:00",
    timeZone: "America/New_York",
  },
  async (event) => {
    await generateWeeklyInsightsForAllUsers();
  }
);

// 🧪 Manual HTTP test trigger
exports.runInsightsNow = functions.https.onRequest(async (req, res) => {
  try {
    await generateWeeklyInsightsForAllUsers();
    res.send("✅ Weekly insights generated manually.");
  } catch (err) {
    console.error("❌ Manual trigger failed:", err);
    res.status(500).send("Failed to run insights.");
  }
});
