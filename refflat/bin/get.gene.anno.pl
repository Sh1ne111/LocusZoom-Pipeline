#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$as,$gff);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"gene:s"=>\$fin,
	"gff:s"=>\$gff,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($gff);
#$fout=ABSOLUTE_DIR($fout);
#my %gene;
open In,$gff;
open Out,">$fout";
print Out "geneName\tname\tchrom\tstrand\ttxStart\ttxEnd\n";#\tcdsStart\tcdsEnd\texonStarts\texonEnds\n";
while(<In>){
	chomp;
	next if (/#/);
	next if (/Mt/);
	next if (/Pt/);
	next if (/chrUn/);
	#print $_;die;
	my ($chr,$dbs,$type,$start,$end,undef,$strand,undef,$details)=split/\s+/,$_,9;
	my ($gens,$geneid);
	if ($type =~ "gene" ){
		my @adas=split/\;/,$details;
		foreach my $ada (@adas){
			if  ($ada =~ "ID="){## now add gene name
				(undef,$gens)=split/\:/,$ada;
				#print $gens,"\n";
			}elsif($ada =~ "gene_id="){
				(undef,$geneid)=split/\=/,$ada;
				#print $geneid;
			}else{next;}
		}
		print Out "$gens\t$geneid\t$chr\t$strand\t$start\t$end\n";
	}
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

	eg:perl $Script -gff ref.gff -out ref.anno
	

Usage:
  Options:
	"gff:s"=>\$gff,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
