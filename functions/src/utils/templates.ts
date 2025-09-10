/**
 * Email template configurations for SendGrid
 */
export const EMAIL_TEMPLATES = {
  STATUS_UPDATE: {
    id: "d-status-update-template-id", // Replace with actual SendGrid template ID
    name: "Application Status Update",
  },
  JOB_MATCH: {
    id: "d-job-match-template-id", // Replace with actual SendGrid template ID
    name: "New Job Match",
  },
  WEEKLY_DIGEST: {
    id: "d-weekly-digest-template-id", // Replace with actual SendGrid template ID
    name: "Weekly Job Digest",
  },
} as const;

/**
 * FCM notification templates
 */
export const FCM_TEMPLATES = {
  APPLICATION_STATUS: {
    title: "Application Update",
    getBody: (jobTitle: string, status: string) => 
      `Your application for ${jobTitle} is now ${status}`,
    data: {
      type: "application_status",
      action: "view_applications",
    },
  },
  JOB_MATCH: {
    title: "New Job Match",
    getBody: (jobTitle: string, company: string) => 
      `New job opportunity: ${jobTitle} at ${company}`,
    data: {
      type: "job_posted",
      action: "view_job",
    },
  },
  WEEKLY_DIGEST: {
    title: "Weekly Job Digest",
    getBody: (jobCount: number) => 
      `${jobCount} new jobs matching your preferences this week`,
    data: {
      type: "weekly_digest",
      action: "view_jobs",
    },
  },
} as const;

/**
 * Firestore notification templates
 */
export const NOTIFICATION_TEMPLATES = {
  APPLICATION_STATUS: {
    getTitle: (jobTitle: string) => `Application Update - ${jobTitle}`,
    getBody: (jobTitle: string, status: string) => 
      `Your application for "${jobTitle}" status has been updated to: ${status}`,
  },
  JOB_MATCH: {
    getTitle: (jobTitle: string) => `New Job Match: ${jobTitle}`,
    getBody: (jobTitle: string, company: string) => 
      `A new job opportunity "${jobTitle}" at ${company} matches your preferences`,
  },
  WEEKLY_DIGEST: {
    getTitle: (jobCount: number) => `${jobCount} New Jobs This Week`,
    getBody: (jobCount: number) => 
      `Your weekly digest contains ${jobCount} new job opportunities`,
  },
} as const;

/**
 * Application status display names
 */
export const APPLICATION_STATUS_LABELS = {
  pending: "Under Review",
  reviewing: "Being Reviewed",
  shortlisted: "Shortlisted",
  interview_scheduled: "Interview Scheduled",
  interviewed: "Interviewed",
  selected: "Selected",
  rejected: "Not Selected",
  withdrawn: "Withdrawn",
} as const;

export type ApplicationStatus = keyof typeof APPLICATION_STATUS_LABELS;
