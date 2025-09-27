# Cloudinary Setup Guide

## ✅ **Cloudinary Integration Complete!**

Your app is now configured to use Cloudinary for file storage. Here's what you need to do to make it work:

## 🔧 **Cloudinary Dashboard Setup**

### 1. **Create Cloudinary Account**
- Go to [cloudinary.com](https://cloudinary.com)
- Sign up for a free account
- Get your Cloud Name from the dashboard

### 2. **Configure Upload Presets**
You need to create these upload presets in your Cloudinary dashboard:

#### **For Images (Profile Pictures & Company Logos):**
- **Preset Name**: `jobhunt_images`
- **Signing Mode**: `Unsigned`
- **Folder**: `jobhunt-dev/profile_images` (for profile pics) or `jobhunt-dev/company_logos` (for company logos)
- **Allowed Formats**: `jpg, jpeg, png, gif, webp`
- **Max File Size**: `10MB`

#### **For Documents (CVs):**
- **Preset Name**: `jobhunt_documents`
- **Signing Mode**: `Unsigned`
- **Folder**: `jobhunt-dev/cv_documents`
- **Allowed Formats**: `pdf, doc, docx`
- **Max File Size**: `10MB`

### 3. **Update Cloud Name**
In `lib/core/services/cloudinary_upload_service.dart`, update line 40:
```dart
static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/upload';
```

Replace `YOUR_CLOUD_NAME` with your actual Cloudinary cloud name.

## 📁 **How It Works Now**

### **Profile Pictures:**
- Uploaded to: `jobhunt-dev/profile_images/`
- Public ID: `profile_[user_id]`
- Accessible via Cloudinary CDN

### **CV Documents:**
- Uploaded to: `jobhunt-dev/cv_documents/`
- Public ID: `cv_[user_id]`
- Accessible via Cloudinary CDN

### **Company Logos:**
- Uploaded to: `jobhunt-dev/company_logos/`
- Public ID: `company_logo_[user_id]`
- Accessible via Cloudinary CDN

## 🚀 **Testing**

Once you've set up the presets in Cloudinary:

1. **Profile Picture Upload**: Go to Profile → Upload Photo
2. **CV Upload**: Go to Profile → Upload CV
3. **Company Logo Upload**: Go to Company → Upload Logo

All files will be stored in your Cloudinary account and accessible via secure URLs.

## 🔒 **Security**

- Files are uploaded using unsigned presets (no API keys needed in the app)
- Each user's files are organized by their user ID
- File types and sizes are validated before upload
- All uploads go through Cloudinary's secure infrastructure

## 📱 **Fallback**

If Cloudinary upload fails, the app will show an error message. The upload system is designed to be robust and handle network issues gracefully.

---

**Ready to test!** Set up your Cloudinary presets and try uploading files. They'll be stored in your Cloudinary account and accessible via secure URLs.
