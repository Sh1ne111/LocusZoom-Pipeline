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
my %gene;
open In,$fin;
while (<In>){
	chomp;
	next if (/geneName/);
	my ($gene1,undef,$chr1,undef,$start1,$end1,undef)=split/\s+/,$_;
	my $gens=$_;
	open IN,$gff;
	while(<IN>){
		chomp;
		next if (/#/);
		next if (/sca/);
		my ($chr2,$dbs,$type,$start2,$end2,undef,$strand,undef,$details)=split/\s+/,$_,9;
		#my (@stats,@ends);
		if (($chr1 eq $chr2) && ($type eq "CDS") ){
			my ($ged,$biotype,$gene_id,undef)=split/\;/,$details,4;
			my (undef,$gen)=split/\:/,$ged;
			my ($gene2,undef)=split/\./,$gen;
			if ($gene1 eq $gene2 && $start1<$start2 && $end2<$end1){
				$gene{$gens}{CDS}=join("\t",$start2,$end2);
				$gene{$gens}{CDSs}++;
    			$gene{$gens}{CDS1} .= "," if exists $gene{$gens}{CDS1};
    			$gene{$gens}{CDS1} .= $start2;
				#$gene{$gens}{CDS1} .= "," if exists $gene{$gens}{CDS1};
    			$gene{$gens}{CDS2} .= "," if exists $gene{$gens}{CDS2};
    			$gene{$gens}{CDS2} .= $end2;
				#$gene{$gens}{CDS2} .= "," if exists $gene{$gens}{CDS2};
			}
		}elsif(($chr1 eq $chr2) && ($type eq "exon")){ 
			my ($ged,$biotype,$gene_id,undef)=split/\;/,$details,4;
			my (undef,$gen)=split/\:/,$ged;
			my ($gene2,undef)=split/\./,$gen;
			if (($gene1 eq $gene2) && (($start1<$start2 && $end2<$end1) || ($start1>$start2 && $end2<$end1) ||($start1<$start2 && $end2>$end1))){
				#push @stats=join(","$start2);
				#push @ends=join(",",$end2);
				$gene{$gens}{exons}++;
    			$gene{$gens}{exon1} .= "," if exists $gene{$gens}{exon1};
    			$gene{$gens}{exon1} .= $start2;
				#$gene{$gens}{exon1} .= "," if exists $gene{$gens}{exon1};
    			$gene{$gens}{exon2} .= "," if exists $gene{$gens}{exon2};
    			$gene{$gens}{exon2} .= $end2;
				#$gene{$gens}{exon2} .= "," if exists $gene{$gens}{exon2};
			}
		}else{
			next;
		}
	}
	close IN;
	#print Dumper \%gene;die;
}
close In;
open Out,">$fout";
foreach my $geness (sort keys %gene){
	$gene{$geness}{CDS1}||="NA";
	$gene{$geness}{CDS2}||="NA";
	$gene{$geness}{exons}||="NA";
	$gene{$geness}{exon1}||="NA";
	$gene{$geness}{exon2}||="NA";
	print Out "$geness\t$gene{$geness}{CDS1}\t$gene{$geness}{CDS2}\t$gene{$geness}{exons}\t$gene{$geness}{exon1}\t$gene{$geness}{exon2}\n";
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

	eg:perl $Script -gene 100.anno -gff chr1.gff -out 100.table 
		
	

Usage:
  Options:
	"gff:s"=>\$gff,
	"out:s"=>\$fout,
USAGE
        print $usage;
        exit;
}
