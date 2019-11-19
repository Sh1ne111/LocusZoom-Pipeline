#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
get refflatable
python get.refflat.py --gff ref.gff --out refflat.table
"""
__author__ = 'Meng Luo'
__Email__ = 'chzleuo@gmail.com'
__copyright__ = 'Copyright (C) 2019 MARJOBIO'
__license__ = 'GPL'
__modified__= '20190815'

import os
import argparse
import sys
import re

parser = argparse.ArgumentParser(description="huoqu can shu")
parser.add_argument('-i', '--gff',required=True, help=' file gff3')
parser.add_argument('-o', '--out',required=True, help='ouput file fasta')
args = parser.parse_args()

def chuligene(line):
    lines = line.strip().split("\t")
    gene_id = lines[8].strip().split(";")[2].strip().split("=")[1]
    gene_start = lines[3]
    gene_end = lines[4]
    chrid = lines[0]
    listgene = [gene_id,chrid,gene_start]
    listgene = [chrid,gene_id,gene_start,gene_end]
    return listgene


def chuliexon(line):
    lines = line.strip().split("\t")
    exon_start = lines[3]
    exon_end = lines[4]
    listexon = [exon_start,exon_end]
    return listexon


def linetowrite():
    listwrite = [listgene[0],listgene[1],listgene[2],listgene[3],cdsbag_start,cdsbag_end,n,exonbag_start,exonbag_end]
    strwrite = "\t".join(listwrite)+"\n"
    return strwrite



with open(args.gff) as inf,open(args.out,"w") as ouf:
    listgene=""
    exonbag_start = []
    exonbag_end = []
    cdsbag_start = []
    cdsbag_end = []
    for line in inf:
        if line[0]=="#":
            pass
        else:
            lines = line.strip().split("\t")
            if lines[2]=="gene" and listgene == "":
                listgene = chuligene(line)
                flag = 'e'
            elif lines[2]=="exon" and listgene != "":
                listexon = chuliexon(line)
                exonbag_start.append(listexon[0])
                exonbag_end.append(listexon[1])

            elif lines[2]=="CDS" and listgene != "":
                listcds = chuliexon(line)
                cdsbag_start.append(listcds[0])
                cdsbag_end.append(listcds[1])
            elif lines[2]=="gene" and listgene != "":
                n = str(len(cdsbag_start))
                exonbag_start=",".join(exonbag_start)
                exonbag_end=",".join(exonbag_end)
                cdsbag_start=",".join(cdsbag_start)
                cdsbag_end=",".join(cdsbag_end)
                #listgene,exonbag_start,exonbag_end,cdsbag_start,cdsbag_end
                line_write = linetowrite()
                ouf.write(line_write)
                exonbag_start = []
                exonbag_end = []
                cdsbag_start = []
                cdsbag_end = []
                listgene = chuligene(line)
    exonbag_start=",".join(exonbag_start)
    exonbag_end=",".join(exonbag_end)
    cdsbag_start=",".join(cdsbag_start)
    cdsbag_end=",".join(cdsbag_end)
    line_write = linetowrite()
    ouf.write(line_write)











