#!/usr/bin/env bash
SCRIPT_FOLDER=$(dirname $(readlink -f $0))
SOURCE_FOLDER="${SCRIPT_FOLDER}/source_data/" # Change source folder path
NUM_THREADS=20

mkdir -p ./r-libs
export R_LIBS_USER=./r-libs
Rscript ${SCRIPT_FOLDER}/requirements.R

for CHIP_TYPE in 1M-HK 1M-ME; do
    mkdir -p ./pbm_source_data_by_chiptype/${CHIP_TYPE}
    for FN in $(find ${SOURCE_FOLDER} -name "*${CHIP_TYPE}*"); do
        ln -s "$(readlink -m "${FN}" )" ./pbm_source_data_by_chiptype/${CHIP_TYPE}
    done
    ${SCRIPT_FOLDER}/process_data.sh --source ./pbm_source_data_by_chiptype/${CHIP_TYPE} \
                      --destination ./PBM_${CHIP_TYPE} \
                      --tmp ./pbm_intermediate_${CHIP_TYPE} \
                      --name-mapping ${SCRIPT_FOLDER}/tf_name_mapping.txt \
                      --num-threads ${NUM_THREADS}
    rm -r ./pbm_intermediate_${CHIP_TYPE}
done

rm -r ./pbm_source_data_by_chiptype/
