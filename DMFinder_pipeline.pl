#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Path;
use File::Basename;
use Cwd;
use FindBin qw($Bin);
use lib "$Bin/lib";
use AnaMethod;


my ($input,$outdir,$plot,$env,$move,$dmfind_arg,$monitorOption,$java, $help, $qsubMemory, $pymonitor, $python, $Rscript);
GetOptions(
	"input:s" => \$input,
	"env:s"=> \$env,
	"outdir:s" => \$outdir,
	"move:s" => \$move,
	"m:s" => \$monitorOption,
	"help|?" => \$help,
	"qsubMemory:s" => \$qsubMemory,
	"pymonitor:s" => \$pymonitor,
	"python:s" => \$python,
	"Rscript:s" => \$Rscript,
	"plot" => \$plot,
	"dmfind:s" => \$dmfind_arg,
);
my $usage = <<USE;
Usage:
description: DMFinder analysis
author: LuoShizhi, luoshizhi\@genomics.cn
date: 2017-08-17
usage: perl $0 [options]
	Common options:
	-input*		<str>	input list. sample   bam   sv   bed   dependence.sh(optioanl)
	-env <str>   export environment variable[\$Bin/environment.sh]
				PATH/MANPATH/LD_LIBRARY_PATH/CFLAGS/LDFLAGS/C_INCLUDE_PATH/CPLUS_INCLUDE_PATH/LIBRARY_PATH/CPATH/R_LIBS
	-outdir*		<str>	outdir.[./]
	-move		<str>	if this parameter is set,final result will be moved to it from output dir.
	-m		<str>	monitor options. will create monitor shell while defined this option"-P common -q bc.q -p test"
	-qsubMemory	<str>	Job memory.format:step1_mem,step2_mem[1G,4G,8G]

	-dmfind  dmfinder arg option default "--min_cyclic 1 --min_non_cyclic 1 --window 10000"
	-help|?			print help information

	Database options:
	Software options:
	-pymonitor	<str>	monitor path [\$Bin/bin/monitor]
	-Rscript	<str>	Rscript path [\$Bin/bin/Rscript]

e.g.:
	perl $0 -input breakpoint.list -outdir ./outdir
USE

die $usage unless ($input && $outdir);
$qsubMemory ||= "1G,4G,8G";
my @qsubMemory = split /,/,$qsubMemory;
$qsubMemory[0] ||= "1G";
$qsubMemory[1] ||= "4G";
$qsubMemory[1] ||= "8G";
$outdir ||= "./";
mkpath $outdir;
$outdir = File::Spec->rel2abs($outdir);

$Rscript ||= "$Bin/bin/Rscript";
$env ||="$Bin/environment.sh";
$dmfind_arg ||= "--min_cyclic 1 --min_non_cyclic 1 --window 10000";
$monitorOption ||="-P common -q bc.q -p test";
$pymonitor ||="$Bin/bin/monitor";
if($move){
	$move = File::Spec->rel2abs($move);
	mkpath $move;
}
#$sample_pair = File::Spec->rel2abs($sample_pair);


my ($bam,$sv,$bed,$dependent) = &ReadInfo2($input);

my %bam = %$bam;
my %sv = %$sv;
my %bed = %$bed;
my %dependent = %$dependent;


my ($shell, $process, $list)=("$outdir/shell", "$outdir/process", "$outdir/list");
mkpath($shell);mkpath($process);mkpath($list);
my $dependence = "$list/dependence.txt";

open TXT, ">$dependence" or die $!;
my $out  = ($move)?$move:$process;


foreach my $sample (keys %bam){
	my $process_t = "$process/$sample"; mkpath $process_t;
	my $shell_t = "$shell/$sample" ; mkpath $shell_t;
	###step1 dmfinder
	my $dmfind = "$shell_t/step1.dmfind.sh";
	my $content ="source $env&&\\\n";
	$content .="cd $process_t  &&\\\n";
	$content .="perl $Bin/script/dm_find.pl $dmfind_arg --input_bam $bam{$sample} --sv $sv{$sample} --cn $bed{$sample} >$process_t/result 2>log &&\\\n";
	$content .="python $Bin/script/plot_dm_result.py $process_t/result $sv{$sample} $sample";
	if (exists $dependent{$sample}) {
		print TXT "$dependent{$sample}\t$dmfind:$qsubMemory[0]\n";
	}else{
		print TXT "$dmfind:$qsubMemory[1]\n";
	}
	AnaMethod::generateShell($dmfind,$content);
}

if(defined $pymonitor && defined $monitorOption){
	`echo "$pymonitor $monitorOption -i $dependence" >$list/qsub.sh`;
}


close TXT;


sub ReadSampleInfo {
        my ($file) = @_;
        my (%hashSample,%hashDepend,%hashlength);
        open IN, "$file" or die $!;
        while (<IN>) {
                chomp;
                next if(/^\s*$/);
                s/\s*$//;
                s/^\s*//;
                my @tmp = split /\t+/;
                $hashSample{$tmp[0]}=$tmp[1];
				$hashlength{$tmp[0]}=$tmp[2];
                $hashDepend{$tmp[0]}=$tmp[3] if(@tmp >= 4);
        }
        close IN;
        return (\%hashSample,\%hashDepend,\%hashlength);
}
sub ReadInfo2 {
        my ($file) = @_;
        my (%hashbam,%hashsv,%hashbed,%hashDepend);
        open IN, "$file" or die $!;
        while (<IN>) {
                chomp;
                next if(/^\s*$/);
                s/\s*$//;
                s/^\s*//;
                my @tmp = split /\t+/;
                $hashbam{$tmp[0]}=$tmp[1];
                $hashsv{$tmp[0]}=$tmp[2];
                $hashbed{$tmp[0]}=$tmp[3];
                $hashDepend{$tmp[0]}=$tmp[4] if(@tmp >= 5);
        }
        close IN;
        return (\%hashbam,\%hashsv,\%hashbed,\%hashDepend);
}

sub Readpair2 {
        my ($file) = @_;
		my %T_N;
        my ($control,$treatment,%pair,%C,%T);
        open IN, "$file" or die $!;
        while (<IN>) {
                next if(/^\s*$/);
                chomp;
                s/\s*$//;
                s/^\s*//;
                next if /^\s+#/;
                if(/(\S+)\t(\S+)/){
                        $control = $1;
                        $treatment = $2;
                }
                $T_N{$treatment}=$control;
        }
        close IN;
        return (%T_N);
}

