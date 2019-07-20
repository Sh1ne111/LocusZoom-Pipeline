## LocusZoom Pipeline visualization of GWAS (eQTL, EWAS and TWAS) results for research and publication 

  [LocusZoom](http://locuszoom.org/) is amazing tool for dataViz. It is so comfortable to visual human species GWAS or metal GWAS result etc, though. The author didn't provided a tool to how to prepare the refflat table like UCSC brower format. Here, for some work i wrote a pipeline to get the refFlat tabel and snp.pos from any species and only need you provide the annotation of genome (genome annotation file from the NCBI or ensembl or somewhere reasonable) and the SNP calling vcf file from your are interested in research area.
### Here were two eQTLs result 
1. LocusZoom plot for barley eQTL(chr2:14981819) result with gene: HORVU0Hr1G019610 

![HORVU0Hr1G019610](Fig/chr2_6981819-22981819-1.png "HORVU0Hr1G019610")

2. LocusZoom plot for barley eQTL(chr5:135426027) result with gene: HORVU7Hr1G119370

![HORVU7Hr1G119370](Fig/chr5_115426027-155426027-1.png "HORVU7Hr1G119370")

### make own database  

#### How to get the refFlat and snp position table

> The [refFlat](https://genome-source.gi.ucsc.edu/gitlist/kent.git/raw/master/src/hg/lib/refFlat.as) table mirrors what is currently supplied by the UCSC database, here, [format](https://genome-source.gi.ucsc.edu/gitlist/kent.git/raw/master/src/hg/lib/refFlat.as). You need to qsub my Pipeline, cause it will take a while for get the reffalt table, if your species wiht a big reference genome, then will take more time to get the data result. my demo was the  [barley](ftp://ftp.ensemblgenomes.org/pub/plants/release-44/gff3/hordeum_vulgare) specie and needs more than five hours.
```linux
$ perl refflat.pipeline.pl
Contact:        czheluo@gmail.com
Script:         refflat.pipeline.pl
Description:
        eg:perl refflat.pipeline.pl -chrlist ref.chrlist -gff ref.gff3 -vcf pop.recode.vcf -out ./
Usage:
  Options:
  -chrlist <file> the chromosome list file,and looks like: chr1 365483943
  -gff <file>  genome annotation file > *.gff3
  -vcf <file> *.vcf
  -out <dir> output director name
  -queue <str> default was "sh",for using to queue your job, or if you run in a server you just need to give the pathway.
  looks like; queue-seg.pl and also can add the resource of the memory
  -wsh <dir> the work shell default was "work_sh"
  -step <str> control the steps you want to run, upto 3
  -stop <str> as the same as step means
```
```linux
$ nohup qsub perl refflat.pipeline.pl -chrlist ref.chrlist -gff ref.gff3 -vcf pop.recode.vcf -out ./ & 
# or  (which running local node in your machine)
$ nohup perl refflat.pipeline.pl -chrlist ref.chrlist -gff ref.gff3 -vcf pop.recode.vcf -out ./ &
```
The pipeline will generate snp.pos and refflat.tbale files for your to build own database, excuting as following:
For details click [here](https://genome.sph.umich.edu/wiki/LocusZoom_Standalone).
```linux
$ python dbmeister.py --db barley.db --snp_pos snp.pos
$ python dbmeister.py --db barley.db --refflat refflat.table
```
### Estimating recombination rates from population genetic data  
> Currently, there are several popular softwares to calculate which like [FastEPRR](http://www.picb.ac.cn/evolgen/softwares/FastEPRR.html), [LDhat](https://github.com/auton1/LDhat), and [MLrho](http://guanine.evolbio.mpg.de/mlRho/). Here, i will take the FastEPRR as example. For the detail introduction see [here](http://www.picb.ac.cn/evolgen/softwares/download/FastEPRR/FastEPRR2.0/FastEPRR_manual.pdf). Mainly include three steps. and before you need know your genotype was phased or not. if not you need phased before running. here, i using the [beagle](https://faculty.washington.edu/browning/beagle/beagle.html) for imputation and phased.

```linux
$ java -jar beagle.11Mar19.69c.jar gt=pop.recode.vcf.gz out=pop.phased.vcf.gz
```
> if your genotype already phased and impution, i wrote a perl script for get the data format for FastEPRR from your vcf genotype file. 
```linux
$ perl get.FastEPRR.pl -vcf pop.recode.vcf -out pop.phased.vcf 
```
> make sure your chromesome in your vcf files was numeric. if not, you can run a one liner perl for change string to numeric.

```linux
$ less pop.recode.vcf |perl -ne 'chomp;if(/#/){print "$_\n"}else{($chr,$all)=split/\s+/,$_,2;$chr=~s/chr//g;print "$chr\t$all\n"}' > pop.vcf
```
> The FastEPRR can run single chromesome only, so you have to split your vcf to couples of vcf files. Here, Split it by vcftools super convenient in one liner command.   
```linux
$ less list |perl -ne 'chomp;`vcftools --vcf pop.vcf --chr $_ --recode --out pop.$_.vcf.gz && gzip pop.$_.vcf.gz`'
```
> After get all chrs vcf file, you just can run my R code as following: 
```linux
$ Rscipt rho.R 
Usage: rho.R [-[-input|i] <character>] [-[-output|o]] [-[-wl|l] <character>] [-[-wd|d] <character>] [-[-nj|n] <character>] [-[-cj|c] <character>] [-[-set|s] <character>] [-[-help|h]]
Usage example:
      Usage example:
      Rscript rho.R --input ./ --output result
      Usage:
      --input  dir for VCFs where is (give the absolute path)
      --output  output result dir
      --wl  the window Length (default: 500000)
      --wd the winDXThreshold (default: 10, not for human species (30))
      --nj the job number (default 1)
      --cj currently run job (default 1, and must less than job number value)
      --set Rho values of training set (default :0.0, 0.5, 1.0, 2.0, 5.0,  10.0,  20.0,  40.0,  70.0,  110.0,  170.0)
      --help            usage
$ nohup Rscript rho.R --input ./ --output result &
```
> After finished,you will get mutiple folders, and like: 
![FastEPRR](Fig/FastEPRR.png "FastEPRR")
Then you need run perl script following to get result, but not the last, you need add the cm_pos from your population genetic map, if not ,you only add additional column as the fourth, then add to your build database. 
```perl
$ perl get.gasteprr.result.pl -int ./ -out fasteprr.result
$ perl get.rho.result.pl -result fasteprr.result -vcf pop.recode.vcf -out recomb_rate.table
```
```linux
    $ python dbmeister.py --db barley.db --recomb_rate recomb_rate.table
```
> if you got Error: file recomb_rate.table does not have tthe proper number of columns (or your delimiter is incorrect.) 
```linux
    $ less recomb_rate.table |sed 's/\s/\t/g' > recomb_rate.delimiter.table && python dbmeister.py --db barley.db --recomb_rate recomb_rate.delimiter.table
```
### optimization your own plot 

```linux
$ ./../bin/locuszoom --metal chr5_135426027.metal --refsnp chr5:135426027 --flank 20MB  --build by38 --pop BARLEY --source 1000G_July2019 --no-cleanup
```
