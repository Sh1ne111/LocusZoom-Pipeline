#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"int:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fout);

open In,$fin;
open Out,">$fout";

while (<In>) {
	chomp;
	my ($chr,$startg,$endg,$tran,undef,$strand,$startcd,$endcd,undef,$numex,$startex,$endex)=split/\s+/,$_;
	print Out "$tran\t$tran\t$chr\t$strand\t$startg\t$endg\t$startcd\t$endcd\t$numex\t$startex\t$endex\n";
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

	eg: perl $Script -int Mus_musculus.GRCm38.96.Pred -out Mus_musculus.GRCm38.96.refflat
	
Usage:
  Options:
	-int input file name
	-out output file name 
	-h         Help

USAGE
        print $usage;
        exit;
}
