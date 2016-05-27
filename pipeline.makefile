dhs_peaks.broadPeak : filtered.bam
	macs2 callpeak -t filtered.bam -f BAM -n dhs -g 1.23e9 -q 0.05 -B --broad

filtered.bam : aligned.bam
	java -jar $$PICARD/picard.jar SortSam INPUT=aligned.bam OUTPUT=sorted.bam SORT_ORDER=coordinate VALIDATION_STRINGENCY=SILENT
	java -jar $$PICARD/picard.jar MarkDuplicates INPUT=sorted.bam OUTPUT=sorted.marked.bam METRICS_FILE=output.dup_metrics REMOVE_DUPLICATES=false ASSUME_SORTED=true VALIDATION_STRINGENCY=SILENT
	samtools view -b -q 15 sorted.marked.bam > filtered.bam
	rm sorted.bam sorted.marked.bam

aligned.bam : R1_val_1.sai R2_val_2.sai
	bwa sampe $(ASSEMBLY) R1_val_1.sai R2_val_2.sai R1.fq.gz R2.fq.gz | samtools view -bS - > $@

%.sai: %.fq.gz
	bwa aln -q 15 -t 8 $(ASSEMBLY) $< > $@

R1_val_1.fq.gz R2_val_2.fq.gz : R1.fq.gz R2.fq.gz
	trim_galore --paired $^

%.fq.gz : %.fastq.gz
	mv $< $@

