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
	"vcf:s"=>\$fin,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fin);
open In,$fin;
open Out,">$fout";
while(<In>){
	chomp;
	if (/#/){
		print Out "$_\n";
	}else{
		my ($chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@info)=split(/\t/,$_); 
		my @all;
		for (my $i=0;$i<@info;$i++) {
			my @infos=split(/\:/,$info[$i]);
			my $sam=$infos[0];
			$sam=~ s/\//|/g;
			#print $sam;die;
			push @all,join("\t",$sam);
		}
		#print Dumper @all;die;
		print Out join("\t",$chrom,$pos,$id,$ref,$alt,$qual,$filter,$info,$format,@all),"\n";
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

	eg:perl $Script -chrlist ref.chrlist -gff ref.gff -out map/
	

Usage:
  Options:
	"vcf:s"=>\$fin,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
