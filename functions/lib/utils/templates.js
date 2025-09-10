"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.APPLICATION_STATUS_LABELS = exports.NOTIFICATION_TEMPLATES = exports.FCM_TEMPLATES = exports.EMAIL_TEMPLATES = void 0;
/**
 * Email template configurations for SendGrid
 */
exports.EMAIL_TEMPLATES = {
    STATUS_UPDATE: {
        id: "d-status-update-template-id",
        name: "Application Status Update",
    },
    JOB_MATCH: {
        id: "d-job-match-template-id",
        name: "New Job Match",
    },
    WEEKLY_DIGEST: {
        id: "d-weekly-digest-template-id",
        name: "Weekly Job Digest",
    },
};
/**
 * FCM notification templates
 */
exports.FCM_TEMPLATES = {
    APPLICATION_STATUS: {
        title: "Application Update",
        getBody: (jobTitle, status) => `Your application for ${jobTitle} is now ${status}`,
        data: {
            type: "application_status",
            action: "view_applications",
        },
    },
    JOB_MATCH: {
        title: "New Job Match",
        getBody: (jobTitle, company) => `New job opportunity: ${jobTitle} at ${company}`,
        data: {
            type: "job_posted",
            action: "view_job",
        },
    },
    WEEKLY_DIGEST: {
        title: "Weekly Job Digest",
        getBody: (jobCount) => `${jobCount} new jobs matching your preferences this week`,
        data: {
            type: "weekly_digest",
            action: "view_jobs",
        },
    },
};
/**
 * Firestore notification templates
 */
exports.NOTIFICATION_TEMPLATES = {
    APPLICATION_STATUS: {
        getTitle: (jobTitle) => `Application Update - ${jobTitle}`,
        getBody: (jobTitle, status) => `Your application for "${jobTitle}" status has been updated to: ${status}`,
    },
    JOB_MATCH: {
        getTitle: (jobTitle) => `New Job Match: ${jobTitle}`,
        getBody: (jobTitle, company) => `A new job opportunity "${jobTitle}" at ${company} matches your preferences`,
    },
    WEEKLY_DIGEST: {
        getTitle: (jobCount) => `${jobCount} New Jobs This Week`,
        getBody: (jobCount) => `Your weekly digest contains ${jobCount} new job opportunities`,
    },
};
/**
 * Application status display names
 */
exports.APPLICATION_STATUS_LABELS = {
    pending: "Under Review",
    reviewing: "Being Reviewed",
    shortlisted: "Shortlisted",
    interview_scheduled: "Interview Scheduled",
    interviewed: "Interviewed",
    selected: "Selected",
    rejected: "Not Selected",
    withdrawn: "Withdrawn",
};
//# sourceMappingURL=templates.js.map