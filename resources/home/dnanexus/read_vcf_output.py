'''
Created on 5 Feb 2017

@author: aled
'''
class report_vcfeval():
	def __init__(self):
		self.vcfeval=open('/home/dnanexus/out/rtg_output/vcfeval_output/rtg/summary.txt','r')
		self.bed=open('/home/dnanexus/intersect.bed','r')
		self.output=open('/home/dnanexus/medcalc_input.txt','w')

		self.TP=0
		self.TN=0
		self.FP=0
		self.FN=0
	
	def do(self):
		''' Read the vcfeval  '''
		# loop through the vcfeval summary file 
		for line in self.vcfeval:
			# split on space
			splitline=line.split(" ")
			vcfeval_out=[]
		for i in splitline:
			# remove the empty elements to capture the true pos, false pos and false neg
			if i != '':
				vcfeval_out.append(i)

		self.TP=int(vcfeval_out[2])
		self.FP=int(vcfeval_out[3])
		self.FN=int(vcfeval_out[4])

		# read the intersect bedfile to count the number of bases tested
		basecount=0
		for line in self.bed:
				splitline=line.split("\t")
				basecount=basecount+(int(splitline[2])-int(splitline[1])+1)
				# true negatives is all the bases minus TP,FP,TN
		self.TN=basecount-int(self.TP)-int(self.FN)-int(self.FP)


		print "TP:"+str(self.TP)
		print "TN:"+str(self.TN)
		print "FP:"+str(self.FP)
		print "FN:"+str(self.FN)

		#calculate sensitvity
		sensitivity=float(self.TP/(self.TP+self.FN))
		print "sensitivity:", str(sensitivity)

		#calculate specificity
		specificity=float(self.TN/(self.TN+self.FP))
		print "specificity:",str(specificity)

		# write to a output file.
		self.output.write("TP:"+str(self.TP)+"\nTN:"+str(self.TN)+"\nFP:"+str(self.FP)+"\nFN:"+str(self.FN)+"\nsensitivity:"+str(sensitivity)+"\nspecificity:"+str(specificity))    
	       
if __name__ == "__main__":
	a=report_vcfeval()
	a.do()