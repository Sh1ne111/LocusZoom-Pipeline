#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fout,$vcf,$gff,$step,$stop,$queue,$chrlist,$wsh);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"chrlist:s"=>\$chrlist,
	"gff:s"=>\$gff,
	"vcf:s"=>\$vcf,
	"out:s"=>\$fout,
	"queue:s"=>\$queue,
	"wsh:s"=>\$wsh,
	"step:s"=>\$step,
	"stop:s"=>\$stop,
			) or &USAGE;
&USAGE unless ($gff and $chrlist and $vcf);
$fout=ABSOLUTE_DIR($fout);
$queue||="sh";
$step ||=1;
$stop||=-1;
mkdir $wsh if(-d $wsh);
$wsh=ABSOLUTE_DIR($wsh);
my $tmp=time();
open Log,">$fout/$wsh/reffalt.$tmp.log";
if ($step == 1) {
	print Log "########################################\n";
	print Log "split gff and get snp.pos from vcf\n"; 
	my $time = time();
	print Log "########################################\n";
	my $job1="perl $Bin/bin/get.chr.pl  -chrlist $chrlist -gff $gff -out $fout/gff ";
	my $job2="perl $Bin/bin/get.pos.pl -vcf $vcf -out $fout/snp.pos";
	print Log "$job1\n";
	`$job1`;
	`$job2`;
	print Log "$job2\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 2) {
	print Log "########################################\n";
	print Log "get a refflat table with more information than requrie\n"; 
	my $time = time();
	print Log "########################################\n";
	my @gffs=glob("$fout/gff/*.gff");
	open Out,">$fout/get.reffalt.sh";
	foreach my $gf (@gffs) {
		my $fln=basename($gf);
		print Out "perl $Bin/bin/get.gene.anno.pl -gff $fout/gff/$fln -out $fout/gff/$fln.anno && ";
		print Out "perl $Bin/bin/get.count.pl -gene $fout/gff/$fln.anno -gff $fout/gff/$fln -out $fout/gff/$fln.table \n";
	}
	close Out;
	if ($queue eq "sh"){
		`nohup sh $fout/get.reffalt.sh &`;
	}else{
		`nohup $queue $fout/get.reffalt.sh &`;
	}
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
if ($step == 3) {
	print Log "########################################\n";
	print Log "get final refflat tabel\n"; 
	my $time = time();
	print Log "########################################\n";
	my $job="perl $Bin/bin/get.final.pl -vcf refflat.all.table -out refflat.table ";
	print Log "$job\n";
	`$job`;
	print Log "$job\tdone!\n";
	print Log "########################################\n";
	print Log "Done and elapsed time : ",time()-$time,"s\n";
	print Log "########################################\n";
	$step++ if ($step ne $stop);
}
close Log;
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

	eg:perl $Script -chrlist ref.chrlist -gff ref.gff3 -vcf pop.recode.vcf -out ./
	

Usage:
  Options:
  -chrlist <file> the chromosome list file,and looks like: chr1	365483943
  -gff <file>  genome annotation file > *.gff3 
  -vcf <file> *.vcf 
  -out <dir> output director name
  -queue <str> default was "sh",for using to queue your job, or if you run in a server you just need to give the pathway.
  looks like; queue-seg.pl and also can add the resource of the memory
  -wsh <dir> the work shell default was "work_sh"
  -step <str> control the steps you want to run, upto 3
  -stop <str> as the same as step means

USAGE
        print $usage;
        exit;
}
