#!/bin/bash

# Usage: ./extract_subject_stats_singlecol.sh 0028197

subject_id="$1"
input_dir="$HOME/combined_csv"
output_dir="$HOME/combined_csv"
output_file="${output_dir}/${subject_id}_extracted_stats.csv"

# Files to scan
csv_files=(
    "lh_area.csv"
    "lh_meancurv.csv"
    "lh_thickness.csv"
    "lh_volume.csv"
    "rh_area.csv"
    "rh_meancurv.csv"
    "rh_thickness.csv"
    "rh_volume.csv"
    "aseg_volume.csv"
)

# Initialize output
echo "Metric,Value" > "$output_file"

for file in "${csv_files[@]}"; do
    filepath="${input_dir}/${file}"
    if [[ ! -f "$filepath" ]]; then
        echo "❌ File $filepath not found, skipping."
        continue
    fi

    metric_name="${file%.csv}"

    # Extract the tab-separated header and subject's line
    header=$(head -n 1 "$filepath")
    line=$(grep "^$subject_id" "$filepath")

    if [[ -z "$line" ]]; then
        echo "⚠️ Subject $subject_id not found in $file, skipping."
        continue
    fi

    # Split both into arrays
    IFS=$'\t' read -r -a header_array <<< "$header"
    IFS=$'\t' read -r -a line_array <<< "$line"

    # Align and write
    for i in "${!header_array[@]}"; do
        label="${header_array[i]}"
        value="${line_array[i]}"
        echo "${metric_name}_${label},${value}" >> "$output_file"
    done
done

echo "✅ Finished writing: $output_file"

