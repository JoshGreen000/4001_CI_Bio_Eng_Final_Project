#!/bin/bash

# Define SUBJECTS_DIR and OUTPUT_DIR
SUBJECTS_DIR="${SUBJECTS_DIR:-/home/ubuntu/output/chess}"
OUTPUT_DIR="./combined_csv"
mkdir -p "$OUTPUT_DIR"

echo "🔧 Gathering stats from: $SUBJECTS_DIR"
echo "📁 Necessary CSVs will be in: $OUTPUT_DIR"

# 1. Get only subjects that have all required .stats files
subjects=""
for subjdir in "$SUBJECTS_DIR"/*; do
    subjname=$(basename "$subjdir")
    lh_aparc="$subjdir/stats/lh.aparc.stats"
    rh_aparc="$subjdir/stats/rh.aparc.stats"
    aseg="$subjdir/stats/aseg.stats"

    if [[ -f "$lh_aparc" && -f "$rh_aparc" && -f "$aseg" ]]; then
        subjects+="$subjname "
    fi
done

if [ -z "$subjects" ]; then
    echo "❌ No subjects with all required stats files found."
    exit 1
fi

echo "✅ Subjects to include: $subjects"

# 2. Run FreeSurfer table conversion
convert_table() {
    aparcstats2table --hemi "$1" --meas "$2" --subjects $subjects \
        --tablefile "$OUTPUT_DIR/${1}_${2}.csv"
}

convert_aseg_table() {
    asegstats2table --subjects $subjects --meas volume \
        --tablefile "$OUTPUT_DIR/aseg_volume.csv"
}

convert_table lh thickness
convert_table rh thickness
convert_table lh area
convert_table rh area
convert_table lh volume
convert_table rh volume
convert_table lh meancurv
convert_table rh meancurv
convert_aseg_table

# 3. Merge all CSVs
echo "🔄 Merging CSVs..."
python3 <<EOF
import pandas as pd
import glob
import os

csvs = sorted(glob.glob("./combined_csv/*.csv"))
if not csvs:
    print("❌ No CSVs found. Aborting.")
    exit(1)

dfs = []
print("🔍 Loading CSVs for merge...")

for f in csvs:
    print(f"📄 Processing: {f}")
    try:
        df = pd.read_csv(f)

        # Fix missing header: detect if first row is numeric and columns are garbled
        if df.columns[0].strip().startswith("Measure") or not df.columns[0].lower().startswith("subject"):
            print(f"🛠️ Fixing header in {f}")
            df = pd.read_csv(f, skiprows=1)

        if df.empty:
            print(f"⚠️ Skipping empty file: {f}")
            continue

        dfs.append(df)
    except Exception as e:
        print(f"❌ Failed to load {f}: {e}")

# Verify we have valid dataframes
if not dfs:
    print("❌ No valid CSVs to merge. Exiting.")
    exit(1)

# Merge on subject ID column (assumed to be first column)
merged = dfs[0]
for df in dfs[1:]:
    try:
        merged = pd.merge(merged, df, on=merged.columns[0], how='inner')
    except Exception as e:
        print(f"⚠️ Merge failed with file, skipping: {e}")

# Show subject list included in final merged file
subjects_col = merged.columns[0]
subject_list = merged[subjects_col].tolist()
print(f"\n🧠 Subjects included in final merged data: {subject_list}")

# Save the merged file
merged.to_csv("./combined_csv/master_features.csv", index=False)
print("✅ Master CSV saved at ./combined_csv/master_features.csv")
EOF

