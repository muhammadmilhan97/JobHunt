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
exports.MailerService = void 0;
const sgMail = __importStar(require("@sendgrid/mail"));
const functions = __importStar(require("firebase-functions"));
const templates_1 = require("./templates");
/**
 * SendGrid email service utility
 */
class MailerService {
    constructor() {
        this.initialized = false;
        this.initialize();
    }
    static getInstance() {
        if (!MailerService.instance) {
            MailerService.instance = new MailerService();
        }
        return MailerService.instance;
    }
    initialize() {
        var _a;
        if (this.initialized)
            return;
        const config = functions.config();
        if (!((_a = config.sendgrid) === null || _a === void 0 ? void 0 : _a.key)) {
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
    async sendApplicationStatusUpdate(userEmail, userName, jobTitle, companyName, newStatus, applicationId) {
        var _a;
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
            app_url: `${((_a = config.app) === null || _a === void 0 ? void 0 : _a.base_url) || "https://jobhunt.app"}/applications/${applicationId}`,
        };
        const msg = {
            to: userEmail,
            from: {
                email: config.sendgrid.from,
                name: "JobHunt",
            },
            templateId: templates_1.EMAIL_TEMPLATES.STATUS_UPDATE.id,
            dynamicTemplateData: templateData,
        };
        try {
            await sgMail.send(msg);
            functions.logger.info(`Application status email sent to ${userEmail}`, {
                applicationId,
                status: newStatus,
            });
        }
        catch (error) {
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
    async sendJobMatchNotification(userEmail, userName, jobTitle, companyName, jobId, jobCategory, location) {
        var _a;
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
            job_url: `${((_a = config.app) === null || _a === void 0 ? void 0 : _a.base_url) || "https://jobhunt.app"}/jobs/${jobId}`,
        };
        const msg = {
            to: userEmail,
            from: {
                email: config.sendgrid.from,
                name: "JobHunt",
            },
            templateId: templates_1.EMAIL_TEMPLATES.JOB_MATCH.id,
            dynamicTemplateData: templateData,
        };
        try {
            await sgMail.send(msg);
            functions.logger.info(`Job match email sent to ${userEmail}`, {
                jobId,
                jobTitle,
            });
        }
        catch (error) {
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
    async sendWeeklyDigest(userEmail, userName, jobs, userCategory) {
        var _a;
        if (!this.initialized) {
            functions.logger.warn("SendGrid not initialized, skipping email");
            return;
        }
        const config = functions.config();
        const templateData = {
            user_name: userName,
            user_category: userCategory,
            job_count: jobs.length,
            jobs: jobs.map(job => {
                var _a;
                return (Object.assign(Object.assign({}, job), { job_url: `${((_a = config.app) === null || _a === void 0 ? void 0 : _a.base_url) || "https://jobhunt.app"}/jobs/${job.id}` }));
            }),
            browse_url: `${((_a = config.app) === null || _a === void 0 ? void 0 : _a.base_url) || "https://jobhunt.app"}/jobs?category=${encodeURIComponent(userCategory)}`,
        };
        const msg = {
            to: userEmail,
            from: {
                email: config.sendgrid.from,
                name: "JobHunt",
            },
            templateId: templates_1.EMAIL_TEMPLATES.WEEKLY_DIGEST.id,
            dynamicTemplateData: templateData,
        };
        try {
            await sgMail.send(msg);
            functions.logger.info(`Weekly digest sent to ${userEmail}`, {
                jobCount: jobs.length,
                category: userCategory,
            });
        }
        catch (error) {
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
    async sendBulkEmails(emails, batchSize = 100) {
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
            }
            catch (error) {
                functions.logger.error(`Failed to send email batch ${Math.floor(i / batchSize) + 1}`, {
                    error,
                    batchSize: batch.length,
                });
                // Continue with next batch even if one fails
            }
        }
    }
}
exports.MailerService = MailerService;
//# sourceMappingURL=mailer.js.map