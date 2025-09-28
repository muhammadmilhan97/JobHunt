# 🔥 Firebase Test Data Creation Guide

## Step 1: Create Required Index
**CLICK THIS LINK FIRST:**
```
https://console.firebase.google.com/v1/r/project/jobhunt-dev-7b0ae/firestore/indexes?create_composite=ClZwcm9qZ�N0cy9qb2JodW50LWRldi03YjBhZS9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvYXBwbGljYXRpb25zL2luZGV4ZXMvXxABGg4KCmVtcGxveWVySWQQARoNCgljcmVhdGVkQXQQAhoMCghfX25hbWVfXxAC
```

## Step 2: Add Test Applications Manually

1. **Go to Firebase Console:** https://console.firebase.google.com/
2. **Select Project:** `jobhunt-dev-7b0ae`
3. **Go to Firestore Database**
4. **Click "Start Collection"** 
5. **Collection ID:** `applications`

### **Add These Test Applications:**

**Application 1:**
```json
{
  "jobId": "YOUR_JOB_ID_HERE", 
  "employerId": "ZdWP1xCoYITJQW8795gTq03FeJ62",
  "jobSeekerId": "test_seeker_1",
  "jobTitle": "Full Stack Developer",
  "employerName": "Your Company Name",
  "cvUrl": "https://example.com/cv1.pdf",
  "coverLetter": "I am very interested in this position and have 3 years of experience.",
  "expectedSalary": 60000,
  "status": "pending",
  "createdAt": "2025-09-28T10:00:00Z",
  "updatedAt": "2025-09-28T10:00:00Z"
}
```

**Application 2:**
```json
{
  "jobId": "YOUR_JOB_ID_HERE",
  "employerId": "ZdWP1xCoYITJQW8795gTq03FeJ62", 
  "jobSeekerId": "test_seeker_2",
  "jobTitle": "Full Stack Developer",
  "employerName": "Your Company Name",
  "cvUrl": "https://example.com/cv2.pdf",
  "coverLetter": "I have strong React and Node.js skills perfect for this role.",
  "expectedSalary": 75000,
  "status": "accepted",
  "createdAt": "2025-09-27T15:30:00Z",
  "updatedAt": "2025-09-28T09:00:00Z"
}
```

**Application 3:**
```json
{
  "jobId": "YOUR_JOB_ID_HERE",
  "employerId": "ZdWP1xCoYITJQW8795gTq03FeJ62",
  "jobSeekerId": "test_seeker_3", 
  "jobTitle": "Full Stack Developer",
  "employerName": "Your Company Name",
  "cvUrl": "https://example.com/cv3.pdf",
  "coverLetter": "Looking forward to contributing to your team's success.",
  "expectedSalary": 55000,
  "status": "rejected",
  "createdAt": "2025-09-26T12:00:00Z",
  "updatedAt": "2025-09-27T14:00:00Z"
}
```

## Step 3: Get Your Job ID

1. **In Firebase Console**, go to `jobs` collection
2. **Find your job document** 
3. **Copy the Document ID** (this is your jobId)
4. **Replace "YOUR_JOB_ID_HERE"** in the applications above

## Step 4: Expected Results

After adding these applications and creating the index:

✅ **Analytics Page:**
- Total Jobs: 1
- Active Jobs: 1  
- Total Applicants: 3
- Pending Applications: 1

✅ **All Applicants Page:**
- Will show 3 applications with different statuses
- Pending, Accepted, Rejected status chips

✅ **Dashboard KPIs:**
- Real application counts
- Working navigation to all pages

## 🚀 Quick Test:
1. Create the Firebase index (link above)
2. Add 2-3 test applications
3. Restart your app
4. Check Analytics and Applicants pages
