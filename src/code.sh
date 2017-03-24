#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x

# set default java to java version 8 (prepackaged in this app)
sudo update-alternatives --install /usr/bin/java java /usr/bin/jdk1.8.0_45/bin/java 10000

# Fetch input files
dx download "$input_vcf" 
dx download "$bedfile" 

#input_vcf2=$input_vcf
#check if vcf is .gz
echo "$input_vcf_name"
vcfname="$input_vcf_name"
if [[  $vcfname =~ \.gz$ ]]; then 
	echo "ZIPPED VCF unzipping.";
	gzip -cd $input_vcf_name > $input_vcf_prefix.vcf;
	#input_vcf=$input_vcf_prefix
	#input_vcf_prefix=$(basename $input_vcf .vcf.gz)
else 
	echo "not zipped";
fi

# if [[ input_vcf2 =~ \.gz$ ]] then; do
# 	#unzip
# 	gzip -cd $input_vcf2 > unzipped_vcf
# 	input_vcf2=unzipped_vcf
# done

#make vt , rtg and bedtools executable
#sudo chmod u=x /usr/bin/vt/vt
#sudo chmod u=x /usr/bin/rtg-tools-3.7-23b7d60/rtg
#sudo chmod u=x /usr/bin/bedtools2/bin/bedtools

panelnumber=$bedfile_prefix

#make folders to put output files
mkdir -p ~/out/vcfeval_files/vcfeval_output ~/out/rtg_output/vcfeval_output

#remove chr from vcf and bedfile (incase present)
sed 's/chr//' $input_vcf_prefix.vcf > ~/$input_vcf_prefix.minuschr.vcf
sed  -i 's/chr//' $panelnumber.bed

#create sdf
/usr/bin/rtg-tools-3.7-23b7d60/rtg format -o ~/reference.sdf ~/genome.fa

 
# Run vt
/usr/bin/vt/vt  decompose -s ~/$input_vcf_prefix.minuschr.vcf | /usr/bin/vt/vt normalize -r ~/genome.fa - > ~/$input_vcf_prefix.minuschr_normalised.vcf

# zip and index the vcf file
bgzip -c ~/$input_vcf_prefix.minuschr_normalised.vcf > ~/normalised.vcf.gz
tabix -p vcf ~/normalised.vcf.gz

#create intersect bedfile
 /usr/bin/bedtools2/bin/bedtools intersect -a $panelnumber.bed -b ~/NA12878.bed > intersect.bed

# run RTG
/usr/bin/rtg-tools-3.7-23b7d60/rtg vcfeval -b /home/dnanexus/GIAB_NA12878_v2.18_minus_chr.vcf.gz --bed-regions intersect.bed -c ~/normalised.vcf.gz -t /home/dnanexus/reference.sdf -o ~/out/rtg_output/vcfeval_output/rtg --vcf-score-field=QUAL
/usr/bin/rtg-tools-3.7-23b7d60/rtg rocplot --png=/home/dnanexus/out/vcfeval_files/vcfeval_output/$input_vcf_prefix.roccurve.png /home/dnanexus/out/rtg_output/vcfeval_output/rtg/weighted_roc.tsv.gz

python read_vcf_output.py

mv  ~/$input_vcf_prefix.minuschr_normalised.vcf ~/out/vcfeval_files/vcfeval_output/$input_vcf_prefix.minuschr_normalised.vcf
mv ~/intersect.bed  ~/out/vcfeval_files/vcfeval_output/$panelnumber.NA12878intersect.bed
mv ~/medcalc_input.txt ~/out/vcfeval_files/vcfeval_output/$panelnumber.medcalc_input.txt

#mark-section "Uploading results"
dx-upload-all-outputs --parallel