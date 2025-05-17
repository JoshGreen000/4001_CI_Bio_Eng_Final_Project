#!/bin/bash

# Check for subject ID input
if [ -z "$1" ]; then
  echo "❌ Usage: $0 <subject_id>"
  exit 1
fi

# Configuration
SUBJECT_ID="$1"
SUBJECTS_DIR="/home/ubuntu/output/chess"
LOG_FILE="$HOME/Results/${SUBJECT_ID}_vol2surf.log"
OUTPUT_DIR="$SUBJECTS_DIR/$SUBJECT_ID/surf"

# Run mri_vol2surf for both hemispheres in background
for hemi in lh rh; do
  echo "🔄 Starting mri_vol2surf for $SUBJECT_ID ($hemi)" >> "$LOG_FILE"
  
  mri_vol2surf \
    --mov "$SUBJECTS_DIR/$SUBJECT_ID/mri/norm.mgz" \
    --reg "$SUBJECTS_DIR/$SUBJECT_ID/mri/rawavg2orig.lta" \
    --hemi "$hemi" \
    --trgsubject fsaverage \
    --projfrac 0.5 \
    --interp trilinear \
    --o "$OUTPUT_DIR/${hemi}_norm_on_surface.mgh" \
    >> "$LOG_FILE" 2>&1 &
done

echo "✅ mri_vol2surf started in background for both hemispheres of $SUBJECT_ID"

