#!/bin/bash

# Script: sangseqfuse.sh
# Description: Converts forward and reverse Sanger sequencing (.ab1) files into a consensus FASTA sequence.
# Output: Final consensus is stored in consensus/<prefix>/, and all intermediate files are retained in <prefix>_temp/
# Usage:
#   ./sangseqfuse.sh --forward F.ab1 --reverse R.ab1 --prefix Sample1 --output consensus.fasta

set -e

# Parsing Flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--forward) FORWARD_AB1="$2"; shift ;;
        -r|--reverse) REVERSE_AB1="$2"; shift ;;
        -p|--prefix) PREFIX="$2"; shift ;;
        -o|--output) OUTPUT_FASTA="$2"; shift ;;
        -h|--help)
            echo "Usage: $0 -f <forward.ab1> -r <reverse.ab1> -p <prefix> -o <output.fasta>"
            echo "Example: ./sangseqfuse.sh --forward F.ab1 --reverse R.ab1 --prefix Sample1 --output consensus.fasta"
            echo "<prefix> will also be set as your sequence header
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Validating Required Inputs
if [[ -z "$FORWARD_AB1" || -z "$REVERSE_AB1" || -z "$PREFIX" || -z "$OUTPUT_FASTA" ]]; then
    echo "Missing required arguments."
    echo "Use -h or --help for usage."
    exit 1
fi

# Check Dependancies
for cmd in mafft cons seqret; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd not found. Please install EMBOSS and MAFFT."
        exit 1
    fi
done

# Create Temporary Directory
TMP_DIR="intemediates/${PREFIX}"
mkdir -p "$TMP_DIR"
mkdir -p "$(dirname "$OUTPUT_FASTA")" 2>/dev/null || true

# Actual Process
# Step 1: Convert .ab1 to .fasta using Biopython
python3 - <<EOF
from Bio import SeqIO
SeqIO.convert("$FORWARD_AB1", "abi", "$TMP_DIR/${PREFIX}_forward.fasta", "fasta")
SeqIO.convert("$REVERSE_AB1", "abi", "$TMP_DIR/${PREFIX}_reverse_raw.fasta", "fasta")
EOF

# Step 2: Rename headers
sed -i "s/^>.*/>${PREFIX}_forward/" "$TMP_DIR/${PREFIX}_forward.fasta"
sed -i "s/^>.*/>${PREFIX}_reverse/" "$TMP_DIR/${PREFIX}_reverse_raw.fasta"

# Step 3: Reverse-complement the reverse read
seqret -sequence "$TMP_DIR/${PREFIX}_reverse_raw.fasta" \
       -outseq "$TMP_DIR/${PREFIX}_reversecomplement.fasta" \
       -sreverse Y

# Step 4: Concatenate both sequences
cat "$TMP_DIR/${PREFIX}_forward.fasta" "$TMP_DIR/${PREFIX}_reversecomplement.fasta" > "$TMP_DIR/${PREFIX}_combined.fasta"

# Step 5: MAFFT alignment
mafft --quiet --adjustdirection "$TMP_DIR/${PREFIX}_combined.fasta" > "$TMP_DIR/${PREFIX}_aligned.fasta"

# Step 6: Generate consensus
cons -sequence "$TMP_DIR/${PREFIX}_aligned.fasta" \
     -outseq "$TMP_DIR/${PREFIX}_rawcons.fasta" \
     -name "$PREFIX"

# Step 7: Final formatting
FINAL_DIR="consensus/${PREFIX}"
mkdir -p "$FINAL_DIR"

TEMP_CONSENSUS="$TMP_DIR/${PREFIX}_rawcons.fasta"
FORMATTED_CONSENSUS="$TMP_DIR/${PREFIX}_consensus_final.fasta"
sed '/^>/!s/[a-z]/\U&/g' "$TEMP_CONSENSUS" > "$FORMATTED_CONSENSUS"

# Step 8: Move final consensus to output directory
FINAL_OUTPUT_PATH="${FINAL_DIR}/$(basename "$OUTPUT_FASTA")"
mv "$FORMATTED_CONSENSUS" "$FINAL_OUTPUT_PATH"

echo "Consensus sequence saved to: $FINAL_OUTPUT_PATH"
echo "All intermediate files saved in: $TMP_DIR"
