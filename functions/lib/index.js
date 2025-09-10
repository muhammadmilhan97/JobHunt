"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.digestWeekly = exports.onJobWrite = exports.onApplicationUpdate = exports.signCloudinaryUpload = exports.setUserRole = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
const cloudinary_1 = require("cloudinary");
const mailer_1 = require("./utils/mailer");
const fcm_1 = require("./utils/fcm");
const templates_1 = require("./utils/templates");
// Initialize Firebase Admin
admin.initializeApp();
// Configure Cloudinary
const config = functions.config();
if (config.cloudinary) {
    cloudinary_1.v2.config({
        cloud_name: config.cloudinary.cloud_name,
        api_key: config.cloudinary.api_key,
        api_secret: config.cloudinary.api_secret,
    });
}
/**
 * 1. Set User Role (Callable Function)
 * Auth required; for dev allow any signed-in user to set own role
 */
exports.setUserRole = functions.https.onCall(async (data, context) => {
    // Check authentication
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "The function must be called while authenticated.");
    }
    // Validate input
    const { role } = data;
    const validRoles = ["job_seeker", "employer", "admin"];
    if (!role || typeof role !== "string" || !validRoles.includes(role)) {
        throw new functions.https.HttpsError("invalid-argument", `Role must be one of: ${validRoles.join(", ")}`);
    }
    const userId = context.auth.uid;
    try {
        // Set custom claims
        await admin.auth().setCustomUserClaims(userId, { role });
        // Update user document in Firestore
        await admin.firestore()
            .collection("users")
            .doc(userId)
            .set({
            role,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        functions.logger.info(`User role updated`, { userId, role });
        return { success: true, role };
    }
    catch (error) {
        functions.logger.error("Failed to set user role", { error, userId, role });
        throw new functions.https.HttpsError("internal", "Failed to update user role");
    }
});
/**
 * 2. Sign Cloudinary Upload (HTTPS Function)
 * Auth required; creates signed upload parameters
 */
exports.signCloudinaryUpload = functions.https.onRequest(async (req, res) => {
    // Enable CORS
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.set("Access-Control-Allow-Headers", "Authorization, Content-Type");
    if (req.method === "OPTIONS") {
        res.status(200).send();
        return;
    }
    if (req.method !== "POST") {
        res.status(405).json({ error: "Method not allowed" });
        return;
    }
    // Check authentication
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        res.status(401).json({ error: "Unauthorized" });
        return;
    }
    try {
        const idToken = authHeader.split("Bearer ")[1];
        await admin.auth().verifyIdToken(idToken);
    }
    catch (error) {
        functions.logger.error("Invalid ID token", { error });
        res.status(401).json({ error: "Invalid authentication token" });
        return;
    }
    // Validate input
    const { folder, preset, public_id } = req.body;
    if (!folder || !preset) {
        res.status(400).json({
            error: "Missing required fields: folder, preset"
        });
        return;
    }
    // Validate folder format (security)
    const allowedFolders = ["jobhunt-dev/cv", "jobhunt-dev/logos", "jobhunt-dev/profiles"];
    if (!allowedFolders.includes(folder)) {
        res.status(400).json({
            error: `Invalid folder. Allowed: ${allowedFolders.join(", ")}`
        });
        return;
    }
    try {
        const timestamp = Math.round(new Date().getTime() / 1000);
        // Prepare upload parameters
        const uploadParams = {
            timestamp,
            folder,
            upload_preset: preset,
        };
        if (public_id) {
            uploadParams.public_id = public_id;
        }
        // Generate signature
        const signature = cloudinary_1.v2.utils.api_sign_request(uploadParams, config.cloudinary.api_secret);
        const response = {
            signature,
            timestamp,
            api_key: config.cloudinary.api_key,
            cloud_name: config.cloudinary.cloud_name,
            upload_url: `https://api.cloudinary.com/v1_1/${config.cloudinary.cloud_name}/upload`,
            upload_params: uploadParams,
        };
        functions.logger.info("Cloudinary upload signature generated", { folder, preset });
        res.json(response);
    }
    catch (error) {
        functions.logger.error("Failed to generate Cloudinary signature", { error });
        res.status(500).json({ error: "Failed to generate upload signature" });
    }
});
/**
 * 3. On Application Update (Firestore Trigger)
 * Sends notifications when application status changes
 */
exports.onApplicationUpdate = functions.firestore
    .document("applications/{applicationId}")
    .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const applicationId = context.params.applicationId;
    // Check if status changed
    if (before.status === after.status) {
        return;
    }
    const newStatus = after.status;
    const jobSeekerId = after.jobSeekerId;
    const jobId = after.jobId;
    try {
        // Get job details
        const jobDoc = await admin.firestore()
            .collection("jobs")
            .doc(jobId)
            .get();
        if (!jobDoc.exists) {
            functions.logger.warn(`Job not found: ${jobId}`);
            return;
        }
        const jobData = jobDoc.data();
        const jobTitle = jobData.title;
        const companyName = jobData.company;
        // Get user details
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(jobSeekerId)
            .get();
        if (!userDoc.exists) {
            functions.logger.warn(`User not found: ${jobSeekerId}`);
            return;
        }
        const userData = userDoc.data();
        const userName = userData.name || "User";
        const userEmail = userData.email;
        // Create Firestore notification
        const template = templates_1.NOTIFICATION_TEMPLATES.APPLICATION_STATUS;
        await admin.firestore()
            .collection("users")
            .doc(jobSeekerId)
            .collection("notifications")
            .add({
            title: template.getTitle(jobTitle),
            body: template.getBody(jobTitle, templates_1.APPLICATION_STATUS_LABELS[newStatus] || newStatus),
            data: {
                type: "application_status",
                applicationId,
                jobId,
                status: newStatus,
            },
            read: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Send FCM notification
        const fcmService = fcm_1.FCMService.getInstance();
        await fcmService.sendApplicationStatusUpdate(jobSeekerId, jobTitle, templates_1.APPLICATION_STATUS_LABELS[newStatus] || newStatus, applicationId, jobId);
        // Send email notification (if email exists)
        if (userEmail) {
            const mailerService = mailer_1.MailerService.getInstance();
            await mailerService.sendApplicationStatusUpdate(userEmail, userName, jobTitle, companyName, templates_1.APPLICATION_STATUS_LABELS[newStatus] || newStatus, applicationId);
        }
        functions.logger.info("Application status notifications sent", {
            applicationId,
            jobSeekerId,
            oldStatus: before.status,
            newStatus,
        });
    }
    catch (error) {
        functions.logger.error("Failed to send application status notifications", {
            error,
            applicationId,
            jobSeekerId,
        });
    }
});
/**
 * 4. On Job Write (Firestore Trigger)
 * Sends notifications for new/updated jobs to matching users
 */
exports.onJobWrite = functions.firestore
    .document("jobs/{jobId}")
    .onWrite(async (change, context) => {
    var _a;
    const jobId = context.params.jobId;
    const after = change.after.exists ? change.after.data() : null;
    // Only process active jobs
    if (!after || !after.isActive) {
        return;
    }
    const isNewJob = !change.before.exists;
    const isUpdatedJob = change.before.exists &&
        ((_a = change.before.data()) === null || _a === void 0 ? void 0 : _a.updatedAt) !== after.updatedAt;
    if (!isNewJob && !isUpdatedJob) {
        return;
    }
    try {
        const jobTitle = after.title;
        const companyName = after.company;
        const jobCategory = after.category;
        const jobCity = after.locationCity;
        // Find matching users (job seekers with matching preferences)
        const usersQuery = admin.firestore()
            .collection("users")
            .where("role", "==", "job_seeker");
        const usersSnapshot = await usersQuery.get();
        const matchingUsers = [];
        usersSnapshot.forEach(doc => {
            const userData = doc.data();
            // Simple matching logic - can be enhanced
            const matchesCategory = !userData.preferredCategory ||
                userData.preferredCategory === jobCategory;
            const matchesCity = !userData.preferredCity ||
                userData.preferredCity === jobCity;
            if (matchesCategory || matchesCity) {
                matchingUsers.push({ id: doc.id, data: userData });
            }
        });
        if (matchingUsers.length === 0) {
            functions.logger.info("No matching users found for job", { jobId, jobTitle });
            return;
        }
        functions.logger.info(`Found ${matchingUsers.length} matching users for job`, {
            jobId,
            jobTitle
        });
        // Process in batches
        const batchSize = 10;
        const template = templates_1.NOTIFICATION_TEMPLATES.JOB_MATCH;
        for (let i = 0; i < matchingUsers.length; i += batchSize) {
            const batch = matchingUsers.slice(i, i + batchSize);
            // Create Firestore notifications batch
            const firestoreBatch = admin.firestore().batch();
            batch.forEach(user => {
                const notificationRef = admin.firestore()
                    .collection("users")
                    .doc(user.id)
                    .collection("notifications")
                    .doc();
                firestoreBatch.set(notificationRef, {
                    title: template.getTitle(jobTitle),
                    body: template.getBody(jobTitle, companyName),
                    data: {
                        type: "job_posted",
                        jobId,
                        category: jobCategory,
                    },
                    read: false,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });
            });
            await firestoreBatch.commit();
            // Send FCM notifications
            const fcmService = fcm_1.FCMService.getInstance();
            const fcmNotifications = batch.map(user => ({
                userId: user.id,
                message: {
                    notification: {
                        title: "New Job Match",
                        body: `${jobTitle} at ${companyName}`,
                    },
                    data: {
                        type: "job_posted",
                        action: "view_job",
                        jobId,
                        category: jobCategory,
                        company: companyName,
                    },
                },
            }));
            await fcmService.sendBulkNotifications(fcmNotifications);
            // Send emails
            const mailerService = mailer_1.MailerService.getInstance();
            const emailPromises = batch
                .filter(user => user.data.email)
                .map(user => mailerService.sendJobMatchNotification(user.data.email, user.data.name || "User", jobTitle, companyName, jobId, jobCategory, `${after.locationCity}, ${after.locationCountry}`));
            await Promise.allSettled(emailPromises);
            functions.logger.info(`Processed batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(matchingUsers.length / batchSize)}`);
        }
        functions.logger.info("Job match notifications sent", {
            jobId,
            jobTitle,
            matchingUsers: matchingUsers.length,
        });
    }
    catch (error) {
        functions.logger.error("Failed to send job match notifications", {
            error,
            jobId,
        });
    }
});
/**
 * 5. Weekly Digest (Scheduled Function)
 * Sends weekly job digest every Monday 08:00 Asia/Karachi
 */
exports.digestWeekly = functions.pubsub
    .schedule("0 8 * * 1") // Every Monday at 8 AM
    .timeZone("Asia/Karachi")
    .onRun(async () => {
    try {
        functions.logger.info("Starting weekly digest job");
        // Get all job seekers
        const usersSnapshot = await admin.firestore()
            .collection("users")
            .where("role", "==", "job_seeker")
            .get();
        if (usersSnapshot.empty) {
            functions.logger.info("No job seekers found for weekly digest");
            return;
        }
        // Get jobs from last week
        const oneWeekAgo = new Date();
        oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
        const jobsSnapshot = await admin.firestore()
            .collection("jobs")
            .where("isActive", "==", true)
            .where("createdAt", ">=", oneWeekAgo)
            .orderBy("createdAt", "desc")
            .get();
        const recentJobs = jobsSnapshot.docs.map(doc => (Object.assign({ id: doc.id }, doc.data())));
        if (recentJobs.length === 0) {
            functions.logger.info("No recent jobs found for weekly digest");
            return;
        }
        functions.logger.info(`Processing weekly digest for ${usersSnapshot.size} users with ${recentJobs.length} recent jobs`);
        // Group jobs by category
        const jobsByCategory = recentJobs.reduce((acc, job) => {
            const category = job.category || "Other";
            if (!acc[category])
                acc[category] = [];
            acc[category].push(job);
            return acc;
        }, {});
        // Process users in batches
        const batchSize = 50;
        const users = usersSnapshot.docs;
        for (let i = 0; i < users.length; i += batchSize) {
            const batch = users.slice(i, i + batchSize);
            const digestPromises = batch.map(async (userDoc) => {
                const userData = userDoc.data();
                const userId = userDoc.id;
                const userCategory = userData.preferredCategory || "IT";
                const userEmail = userData.email;
                const userName = userData.name || "User";
                // Get top 10 jobs for user's category
                const categoryJobs = jobsByCategory[userCategory] || [];
                const topJobs = categoryJobs.slice(0, 10).map((job) => ({
                    id: job.id,
                    title: job.title,
                    company: job.company,
                    location: `${job.locationCity}, ${job.locationCountry}`,
                    salaryRange: job.salaryMin && job.salaryMax ?
                        `${job.salaryMin.toLocaleString()} - ${job.salaryMax.toLocaleString()}` :
                        undefined,
                }));
                if (topJobs.length === 0) {
                    return;
                }
                // Create Firestore notification
                const template = templates_1.NOTIFICATION_TEMPLATES.WEEKLY_DIGEST;
                await admin.firestore()
                    .collection("users")
                    .doc(userId)
                    .collection("notifications")
                    .add({
                    title: template.getTitle(topJobs.length),
                    body: template.getBody(topJobs.length),
                    data: {
                        type: "weekly_digest",
                        jobCount: topJobs.length,
                        category: userCategory,
                    },
                    read: false,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                // Send FCM notification
                const fcmService = fcm_1.FCMService.getInstance();
                await fcmService.sendWeeklyDigestNotification(userId, topJobs.length, userCategory);
                // Send email
                if (userEmail) {
                    const mailerService = mailer_1.MailerService.getInstance();
                    await mailerService.sendWeeklyDigest(userEmail, userName, topJobs, userCategory);
                }
            });
            await Promise.allSettled(digestPromises);
            functions.logger.info(`Processed weekly digest batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(users.length / batchSize)}`);
        }
        functions.logger.info("Weekly digest completed", {
            totalUsers: users.length,
            totalJobs: recentJobs.length,
        });
    }
    catch (error) {
        functions.logger.error("Failed to send weekly digest", { error });
    }
});
//# sourceMappingURL=index.js.map