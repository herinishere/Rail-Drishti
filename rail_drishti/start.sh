#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Rail Drishti — Start Script
# Starts the FastAPI backend; frontend served as static HTML
# ─────────────────────────────────────────────────────────────────────────────

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$PROJECT_DIR/backend"
DATA_DIR="$PROJECT_DIR/data"

echo ""
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║         RAIL DRISHTI — STARTUP SEQUENCE                  ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo ""

# ── Check Python ─────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo "  ✗ Python 3 not found. Install Python 3.10+ and retry."
  exit 1
fi
PYTHON=$(command -v python3)
echo "  ✓ Python: $($PYTHON --version)"

# ── Check data files ─────────────────────────────────────────────────────────
REQUIRED_FILES=(
  "stations.json"
  "schedules.json"
  "Train_details_22122017.csv"
  "train_delay_data.csv"
)

echo ""
echo "  Checking data files…"
MISSING=0
for f in "${REQUIRED_FILES[@]}"; do
  if [ -f "$DATA_DIR/$f" ]; then
    SIZE=$(du -sh "$DATA_DIR/$f" 2>/dev/null | cut -f1)
    echo "  ✓ $f  ($SIZE)"
  else
    echo "  ✗ MISSING: $f"
    MISSING=1
  fi
done

if [ "$MISSING" -eq 1 ]; then
  echo ""
  echo "  ERROR: Place missing data files in the data/ directory."
  exit 1
fi

# ── Install Python dependencies ───────────────────────────────────────────────
echo ""
echo "  Installing/checking Python dependencies…"
$PYTHON -m pip install --quiet -r "$BACKEND_DIR/requirements.txt"
echo "  ✓ Dependencies ready"

# ── Start backend ─────────────────────────────────────────────────────────────
echo ""
echo "  Starting FastAPI backend on http://localhost:8000 …"
echo ""
echo "  ┌─────────────────────────────────────────────────────────┐"
echo "  │  Backend API :  http://localhost:8000                   │"
echo "  │  API Docs    :  http://localhost:8000/docs              │"
echo "  │  Frontend    :  Open frontend/index.html in browser     │"
echo "  │  (or serve frontend with: python3 -m http.server 3000   │"
echo "  │   from the frontend/ directory)                         │"
echo "  └─────────────────────────────────────────────────────────┘"
echo ""

cd "$BACKEND_DIR"
RAILWAYS_DATA_DIR="$DATA_DIR" $PYTHON -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
