#!/bin/bash
##SBATCH -p 128x24          #partition you want to use
#SBATCH --job-name=Signaling # Job name
##SBATCH --mail-type=ALL              # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=gchaves@ucsc.edu  # Where to send mail     
##SBATCH --nodes=10                    # Use one node
##SBATCH --ntasks=10                   # Run a single task       
##SBATCH --cpus-per-task=10            # Number of CPU cores per task
##SBATCH --output=Signaling     # Standard output and error log
##SBATCH --time=1000 
# module load gcc/5.4.0 

#This line introduces the partition to be used for running the script.
#sbatch --partition=128x24 ~/scripts/Signaling_Analysis.sh
#################################################################################################################
####################################  OBJECTIVES OF THE SIGNALING SCRIPT  #######################################
#################################################################################################################


#This script aims to produce a list of genes associated with a biological condition/disease or trait. Ilitially 
#I desired to identify the Signaling Pathways important in a cell model of Huntington's disease.
#Later, I also desired to identify the Signaling pathways affected by genomic variation in RNA-Seq derived from 
#human individuals or cell lines.
#Right now, the script looks at a list of GEO samples, and iterates through a for loop, to download the FASTQ files, 
#align and then count reads in the alignments.
#Later I want the script to be able to perform the DESeq2 differential expression and heatmat plotting or 
#PANTHERDB plotting of the identified genes and Signaling Pathways.



#################################################################################################################
#########################################  UCSC HUMMINGBIRD REQUIREMENTS  #######################################
#################################################################################################################


#I was under the impression that I had to re-install sra-tools the first time I ran the script this year, because 
#I did not have fastq-dump accessible from the path environment accessible to me. Talking to Eric Shell, he said
#that I could source directly from the $which output: ~/anaconda3/bin/conda.
#The step below declares the variable with the path to the location of the Anaconda executables.


source ~/.bashrc


#Don't need to install Anaconda everytime:
#conda install -c bioconda sra-tools


######################################################################################################################################
#########################################  CREATE PROJECT DIRECTORY AND SPECIFY THE GEO LIST  ########################################
######################################################################################################################################


#Define the working directory, or the directory where all downloaded data will be stored
ProjectDirectory=Signaling_GSE68952_H3K4me3
mkdir ~/$ProjectDirectory
#Have the shell script to work based off of the for loop interating on the list of GEO FASTQ files
for fastq_file in $(cat ~/$ProjectDirectory/List_GSE68952.txt)
do

	FastqDirectory=$fastq_file
	mkdir ~/$ProjectDirectory/$FastqDirectory

#Project Name: Defines where the type of analysis will be stored. Inside the project, the same files coming from analisis of GEO database are stored as directories.
#The Project Name defines the name of the working directory, or all files resulting from the analysis of a GEO Fastq file, will be stored.
#mkdir ~/ProjectDirectory/$FastqDirectory



#################################################################################################################
######################################  DOWNLOAD FASTQ FILES FROM GEO ###########################################
#################################################################################################################


	fastq-dump --outdir ~/$ProjectDirectory/$FastqDirectory --split-files $fastq_file


#################################################################################################################
##############################  PATH TO REFERENCE HUMAN GENOME AND FASTQ FILES  #################################
#################################################################################################################



	REFERENCE=~/references/hg19/GRCh37.p13.genome.fa
	FastqR1=~/$ProjectDirectory/$FastqDirectory/$fastq_file"_1.fastq"
	FastqR2=~/$ProjectDirectory/$FastqDirectory/$fastq_file"_2.fastq"



#################################################################################################################
####################################  FASTQC CONTROL  ###########################################################
#################################################################################################################

#conda install -c bioconda fastqc
#	FastqcDirectory=$FastqDirectory"_FastQC"
#	mkdir ~/$ProjectDirectory/$FastqDirectory/$FastqcDirectory

#	fastqc $FastqR1 $FastqR2 -o ~/$ProjectDirectory/$FastqDirectory/$FastqcDirectory


#################################################################################################################
############################################## PERFORM ALIGNMENT ################################################
#################################################################################################################

#Install STAR
#conda install -c bioconda star
#System complained that the index version that was on my computed was not compatible with the version of STAR run by Anaconda, so I had to 
#re-run the indexing step with the newest version of STAR.


#Build index STAR
#STAR  --runMode genomeGenerate --runThreadN 4 --genomeDir ~/references/hg19/ --genomeFastaFiles ~/references/hg19/GRCh37.p13.genome.fa


#Run the alignment
	STAR --genomeDir ~/references/hg19 --readFilesIn $FastqR1 --outFileNamePrefix ~/$ProjectDirectory/$FastqDirectory/$fastq_file"_" --runThreadN 10


#Signaling_Project_Labadorf/SRR1747143/SRR1747143Aligned.out.sam


###################################################################################################################################
#############################################  EXTRACT READ COUNTS WITH HTSEQ COUNT ###############################################
###################################################################################################################################
	htseq-count -i gene_name ~/$ProjectDirectory/$FastqDirectory/$FastqDirectory"_Aligned.out.sam" ~/references/hg19_bme237/gtf/gencode.v19.annotation.gtf > ~/$ProjectDirectory/$FastqDirectory/$FastqDirectory".counts"


###################################################################################################################################
#############################################  DELETE FASTQ FILES AND SAM FILES ###################################################
###################################################################################################################################



#	rm ~/$ProjectDirectory/$FastqDirectory/$fastq_file"_1.fastq"
#	rm ~/$ProjectDirectory/$FastqDirectory/$fastq_file"_2.fastq"
#	rm ~/$ProjectDirectory/$FastqDirectory/$FastqDirectory"_Aligned.out.sam"

done

