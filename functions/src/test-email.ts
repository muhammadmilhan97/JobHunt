import * as functions from "firebase-functions";
import { MailerService } from "./utils/mailer";

/**
 * Test email function to verify Gmail SMTP setup
 */
export const testEmail = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  }

  const { to, subject, message } = data;
  
  if (!to || !subject || !message) {
    throw new functions.https.HttpsError("invalid-argument", "Missing required fields: to, subject, message");
  }

  try {
    const mailer = MailerService.getInstance();
    await mailer.sendBasicEmail(
      to,
      "Test User",
      subject,
      `<h1>Test Email</h1><p>${message}</p><p>Sent from JobHunt Functions</p>`,
      `Test Email\n\n${message}\n\nSent from JobHunt Functions`
    );

    // Log the attempt
    await mailer.logEmailAttempt({
      to,
      subject,
      status: "sent",
      triggeredBy: context.auth.uid,
      type: "test_email",
    });

    return { success: true, message: "Test email sent successfully" };
  } catch (error: any) {
    functions.logger.error("Test email failed", { error, to });
    
    // Log the failure
    const mailer = MailerService.getInstance();
    await mailer.logEmailAttempt({
      to,
      subject,
      status: "failed",
      error: error.message || "Unknown error",
      triggeredBy: context.auth.uid,
      type: "test_email",
    });

    throw new functions.https.HttpsError("internal", `Failed to send test email: ${error.message}`);
  }
});
