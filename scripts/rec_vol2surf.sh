#!/bin/bash

# Input and output paths
INPUT_DIR="/home/ubuntu/chessdata/imaging_data_ctrl"
export SUBJECTS_DIR="/home/ubuntu/output/chess"

# Optional recon-all flags
RECON_FLAGS="-all -fix-ento-wm -transfer-base-bfs -fix-vsinus -fix-mca-dura -fix-ga -fix-acj -synthstrip -synthseg -synthmorph"

# Max parallel jobs
MAX_JOBS=3

run_recon_and_vol2surf() {
    subject=$1
    input_img="$INPUT_DIR/$subject/anat_1/anat.nii.gz"
    log_file="$HOME/Results/${subject}_results_recon.txt"

    echo "🔁 Starting recon-all for $subject" | tee -a "$log_file"

    recon-all -s "$subject" -i "$input_img" $RECON_FLAGS >> "$log_file" 2>&1

    if [[ $? -eq 0 ]]; then
        echo "✅ recon-all done for $subject. Running mri_vol2surf..." | tee -a "$log_file"
        for hemi in lh rh; do
            mri_vol2surf --trgsubject "$subject" \
                         --mov "$SUBJECTS_DIR/$subject/mri/norm.mgz" \
                         --reg "$SUBJECTS_DIR/$subject/mri/rawavg2orig.lta" \
                         --hemi "$hemi" \
                         --o "$SUBJECTS_DIR/$subject/surf/${hemi}.norm_on_surface.mgh" \
                         --projfrac 0.5 >> "$log_file" 2>&1
        done
        echo "✅ mri_vol2surf complete for $subject" | tee -a "$log_file"
    else
        echo "❌ recon-all failed for $subject" | tee -a "$log_file"
    fi
}

# Track number of parallel jobs
job_count=0

for subject_path in "$INPUT_DIR"/*; do
    subject=$(basename "$subject_path")

    if [[ -f "$SUBJECTS_DIR/$subject/scripts/recon-all.done" ]]; then
        echo "⏭️  Skipping $subject: recon-all already done"
        continue
    fi

    run_recon_and_vol2surf "$subject" &
    
    ((job_count++))
    if [[ "$job_count" -ge "$MAX_JOBS" ]]; then
        wait
        job_count=0
    fi
done

wait
echo "🎉 All jobs finished."

