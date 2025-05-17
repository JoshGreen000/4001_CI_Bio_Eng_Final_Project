#!/bin/bash

export FSLDIR=/usr/local/fsl
source $FSLDIR/etc/fslconf/fsl.sh
export PATH=$FSLDIR/bin:$PATH

INPUT_DIR="/home/ubuntu/chessdata/imaging_data_ctrl"
OUTPUT_DIR="/home/ubuntu/output/emotion_chess"
MNI_TEMPLATE="$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz"
MAX_JOBS=3

mkdir -p "$OUTPUT_DIR"
job_count=0

process_subject() {
    subj=$1
    subj_path="$INPUT_DIR/$subj"
    bold_file=$(find "$subj_path/rest_1" -type f \( -name '*bold.nii' -o -name 'rest.nii*' \) | head -n 1)

    if [[ ! -f "$bold_file" ]]; then
        echo "❌ No BOLD file found for $subj"
        return
    fi

    out_dir="$OUTPUT_DIR/$subj"
    lh_surf="$out_dir/lh.bold_on_fsaverage.mgh"
    rh_surf="$out_dir/rh.bold_on_fsaverage.mgh"

    lh_stats="$out_dir/lh_fsavg_segstats.txt"
    rh_stats="$out_dir/rh_fsavg_segstats.txt"

    if [[ -f "$lh_surf" && -f "$rh_surf" && -f "$lh_stats" && -f "$rh_stats" ]]; then
        echo "⏩ $subj already fully processed. Skipping."
        return
    fi

    echo "🔄 Processing $subj"
    mkdir -p "$out_dir"

    # Preprocessing pipeline
    fslmaths "$bold_file" -mul 1 "$out_dir/bold_float.nii.gz"
    slicetimer -i "$out_dir/bold_float.nii.gz" -o "$out_dir/bold_st.nii.gz"
    mcflirt -in "$out_dir/bold_st.nii.gz" -out "$out_dir/bold_moco.nii.gz"
    bet "$out_dir/bold_moco.nii.gz" "$out_dir/bold_brain.nii.gz" -F -f 0.3
    flirt -in "$out_dir/bold_brain.nii.gz" -ref "$MNI_TEMPLATE" \
          -out "$out_dir/bold_mni.nii.gz" -omat "$out_dir/bold2mni.mat"

    export SUBJECTS_DIR="/home/ubuntu/output/chess"

    for hemi in lh rh; do
        mri_vol2surf --mov "$out_dir/bold_mni.nii.gz" \
                     --regheader fsaverage \
                     --hemi "$hemi" \
                     --trgsubject fsaverage \
                     --o "$out_dir/${hemi}.bold_on_fsaverage.mgh" \
                     --projfrac 0.5
    done

    for hemi in lh rh; do
	# annot_path="fsaverage/label/${hemi}.aparc.annot"
	# Take out surf if files do not exist.
	mri_segstats \
		--annot fsaverage ${hemi} aparc \
  		--i "$out_dir/${hemi}.bold_on_fsaverage.mgh" \
  		--sum "$out_dir/${hemi}_fsavg_segstats.txt"  
    done

    if [[ ! -f "$lh_stats" || ! -f "$rh_stats" ]]; then
        echo "⚠️ Incomplete stats for $subj" >&2
    fi


    echo "✅ Finished $subj"
}

# Main loop with parallel control
for subj_path in "$INPUT_DIR"/0028*; do
    subj=$(basename "$subj_path")

    process_subject "$subj" > "$HOME/Results/${subj}-bold-preprocess.log" 2>&1 &

    ((job_count++))
    if [[ "$job_count" -ge "$MAX_JOBS" ]]; then
        wait
        job_count=0
    fi
done

wait
echo "🎉 All subjects preprocessed in parallel."

