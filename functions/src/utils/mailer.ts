import * as sgMail from "@sendgrid/mail";
import * as functions from "firebase-functions";
import nodemailer from "nodemailer";
import { EMAIL_TEMPLATES } from "./templates";

/**
 * SendGrid email service utility
 */
export class MailerService {
  private static instance: MailerService;
  private initialized = false;
  private useGmail = false;
  private transporter: nodemailer.Transporter | null = null;

  private constructor() {
    this.initialize();
  }

  public async sendBasicEmail(
    toEmail: string,
    toName: string,
    subject: string,
    html: string,
    text?: string
  ): Promise<void> {
    if (!this.initialized) {
      functions.logger.warn("Mailer not initialized, skipping email");
      return;
    }

    const config = functions.config();

    try {
      if (this.useGmail && this.transporter) {
        await this.transporter.sendMail({
          from: {
            name: "JobHunt",
            address: config.gmail?.from || config.gmail?.user,
          },
          to: { name: toName, address: toEmail },
          subject,
          html,
          text,
        });
      } else {
        const msg: sgMail.MailDataRequired = {
          to: toEmail,
          from: {
            email: config.sendgrid?.from,
            name: "JobHunt",
          },
          subject,
          html,
          text,
        } as any;
        await sgMail.send(msg);
      }
      functions.logger.info(`Email sent to ${toEmail} with subject: ${subject}`);
    } catch (error) {
      functions.logger.error("Failed to send basic email", { error, toEmail, subject });
      throw error;
    }
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
    // Prefer Gmail SMTP if configured
    const gmailUser = config.gmail?.user;
    const gmailPass = config.gmail?.pass;
    if (gmailUser && gmailPass) {
      this.transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: gmailUser,
          pass: gmailPass,
        },
      });
      this.useGmail = true;
      this.initialized = true;
      functions.logger.info("Gmail SMTP mailer initialized");
      return;
    }

    // Fallback to SendGrid if Gmail not configured
    if (config.sendgrid?.key) {
      sgMail.setApiKey(config.sendgrid.key);
      this.useGmail = false;
      this.initialized = true;
      functions.logger.info("SendGrid mailer initialized");
      return;
    }

    functions.logger.warn("No mailer configured (Gmail SMTP or SendGrid)");
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
      functions.logger.warn("Mailer not initialized, skipping email");
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

    try {
      if (this.useGmail && this.transporter) {
        await this.transporter.sendMail({
          from: {
            name: "JobHunt",
            address: config.gmail?.from || config.gmail?.user,
          },
          to: { name: userName, address: userEmail },
          subject: EMAIL_TEMPLATES.STATUS_UPDATE.subject(jobTitle, companyName, newStatus),
          html: EMAIL_TEMPLATES.STATUS_UPDATE.html(templateData),
          text: EMAIL_TEMPLATES.STATUS_UPDATE.text(templateData),
        });
      } else {
        const msg: sgMail.MailDataRequired = {
          to: userEmail,
          from: {
            email: config.sendgrid.from,
            name: "JobHunt",
          },
          templateId: EMAIL_TEMPLATES.STATUS_UPDATE.id,
          dynamicTemplateData: templateData,
        };
        await sgMail.send(msg);
      }
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
      functions.logger.warn("Mailer not initialized, skipping email");
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

    try {
      if (this.useGmail && this.transporter) {
        await this.transporter.sendMail({
          from: {
            name: "JobHunt",
            address: config.gmail?.from || config.gmail?.user,
          },
          to: { name: userName, address: userEmail },
          subject: EMAIL_TEMPLATES.JOB_MATCH.subject(jobTitle, companyName),
          html: EMAIL_TEMPLATES.JOB_MATCH.html(templateData),
          text: EMAIL_TEMPLATES.JOB_MATCH.text(templateData),
        });
      } else {
        const msg: sgMail.MailDataRequired = {
          to: userEmail,
          from: {
            email: config.sendgrid.from,
            name: "JobHunt",
          },
          templateId: EMAIL_TEMPLATES.JOB_MATCH.id,
          dynamicTemplateData: templateData,
        };
        await sgMail.send(msg);
      }
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
      functions.logger.warn("Mailer not initialized, skipping email");
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

    try {
      if (this.useGmail && this.transporter) {
        await this.transporter.sendMail({
          from: {
            name: "JobHunt",
            address: config.gmail?.from || config.gmail?.user,
          },
          to: { name: userName, address: userEmail },
          subject: EMAIL_TEMPLATES.WEEKLY_DIGEST.subject(jobs.length),
          html: EMAIL_TEMPLATES.WEEKLY_DIGEST.html(templateData),
          text: EMAIL_TEMPLATES.WEEKLY_DIGEST.text(templateData),
        });
      } else {
        const msg: sgMail.MailDataRequired = {
          to: userEmail,
          from: {
            email: config.sendgrid.from,
            name: "JobHunt",
          },
          templateId: EMAIL_TEMPLATES.WEEKLY_DIGEST.id,
          dynamicTemplateData: templateData,
        };
        await sgMail.send(msg);
      }
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
      functions.logger.warn("Mailer not initialized, skipping bulk emails");
      return;
    }

    functions.logger.info(`Sending ${emails.length} emails in batches of ${batchSize}`);

    if (this.useGmail && this.transporter) {
      for (let i = 0; i < emails.length; i += batchSize) {
        const batch = emails.slice(i, i + batchSize);
        try {
          await Promise.all(
            batch.map(m =>
              this.transporter!.sendMail({
                from: (m.from as any) || {
                  name: "JobHunt",
                  address: functions.config().gmail?.from || functions.config().gmail?.user,
                },
                to: m.to as any,
                subject: m.subject as string,
                html: (m as any).html,
                text: (m as any).text,
              })
            )
          );
          functions.logger.info(`Sent batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(emails.length / batchSize)}`);
          if (i + batchSize < emails.length) {
            await new Promise(resolve => setTimeout(resolve, 1000));
          }
        } catch (error) {
          functions.logger.error(`Failed to send email batch ${Math.floor(i / batchSize) + 1}`, {
            error,
            batchSize: batch.length,
          });
        }
      }
    } else {
      for (let i = 0; i < emails.length; i += batchSize) {
        const batch = emails.slice(i, i + batchSize);
        try {
          await sgMail.send(batch);
          functions.logger.info(`Sent batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(emails.length / batchSize)}`);
          if (i + batchSize < emails.length) {
            await new Promise(resolve => setTimeout(resolve, 1000));
          }
        } catch (error) {
          functions.logger.error(`Failed to send email batch ${Math.floor(i / batchSize) + 1}`, {
            error,
            batchSize: batch.length,
          });
        }
      }
    }
  }
}
