# Admin Setup Guide for JobHunt

## Method 1: Firebase Console + Manual Setup (Recommended for first admin)

### Step 1: Create Admin User in Firebase Authentication
1. Go to your Firebase Console
2. Navigate to **Authentication** > **Users**
3. Click **Add User**
4. Enter admin email and password (e.g., `admin@jobhunt.com`)
5. Click **Add User**

### Step 2: Set Admin Role in Firestore
1. Go to **Firestore Database**
2. Navigate to the `users` collection
3. Find the document with the admin user's UID
4. If it doesn't exist, create it with these fields:
   ```json
   {
     "email": "admin@jobhunt.com",
     "name": "Admin User",
     "role": "admin",
     "createdAt": [current timestamp],
     "updatedAt": [current timestamp],
     "emailNotifications": true,
     "weeklyDigest": false,
     "instantAlerts": false,
     "jobPostingNotifications": false
   }
   ```
5. If it exists, update the `role` field to `"admin"`

### Step 3: Set Custom Claims (Optional but recommended)
This requires Firebase Functions. Run this in your Firebase Functions environment:
```javascript
// In Firebase Functions console or via admin SDK
const admin = require('firebase-admin');
admin.auth().setCustomUserClaims('USER_UID_HERE', { role: 'admin' });
```

### Step 4: Test Admin Access
1. Sign in to your app with the admin credentials
2. Navigate to `/admin/panel` route
3. Verify admin dashboard loads correctly

## Method 2: Programmatic Admin Creation (For additional admins)

Use the admin creation function we'll implement in the app.

## Security Notes
- Admin role should only be set manually or by existing admins
- Consider implementing admin invitation system for production
- Regular registration flow blocks admin role creation for security
