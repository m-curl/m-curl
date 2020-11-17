# M-CURL: Masked Contrastive Representation Learning for Reinforcement Learning

This repository contains the code for M-CURL.

## Installation 

All of the dependencies are in the `Dockerfile`.
You can build it with the following command:

```shell script
docker build -t mcurl .
```

## Instructions
To train an M-CURL agent on the `cartpole swingup` task,  please use `script/run_withouttb.sh` 
from the root of this directory. One example is as follows, 
and you can modify it to try different environments / hyperparamters.
```shell script
#!/usr/bin/env bash
export PYTHONIOENCODING="UTF-8"
nvidia-smi

DOMAIN=cartpole
TASK=swingup
SEED=1

CUDA=${1:-0}
cd scripts
bash run_withouttb.sh $DOMAIN $TASK -s $SEED -c $CUDA  --num_train_steps 500000
```
