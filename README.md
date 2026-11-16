# Running SPM on RACC (CINN)

SPM is installed on RACC (University of Reading) as a CINN module: the **standalone**
SPM26 from Neurodesk, compiled with the free MATLAB Runtime and run through Transparent
Singularity. You do **not** need MATLAB or a MATLAB licence, and there is nothing to
install yourself.

| Tool | Module | Command |
|------|--------|---------|
| SPM26 (standalone) | `spm26/26.10.01` | `spm26` |

> Standalone SPM runs SPM's own functions and batches. It cannot be called from inside
> your own MATLAB scripts (`addpath(spm)`); for that you need SPM's source code with
> MATLAB — ask Simon if you need this.

---

## 1. One-time setup

Add this line to the end of your `~/.bashrc` (skip if you already have it from the
fMRIPrep guide):

```bash
module use /software/modules/CINN
```

Then:

```bash
source ~/.bashrc
module load spm26/26.10.01
spm26 --version
```

## 2. Check it works

`examples/spm_test.m` prints the SPM version and reads SPM's own template image:

```bash
git clone https://github.com/yuanqm822/CINN_SPM.git
cd CINN_SPM
module load spm26/26.10.01
spm26 script examples/spm_test.m
```

## 3. Ways to run SPM

| What | Command |
|------|---------|
| A saved batch (from the Batch Editor, *File → Save Batch*, as `.m`) | `spm26 batch job.m` |
| A MATLAB script using SPM functions | `spm26 script myscript.m` |
| A single command | `spm26 eval "disp(spm('Ver'))"` |
| The GUI (needs `ssh -X`, slow over a remote connection) | `spm26 fmri` |

A practical workflow: build and save one subject's batch in the GUI (on RACC with
`ssh -X`, or on your own computer with the same SPM version), then run it for every
subject as jobs on the cluster.

## 4. Running batches as Slurm jobs

`run_spm_batch.sh` runs one batch file per array task, so many subjects run in
parallel. List your batch files, one per line, in `jobs.txt`:

```
/scratch5/<user>/<project>/batches/sub-101_preproc_job.m
/scratch5/<user>/<project>/batches/sub-102_preproc_job.m
```

Set `#SBATCH --array=1-N` (N = number of lines in `jobs.txt`), then:

```bash
mkdir -p logs
sbatch run_spm_batch.sh
```

### One batch for many subjects

Rather than saving a batch per subject, keep one **template** batch and let the job
fill in the subject. `examples/make_batches.sh` copies a template, replacing the text
`SUBJECT` with each subject ID from `subjects.txt`, and writes `jobs.txt`:

```bash
# in the template, write paths like /scratch5/<user>/<project>/bids/sub-SUBJECT/anat/...
bash examples/make_batches.sh my_template_job.m subjects.txt batches/
sbatch run_spm_batch.sh
```

Batch files must use full paths. Files that are gzipped (`.nii.gz`, e.g. from BIDS)
need to be unzipped first: SPM reads `.nii`, not `.nii.gz`.

## 5. Tips and troubleshooting

- **Monitor jobs:** `squeue -u $USER`; logs are in `logs/spm_<jobid>_<task>.out/.err`.
- **"Could not access the MATLAB Runtime component cache"** or random failures when
  many SPM jobs start at once: the runtime unpacks into a shared cache. The job script
  gives each job its own cache in `/tmp` (`MCR_CACHE_ROOT`); do the same if you write
  your own scripts.
- **"File not found" for a path that exists:** the container can only see bound folders
  (`/software`, `/home`, `/storage`, `/scratch2`–`/scratch6`). Add others with
  `export APPTAINER_BINDPATH="$APPTAINER_BINDPATH,/other/path"`.
- **Don't load other container modules in the same job** (e.g. Osprey): each one puts
  its own copies of common commands on your `PATH`, which can clash.
- **Help text:** `module help spm26/26.10.01`

## Documentation

- SPM: <https://www.fil.ion.ucl.ac.uk/spm/>
- SPM standalone: <https://www.fil.ion.ucl.ac.uk/spm/docs/installation/standalone/>
- Neurodesk: <https://neurodesk.org>

Questions or problems: contact Dr Simon Yuan (simon.yuan@reading.ac.uk).
