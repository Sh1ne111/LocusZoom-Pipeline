#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($flat,$fout);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"table:s"=>\$flat,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($flat);
local $" = "\t";
open In,$flat;
open Out,">$fout";
print Out "geneName\tname\tchrom\tstrand\ttxStart\ttxEnd\tcdsStart\tcdsEnd\texonCount\texonStarts\texonEnds\n";
while (<In>){
	chomp;
	my($gene1,$gene2,$chr,$strand,$start,$end,$CDS1,$CDS2,$exon)=split/\s+/,$_,9;
	my@cds1=split/\,/,$CDS1;
	my @cds2=split/\,/,$CDS2;
	my @exons=split/\s+/,$exon;
	print Out "$gene1	$gene2	$chr	$strand	$start	$end	$cds1[0]	$cds2[0]	$exons[0]	$exons[1]\,	$exons[2]\,\n";
	#print Out,join("\t",$gene1,$gene2,$chr,$strand,$start,$end,$cds1[0],$cds2[0]",join(",",$exons[0]","$exons[1]\,",""$exons[2]\),"\n";
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

	eg:perl $Script -table refflat.all.table -out refflat.table
	

Usage:
  Options:
	"table:s"=>\$flat,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
