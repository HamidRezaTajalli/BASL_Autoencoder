#!/bin/bash -l

#####################
# job-array example #
#####################

#SBATCH --partition=general
#SBATCH --qos=long
#SBATCH --time=2-0:00:00

# 500MB memory per core
# this is a hard limit
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1

#SBATCH --mem=16000

module use /opt/insy/modulefiles
module load cuda/11.2 cudnn/11.2-8.1.1.33
module list

previous=$(nvidia-smi --query-accounted-apps=gpu_utilization,mem_utilization,max_memory_usage,time --format=csv | tail -n +2)


datasets=("mnist" "cifar10" "fmnist")
models=("resnet9" "lenet" "stripnet")
num_of_exp=(1)
cut_layers=(1 2 3)
num_clients_list=(1 3 5 7)
fixed_alpha=True
tb_inj=False
alpha_list=(0.5 0.2 0.09 0.06)

for dataset in ${!datasets[@]};
do
    for model in ${!models[@]};
    do
        for num_clients in ${!num_clients_list[@]};
        do
            for cut_layer in ${!cut_layers[@]};
            do
                for exp_num in $(seq 1 $num_of_exp);
                do
                    srun python3 ./BASL_Autoencoder/main.py --dataname $dataset --model $model --exp_num $exp_num --cutlayer $cut_layer --num_clients $num_clients --fixed_alpha
                done
            done
        done
    done
done


nvidia-smi --query-accounted-apps=gpu_utilization,mem_utilization,max_memory_usage,time --format=csv | grep -v -F "$previous"