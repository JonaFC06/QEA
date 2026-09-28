#!/bin/bash
#SBATCH --job-name=qea
#SBATCH --partition=kura
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --hint=nomultithread
#SBATCH --time=1-00:00:00
#SBATCH --output=/data/casch/QEA/results/slurm-%j.out
#SBATCH --error=/data/casch/QEA/results/slurm-%j.out

set -eu

REPO=/data/casch/QEA
CONFIG=${1:-$REPO/config.toml}
OUT=$REPO/results/$SLURM_JOB_ID

# The bashrc points uv at node-local /tmp; keep the interpreter on /data so
# the venv is not a dangling symlink when another node reuses it.
export UV_PYTHON_INSTALL_DIR=/data/casch/.local/share/uv/python
export UV_CACHE_DIR=/data/casch/.cache/uv
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

cd "$REPO"
/data/casch/.local/bin/uv sync --locked

mkdir -p "$OUT"
cp "$CONFIG" "$OUT/"
cd "$OUT"
echo "host $(hostname)  start $(date -Is)  config $CONFIG"
"$REPO/.venv/bin/qea" -c "$CONFIG" > run.log 2>&1
echo "end $(date -Is)"
