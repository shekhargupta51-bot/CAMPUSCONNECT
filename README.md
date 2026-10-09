# CampusConnect — Full-Stack Academic Portal

**CampusConnect** is a full-stack academic web application built with **React**, **Vite**, **Tailwind CSS**, and **Firebase** (Authentication, Cloud Firestore, Cloud Storage, and Security Rules). It enables Administrators, Professors, and Students to interact across courses with live multi-device synchronization and role-based access control.

---

## 🚀 Quick Start Guide

### 1. Installation & Running Locally
```powershell
# In the project directory (d:\campus connect):
npm install

# Start the Vite local development server:
npm run dev
```
Open **[http://localhost:5173](http://localhost:5173)** in your browser.

---

## 🔒 Role-Based Access Control (RBAC) & Personas

The application supports three distinct roles with enforced security boundaries:

| Role | Permissions & Capabilities |
| :--- | :--- |
| **Administrator** | Creates courses, assigns faculty instructors, manages student enrolments, provisions user accounts, broadcasts school-wide bulletins, and manages database seeding. |
| **Professor (Faculty)** | Manages assigned courses, uploads learning resources to Cloud Storage, creates assignments, collects & grades student submissions with written feedback, and records attendance sessions. |
| **Student (Learner)** | Accesses enrolled courses, downloads study material, submits project links or files to Cloud Storage, tracks attendance % ($<75\%$ exam eligibility warnings), and views published marks & feedback. |

### Demo Accounts for Fast Evaluation:
1. **Administrator:** `Dr. Arthur Pendelton` (`admin@campusconnect.edu` • Dean of Academic Computing)
2. **Professor 1:** `Dr. Evelyn Vance` (`e.vance@campusconnect.edu` • Distributed Systems & Cloud Native)
3. **Professor 2:** `Prof. Marcus Chen` (`m.chen@campusconnect.edu` • Database Architecture & Algorithms)
4. **Student 1:** `Alex Rivera` (`CS2023-042` • Semester 6 • CGPA 3.88)
5. **Student 2:** `Priya Sharma` (`CS2023-088` • Semester 6 • CGPA 3.94)
6. **Student 3:** `Jordan Lee` (`CS2023-115` • Semester 6 • CGPA 3.62)

*You can swap between accounts in 1 click using the **"Role" pill** in the top navigation bar or the **Login Page**.*

---

## ☁️ Step-by-Step Firebase Backend Setup Guide (Beginner Friendly)

If you want to connect CampusConnect to your own live Firebase project for multi-device synchronization:

### Step 1: Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **"Add project"**, name it (e.g. `campusconnect-live`), and follow the prompts (Google Analytics is optional).

### Step 2: Register a Web App
1. In your Firebase Project Overview page, click the **Web icon (`</>`)** to add an app.
2. Enter an app nickname (e.g. `CampusConnect Web`) and click **Register app**.
3. Firebase will display your `firebaseConfig` object containing:
   - `apiKey`
   - `authDomain`
   - `projectId`
   - `storageBucket`
   - `messagingSenderId`
   - `appId`

### Step 3: Configure Environment Variables
Create a file named `.env` in the root of the project (`d:\campus connect\.env`) and copy the keys:
```env
VITE_FIREBASE_API_KEY=AIzaSy...your-api-key...
VITE_FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your-project-id
VITE_FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=123456789012
VITE_FIREBASE_APP_ID=1:123456789012:web:...
```
*(Alternatively, you can click **"Cloud Status"** in the Administrator Dashboard within the app and paste the credentials directly without editing files).*

### Step 4: Enable Authentication
1. In the Firebase Console sidebar, go to **Build $\rightarrow$ Authentication**.
2. Click **Get Started**, select **Email/Password** under Sign-in methods, enable **Email/Password**, and click **Save**.

### Step 5: Enable Cloud Firestore Database
1. In the sidebar, go to **Build $\rightarrow$ Firestore Database**.
2. Click **Create database**, choose a location (e.g. `nam5 (us-central)` or `asia-south1`), and start in **Production mode**.
3. Go to the **Rules** tab, paste the contents of [`firestore.rules`](file:///d:/campus%20connect/firestore.rules), and click **Publish**.

### Step 6: Enable Cloud Storage
1. In the sidebar, go to **Build $\rightarrow$ Storage**.
2. Click **Get Started**, choose your bucket location, and finish.
3. Go to the **Rules** tab, paste the contents of [`storage.rules`](file:///d:/campus%20connect/storage.rules), and click **Publish**.

### Step 7: 1-Click Firestore Database Seeding
1. Sign in as **Dr. Arthur Pendelton (Administrator)** or open **[http://localhost:5173](http://localhost:5173)**.
2. Go to the **Cloud Backend & Data Seeder** tab in the Administrator Portal.
3. Click **"Seed Live Firestore"**. In seconds, all standard courses, lecture notes, assignments, attendance logs, and sample marks will be written directly to your Cloud Firestore collections!

---

## 🛡️ Security Architecture & Anti-Tampering Rules

CampusConnect implements defense-in-depth security:

1. **Strict Role Verification:**
   - Public user sign-ups are strictly hardcoded to the `student` role in both client code and Firestore security rules.
   - Users **cannot elevate their own privileges** or assign themselves professor/admin roles via browser console or network payloads.
   - Professors and Administrators can only be provisioned by authenticated Administrators.

2. **Isolated Student Data:**
   - Students can **only** read and write their own submissions and attendance records (`request.auth.uid == studentId`).
   - Unpublished grades and other students' submissions are rejected by Firestore security rules.

3. **Course Assignment Boundaries:**
   - Professors can only create assignments, record attendance, and publish grades for subjects where they are the officially assigned instructor (`subject.professorId == request.auth.uid`).

4. **Storage File Size & Type Validation:**
   - Cloud Storage rules restrict file uploads to $\le 25\text{MB}$ and prevent students from overwriting another student's submission directory.

---

## 📁 Database Schema Reference

- **`users`**: `{ uid, name, email, role, department, designation/rollNumber, semester, cgpa, office, officeHours, createdAt }`
- **`subjects`**: `{ id, code, title, professorId, credits, schedule, room, description, enrolledStudentIds, createdBy, createdAt }`
- **`resources`**: `{ id, subjectId, title, category, description, uploadedBy, uploadedAt, fileType, fileSize, downloadUrl, storagePath, externalLink }`
- **`assignments`**: `{ id, subjectId, title, description, dueDate, maxMarks, weightage, createdBy, createdAt, attachmentName, attachmentSize }`
- **`submissions`**: `{ id, assignmentId, studentId, submissionType, submissionUrl, fileName, fileSize, storagePath, downloadUrl, comments, submittedAt, status, marks, maxMarks, feedback, gradedBy, gradedAt }`
- **`attendance_sessions`**: `{ id, subjectId, date, topic, conductedBy, records: { [studentId]: 'present' | 'absent' | 'late' }, updatedAt }`
- **`marks`**: `{ id, subjectId, studentId, assessmentName, category, scoredMarks, maxMarks, weightage, date, feedback, publishedBy, publishedAt }`
- **`announcements`**: `{ id, title, subjectId, authorId, authorName, authorRole, priority, pinned, publishedAt, content }`

---

## 🛠️ Testing & Verification Walkthrough

You can test full end-to-end workflows across roles:

1. **Admin Provisions Course & Enrolment:**
   - Switch to Administrator (`Dr. Arthur Pendelton`).
   - Go to *Curriculum & Accounts* $\rightarrow$ Click **"New Course"** $\rightarrow$ Create course `CS405: Compiler Design` $\rightarrow$ Click **"Manage Enrolment"** and enroll student *Alex Rivera*.

2. **Professor Creates Assignment & Uploads Slides:**
   - Switch to Professor (`Dr. Evelyn Vance`).
   - Go to *Assignments & Submissions* $\rightarrow$ Click **"Create New Assignment"**.
   - Go to *Notes & Learning Material* $\rightarrow$ Click **"Upload New Material"** $\rightarrow$ Attach a slide deck file with live upload progress.

3. **Student Submits Assignment:**
   - Switch to Student (*Alex Rivera* or *Jordan Lee*).
   - Go to *Assignments & Projects* $\rightarrow$ Click **"Submit Project"** $\rightarrow$ Paste GitHub URL or attach file $\rightarrow$ Confirm.

4. **Professor Grades Submission:**
   - Switch back to Professor (`Dr. Evelyn Vance`).
   - Open *Assignments & Submissions* $\rightarrow$ Click **"View Submissions"** on the assignment $\rightarrow$ Click **"Score & Feedback"** $\rightarrow$ Enter score (e.g. `95/100`) and written critique $\rightarrow$ Publish.

5. **Student Inspects Feedback & Attendance:**
   - Switch to Student (*Alex Rivera*).
   - Go to *Marks & Feedback* to verify the newly published score and professor comments.
   - Go to *Attendance Record* to check real-time attendance percentage and safety indicators.

---

## 📦 Production Build & Deployment

To bundle the application for production deployment (Firebase Hosting, Vercel, Netlify):

```powershell
# Build production bundle
npm run build

# Preview production build locally
npm run preview

# Deploy to Firebase Hosting (requires firebase-tools)
firebase deploy
```
