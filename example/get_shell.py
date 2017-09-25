import os,sys
if len(sys.argv)!=2:
    print "Usage:python get_shell.py input.txt"
    sys.exit()
inp=open(sys.argv[1],'r')
pwd=os.popen("pwd").read().strip()
for i in inp:
    ii=i.strip().split()
    os.system("mkdir -p "+ii[0])
    os.chdir(ii[0])
    os.system("ln -s /ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/DMFinder/dm_find.pl")
    os.system("ln -s /ifshk4/BC_PUB/biosoft/pipe/bc_tumor/newblc/DMFinder/dm_find_core.pl")
    a=open('run.sh','w')
    a.write('''#!/bin/bash
export PATH="/ifshk7/BC_PS/zhengwenyuan/install/perl5.18.4/bin/:$PATH"
export PATH="/ifshk1/BC_CANCER/01bin/DNA/software/pipeline/CSAP_v5.2.7/bin/Tool/samtools/:$PATH"
perl dm_find.pl --input_bam %s --sv %s  --cn %s --min_cyclic 1 --min_non_cyclic 1 --window 10000 '''%(ii[1],ii[2],ii[3]))
    a.close()
    os.system("qsub -cwd -l vf=2g -q bc.q -P common run.sh")
    os.chdir(pwd)
inp.close()
