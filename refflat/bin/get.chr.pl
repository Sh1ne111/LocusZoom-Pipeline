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
	"chrlist:s"=>\$fin,
	"gff:s"=>\$gff,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($gff);
mkdir $fout if(-d $fout);
$fout=ABSOLUTE_DIR($fout);
open In,$fin;
while (<In>){
	chomp;
	my($chr,undef)=split/\s+/,$_;
	open IN,$gff;
	open Out,">$fout/$chr.gff";
	while (<IN>){
		chomp;
		my ($ch,$all)=split/\s+/,$_,2;
		if($ch eq $chr){
			print Out "$_\n";
		}else{next;}
	}
	close IN;
	close Out;
}
close In;
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
Contact:        czheluo\@gmail.com
Script:			$Script
Description:

	eg:perl $Script -chrlist ref.chrlist -gff ref.gff -out map/
	

Usage:
  Options:
	"chrlist:s"=>\$fin,
	"gff:s"=>\$gff,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
