import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { FCM_TEMPLATES } from "./templates";

/**
 * Firebase Cloud Messaging service utility
 */
export class FCMService {
  private static instance: FCMService;

  private constructor() {}

  public static getInstance(): FCMService {
    if (!FCMService.instance) {
      FCMService.instance = new FCMService();
    }
    return FCMService.instance;
  }

  /**
   * Get user's FCM tokens from Firestore
   */
  private async getUserTokens(userId: string): Promise<string[]> {
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
      const fcmTokens = userData?.fcmTokens || [];

      // Extract token strings from token objects
      return fcmTokens
        .filter((tokenData: any) => tokenData && typeof tokenData === "object" && tokenData.token)
        .map((tokenData: any) => tokenData.token as string);
    } catch (error) {
      functions.logger.error(`Failed to get FCM tokens for user ${userId}`, { error });
      return [];
    }
  }

  /**
   * Send application status update notification
   */
  public async sendApplicationStatusUpdate(
    userId: string,
    jobTitle: string,
    status: string,
    applicationId: string,
    jobId: string
  ): Promise<void> {
    const tokens = await this.getUserTokens(userId);
    if (tokens.length === 0) {
      functions.logger.info(`No FCM tokens found for user ${userId}`);
      return;
    }

    const template = FCM_TEMPLATES.APPLICATION_STATUS;
    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title: template.title,
        body: template.getBody(jobTitle, status),
      },
      data: {
        ...template.data,
        applicationId,
        jobId,
        status,
      },
      android: {
        notification: {
          channelId: "application_updates",
          priority: "high" as const,
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
    } catch (error) {
      functions.logger.error(`Failed to send FCM application status to ${userId}`, {
        error,
        applicationId,
      });
    }
  }

  /**
   * Send job match notification
   */
  public async sendJobMatchNotification(
    userId: string,
    jobTitle: string,
    company: string,
    jobId: string,
    category: string
  ): Promise<void> {
    const tokens = await this.getUserTokens(userId);
    if (tokens.length === 0) {
      functions.logger.info(`No FCM tokens found for user ${userId}`);
      return;
    }

    const template = FCM_TEMPLATES.JOB_MATCH;
    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title: template.title,
        body: template.getBody(jobTitle, company),
      },
      data: {
        ...template.data,
        jobId,
        category,
        company,
      },
      android: {
        notification: {
          channelId: "job_matches",
          priority: "default" as const,
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
    } catch (error) {
      functions.logger.error(`Failed to send FCM job match to ${userId}`, {
        error,
        jobId,
      });
    }
  }

  /**
   * Send weekly digest notification
   */
  public async sendWeeklyDigestNotification(
    userId: string,
    jobCount: number,
    category: string
  ): Promise<void> {
    const tokens = await this.getUserTokens(userId);
    if (tokens.length === 0) {
      functions.logger.info(`No FCM tokens found for user ${userId}`);
      return;
    }

    const template = FCM_TEMPLATES.WEEKLY_DIGEST;
    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title: template.title,
        body: template.getBody(jobCount),
      },
      data: {
        ...template.data,
        jobCount: jobCount.toString(),
        category,
      },
      android: {
        notification: {
          channelId: "weekly_digest",
          priority: "default" as const,
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
    } catch (error) {
      functions.logger.error(`Failed to send FCM weekly digest to ${userId}`, {
        error,
        category,
      });
    }
  }

  /**
   * Send bulk FCM notifications with batching
   */
  public async sendBulkNotifications(
    notifications: Array<{
      userId: string;
      message: Omit<admin.messaging.MulticastMessage, "tokens">;
    }>,
    batchSize = 500
  ): Promise<void> {
    functions.logger.info(`Sending FCM notifications to ${notifications.length} users`);

    // Get all tokens first
    const userTokens = new Map<string, string[]>();
    for (const notification of notifications) {
      const tokens = await this.getUserTokens(notification.userId);
      if (tokens.length > 0) {
        userTokens.set(notification.userId, tokens);
      }
    }

    // Prepare messages
    const messages: admin.messaging.MulticastMessage[] = [];
    for (const notification of notifications) {
      const tokens = userTokens.get(notification.userId);
      if (tokens && tokens.length > 0) {
        messages.push({
          ...notification.message,
          tokens,
        });
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
      } catch (error) {
        functions.logger.error(`Failed to send FCM batch ${Math.floor(i / batchSize) + 1}`, { error });
      }
    }
  }

  /**
   * Clean up invalid FCM tokens from user document
   */
  private async cleanupInvalidTokens(
    userId: string,
    sentTokens: string[],
    responses: admin.messaging.SendResponse[]
  ): Promise<void> {
    const invalidTokens: string[] = [];

    responses.forEach((response, index) => {
      if (!response.success && response.error) {
        const errorCode = response.error.code;
        
        // Remove tokens that are permanently invalid
        if (
          errorCode === "messaging/registration-token-not-registered" ||
          errorCode === "messaging/invalid-registration-token"
        ) {
          invalidTokens.push(sentTokens[index]);
        }
      }
    });

    if (invalidTokens.length === 0) return;

    try {
      // Get current user document
      const userDoc = await admin.firestore()
        .collection("users")
        .doc(userId)
        .get();

      if (!userDoc.exists) return;

      const userData = userDoc.data();
      const currentTokens = userData?.fcmTokens || [];

      // Filter out invalid tokens
      const validTokens = currentTokens.filter((tokenData: any) => {
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
    } catch (error) {
      functions.logger.error(`Failed to cleanup invalid tokens for user ${userId}`, { error });
    }
  }
}
