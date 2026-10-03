import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
import resourceRoutes from "./routes/resources.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// ==========================================
// STRATEGIC FIX 2: DYNAMIC CORS WHITELISTING
// ==========================================
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(",")
  : ["https://dev-resource-tracker-api.netlify.app", "http://localhost:5173"];

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        console.warn(
          `⚠️ Blocked by CORS Architecture: Request from origin ${origin} rejected.`,
        );
        callback(new Error("Not allowed by CORS"));
      }
    },
  }),
);

app.use(express.json());

// Test root route - MUST come before other routes
app.get("/", (req, res) => {
  res.json({
    message: "🚀 Developer Resource Tracker API is running!",
    version: "1.0.0",
    endpoints: {
      resources: "/api/resources",
      health: "/health",
    },
  });
});

// Health check route
app.get("/health", (req, res) => {
  res.json({
    status: "OK",
    timestamp: new Date().toISOString(),
    database:
      mongoose.connection.readyState === 1 ? "Connected" : "Disconnected",
  });
});

// API routes
app.use("/api/resources", resourceRoutes);

// Handle 404 errors
app.use("*", (req, res) => {
  res.status(404).json({
    error: "Route not found",
    availableRoutes: ["/", "/health", "/api/resources"],
  });
});

// ==========================================
// STRATEGIC FIX 1: THE DATABASE FAIL-FAST RULE
// ==========================================
const connectDB = async () => {
  const mongoUri = process.env.MONGO_URI;

  // Enforce the infrastructure boundary
  if (!mongoUri) {
    console.error("======================================================");
    console.error("❌ FATAL ARCHITECTURE ERROR: MONGO_URI is not defined!");
    console.error("The system cannot initialize without a target data tier.");
    console.error("======================================================");
    process.exit(1); // Kill the container/process instantly
  }

  try {
    await mongoose.connect(mongoUri);
    console.log("✅ MongoDB connected successfully");
  } catch (error) {
    console.error("❌ MongoDB execution error:", error.message);
    process.exit(1);
  }
};

connectDB();

// Start server
app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`📍 Local: http://localhost:${PORT}`);
});
