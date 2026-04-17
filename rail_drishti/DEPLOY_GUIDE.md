# 🚆 Rail Drishti — Full Deploy Guide

---

## ✅ PART 1 — Run Locally on Windows (Fixed)

### The correct way on Windows PowerShell

Open PowerShell inside the `rail_drishti/` folder and run:

```powershell
# Option A — Use the new start script (easiest)
.\start_windows.ps1
```

If PowerShell blocks scripts, run this first (one time only):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Then open:** http://localhost:8000/app

---

### Manual steps (if script doesn't work)

```powershell
# Step 1 — Create venv (only first time)
python -m venv venv

# Step 2 — Activate venv
.\venv\Scripts\activate

# Step 3 — Install packages
pip install -r backend\requirements.txt

# Step 4 — Set env variable AND start (two separate lines)
$env:RAILWAYS_DATA_DIR = "./data"
python -m uvicorn backend.app:app --host 0.0.0.0 --port 8000 --reload
```

**Wait for:** `System ready` in terminal (takes 60–120 seconds first time)

**Then open:** http://localhost:8000/app

---

## 🌐 PART 2 — Deploy on Render (Free, No Credit Card)

Render is the easiest free hosting platform. Your app will be live at a public URL like `https://rail-drishti.onrender.com`

### Step 1 — Push to GitHub

You need a GitHub account. Go to https://github.com → New Repository → name it `rail-drishti` → Create.

Then in PowerShell inside `rail_drishti/`:

```powershell
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/rail-drishti.git
git push -u origin main
```

> ⚠️ The data files are large (79MB + 16MB). GitHub has a 100MB file limit.
> If push fails, see the **"Large Files Fix"** section below.

---

### Step 2 — Deploy on Render

1. Go to https://render.com → Sign up (free)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub account → Select the `rail-drishti` repo
4. Fill in these settings:

| Field | Value |
|---|---|
| Name | rail-drishti |
| Region | Singapore (closest to India) |
| Branch | main |
| Runtime | **Docker** |
| Instance Type | **Free** |

5. Click **"Advanced"** → Add environment variables:

| Key | Value |
|---|---|
| `RAILWAYS_DATA_DIR` | `/app/data` |
| `PYTHONPATH` | `/app/backend` |

6. Click **"Create Web Service"**

Render will now build your Docker image (takes 5–10 minutes first time).

**Your live URL:** `https://rail-drishti.onrender.com/app`

---

### ⚠️ Large Files Fix (GitHub 100MB limit)

`schedules.json` is 79MB — GitHub may reject it. Fix:

**Option A — Use Git LFS (recommended)**

```powershell
# Install Git LFS first: https://git-lfs.com
git lfs install
git lfs track "data/schedules.json"
git lfs track "data/Train_details_22122017.csv"
git add .gitattributes
git add .
git commit -m "Add large files via LFS"
git push
```

**Option B — Add data files to .gitignore and use Render disk**

Edit `.gitignore` and add:
```
data/schedules.json
data/Train_details_22122017.csv
```

Then on Render:
1. Go to your service → **"Disks"** tab
2. Add a disk: Mount path `/app/data`, size 2 GB
3. SSH into the Render shell and upload files manually

---

## 🐳 PART 3 — Deploy with Docker on Any VPS

If you have any Linux server (DigitalOcean, Hostinger, AWS EC2):

```bash
# 1. SSH into server
ssh root@your-server-ip

# 2. Install Docker (one time)
curl -fsSL https://get.docker.com | sh

# 3. Upload project from your local machine (run this locally)
scp -r rail_drishti root@your-server-ip:/root/

# 4. SSH back and run
ssh root@your-server-ip
cd rail_drishti
docker compose up -d --build

# 5. Check status
docker compose ps
curl http://localhost:8000/health
```

**Your app runs at:** `http://your-server-ip:8000/app`

### Keep it running after reboot

The `docker-compose.yml` already has `restart: unless-stopped` — your app will auto-restart after server reboots.

---

## 🔍 PART 4 — Verify Everything Works

After deploying, test these URLs:

```
http://your-url/health                              → {"status":"ok","loaded":true}
http://your-url/api/user/train-info?train_no=12301  → Train data JSON
http://your-url/api/admin/operational-dashboard     → System stats
http://your-url/docs                                → Swagger API docs
http://your-url/app                                 → Frontend UI
```

---

## ❓ Common Problems & Fixes

| Problem | Fix |
|---|---|
| `Cannot run script` on PowerShell | Run: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| `RAILWAYS_DATA_DIR not recognized` | Use TWO separate lines: first `$env:RAILWAYS_DATA_DIR="./data"`, then the uvicorn command |
| Site not loading after deploy | Wait 2–3 minutes — Render free tier has a cold start delay |
| `{"loaded":false}` from `/health` | Data is still loading — wait 60–90 more seconds |
| GitHub push rejected (file too large) | Use Git LFS for `schedules.json` and `Train_details_22122017.csv` |
| Render build fails | Check build logs in Render dashboard → usually a missing data file |
| `ModuleNotFoundError` | Make sure venv is activated: `.\venv\Scripts\activate` |
