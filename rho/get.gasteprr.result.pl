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
&USAGE unless ($fin);
$fin=ABSOLUTE_DIR($fin);
open Out,">$fout";
print Out "chr\tstart\tend\trecomb\n";
my @files=glob("$fin/result3_*");
foreach my $file (@files){
	my $fln= basename($file);
	my ($name,$chr)=split/\_/,$fln;
	open In,"$fin/$fln/$chr";
	while (<In>){
		chomp;
		if (/Start/){
			next;
		}else{
			my($start,$end,$rho,undef,undef)=split/\s+/,$_;
			$chr=~s/chr//g;
			print Out "$chr\t$start\t$end\t$rho\n";
		}
	}
	close In;
}
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

	eg:perl $Script -int RRresult/RRresult/ -out fasteprr.result
	

Usage:
  Options:
	"int:s"=>\$fin,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
