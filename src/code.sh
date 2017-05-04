#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x

# set default java to java version 8 (prepackaged in this app)
sudo update-alternatives --install /usr/bin/java java /usr/bin/jdk1.8.0_45/bin/java 10000

# Fetch input files
dx download "$input_vcf" 
dx download "$panel_bedfile" 
dx download "$truth_vcf"
dx download "$high_conf_bedfile"
dx download project-F2VPgqQ0KzKZkPfQKJ90F8J2:/Workflows/vcfeval_test_may17/human_g1k_v37_chr1-22XYonly.fasta


echo "$input_vcf_name"
vcfname="$input_vcf_name"
if [[  $vcfname =~ \.gz$ ]]; then 
	vcfname=$(echo ${vcfname%.*})
	echo "ZIPPED VCF unzipping."
	gzip -cd $input_vcf_name > $vcfname
	#vcfname=$input_vcf_prefix.vcf
	echo $vcfname
else 
	echo "not zipped"
	echo $vcfname
fi

#capture panel number from bedfile
panelnumber=$panel_bedfile_prefix

#make folders to put output files
mkdir -p ~/out/vcfeval_files/vcfeval_output ~/out/rtg_output/vcfeval_output

#remove chr from vcf and bedfile (incase present)
sed 's/chr//' $vcfname > ~/$input_vcf_prefix.minuschr.vcf
sed  -i 's/chr//' $panelnumber.bed

#create sdf
/usr/bin/rtg-tools-3.7-23b7d60/rtg format -o ~/reference.sdf ~/human_g1k_v37_chr1-22XYonly.fasta

# #unzip truth VCF
# gzip -cd $truth_vcf > /home/dnanexus/truth.vcf

# # Run vt on truth vcf
# /usr/bin/vt/vt  decompose -s /home/dnanexus/truth.vcf | /usr/bin/vt/vt normalize -r ~/genome.fa - > /home/dnanexus/normalised_truth.vcf

# # zip and index the vcf file
# bgzip -c /home/dnanexus/home/dnanexus/normalised_truth.vcf > /home/dnanexus/home/dnanexus/normalised_truth.vcf.gz
# tabix -p vcf /home/dnanexus/home/dnanexus/normalised_truth.vcf.gz
tabix -p vcf $truth_vcf_name

 
# Run vt on test vcf
#/usr/bin/vt/vt  decompose -s ~/$input_vcf_prefix.minuschr.vcf | /usr/bin/vt/vt normalize -r ~/genome.fa - > ~/$input_vcf_prefix.minuschr_normalised.vcf
# zip and index the test vcf file
bgzip -c ~/$input_vcf_prefix.minuschr.vcf > ~/test.vcf.gz
tabix -p vcf ~/test.vcf.gz

#create intersect bedfile
 /usr/bin/bedtools2/bin/bedtools intersect -a $panelnumber.bed -b $high_conf_bedfile_name > intersect.bed

# run RTG
/usr/bin/rtg-tools-3.7-23b7d60/rtg vcfeval -b $truth_vcf_name --bed-regions intersect.bed -c ~/test.vcf.gz -t /home/dnanexus/reference.sdf -o ~/out/rtg_output/vcfeval_output/rtg --vcf-score-field=$score_field
/usr/bin/rtg-tools-3.7-23b7d60/rtg rocplot --png=/home/dnanexus/out/vcfeval_files/vcfeval_output/$input_vcf_prefix.roccurve.png /home/dnanexus/out/rtg_output/vcfeval_output/rtg/weighted_roc.tsv.gz

python read_vcf_output.py

mv  ~/$input_vcf_prefix.minuschr.vcf ~/out/vcfeval_files/vcfeval_output/$input_vcf_prefix.minuschr_normalised.vcf
mv ~/intersect.bed  ~/out/vcfeval_files/vcfeval_output/$panelnumber.NA12878intersect.bed
mv ~/medcalc_input.txt ~/out/vcfeval_files/vcfeval_output/$panelnumber.medcalc_input.txt

#mark-section "Uploading results"
dx-upload-all-outputs --parallel