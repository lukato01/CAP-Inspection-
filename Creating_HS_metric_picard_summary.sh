module load python/2.7.6 awscli
while read folder; do

  ###
  ## part 1: copying files from AWS
  #
  src_folder="s3://s4-gtl-clinicaldata-2017/qxt/results/ngs/"$folder
  #dst_folder="/sc/orga/work/lukato01/hs_metrics_glacier/"$folder
  dst_folder="/sc/orga/projects/NIPT/data/scratch/CAP/"$folder
  
  # test if file exists at the source folder, if not skip all following code 
  echo "Testing if per_sample_capture.tsv exists in the folder $src_folder"
  exists=$(aws s3 ls $src_folder"/per_sample_capture.tsv")
  if [ -z "$exists" ]; then
    continue
  fi

  # copy the per_sample_capture.tsv file
  cmd1="aws s3 cp "$src_folder"/per_sample_capture.tsv $dst_folder/per_sample_capture.tsv"
  echo "Copying the per_sample_capture.tsv with command: $cmd1"
  eval $cmd1
   
  # copy the *dedup.bam files
  cmd2="aws s3 cp s3://s4-gtl-clinicaldata-2017/qxt/results/ngs/"$folder"/results/ $dst_folder --recursive --exclude \"*\" --include \"*dedup.bam\" --force-glacier-transfer"
  echo "Copying the *dedup.bam files with command: $cmd2"
  eval $cmd2
  
  ###
  ## Part 2: running picard summary
  #
  for file in /sc/orga/projects/NIPT/data/scratch/CAP/$folder/*.dedup.bam
  do	 
  	  # Wait here while max number of jobs is started, as soon as one job finishes start another
	  max_jobs="500"
	  while true; do
	    
	    njobs=`bjobs 2>&1 | grep "lukato01" | grep -o "mycode3" | wc -l`	    
	    if [ "$njobs" -ge "$max_jobs" ]; then
	       echo "have $max_jobs jobs or over, sleeping 5 seconds and checking status again"
	       sleep 10
	    else
	       echo "have less than $max_jobs jobs, starting another job"
	       break
	    fi
	  done
	  
	  SAMPLE=`echo $file | rev | cut -d"." -f3 | rev`
	  PART2=`basename "$file"`
	  MYBAIT=`cat /sc/orga/projects/NIPT/data/scratch/CAP/$folder/per_sample_capture.tsv | grep $SAMPLE | cut -f2`
	  cmd="module load picard/2.7.1-mgtl; java -jar -Xmx2g /hpc/packages/minerva-common/picard/2.7.1/picard.jar CollectHsMetrics I=$file O=/sc/orga/projects/NIPT/data/scratch/CAP/$folder/$PART2.HsMetrics.picard BAIT_INTERVALS=$MYBAIT TARGET_INTERVALS=$MYBAIT"
	  
	  bsub -W 1:00 -q alloc -P acc_Sema4 -o mybsub3.out -e mybsub3.err -J mycode3 "$cmd"
	  
	  echo "Running cmd: $cmd"
      echo 
  done
  
  ###
  ## Extra part: sit here until all the jobs are finished
  #
  while true; do
	
	njobs=`bjobs 2>&1 | grep "lukato01" | grep -o "mycode3" | wc -l`
	if [ "$njobs" -ge "1" ]; then
	  echo "$njobs jobs are still running, sleeping x seconds and checking status again"
	   sleep 5
	 else
	   echo "No more jobs, proceeding"
	   break
	 fi
  done
  
  
  ###
  ## Part 3: clean the files that were downloaded
  #
  cmd3="rm -rf $dst_folder/*.dedup.bam"
  # cmd3="rm -rf $dst_folder"
  echo "Running the remove files command: $cmd3"
  eval $cmd3
  
  
done < /sc/orga/work/lukato01/needpicardsummaryfolders.txt
