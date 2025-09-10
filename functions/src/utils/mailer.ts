import * as sgMail from "@sendgrid/mail";
import * as functions from "firebase-functions";
import { EMAIL_TEMPLATES } from "./templates";

/**
 * SendGrid email service utility
 */
export class MailerService {
  private static instance: MailerService;
  private initialized = false;

  private constructor() {
    this.initialize();
  }

  public static getInstance(): MailerService {
    if (!MailerService.instance) {
      MailerService.instance = new MailerService();
    }
    return MailerService.instance;
  }

  private initialize(): void {
    if (this.initialized) return;

    const config = functions.config();
    if (!config.sendgrid?.key) {
      functions.logger.warn("SendGrid API key not configured");
      return;
    }

    sgMail.setApiKey(config.sendgrid.key);
    this.initialized = true;
    functions.logger.info("SendGrid mailer initialized");
  }

  /**
   * Send application status update email
   */
  public async sendApplicationStatusUpdate(
    userEmail: string,
    userName: string,
    jobTitle: string,
    companyName: string,
    newStatus: string,
    applicationId: string
  ): Promise<void> {
    if (!this.initialized) {
      functions.logger.warn("SendGrid not initialized, skipping email");
      return;
    }

    const config = functions.config();
    const templateData = {
      user_name: userName,
      job_title: jobTitle,
      company_name: companyName,
      status: newStatus,
      application_id: applicationId,
      app_url: `${config.app?.base_url || "https://jobhunt.app"}/applications/${applicationId}`,
    };

    const msg: sgMail.MailDataRequired = {
      to: userEmail,
      from: {
        email: config.sendgrid.from,
        name: "JobHunt",
      },
      templateId: EMAIL_TEMPLATES.STATUS_UPDATE.id,
      dynamicTemplateData: templateData,
    };

    try {
      await sgMail.send(msg);
      functions.logger.info(`Application status email sent to ${userEmail}`, {
        applicationId,
        status: newStatus,
      });
    } catch (error) {
      functions.logger.error("Failed to send application status email", {
        error,
        userEmail,
        applicationId,
      });
      throw error;
    }
  }

  /**
   * Send job match notification email
   */
  public async sendJobMatchNotification(
    userEmail: string,
    userName: string,
    jobTitle: string,
    companyName: string,
    jobId: string,
    jobCategory: string,
    location: string
  ): Promise<void> {
    if (!this.initialized) {
      functions.logger.warn("SendGrid not initialized, skipping email");
      return;
    }

    const config = functions.config();
    const templateData = {
      user_name: userName,
      job_title: jobTitle,
      company_name: companyName,
      job_category: jobCategory,
      location,
      job_url: `${config.app?.base_url || "https://jobhunt.app"}/jobs/${jobId}`,
    };

    const msg: sgMail.MailDataRequired = {
      to: userEmail,
      from: {
        email: config.sendgrid.from,
        name: "JobHunt",
      },
      templateId: EMAIL_TEMPLATES.JOB_MATCH.id,
      dynamicTemplateData: templateData,
    };

    try {
      await sgMail.send(msg);
      functions.logger.info(`Job match email sent to ${userEmail}`, {
        jobId,
        jobTitle,
      });
    } catch (error) {
      functions.logger.error("Failed to send job match email", {
        error,
        userEmail,
        jobId,
      });
      throw error;
    }
  }

  /**
   * Send weekly digest email
   */
  public async sendWeeklyDigest(
    userEmail: string,
    userName: string,
    jobs: Array<{
      id: string;
      title: string;
      company: string;
      location: string;
      salaryRange?: string;
    }>,
    userCategory: string
  ): Promise<void> {
    if (!this.initialized) {
      functions.logger.warn("SendGrid not initialized, skipping email");
      return;
    }

    const config = functions.config();
    const templateData = {
      user_name: userName,
      user_category: userCategory,
      job_count: jobs.length,
      jobs: jobs.map(job => ({
        ...job,
        job_url: `${config.app?.base_url || "https://jobhunt.app"}/jobs/${job.id}`,
      })),
      browse_url: `${config.app?.base_url || "https://jobhunt.app"}/jobs?category=${encodeURIComponent(userCategory)}`,
    };

    const msg: sgMail.MailDataRequired = {
      to: userEmail,
      from: {
        email: config.sendgrid.from,
        name: "JobHunt",
      },
      templateId: EMAIL_TEMPLATES.WEEKLY_DIGEST.id,
      dynamicTemplateData: templateData,
    };

    try {
      await sgMail.send(msg);
      functions.logger.info(`Weekly digest sent to ${userEmail}`, {
        jobCount: jobs.length,
        category: userCategory,
      });
    } catch (error) {
      functions.logger.error("Failed to send weekly digest", {
        error,
        userEmail,
        category: userCategory,
      });
      throw error;
    }
  }

  /**
   * Send bulk emails with batching to avoid rate limits
   */
  public async sendBulkEmails(
    emails: sgMail.MailDataRequired[],
    batchSize = 100
  ): Promise<void> {
    if (!this.initialized) {
      functions.logger.warn("SendGrid not initialized, skipping bulk emails");
      return;
    }

    functions.logger.info(`Sending ${emails.length} emails in batches of ${batchSize}`);

    for (let i = 0; i < emails.length; i += batchSize) {
      const batch = emails.slice(i, i + batchSize);
      
      try {
        await sgMail.send(batch);
        functions.logger.info(`Sent batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(emails.length / batchSize)}`);
        
        // Add delay between batches to respect rate limits
        if (i + batchSize < emails.length) {
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
      } catch (error) {
        functions.logger.error(`Failed to send email batch ${Math.floor(i / batchSize) + 1}`, {
          error,
          batchSize: batch.length,
        });
        // Continue with next batch even if one fails
      }
    }
  }
}
