####   restoring vcf files ####

egrep "qxt/results/ngs/[^/]*/results/[^/]*.vcf.gz" /sc/orga/projects/CCSQXT/data/scratch/lukato01/s4-gtl-clinicdata-2017_20180814.txt |grep ".vcf.gz$"  > vcffiles.txt
cat vcffiles.txt  | egrep -v "\.(raw|disc|tomm|IND|SNP|gvcf)\.vcf\.gz$" | tr -s " " | cut -d" " -f4 > restore_vcf.txt

module load python/2.7.6 awscli
cat frestore_vcf.txt|while read line;
do
  cmd="aws s3api restore-object --bucket s4-gtl-clinicaldata-2017 --key "$line" --restore-request '{\"Days\":120,\"GlacierJobParameters\":{\"Tier\":\"Bulk\"}}'" ;
  echo $cmd
  echo $cmd >> log.today
  eval $cmd
done


egrep "qxt/results/ngs/[^/]*/results/[^/]*dedup.bam" /sc/orga/projects/CCSQXT/data/scratch/lukato01/s4-gtl-clinicdata-2017_20180814.txt |grep ".dedup.bam$"  > bamfiles.txt
cat bamfiles.txt  | tr -s " " | cut -d" " -f4 > restore_bamfiles.txt

cat resoter_bamfiles.txt |while read line;
do
  cmd="aws s3api restore-object --bucket s4-gtl-clinicaldata-2017 --key "$line" --restore-request '{\"Days\":120,\"GlacierJobParameters\":{\"Tier\":\"Bulk\"}}'" ;
  echo $cmd
  echo $cmd >> log.today
  eval $cmd
done


#####  restore RunSummary.txt/Undetermined.csv ######

egrep "RunSummary.txt|Undetermined.csv$" /sc/orga/projects/CCSQXT/data/scratch/lukato01/s4-gtl-clinicdata-2017_20180814.txt > RunSummary_Undetermined.txt
cat RunSummary_Undetermined.txt  | tr -s " " | cut -d" " -f4 > restore_RunSummary_Undetermined.txt.txt

module load python/2.7.6 awscli
cat restore_RunSummary_Undetermined.txt.txt|while read line;
do
  cmd="aws s3api restore-object --bucket s4-gtl-clinicaldata-2017 --key "$line" --restore-request '{\"Days\":120,\"GlacierJobParameters\":{\"Tier\":\"Bulk\"}}'" ;
  echo $cmd
  echo $cmd >> log.today
  eval $cmd
done



