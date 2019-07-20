#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout1,$fout2);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"vcf:s"=>\$fin,
	"out1:s"=>\$fout1,
	"out2:s"=>\$fout2,
			) or &USAGE;
&USAGE unless ($fin);
open In,$fin;
open Out,">$fout1";
open OUT,">$fout2";
print OUT "snp\tsnp_set\n";
print Out "snp\tchr\tpos\n";
while (<In>){
	chomp;
	next if(/#/);
	my ($chr,$pos,$marker,$filter)=split/\s+/,$_,4;
	$marker=~s/_/:/g;
	$chr=~s/chr//g;
	print Out "$marker\t$chr\t$pos\n";
	print OUT "$marker\tSNP_density\n";
}
close In;
close Out;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub ABSOLUTE_DIR #$pavfile=&ABSOLUTE_DIR($pavfile);
{
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir \n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}
sub USAGE {#
        my $usage=<<"USAGE";
Contact:        meng.luo\@majorbio.com;
Script:			$Script
Description:

	eg:perl $Script -vcf pop.noindel.recode.vcf -out1 snp.pos -out2 snp.set
	

Usage:
  Options:
	"help|?" =>\&USAGE,
	"vcf:s"=>\$fin,
	"out1:s"=>\$fout1,
	"out2:s"=>\$fout2,
USAGE
        print $usage;
        exit;
}
