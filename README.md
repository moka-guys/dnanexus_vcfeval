# dnanexus_vcfeval v1.1

## What does this app do?

This calculates sensitivity and specificity using the NA12878 truth sample. 

## What are typical use cases for this app?

When validating a new test, or changes to a process the NA12878 DNA sample can be run through a process. The resulting 'test' vcf  contains all the variants detected by the test.

This list of variants can be compared to the truth set and then calculate specificity and sensitivity.

The app produces a count of true positive, true negative, false positive and false negative calls which can then be used to calculate sensitivity and specificity (with 95% confidence intervals using the calculator at https://www.medcalc.org/calc/diagnostic_test.php)

## What data are required for this app to run?

This app requires a vcf.gz and a bed file.
Note:  
1. Currently the vcf file must not be gzipped (Future versions of this app may be able to handle .vcf,gz) 
2. The bedfile name must not contain spaces or characters such as + and -


## What does this app output?

This app outputs:
1. RTG output folder including
 * VCF files for true positive, false positive and false negatives
 * ROC curves
 * summary.txt containing the TP/FP/FN/TN counts
2. A file which has parsed summary.txt and the bedfile to produce an output which can be used with the online statistical calculator.
3. the normalised ROC curve
4. A bedfile with the intersect between the NA12878 high confidence regions and the test bed file.
5. The normalised test vcf


## How does this app work?
* The NA12878 truth vcf and bed file is packaged within the app.

* The test vcf and bed file are parsed to remove 'chr'

* vt is then used to decompose the test vcf
* The normalised vcf is then indexed and zipped
* The intersect between the NA12878 high confidence regions and the test bed is created
* RTG vcf eval is used to calculate the sensitivity and specificity
* RTG rocplot creates a ROC curve.

* A python scrip then parses the vcfeval outputs and the bed file to produce an output which can be easily entered into the medcalc software.


## This app was made by Viapath Genome Informatics 



