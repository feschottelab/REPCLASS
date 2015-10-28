README for REPCLASS
-------------------
last update 08/03/09

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

TABLE OF CONTENT:

1. GENERAL INFORMATION

2. TEs' CLASSIFICATION

3. REPCLASS MODULES

4. REPCLASS INSTALLATION

-------------------

1. GENERAL INFORMATION

REPCLASS is a software which automates the classification of transposable elements (TEs) in eukaryotic genomes. The actual package contains a:

	1.1. 'bin' folder with seven perl scripts, among which 'choosemodule.pl' and 'rc.pl' (these are the files that you will have to use for each run of REPCLASS as indicated in the 'README--UserGuide101.txt' sections 5.)

	1.2. 'conf' folder with:

		1.2.1. a 'tsdxml' folder
		
		1.2.2. two configuration files:

			* a 'repclass.conf' file: contains the location of all the REPCLASS binaries, plus input and output files, external softwares and repbase files;

			* a 'theconfig.conf' file: used as template to generate a 'userconfigure.conf' file in the folder of the user.

		1.2.3. the 'conf' folder also contains a 'tempchoice' file: the user would have to create a similar file namely 'mytempchoice' in his folder.

		The 'mytempchoice' stores the choice operated by the user.

	1.3. 'repbase' folder where the latest Repbase Update collection (EMBL, and fasta formats) will be downloaded and uncompressed; the indexed file ('repbase.ind') of the concatenated RepBase EMBL file ('rebase_all.embl') will also be created in this folder by the program

	1.4. 'scripts' folder containing six (06) perl scripts used to filter out false positive from the consensus sequences' library which sequences are used as queries in the program.

	1.5. 'tmp' folder which is required during the creation of the Repbase indexed file


2. TEs' CLASSIFICATION

The classification of TEs by REPCLASS is a multi-step process which involves:

	2.1. IDENTIFICATION of the repetitive DNA (TE) landscape of the target genome in the first place: 

	This is done using 'REPEATSCOUT'. We recommend 'REPEATSCOUT' over many other repeat identifiers (e.g. Recon, ReAS) because, during our experiments we found that repeats identified by this program are of better quality (more complete - better end points or boundaries, help classification).

		2.1.1. Input to such programs generally is the genome file of the organism in fasta format. Please make sure there are no 'N's character in the genome file. This could lead to repeats with 'N's being identified and lead to false positives by REPCLASS.

		2.1.2. Output generally is a library of consensus sequences.

		2.1.3. For help with how to run REPEATSCOUT, please refer this:  http://bix.ucsd.edu/repeatscout/readme.1.0.5.txt'.

	2.2. FILTERING:

The analysis of different genomes has revealed that:

		2.2.1. the repeats identified by the repeat identifier programs are not transposable elements (TEs).

		2.2.2. the number of these non-TEs was significant enough to hamper REPCLASS performance (more repeats, more time consummed, and more false positives).

		2.2.3. Hence, we decided to filter out these non-TEs based on repeat length (number of nucleotides in the consensus sequence) and copy number (number of copies of these TEs in the genome).

		2.2.4. For such filtering, we provide 6 scripts, 3 for repeatlength and 3 for copynumber filtering. These scripts are located in the 'scripts' folder of the downloadable REPCLASS package (REPCLASS/scripts). A full description of each of these scripts is given in the 'README--Filtering101.txt' file located in the 'REPCLASS.1.0.1.documentation' folder of the REPCLASS package.

		2.2.5. The "README--Filtering101.txt" file also explains in detail the entire process, and the input and output files' formats for each scipt.

	2.3. CLASSIFICATION:

This is the final step which involves the REPCLASS software. This program requires two fasta files as inputs:

		2.3.1. Genome file of the organism in the fasta format. It is the same file that was input to REPEATSCOUT (recommended) or other repeat identifier programs (of your choice).

		2.3.2. A library of consensus sequences in fasta format. This can be the file obtained by running the genome sequence (in 2.3.1.) through programs like REPEATSCOUT (in 2.1.) (recommended) or other similar programs. But, usually it will be the file obtained after filtering the REPEATSCOUT output by using the above mentioned filtering scripts (in 2.2.).

		2.3.3. Once you have both of the above mentioned files ready, the genome and consensus library, please, refer to the 'README--UserGuide101.txt' file located in the 'REPCLASS.1.0.1.documentation' folder of the REPCLASS package. This user guide contains all the information needed to perform a successful configuration of all the entries required for each run.

3. REPCLASS MODULES

REPCLASS classifies TEs using three different modules (1) as it follows:

	3.1. Homology-based (HOM) approach:
	looks for conserved domains and motifs of previously annotated TEs.

	3.2. Structural (STR):
	identfies known characteristic features at the termini of annotated TEs such as the:

		3.2.1. simple sequence repeats at the end of the non-LTR retrotransposons

		3.2.2. long terminal repeats of the LTR retrotransposons

		3.2.3. terminal inverted repeats (TIRs) of the cut-and-paste DNA transposons

		3.2.4. and the rolling-circle transposons (Helitrons) which display a short GC-rich palindromic stem loop structure near one end and a 5'-TC-3' motif at the other end.

	3.3. Target Site Duplication (TSD):
	this third module of RC is designed to determine the short target site duplication (TSD module) of host sequence induced upon chromosomal integration of individual elements. The length and sequence of the TSD reflects the mechanisms and properties of the enzymes catalyzing integration. Thus TSD length is often diagnostic of specific subclasses or superfamilies. For example, 

		3.3.1.	non-LTR elements are flanked by TSD of variable length, 

		3.3.2.	LTR elements create 4-6 bp TSD, 

		3.3.3.	DNA transposons have TSDs that vary from 2 to 9 bp but are generally conserved in length for a given family and superfamily, 

		3.3.4.	and Helitrons create no TSD upon insertion but they insert between a 5’-A and a 3’-T.

	Hence, information on TSD can be useful to confirm or refine the classification based on other criteria.

4. REPCLASS INSTALLATION

Please refer to the "README--Install-Repclass101.txt" file which is located in the 'REPCLASS' directory as the current "README--General-Info101.txt" and the "README--Initial-Setup101.txt".

