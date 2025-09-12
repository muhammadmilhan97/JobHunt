# JobHunt - Final Project Supervisor Guide
**CS619 - Final Project**  
**Group ID: S25PROJECT88248 (BC210423055)**  
**Phase: Prototype**  
**Timeline: Wed 30 Jul, 2025 - Fri 12 Sep, 2025**  
**Supervisor: Saeed Nasir**

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Admin Access Credentials](#admin-access-credentials)
3. [Application Architecture](#application-architecture)
4. [User Roles & Authentication](#user-roles--authentication)
5. [Feature Walkthrough](#feature-walkthrough)
6. [Technical Implementation](#technical-implementation)
7. [Database Structure](#database-structure)
8. [Testing Scenarios](#testing-scenarios)
9. [Known Issues & Future Enhancements](#known-issues--future-enhancements)

---

## Project Overview

**JobHunt** is a comprehensive job portal application built with Flutter and Firebase, designed to connect job seekers with employers through an intuitive, role-based interface. The application supports three distinct user roles: Job Seekers, Employers, and Administrators, each with specialized functionalities.

### Key Features
- **Multi-role Authentication System** with PIN-based security
- **Job Posting & Management** for employers
- **Job Search & Application System** for seekers
- **Admin Dashboard** for user and content management
- **Email Notifications** via Gmail SMTP
- **Real-time Updates** using Firebase Firestore
- **Responsive Design** with branded UI components

---

## Admin Access Credentials

### Primary Admin Account
```
Email: jobhuntapplication@gmail.com
Password: 12e12e12e
```

**Important Notes:**
- This is the only admin account in the system
- Admin has full access to all user management features
- Admin can approve/reject user registrations
- Admin can moderate jobs and applications
- Admin has access to analytics and system monitoring

---

## Application Architecture

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication, Cloud Functions)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Email Service**: Gmail SMTP via Nodemailer
- **UI Framework**: Material Design 3

### Project Structure
```
lib/
├── app/                    # App configuration (router, theme)
├── core/                   # Core services and utilities
│   ├── config/            # Configuration files
│   ├── models/            # Data models
│   ├── providers/         # Riverpod providers
│   ├── repository/        # Data access layer
│   ├── services/          # Business logic services
│   ├── ui/                # UI utilities
│   ├── utils/             # Helper functions
│   └── widgets/           # Reusable widgets
├── features/              # Feature-based modules
│   ├── admin/             # Admin-specific features
│   ├── auth/              # Authentication features
│   ├── employer/          # Employer features
│   ├── seeker/            # Job seeker features
│   ├── notifications/     # Notification system
│   └── shared/            # Shared components
└── widgets/               # Global widgets
```

---

## User Roles & Authentication

### 1. Job Seeker
**Primary Functions:**
- Browse and search jobs
- Apply to positions
- Manage applications
- Set up job alerts
- View application status

### 2. Employer
**Primary Functions:**
- Post job listings
- Manage posted jobs
- Review applications
- View analytics
- Manage company profile

### 3. Administrator
**Primary Functions:**
- Approve/reject user registrations
- Moderate job postings
- Manage user accounts
- View system analytics
- Monitor application health

### Authentication Flow
1. **Registration**: Users register with email, password, and role selection
2. **Admin Approval**: All non-admin users require admin approval
3. **PIN Setup**: After approval, users set up a 4-digit PIN
4. **Login**: Users authenticate with email/password + PIN verification
5. **Role-based Navigation**: Users are redirected to role-specific dashboards

---

## Feature Walkthrough

### 🔐 Authentication System

#### Registration Process
1. Navigate to `/auth/register`
2. Fill in registration form:
   - Name, Email, Password
   - Role selection (Job Seeker/Employer)
   - Company name (for employers)
3. Submit registration
4. **Admin approval required** - User receives pending approval status
5. Admin approves via admin dashboard
6. User receives approval email
7. User sets up PIN via `/auth/pin-setup`
8. User can now access the application

#### Login Process
1. Navigate to `/auth`
2. Enter email and password
3. Enter 4-digit PIN
4. Access role-specific dashboard

### 👤 Job Seeker Features

#### Dashboard (`/seeker/dashboard`)
- **Job Recommendations**: Personalized job suggestions
- **Recent Applications**: Track application status
- **Quick Actions**: Search jobs, view applications
- **Statistics**: Application success rate, profile completeness

#### Job Search (`/seeker/search`)
- **Advanced Filters**: Category, location, salary, job type
- **Search Results**: Paginated job listings
- **Job Details**: Full job description, requirements, company info
- **Apply Button**: Direct application submission

#### Applications Management (`/seeker/applications`)
- **Application History**: All submitted applications
- **Status Tracking**: Pending, Reviewed, Accepted, Rejected
- **Application Details**: Cover letter, resume, submission date
- **Withdraw Option**: Cancel pending applications

#### Profile Management (`/seeker/profile`)
- **Personal Information**: Name, email, contact details
- **Professional Summary**: Bio, skills, experience
- **Resume Upload**: PDF document management
- **Skills & Certifications**: Professional qualifications

### 🏢 Employer Features

#### Dashboard (`/employer/dashboard`)
- **Company Overview**: Welcome message with company name
- **Quick Actions**: Post new job, view analytics
- **Metrics**: Total jobs posted, total applicants
- **Recent Jobs**: Latest job postings with applicant counts
- **My Jobs Section**: List of all posted jobs

#### Job Posting (`/employer/post`)
- **Job Information**: Title, category, type, salary range
- **Job Description**: Detailed role description
- **Location**: City and country selection
- **Requirements**: Skills and qualifications needed
- **Additional Info**: Company logo URL
- **Save Draft**: Option to save incomplete postings
- **Publish**: Submit job for public viewing

#### Job Management (`/employer/my-jobs`)
- **Job Listings**: All posted jobs with status
- **Edit Jobs**: Modify job details
- **View Applicants**: See who applied to each job
- **Job Status**: Active/Inactive toggle
- **Delete Jobs**: Remove job postings

#### Applicants Management (`/employer/job/{jobId}/applicants`)
- **Applicant List**: All applications for specific job
- **Applicant Profiles**: Detailed seeker information
- **Resume Viewing**: Download and view resumes
- **Application Status**: Update application status
- **Communication**: Contact applicants directly

#### Company Profile (`/employer/company`)
- **Company Information**: Name, description, industry
- **Contact Details**: Address, phone, website
- **Company Logo**: Upload and manage logo
- **Social Media**: LinkedIn, Twitter profiles

### 👨‍💼 Administrator Features

#### Admin Dashboard (`/admin/panel`)
- **System Overview**: Total users, jobs, applications
- **Pending Approvals**: Users awaiting approval
- **Recent Activity**: Latest registrations, job postings
- **Quick Actions**: Approve users, moderate content

#### User Management (`/admin/users`)
- **User List**: All registered users with roles
- **User Details**: Profile information, registration date
- **Approval Actions**: Approve/reject user registrations
- **User Status**: Active, suspended, pending
- **Bulk Operations**: Mass approve/reject users

#### Job Moderation (`/admin/jobs`)
- **Job Listings**: All posted jobs in the system
- **Job Details**: Full job information and employer details
- **Moderation Actions**: Approve, reject, or flag jobs
- **Content Review**: Check for inappropriate content
- **Employer Information**: View job poster details

#### User Approvals (`/admin/approvals`)
- **Pending Approvals**: Users awaiting admin approval
- **Approval History**: Track approval decisions
- **Bulk Approval**: Approve multiple users at once
- **Rejection Reasons**: Provide feedback for rejections

---

## Technical Implementation

### State Management (Riverpod)
- **Providers**: Centralized state management
- **Stream Providers**: Real-time data updates
- **Family Providers**: Parameterized providers for user-specific data
- **State Notifiers**: Complex state management for forms

### Navigation (GoRouter)
- **Route Guards**: Role-based access control
- **Deep Linking**: Support for direct URL access
- **Nested Navigation**: Tab-based navigation within roles
- **Route Parameters**: Dynamic routing for job/application details

### Firebase Integration
- **Authentication**: Email/password with custom claims
- **Firestore**: Real-time database for jobs, users, applications
- **Cloud Functions**: Server-side logic for email notifications
- **Security Rules**: Role-based data access control

### Email System
- **Gmail SMTP**: Primary email service via Nodemailer
- **Notification Types**:
  - User approval/rejection emails
  - Job posting confirmations
  - Application status updates
  - Weekly digest for job seekers
- **Email Templates**: HTML-formatted notifications

### UI/UX Design
- **Branded Components**: Consistent JobHunt branding
- **Responsive Design**: Mobile-first approach
- **Material Design 3**: Modern UI components
- **Accessibility**: Screen reader support, keyboard navigation

---

## Database Structure

### Collections

#### Users Collection (`users`)
```json
{
  "name": "string",
  "email": "string",
  "role": "job_seeker|employer|admin",
  "approvalStatus": "pending|approved|rejected",
  "companyName": "string", // for employers
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "emailNotifications": "boolean",
  "weeklyDigest": "boolean",
  "instantAlerts": "boolean",
  "jobPostingNotifications": "boolean"
}
```

#### Jobs Collection (`jobs`)
```json
{
  "title": "string",
  "company": "string",
  "category": "string",
  "locationCity": "string",
  "locationCountry": "string",
  "salaryMin": "number",
  "salaryMax": "number",
  "type": "string",
  "logoUrl": "string",
  "description": "string",
  "requirements": ["string"],
  "skills": ["string"],
  "createdAt": "timestamp",
  "employerId": "string",
  "isActive": "boolean",
  "updatedAt": "timestamp"
}
```

#### Applications Collection (`applications`)
```json
{
  "jobId": "string",
  "seekerId": "string",
  "employerId": "string",
  "coverLetter": "string",
  "resumeUrl": "string",
  "status": "pending|reviewed|accepted|rejected",
  "appliedAt": "timestamp",
  "reviewedAt": "timestamp",
  "notes": "string"
}
```

---

## Testing Scenarios

### 1. Complete User Registration Flow
1. **Register as Job Seeker**:
   - Go to `/auth/register`
   - Fill form with job seeker details
   - Submit registration
   - Verify pending approval status

2. **Register as Employer**:
   - Go to `/auth/register`
   - Fill form with employer details
   - Submit registration
   - Verify pending approval status

3. **Admin Approval**:
   - Login as admin (`jobhuntapplication@gmail.com` / `12e12e12e`)
   - Go to `/admin/approvals`
   - Approve both users
   - Verify approval emails sent

4. **PIN Setup**:
   - Login with approved users
   - Set up 4-digit PIN
   - Verify access to role-specific dashboards

### 2. Job Seeker Workflow
1. **Browse Jobs**:
   - Go to `/seeker/search`
   - Use filters to find relevant jobs
   - View job details
   - Apply to jobs

2. **Manage Applications**:
   - Go to `/seeker/applications`
   - View application history
   - Check application status
   - Withdraw applications if needed

3. **Profile Management**:
   - Go to `/seeker/profile`
   - Update personal information
   - Upload resume
   - Add skills and certifications

### 3. Employer Workflow
1. **Post Jobs**:
   - Go to `/employer/post`
   - Fill job posting form
   - Add requirements and skills
   - Publish job

2. **Manage Jobs**:
   - Go to `/employer/my-jobs`
   - View all posted jobs
   - Edit job details
   - Toggle job status

3. **Review Applications**:
   - Go to specific job's applicants page
   - View applicant profiles
   - Download resumes
   - Update application status

### 4. Admin Workflow
1. **User Management**:
   - Go to `/admin/users`
   - View all users
   - Approve/reject pending users
   - Suspend/unsuspend users

2. **Job Moderation**:
   - Go to `/admin/jobs`
   - Review all job postings
   - Moderate inappropriate content
   - Deactivate problematic jobs

3. **System Monitoring**:
   - Go to `/admin/panel`
   - View system analytics
   - Monitor user activity
   - Check system health

---

## Known Issues & Future Enhancements

### Current Limitations
1. **Company Name**: Hardcoded as "EXXSN LTD" in job postings
2. **Resume Upload**: File upload functionality needs implementation
3. **Real-time Chat**: No messaging system between employers and seekers
4. **Advanced Search**: Limited search capabilities
5. **Mobile Optimization**: Some screens need mobile-specific improvements

### Planned Enhancements
1. **Company Profiles**: Dynamic company information management
2. **File Management**: Resume and document upload system
3. **Messaging System**: In-app communication between users
4. **Advanced Analytics**: Detailed reporting for employers
5. **Mobile App**: Native mobile application
6. **API Integration**: Third-party job board integrations
7. **Payment System**: Premium features and job promotion
8. **AI Matching**: Intelligent job-seeker matching

### Technical Debt
1. **Error Handling**: Comprehensive error handling implementation
2. **Loading States**: Improved loading indicators
3. **Offline Support**: Offline functionality for critical features
4. **Performance**: Query optimization and caching
5. **Security**: Enhanced security measures and validation

---

## Development Environment Setup

### Prerequisites
- Flutter SDK (3.0+)
- Firebase CLI
- Node.js (for Cloud Functions)
- Android Studio / VS Code

### Setup Instructions
1. **Clone Repository**: `git clone [repository-url]`
2. **Install Dependencies**: `flutter pub get`
3. **Firebase Setup**: `firebase login && firebase use [project-id]`
4. **Environment Variables**: Configure `.env` file with API keys
5. **Run Application**: `flutter run`

### Firebase Configuration
- **Authentication**: Email/password enabled
- **Firestore**: Database with security rules
- **Cloud Functions**: Deployed for email notifications
- **Storage**: Configured for file uploads

---

## Conclusion

JobHunt represents a comprehensive job portal solution with robust role-based access control, real-time updates, and scalable architecture. The application successfully implements the core features required for a job portal while maintaining clean code structure and user-friendly interface.

The prototype phase demonstrates the viability of the concept and provides a solid foundation for future development phases. The modular architecture allows for easy feature additions and improvements.

**Key Achievements:**
- ✅ Multi-role authentication system
- ✅ Job posting and management
- ✅ Application tracking system
- ✅ Admin approval workflow
- ✅ Email notification system
- ✅ Responsive UI design
- ✅ Real-time data synchronization

**Next Phase Recommendations:**
- Implement file upload system
- Add advanced search capabilities
- Develop messaging system
- Enhance mobile experience
- Add analytics and reporting

---

*This guide provides comprehensive coverage of the JobHunt application. For technical details or specific implementation questions, please refer to the source code or contact the development team.*

**Contact Information:**
- **Project Lead**: Muhammad Milhan
- **Group ID**: S25PROJECT88248 (BC210423055)
- **Email**: bc210423055mmi@vu.edu.pk
- **Supervisor**: Saeed Nasir
