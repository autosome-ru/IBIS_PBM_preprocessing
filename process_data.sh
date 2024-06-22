#!/usr/bin/env bash
set -euo pipefail

SCRIPT_FOLDER=$(dirname $(readlink -f $0))

CHIPS_SOURCE_FOLDER=./data/RawData
NUM_THREADS=20
NORMALIZATION_OPTS='--log10'

INTERMEDIATE_FOLDER='results_databox_intermediate'
RESULTS_FOLDER='results_databox'

NAME_MAPPING='no' # 'tf_name_mapping.txt' # use `--name_mapping no` to skip mapping

while true; do
    case "${1-}" in
        --source)
            CHIPS_SOURCE_FOLDER="$(readlink -m "$2")"
            shift
            ;;
        --destination)
            RESULTS_FOLDER="$(readlink -m "$2")"
            shift
            ;;
        --tmp)
            INTERMEDIATE_FOLDER="$(readlink -m "$2")"
            shift
            ;;
        --num-threads)
            NUM_THREADS="$2"
            shift
            ;;
        --name-mapping)
            if [[ "$2" == "no" ]]; then
                NAME_MAPPING="no"
            else
                NAME_MAPPING="$(readlink -m "$2")"
            fi
            shift
            ;;
        -?*)
            echo -e "WARN: Unknown option (ignored): $1\n" >&2
            ;;
        *)
            break
    esac
    shift
done

if [[ "$NAME_MAPPING" != "no" ]]; then
    ruby ${SCRIPT_FOLDER}/rename_chips.rb \
         --source ${CHIPS_SOURCE_FOLDER} \
         --destination ${INTERMEDIATE_FOLDER}/raw_intensities/ \
         --tf-mapping "${NAME_MAPPING}";
    CHIPS_SOURCE_FOLDER="${INTERMEDIATE_FOLDER}/raw_intensities/"
fi

## SD_intensities
# window-size=5 means window 11x11
${SCRIPT_FOLDER}/spatial_detrending.sh --source ${CHIPS_SOURCE_FOLDER} \
                        --destination ${RESULTS_FOLDER}/SD_intensities/ \
                        --window-size 5 \
                        --num-threads ${NUM_THREADS}

# SDQN_intensities
ruby ${SCRIPT_FOLDER}/quantile_normalize_chips.rb \
        ${NORMALIZATION_OPTS} \
        --source ${RESULTS_FOLDER}/SD_intensities/ \
        --destination ${RESULTS_FOLDER}/SDQN_intensities

## QNZS_intensities
ruby ${SCRIPT_FOLDER}/quantile_normalize_chips.rb \
        ${NORMALIZATION_OPTS} \
        --source ${CHIPS_SOURCE_FOLDER} \
        --destination ${INTERMEDIATE_FOLDER}/quantile_normalized_intensities

ruby ${SCRIPT_FOLDER}/zscore_transform_chips.rb \
        --source ${INTERMEDIATE_FOLDER}/quantile_normalized_intensities \
        --destination ${RESULTS_FOLDER}/QNZS_intensities
