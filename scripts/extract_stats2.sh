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
combined_header = ["subject_id"]

print("🔍 Loading CSVs for merge...")
for path in csvs:
    name = os.path.basename(path).replace(".csv", "")

    try:
        raw = pd.read_csv(path,sep="\t", dtype=str, engine="python")
        # rows = raw[0].str.split("\t", expand=True)

        # if rows.shape[1] < 2:
            # raise ValueError(f"{path} did not split into expected columns")

        header = raw.columns[1:]
        header = [f"{name}_{col.strip()}" for col in header]
        columns = ["subject_id"] + header

        df = raw.copy()
        df.columns = columns
        # df.reset_index(drop=True, inplace=True)
        df["subject_id"] = df["subject_id"].astype(str).str.zfill(7)

        dfs.append((name, df))

    except Exception as e:
        print(f"❌ Error processing file '{path}': {e}")
        print("🔎 First row content:")
        try:
            print(raw.iloc[0, 0])
        except Exception:
            print("⚠️ Unable to print first row.")
        continue

# Merge all on subject_id with diagnostics
merged_name, merged = dfs[0]
for next_name, df in dfs[1:]:
    try:
        before_subjects = set(merged["subject_id"])
        next_subjects = set(df["subject_id"])

        merged = pd.merge(merged, df, on="subject_id", how="inner")
        after_subjects = set(merged["subject_id"])

        lost_subjects = before_subjects - after_subjects
        if lost_subjects:
            print(f"⚠️ Merge with file '{next_name}.csv' dropped {len(lost_subjects)} subjects:")
            for sid in sorted(lost_subjects):
                print(f"   ⛔ {sid}")

    except Exception as e:
        print(f"❌ Merge failed with '{next_name}.csv', skipping: {e}")

# Final Subjects
subject_list = merged["subject_id"].tolist()
print(f"\n🧠 Subjects included in final merged data: {subject_list}")

# Save final output
merged.to_csv("./combined_csv/master_features.csv", index=False)
print("✅ Master CSV saved at ./combined_csv/master_features.csv")
EOF

