# PBM preprocessing pipeline

Pipeline was used to preprocess data for MEX — Codebook Motif Explorer & Motif Benchmarking.

The resulting data was also used for the IBIS Challenge — Codebook/GRECO-BIT open challenge in Inferring Binding Specificities of human transcription factors from multiple experimental data types.

Pipeline is described in `run.sh` file. 

It starts with a pack of chips of the same design (we had two types of chips: 1M-ME and 1M-HK).

We have two preprocessing strategies:

* SD — spatial detrending of chip artifacts
* QNZS — quantile normalization of chip probes followed by Z-score transformation

Source data folder can be provided (default: `./source_data`).

Results will be stored into two folders:
* PBM_1M-HK
* PBM_1M-ME
