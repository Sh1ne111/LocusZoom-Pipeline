### LocusZoom Pipeline Project for any  with reference species

#### LocusZoom plot for barley eQTL result with gene: HORVU0Hr1G019610 

![HORVU0Hr1G019610](Fig/chr2.png "HORVU0Hr1G019610")

#### LocusZoom plot for barley eQTL result with gene: HORVU7Hr1G119370

![HORVU7Hr1G119370](Fig/chr5.png "HORVU7Hr1G119370")

### Estimate recombination rates from population genetic data  
 
#### phased your genotypy first or not 
```java
  $ java -jar beagle.11Mar19.69c.jar gt=pop.recode.vcf.gz out=pop.phased.vcf.gz
```
* if your genotype already phased 
```perl
  $ perl get.FastEPRR.pl -vcf pop.recode.vcf -out pop.phased.vcf 
```
* change the name chr(chart) to numric 
```linux
  $ less pop.recode.vcf |perl -ne 'chomp;if(/#/){print "$_\n"}else{($chr,$all)=split/\s+/,$_,2;$chr=~s/chr//g;print "$chr\t$all\n"}' > pop.vcf
```
