#!/bin/bash
export PATH="/ifshk7/BC_PS/zhengwenyuan/install/perl5.18.4/bin/:$PATH"
export PATH="/ifshk1/BC_CANCER/01bin/DNA/software/pipeline/CSAP_v5.2.7/bin/Tool/samtools/:$PATH"
perl dm_find.pl --input_bam /ifshk7/BC_COM_P6/F14FTSNCKF2658/HUMbtcR/analysis_of_58pair/ZLH-143T/ZLH-143T.sort.rmdup.bam --sv /ifshk7/BC_COM_P6/F14FTSNCKF2658/HUMbtcR/analysis/SV_filter/GC147.filter.fusions  --cn /ifshk7/BC_COM_P6/F15HTSNCKF0525/HUMqifR/Prostate/pathwork/DM/analysis/meerkat_input/seg/GC147.seg.txt.bed --min_cyclic 1 --min_non_cyclic 1 --window 10000 