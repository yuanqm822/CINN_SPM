#!/bin/bash
# Make one SPM batch per subject from a template, and write jobs.txt.
#
# In the template batch, write the subject ID as SUBJECT wherever it should change,
# e.g. /scratch5/<user>/<project>/bids/sub-SUBJECT/anat/sub-SUBJECT_T1w.nii
#
# Usage: bash examples/make_batches.sh <template_job.m> <subjects.txt> <output_dir>
set -euo pipefail

TEMPLATE=${1:?Usage: $0 <template_job.m> <subjects.txt> <output_dir>}
SUBJECTS=${2:?Usage: $0 <template_job.m> <subjects.txt> <output_dir>}
OUTDIR=${3:?Usage: $0 <template_job.m> <subjects.txt> <output_dir>}

grep -q SUBJECT "$TEMPLATE" || { echo "No 'SUBJECT' placeholder found in $TEMPLATE" >&2; exit 1; }
mkdir -p "$OUTDIR"
OUTDIR=$(cd "$OUTDIR" && pwd)
: > jobs.txt

name=$(basename "$TEMPLATE" .m)
while read -r SUB; do
    [ -z "$SUB" ] && continue
    SUB=${SUB#sub-}
    out="$OUTDIR/sub-${SUB}_${name}.m"
    sed "s/SUBJECT/${SUB}/g" "$TEMPLATE" > "$out"
    echo "$out" >> jobs.txt
done < "$SUBJECTS"

n=$(wc -l < jobs.txt)
echo "Wrote $n batch files to $OUTDIR and listed them in jobs.txt"
echo "Set '#SBATCH --array=1-$n' in run_spm_batch.sh, then: sbatch run_spm_batch.sh"
