README for REPCLASS
-------------------
**FILTERING**
-------------------
ast update 08/03/09

Minor modifications:
	- Multi-users capability
	- Running REPCLASS without a target genome

version 1.0.1

Feschotte Lab - University of Texas at Arlington

Contact information for FAQs and/bugs:

Cedric Feschotte
Email: cedric@uta.edu
Office: 817-272-2426

Marcel L. Guibotsy Mboulas
Email: mguibotsy@uta.edu
Lab: 817-272-5574
Fax: 817-272-2855


Thanks:

Umeshkumar Keswani
Nirmal Ranganathan
Marcel L. Guibotsy Mboulas
Assiatou Barrie
David Levine

-------------------

**FILTERING**

The filtering process is required to remove all the non-transposable elements (non-TEs) from the consensus library which sequences are used to classify TEs of the target genome.

Non-TEs are filtered out based on repeat length (number of nucleotides in the consensus sequence) and copy number (number of copies of these sequences in the target genome).

For such filtering, we provide 6 scripts, 3 for repeatlength and 3 for copynumber filtering. These scripts are located in the 'scripts' folder of the downloadable REPCLASS package (REPCLASS/scripts). Here is a full description of each:
	
1. to_get_repeatlength - this script is useful for getting the repeatlength per consensus sequence in the input.
	
	 Usage: to_get_repeatlength.pl <input filename> <output filename>
	 input filename  - library of consensus sequences which length/charactercount you would like to know.
	 output filename - file where you would like to store the output.
	 output format:
	<consensus name/number 1> <character count 1>
	<consensus name/number 2> <character count 2>
	...

2. to_get_copynumer.pl - this scripts is useful for getting the copynumber per consensus sequence.

	 Usage: to_get_copynumber.pl <input filename> <matchlength> <matchaccuracy> <output filename>

 	input filename  - blastn output of the library of consensus sequences (e.g. repeatscout output) whose copynumber you would like to know. Please find 'SAMPLE_BLASTN_OUPUT.out' for reference [Give location].
	match length    - minimum % of the consensus length that should match the genome to be counted as a copy. 
			usual value 0.50 (for 50%).
	match accuracy	- minimum % of accuracy required for a match to be considered as a copy. 
			usual value '0.85' (for 85% i.e. 15% mismatch).
	output filename - file where you would like to store the output.
	output format:
	<consensus name/number 1> <copynumber 1> <first match label 1>
	<consensus name/number 2> <copynumber 2> <first match label 2>
	...
	
3. repeatlength_distribution.pl - this script is useful for getting repeatlength distribution for the consensus lib.

	Usage: repeatlength_distribution.pl <input filename> <output filename> <bucket>

	input filename  - library of consensus sequences whose length/charactercount you would like to know.
	output filename - file where you would like to store the output.
	bucket          - distribution bucket.
	output format:
	0 <number of consensuses whose character count falls between 0*bucket and 1*bucket>
	1 <number of consensuses whose character count falls between 1*bucket and 2*bucket>
	2 <number of consensuses whose character count falls between 2*bucket and 3*bucket>
	...
 
4. copynumber_distribution.pl - this script is useful for getting copynumber distribution for the consensus library.

	 Usage: copynumber_distribution.pl <input filename> <matchlength> <matchaccuracy> <bucket> <output filename>

	 input filename - blastn output of the library of consensus sequences whose copynumber you would like to know.
	 match length	- minimum % of the consensus length that should match the genome to be counted as a copy. 
			usual value 0.50 (for 50%).
	 match accuracy - minimum % of accuracy required for a match to be considered as a copy. 
        	           usual value '0.85' (for 85% i.e. 15% mismatch).
	 bucket		- distibution bucket. 
	 output filename - file where you would like to store the output.
	 output format:
	0 <number of consensuses whose copynumber falls between 0*bucket and 1*bucket>
	1 <number of consensuses whose copynumber falls between 1*bucket and 2*bucket>
	2 <number of consensuses whose copynumber falls between 2*bucket and 3*bucket>
	...

5. consensus_removal_based_on_repeatlength.pl - this script is used to remove consensus sequences from the library using a particular repeatlength threshold. All the consensuses in the library with repeatlength less than or equal to this threshold, will be removed and rest would be copied to a new user specified output file.

	Usage: to_get_repeatlength.pl <input filename> <output filename>

	input filename  - library of consensus sequences whose length/charactercount you would like to know.
	output filename - file where you would like to store the output.
	user threshold  - character count threshold. all the consensus sequences in the input file having character count                              less than or equal to this threshold will be classified as bad repeats.
	output format: same as input format with all bad repeats removed.

6. consensus_removal_based_on_copynumber.pl - this script is used to remove consensus sequences from the library using a particular copynumber threshold. All the consensuses in the library with copynumber less than or equal to this threshold, will be removed and rest would be copied to a new user specified output file.
	
	Usage: to_get_copynumber.pl <input blast output> <input fasta filename> <output filename> <user threshold> <matchlength> <matchaccuracy>

	 input blast output - blastn output of the library of consensus sequences (e.g. repeatscout output).
	 input fasta file   - library of consensus sequences (e.g. repeatscout output).
	 output filename    - file where you would like to store the output.
	 user threshold     - copynumber threshold. all the consensus sequences in the input fasta file having copynumber             	                 less than or equal to this threshold will be classified as bad repeats.
	 match length	- minimum % of the consensus length that should match the genome to be counted as a copy. 
			usual value 0.50 (for 50%).
	 match accuracy	- minimum % of accuracy required for a match to be considered as a copy. 
			usual value '0.85' (for 85% i.e. 15% mismatch).
	 output format: same as input fasta file with all bad repeats removed.

