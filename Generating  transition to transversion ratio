#######
module load python/2.7.6 awscli
module load bcftools

while read folder; do

## part 1: copying files from AWS

dst_folder="/sc/orga/work/lukato01/CAP_inspection_files2/"$folder

# copy the *.vcf.gz files
cmd2="aws s3 cp s3://s4-gtl-clinicaldata-2017/qxt/results/ngs/"$folder"/results/ $dst_folder --recursive --exclude \"*\" --include \"*.vcf.gz\" --force-glacier-transfer"
echo "Copying the *.vcf.gz files with command: $cmd2"
eval $cmd2
  
## part 2: run bcftools
	
	for file in /sc/orga/work/lukato01/CAP_inspection_files/$folder/*.vcf.gz
    do
      outfold="/sc/orga/work/lukato01/CAP_inspection_files/"`echo $folder`"/"
      outfile=`basename $file`".ti_tv"
      bcftools stats "$file" > $outfold$outfile;
      echo "Working on folder $file"
    done
   	
  	  
done < /sc/orga/work/lukato01/CAP_inspection_files/vcf.txt 
