#!/bin/bash
MK_TEMPLATE=Makefile.template
MK_LOCAL=Makefile.local

echo "Init repository ..."

if [[ -f "$MK_LOCAL" ]]; then
    echo "$MK_LOCAL already exists. If necessary, back it up, delete it, then rerun this script."
    return
fi

cp $MK_TEMPLATE $MK_LOCAL

#REPO_ROOT=$(pwd)
source ./conf_env.sh
sed -i "s|#export FPGA_DESIGN|export FPGA_DESIGN=$REPO_ROOT|1" $MK_LOCAL 
#export FPGA_DESIGN=$REPO_ROOT

#echo $REPO_ROOT
