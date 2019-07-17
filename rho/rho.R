#!/usr/bin/env Rscript
##########################################
#  https://github.com/czheluo/
#  Copyright (C) 2019  by Meng Luo
#  contact: czheluo@gmail.com
# calculating the recombination rates
##########################################
library(FastEPRR)
library(getopt)
options(bitmapType='cairo')
spec = matrix(c(
  'input','i',1,'character',
  'output','o',0,'character',
  'wl','l',1,'character',
  'wd','d',1,'character',
  'nj','n',1,'character',
  'cj','c',1,'character',
  'set','s',1,'character',
  'help','h',0,'logical'
), byrow=TRUE, ncol=4)
opt = getopt(spec)
print_usage <- function(spec=NULL){
  cat(getopt(spec, usage=TRUE));
  cat("Usage example: \n")
  cat("	
      Usage example: 
      Rscript rho.R --input ./ --output result
      Usage:
      --input  dir for VCFs where is (give the absolute path)
      --output	output result dir
      --wl  the window Length (default: 500000)
      --wd the winDXThreshold (default: 10, not for human species (30))
      --nj the job number (default 1)
      --cj currently run job (default 1, and must less than job number value)
      --set Rho values of training set (default :0.0, 0.5, 1.0, 2.0, 5.0,  10.0,  20.0,  40.0,  70.0,  110.0,  170.0)
      --help		usage
      \n")
  q(status=1);
}
if (is.null(opt$input)) { print_usage(spec)}
if (is.null(opt$output)){print_usage(spec)}
if(is.null(opt$wl)){opt$wl=500000;print(opt$wl)}
if(is.null(opt$wd)){opt$wd=10;print(opt$wd)}
if(is.null(opt$nj)){opt$nj=1;print(opt$nj)}
if(is.null(opt$cj)){opt$wd=1;print(opt$cj)}
if(is.null(opt$set)){opt$set="0.0; 0.5;1.0;2.0;5.0;10.0;20.0;40.0;70.0;110.0;170.0";print(opt$set)}
times<-Sys.time()
#setwd(opt$output)
files <- list.files(opt$input) 
for (i in 1:length(files)) {
  dir.create(paste(opt$output,"result1","_chr",i,sep=""))
  FastEPRR_VCF_step1(vcfFilePath=paste(opt$input,files[i],sep = ""),
                     winLength =opt$wl, winDXThreshold = 5,
                     srcOutputFilePath=paste(opt$output,"/result1","_chr",i,"/chr",i,sep=""))
  dir.create(paste(opt$output,"result2","_chr",i,sep=""))
  FastEPRR_VCF_step2(srcFolderPath=paste(opt$output,"/result1","_chr",i,sep=""),
                     jobNumber=opt$nj,currJob=opt$cj,trainingSet1  = opt$set,
                     DXOutputFolderPath=paste(opt$output,"/result2","_chr",i,sep=""))
  dir.create(paste(opt$output,"result3","_chr",i,sep=""))
  FastEPRR_VCF_step3(srcFolderPath=paste(opt$output,"/result1","_chr",i,sep=""),
                     DXFolderPath=paste(opt$output,"/result2","_chr",i,sep=""),
                     finalOutputFolderPath=paste(opt$output,"/result3","_chr",i,sep=""))
}

escaptime<-Sys.time()-times;
print("Done!");
print(escaptime)


