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
exports.FCMService = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
const templates_1 = require("./templates");
/**
 * Firebase Cloud Messaging service utility
 */
class FCMService {
    constructor() { }
    static getInstance() {
        if (!FCMService.instance) {
            FCMService.instance = new FCMService();
        }
        return FCMService.instance;
    }
    /**
     * Get user's FCM tokens from Firestore
     */
    async getUserTokens(userId) {
        try {
            const userDoc = await admin.firestore()
                .collection("users")
                .doc(userId)
                .get();
            if (!userDoc.exists) {
                functions.logger.warn(`User document not found: ${userId}`);
                return [];
            }
            const userData = userDoc.data();
            const fcmTokens = (userData === null || userData === void 0 ? void 0 : userData.fcmTokens) || [];
            // Extract token strings from token objects
            return fcmTokens
                .filter((tokenData) => tokenData && typeof tokenData === "object" && tokenData.token)
                .map((tokenData) => tokenData.token);
        }
        catch (error) {
            functions.logger.error(`Failed to get FCM tokens for user ${userId}`, { error });
            return [];
        }
    }
    /**
     * Send application status update notification
     */
    async sendApplicationStatusUpdate(userId, jobTitle, status, applicationId, jobId) {
        const tokens = await this.getUserTokens(userId);
        if (tokens.length === 0) {
            functions.logger.info(`No FCM tokens found for user ${userId}`);
            return;
        }
        const template = templates_1.FCM_TEMPLATES.APPLICATION_STATUS;
        const message = {
            tokens,
            notification: {
                title: template.title,
                body: template.getBody(jobTitle, status),
            },
            data: Object.assign(Object.assign({}, template.data), { applicationId,
                jobId,
                status }),
            android: {
                notification: {
                    channelId: "application_updates",
                    priority: "high",
                },
            },
            apns: {
                payload: {
                    aps: {
                        category: "APPLICATION_UPDATE",
                    },
                },
            },
        };
        try {
            const response = await admin.messaging().sendEachForMulticast(message);
            // Log results
            functions.logger.info(`FCM application status sent to ${userId}`, {
                successCount: response.successCount,
                failureCount: response.failureCount,
                tokensCount: tokens.length,
            });
            // Clean up invalid tokens
            await this.cleanupInvalidTokens(userId, tokens, response.responses);
        }
        catch (error) {
            functions.logger.error(`Failed to send FCM application status to ${userId}`, {
                error,
                applicationId,
            });
        }
    }
    /**
     * Send job match notification
     */
    async sendJobMatchNotification(userId, jobTitle, company, jobId, category) {
        const tokens = await this.getUserTokens(userId);
        if (tokens.length === 0) {
            functions.logger.info(`No FCM tokens found for user ${userId}`);
            return;
        }
        const template = templates_1.FCM_TEMPLATES.JOB_MATCH;
        const message = {
            tokens,
            notification: {
                title: template.title,
                body: template.getBody(jobTitle, company),
            },
            data: Object.assign(Object.assign({}, template.data), { jobId,
                category,
                company }),
            android: {
                notification: {
                    channelId: "job_matches",
                    priority: "default",
                },
            },
            apns: {
                payload: {
                    aps: {
                        category: "JOB_MATCH",
                    },
                },
            },
        };
        try {
            const response = await admin.messaging().sendEachForMulticast(message);
            functions.logger.info(`FCM job match sent to ${userId}`, {
                successCount: response.successCount,
                failureCount: response.failureCount,
                jobId,
            });
            await this.cleanupInvalidTokens(userId, tokens, response.responses);
        }
        catch (error) {
            functions.logger.error(`Failed to send FCM job match to ${userId}`, {
                error,
                jobId,
            });
        }
    }
    /**
     * Send weekly digest notification
     */
    async sendWeeklyDigestNotification(userId, jobCount, category) {
        const tokens = await this.getUserTokens(userId);
        if (tokens.length === 0) {
            functions.logger.info(`No FCM tokens found for user ${userId}`);
            return;
        }
        const template = templates_1.FCM_TEMPLATES.WEEKLY_DIGEST;
        const message = {
            tokens,
            notification: {
                title: template.title,
                body: template.getBody(jobCount),
            },
            data: Object.assign(Object.assign({}, template.data), { jobCount: jobCount.toString(), category }),
            android: {
                notification: {
                    channelId: "weekly_digest",
                    priority: "default",
                },
            },
            apns: {
                payload: {
                    aps: {
                        category: "WEEKLY_DIGEST",
                    },
                },
            },
        };
        try {
            const response = await admin.messaging().sendEachForMulticast(message);
            functions.logger.info(`FCM weekly digest sent to ${userId}`, {
                successCount: response.successCount,
                failureCount: response.failureCount,
                jobCount,
            });
            await this.cleanupInvalidTokens(userId, tokens, response.responses);
        }
        catch (error) {
            functions.logger.error(`Failed to send FCM weekly digest to ${userId}`, {
                error,
                category,
            });
        }
    }
    /**
     * Send bulk FCM notifications with batching
     */
    async sendBulkNotifications(notifications, batchSize = 500) {
        functions.logger.info(`Sending FCM notifications to ${notifications.length} users`);
        // Get all tokens first
        const userTokens = new Map();
        for (const notification of notifications) {
            const tokens = await this.getUserTokens(notification.userId);
            if (tokens.length > 0) {
                userTokens.set(notification.userId, tokens);
            }
        }
        // Prepare messages
        const messages = [];
        for (const notification of notifications) {
            const tokens = userTokens.get(notification.userId);
            if (tokens && tokens.length > 0) {
                messages.push(Object.assign(Object.assign({}, notification.message), { tokens }));
            }
        }
        // Send in batches
        for (let i = 0; i < messages.length; i += batchSize) {
            const batch = messages.slice(i, i + batchSize);
            try {
                const promises = batch.map(message => admin.messaging().sendEachForMulticast(message));
                const responses = await Promise.allSettled(promises);
                functions.logger.info(`Sent FCM batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(messages.length / batchSize)}`);
                // Process responses for cleanup
                responses.forEach((result, index) => {
                    if (result.status === "fulfilled") {
                        const message = batch[index];
                        // Find the userId for cleanup
                        const notification = notifications.find(n => {
                            const tokens = userTokens.get(n.userId);
                            return tokens && tokens.every(token => message.tokens.includes(token));
                        });
                        if (notification) {
                            this.cleanupInvalidTokens(notification.userId, message.tokens, result.value.responses);
                        }
                    }
                });
            }
            catch (error) {
                functions.logger.error(`Failed to send FCM batch ${Math.floor(i / batchSize) + 1}`, { error });
            }
        }
    }
    /**
     * Clean up invalid FCM tokens from user document
     */
    async cleanupInvalidTokens(userId, sentTokens, responses) {
        const invalidTokens = [];
        responses.forEach((response, index) => {
            if (!response.success && response.error) {
                const errorCode = response.error.code;
                // Remove tokens that are permanently invalid
                if (errorCode === "messaging/registration-token-not-registered" ||
                    errorCode === "messaging/invalid-registration-token") {
                    invalidTokens.push(sentTokens[index]);
                }
            }
        });
        if (invalidTokens.length === 0)
            return;
        try {
            // Get current user document
            const userDoc = await admin.firestore()
                .collection("users")
                .doc(userId)
                .get();
            if (!userDoc.exists)
                return;
            const userData = userDoc.data();
            const currentTokens = (userData === null || userData === void 0 ? void 0 : userData.fcmTokens) || [];
            // Filter out invalid tokens
            const validTokens = currentTokens.filter((tokenData) => {
                return !invalidTokens.includes(tokenData.token);
            });
            // Update user document
            await admin.firestore()
                .collection("users")
                .doc(userId)
                .update({
                fcmTokens: validTokens,
                lastTokenUpdate: admin.firestore.FieldValue.serverTimestamp(),
            });
            functions.logger.info(`Cleaned up ${invalidTokens.length} invalid FCM tokens for user ${userId}`);
        }
        catch (error) {
            functions.logger.error(`Failed to cleanup invalid tokens for user ${userId}`, { error });
        }
    }
}
exports.FCMService = FCMService;
//# sourceMappingURL=fcm.js.map