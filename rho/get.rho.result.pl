#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fin,$fout,$vcf);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"result:s"=>\$fin,
	"vcf:s"=>\$vcf,
	"out:s"=>\$fout,
			) or &USAGE;
&USAGE unless ($fin);
$fin=ABSOLUTE_DIR($fin);
open In,$vcf;
open Out,">$fout";
print Out "chr\tpos\trecomb\n";
while (<In>){
	chomp;
	next if(/#/);
	my ($chr,$pos,undef)=split/\s+/,$_,3;
	$chr=~s/chr//g;
	#print $chr;die;
	open IN,$fin;
	while (<IN>){
		chomp;
		next if (/chr/);
		my($ch,$start,$end,$rho)=split/\s+/,$_;
		if(($ch eq $chr) && (($start eq $pos) || ($pos >$start && $pos <$end))){
			#print $ch;die;
			print Out "$ch\t$pos\t$rho\n";		
		}else{
			next;
		}
	}
	close IN;
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

	eg:perl $Script -result fasteprr.result -vcf pop.vcf -out rcomb.rate.result
	
Usage:
  Options:
	"result:s"=>\$fin,
	"vcf:s"=>\$vcf,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
