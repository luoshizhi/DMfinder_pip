#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use FindBin qw($Bin);

#my $min_amp = 5; #Minimum number of amplicons in chain to predict as a dm
#my $cutoff = 4; #Cutoff coefficient of standard deviation
#my $mean = 400; #Mean insert length
#my $stdev = 50; #Standard deviation of insert lengths
#my $window = 1200; #Maximum number of base pairs to define proximity between copy number breakpoint and structural variant breakpoint (recommended you set this to 2*(cutoff*stdev*mean))
#my $sv_coordinate_file;
#my $cn_coordinate_file;
####################################

my $input_bam_file;
my $samtools_directory = ""; #Not used anymore. User must specify samtools in the PATH.

my $main_sam_file;
my $window_size; #Size of window to send the classifier

sub outputFiles
{
	#Prints the location of the program result files

	print "\nOutput is in:\n\t$input_bam_file.breakpoints.txt\n";
	
	

}
sub mergeOutputFiles
{
	#Merge the prediction results from pq, qq, and pp into a single file


	if(-e "$main_sam_file.combined.txt")
	{
		system("rm $main_sam_file.combined.txt");
	}
	
	
	
	system("cat $main_sam_file.out.plus.plus.csv >> $main_sam_file.combined.txt");
	system("cat $main_sam_file.out.plus.minus.csv >> $main_sam_file.combined.txt");
	system("cat $main_sam_file.out.minus.plus.csv >> $main_sam_file.combined.txt");
	

	system("grep -v \", -1,\" $main_sam_file.combined.txt | grep -v \", ,\" > $main_sam_file.combined.precise.txt"); #Remove records that have no precise breakpoint predictions

}

sub parseOutput
{
	#Parses the classification results and puts them in a nicer looking format
	#There will be 5 output files (if classification is selected)
		#File with pure breakpoints
		#Unbalanced translocation predictions
		#Balanced translocation predictions
		#Interchromosomal insertion predictions
		#Breakpoints that could not be classified		

	#First reformat the breakpoint file

	my $line = "";
	my @record = ();

	my $chri = "";	
	my $chrj = "";
	my $pos_i = "";
	my $pos_j = "";
	my $strand1 = "";
	my $strand2 = "";
	my $AP = "";	#Abnormal or discordant pairs
	my $chr1_sc = 0;
	my $chr2_sc = 0;
 

	my $balanced = "$main_sam_file.combined.txt.balanced.txt";
        my $unbalanced = "$main_sam_file.combined.txt.unbalanced.txt";
        my $insertion = "$main_sam_file.combined.txt.insertions.txt";
        my $unclassified = "$main_sam_file.combined.txt.unclassified.txt";
	open(IN, "<$main_sam_file.combined.precise.txt") or die("ERROR: bellerophon.pl: Could not open combined cluster output file!\n");
	open(OUT, ">$input_bam_file.breakpoints.txt") or die("ERROR: bellerophon.pl: Could not write to the breakpoint predictions file!\n");
		

	print OUT "chr1\tpos1\tchr2\tpos2\tstrand1\tstrand2\tnum_discordant\tSC1\tSC2\n\n";
	
	while($line = <IN>)
	{
		while($line eq "\n") {$line = <IN>;}
		chomp($line);
		@record = split(/, /, $line);		
		$chri = $record[1];
		$pos_i = $record[7];
		$pos_j = $record[9];
		$AP = $record[3];
		$chrj = $record[4]; 
		$strand1 = $record[10];
		$strand2 = $record[11];
		$chr1_sc = $record[12];
		$chr2_sc = $record[13];				
							
		
		print OUT "$chri\t$pos_i\t$chrj\t$pos_j\t$strand1\t$strand2\t$AP\t$chr1_sc\t$chr2_sc\n";
	
		
	}
	close IN;
	close OUT;

}
sub cleanup
{

}

sub Usage
{
	my $message = $_[0];
	die($message);	
}

######Set default parameter values
#my $amp_merge = 10000; #Merge amplicons that are less than this many bp apart 
my $min_cyclic = 2; #Minimum number of amplicons in chain to predict as a dm
my $min_non_cyclic = 2; #Minimum number of amplicons in a NON-CYCLIC chain to predict as a DM [2]
my $cutoff = 4; #Cutoff coefficient of standard deviation
my $mean = 400; #Mean insert length
my $stdev = 50; #Standard deviation of insert lengths
my $window = 0; #Maximum number of base pairs to define proximity between copy number breakpoint and structural variant breakpoint (recommended you set this to 2*(cutoff*stdev*mean))
my $minqual = 30; #minimum read mapping quality to estimate mapping coverage [30]
my $sv_coordinate_file;
my $cn_coordinate_file;

sub options
{
	print "\nDM Finder v1.0";

	print "\n\nperl dmfind.pl --input_bam {indexed and sorted bam file} --sv {structural variant coordinates in VCF format} --cn {copy number variant coordinates in BED format} [OPTIONS]\n
OPTIONS\n
	--min_cyclic				Minimum number of amplicons in cyclic chain to predict as a double minute [2]
	--min_non_cyclic			Minimum number of amplicons in a non-cyclic chain to predict as a DM [2]
	--cutoff				Cutoff coefficient of mapped read pair standard deviation [4]
	--mean					Mean mapped distance between read pairs [400]
	--stdev					Standard deviation of mapped distances between reads [80]
	--minqual				Minimum read mapping quality to estimate mapping coverage [30]
	--window				Maximum number of base pairs to define proximity between copy number breakpoint and structural variant breakpoint [2*(cutoff*stdev+mean)]\n"
	
}


my $r = `samtools >& does_samtools_exist.txt; echo \$?`;

if($r == 127)
{
	system("rm does_samtools_exist.txt");
	die("ERROR: dm_find.pl: Samtools not found. Is it in your PATH variable?\n");
}
system("rm does_samtools_exist.txt");


GetOptions ('input_bam=s' => \$input_bam_file,
	    'sv=s' => \$sv_coordinate_file,
	    'cn=s' => \$cn_coordinate_file,
	    'min_cyclic=i' => \$min_cyclic,
	    'min_non_cyclic=i' => \$min_non_cyclic,
	    'cutoff=i' => \$cutoff,
	    'mean=s' => \$mean,
	    'stdev=s' => \$stdev,
	    'minqual=i' => \$minqual,
	    'window=i' => \$window) or Usage("Invalid commmand line options.\n");

if($window == 0)
{
	$window = 2*($cutoff*$stdev+$mean);
}
unless(defined $input_bam_file) { options(); Usage("Please provide the path to an indexed BAM file!\n"); }
#Usage("Please provide the path to an indexed BAM file!\n") unless defined $input_bam_file;

unless (-e $input_bam_file) { options(); Usage("Specified BAM file does not exist!\n"); }
unless (-e $input_bam_file.".bai") { options(); Usage("Index file for input BAM not found! Create an index file named $input_bam_file.bai\n"); }
unless (-e $cn_coordinate_file) {options(); Usage("Specified copy number amplicon BED file does not exist!\n"); }
unless (-e $sv_coordinate_file) {options(); Usage("Specified structural variant breakpoint (SV) VCF file does not exist!\n");}

my %options = ();

#RUN DM FINDER
#

system("perl $Bin/dm_find_core.pl $sv_coordinate_file $cn_coordinate_file $window $input_bam_file $minqual $min_cyclic $min_non_cyclic"); 
