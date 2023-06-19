#!/bin/bash


hostid_start=3
if [ $SLURM_NNODES -gt 1 ]
then
    hostid_start=$(( $hostid_start + 1 ))
fi
master="mel${SLURM_NODELIST:hostid_start:4}"
master=`host $master| grep address | awk '{print $4}'`

export MASTER_ADDR=$master
export MASTER_PORT=13245
export LOCAL_SIZE=4
rank=$SLURM_PROCID
nprocs_per_node=4

# WORLD_SIZE=$SLURM_NPROCS
conda activate llama


DISTRIBUTED_ARGS="--nproc_per_node $nprocs_per_node \
                  --nnodes $SLURM_NNODES \
                  --node_rank ${rank} \
                  --master_addr ${MASTER_ADDR} \
                  --master_port ${MASTER_PORT}"

cd ../..
torchrun --standalone --nproc_per_node 4 --nnodes 16 benchmark.py --plugin "gemini" -l 512 -c '65b'




