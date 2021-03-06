#!/bin/bash
echo hostname: `hostname`
echo ==========start at : `date` ==========
cd /ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/Pipeline/module/DMFinder/example/process/GC145  &&\
perl /ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/Pipeline/module/DMFinder/script/dm_find.pl --min_cyclic 1 --min_non_cyclic 1 --window 10000 --input_bam /ifshk7/BC_COM_P6/F14FTSNCKF2658/HUMbtcR/analysis_of_58pair/ZLH-136T/ZLH-136T.sort.rmdup.bam --sv /ifshk7/BC_COM_P6/F14FTSNCKF2658/HUMbtcR/analysis/SV_filter/GC145.filter.fusions --cn /ifshk7/BC_COM_P6/F15HTSNCKF0525/HUMqifR/Prostate/pathwork/DM/analysis/meerkat_input/seg/GC145.seg.txt.bed >/ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/Pipeline/module/DMFinder/example/process/GC145/result 2>log &&\
python /ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/Pipeline/module/DMFinder/script/plot_dm_result.py /ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/Pipeline/module/DMFinder/example/process/GC145/result /ifshk7/BC_COM_P6/F14FTSNCKF2658/HUMbtcR/analysis/SV_filter/GC145.filter.fusions GC145 && \
echo ==========end at : `date` ========== && \
echo Still_waters_run_deep 1>&2 && \
echo Still_waters_run_deep > /ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/Pipeline/module/DMFinder/example/shell/GC145/step1.dmfind.sh.sign
