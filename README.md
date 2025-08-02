# SangSeqFuse

**SangSeqFuse** is a lightweight Bash script that converts forward and reverse Sanger sequencing trace files (`.ab1`) into a consensus FASTA sequence. It performs sequence extraction, reverse complementing, pair-wise alignment, and consensus generation, all in one command-line tool. Popular tools like CAP3 or Phred/Phrap/Consed for creating consensus sequences can often be overly strict or complex for basic Sanger read merging, especially when dealing with short, noisy reads or small-scale sequencing. This tool fixes that problem, especially if the goal to simply create a consensus sequence for performing nBLAST or for building phylogenetic trees.

---

## Features

- Accepts `.ab1` Sanger sequencing trace files (forward and reverse)
- Converts to FASTA using Biopython
- Reverse-complements the reverse strand using **EMBOSS seqret**
- Aligns reads using **MAFFT**
- Generates a consensus sequence using **EMBOSS cons**
- Saves intermediate files and final output in organized directories

---

## Requirements

Make sure the following tools are installed and accessible in your `$PATH`:

| Tool        | Description                              |
|-------------|------------------------------------------|
| [mafft](https://mafft.cbrc.jp/alignment/software/)     | Multiple sequence alignment              |
| [cons](https://www.bioinformatics.nl/cgi-bin/emboss/help/cons)      | EMBOSS tool to generate consensus        |
| [seqret](https://www.bioinformatics.nl/cgi-bin/emboss/help/seqret)    | EMBOSS tool for sequence transformation  |
| [biopython](https://biopython.org/)   | for parsing |

---
 
## Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/demboc/sangseqfuse
cd sangseqfuse
chmod +x sangseqfuse.sh
```
---

## Usage

Make sure to have your sequences located in the same directory as sangseqfuse.sh or you can have sangseqfuse.sh installed in your $PATH

```bash
./sangseqfuse.sh --forward F.ab1 --reverse R.ab1 --prefix Sample1 --output myconsensus.fasta
```
Parameters

| Flag              | Description                                 |
| ----------------- | ------------------------------------------- |
| `-f`, `--forward` | Path to the forward `.ab1` file             |
| `-r`, `--reverse` | Path to the reverse `.ab1` file             |
| `-p`, `--prefix`  | Prefix for intermediate/final file labeling (this will also be your fasta header)|
| `-o`, `--output`  | Name of the output consensus FASTA file     |
| `-h`, `--help`    | Show usage information                      |


