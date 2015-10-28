README for REPCLASS
-------------------
**User configuration guide**
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

**User Configuration Guide**

This guide tells you where to access the different variables to be configured for each run, where to access and how to read the outputs.

Please, read the entire 'User Configuration guide' before proceeding, and make sure you understand each step required for a successful configuration.

0. Before proceeding to the next step:

	*  make sure that all the suite executables or binaries required to run REPCLASS are installed on your machine: check the 'README--Install-Repclass101.txt' file

	*  make sure that the variables in the 'repclass.conf' file have been configured to the complete location of each executable or binary (check the 'README--Initial-Setup101.txt' file), and

	* more importantly,  make sure that the latest Repbase Update collections (EMBL and FASTA formats) have been downloaded and uncompressed to the 'REPCLASS/repbase' folder, and that the index file 'repbase.ind' has been created. Check 'README--Initial-Setup101.txt' file, section 2. and follow the guidelines.

1. Create a 'mytempchoice' file in your folder. This file stores the module choosen by the user. Type in:
	/home/your_folder/REPCLASS/Myconf/mytempchoice

No ';' after you have typed in this line on the command-line; then validate your entry. A blank page will appear; hold the 'Shift' button on the keyboard, and then hit the ':' 
Release both keys and then type in:
	wq!

and then validate your entry. You should get a message at the bottom of the command-line saying:
	"mytempchoice" 854L, 25032C written
or
	"/home/your_folder/REPCLASS/Myconf/mytempchoice" 854L, 25032C written

This means that the 'mytempchoice' file was successfully created.

However, before doing so, make sure that a 'REPCLASS' folder and a 'Myconf' sub-folder exist in your folder. Otherwise, create them by typing:

	mkdir /home/your_folder/REPCLASS

validate your entry, and then, create the 'Myconf' sub-folder under your 'REPCLASS' folder as it follows:

	mkdir /home/your_folder/REPCLASS/Myconf

and validate.

Once done, you can now create the 'mytempchoice' file as directed at the beginning of this 1. section.

2. Copy the 'theconfig.conf' file located in the 'REPCLASS/conf' folder to your 'REPCLASS/Myconf' folder and rename it appropraitely. e.g. use the command:
	cp /home/software/REPCLASS/conf/theconfig.conf  /home/your_folder/REPCLASS/Myconf/userconfigure.conf

3. Open this 'userconfigure.conf' file and make the following modifications:

	3.1. Configure the '$JOB_NAME' entry to an appropriate job name (e.g. name of the species and assembly, or name of organism):
		e.g. $JOB_NAME = "hg18";

	3.2. Configure the '$DATA' entry to the complete location of the folder where you want the repclass output to be located.
		e.g. $DATA = "/mnt/disk4/your_folder/REPCLASSoutputs/human_genome_HOM";

		Note: We suggest that you have your outputs on another directory than the 'home' because of the large amount of data generated; plus, the 'home' directory should be only reserved to programs and the users' entries along with their respective settings for each software. See your administrator for details.

	3.3. '$TEMPCHOICE' variable stores the path of the temporary file which contains the module choosen by the user (section 1.) Each user set the path of this file to its folder as it follows:
		$TEMPCHOICE	=	"/home/your_folder/REPCLASS/Myconf/mytempchoice";

	3.4. Configure the '$GENOME_LOCATION' entry to the complete location of the target genome fasta file (generally where all the genomes are located).

		3.3.1. If you have a target genome:
		e.g. $GENOME_LOCATION = "/mnt/disk3/genomes"

		3.3.2. If not (no space, nothing, between the quotation marks):
		$GENOME_LOCATION = "";
		
	3.5. '$GENOME_FILE' refers to the actuel name of the input target genome fasta file.

		3.5.1 If you have a target genome, just give its actual name:
		e.g. $GENOME_FILE = "hg18_all";

		3.5.2. Otherwise (no space, nothing, between the quotation marks):
		$GENOME_FILE = "";

	3.6. '$TE_SEQUENCE' entry refers to the complete location of the file which contains the consensus sequences that you want to classify.
		e.g. $TE_SEQUENCE = "/home/your_folder/ConsensusLibrary/human_repeats_cons_seq.txt";

4. Save the modifications and close the 'userconfigure.conf' file.

5. RUNNING REPCLASS

Finally, go to the 'REPCLASS/bin' folder and then run REPCLASS by executing the following two steps:

	5.1. run the 'choosemodule.pl' script, with the location of your 'userconfigure.conf' as the argument, as it follows:

		perl ./choosemodule.pl /home/your_folder/REPCLASS/Myconf/userconfigure.conf

	Note:	No ';' after this line; then validate your entry.

		And beware that the perl interpreter loads the path of your 'userconfigure.conf' file to ensure the proper call of the package variables by the 'choosemodule.pl'; and 'choosemodule.pl' prompts user to choose the module(s) he wants to run, and then stores the choice in the "mytempchoice" file you have created in section 1.

	5.2. and then, run the 'rc.pl' script as it follows:

		perl ./rc.pl /home/your_folder/REPCLASS/Myconf/userconfigure.conf

	Note:	No ';' after this line; then validate your entry.

		Again, the perl interpreter loads the path of the user configuration file into the @ARGV variable; this allows the 'userconfigure.conf' file to be passed into the subsequent perl scripts to ensure the proper call of package variables.

	'rc.pl' will call the 'argvalue' and 5 programs:

		5.2.1. xdformat, in the 'wublast' package, - to create a blastable database from the genome file, so that we can blast the consensus sequence library against this database.

		5.2.2. 'fasta_index.pl' - generates an index fasta file of the target genome file for faster execution.

		5.2.3. 'repclass.pl' - repclass perl script which opens directories for each output, separates each individual consensus sequence and passes them on to 'repmain.pl' as inputs through subsequent calls to this script. 

		5.2.4. 'repmain.pl' - classifies each sequence using the 3 different classification methods namely Homology (HOM), Structural (STR) and TSD. Out of these methods Homology is the most reliable, followed by Structural.

		5.2.5. and 'result.pl' - collates the results obtained for every sequence using the above mentioned three classification methods. For each sequence in the ouput there are three classifications for the user to see. In case there are conflicting classifications, we recommend usign above mentionNed reliability ranking (Homology > Structural > TSD) to resolve it.

	Because the three REPCLASS' modules can be ran independently, be aware that when you start running the program, you will be prompted to chose among seven (07) options:
		
		1 Homology (HOM)

		2 Target Site Duplication (TSD)

		3 Structural (STR)

		4 HOM and TSD

		5 HOM and STR

		6 TSD and STR

		7 HOM, TSD and STR

	When prompted, type in the number which corresponds to your need, and then validate your answer (hit 'Enter' on the keyboard).


'choosemodule', 'rc.pl', 'fasta_index.pl', 'repclass.pl', 'repmain.pl', and 'result.pl' are all located in the 'REPCLASS/bin' folder of the REPCLASS package.

	5.3. Because REPCLASS generates large amount of outputs, it is recommanded to redirect all the outputs to your folder in another disk (e.g. disk4) in the 'mnt' directory. In fact, the space in the 'home' directory is usually limited.

	Accordingly, check with your administrator to have your folder in the 'disk4', along with the 'REPCLASSoutputs' and 'REPCLASSnohup' folders as it follows:
		
		mkdir /mnt/disk4/your_folder/REPCLASSouputs

	and then validate your entry;

		mkdir /mnt/disk4/your_folder/REPCLASSnohup

	and then validate your entry;
		
	5.4. For long processes (large data), or if you wish to run several analyses, you may want to have these processes run in the background because, even though you exit the terminal (shell) or the power goes off, the program would continue to run.

	Accordingly, knowing that the 'REPCLASSoutputs' and 'REPCLASSnohup' folders have been created (section 5.3.), the command in section 5.2. (above) would become:

		nohup perl ./rc.pl /home/your_folder/REPCLASS/Myconf/userconfigure.conf >/mnt/disk4/marcel/REPCLASSnohup/human_genome_HOM.nohup&

	Note:	It is critical that you follow the syntax above with the "&" (ampersand) at the end of the line; then validate your entry.

		Meanwhile, section 5.1. would remain unchanged.

6. HOWTO ACCESS AND READ THE OUTPUTS

	6.1. ACCESSING OUTPOUTS

REPCLASS delivers the results of the analyses in the '$DATA' folder (e.g. see 3.2. above). In '$DATA', you will find a folder which name refers to your reference genome; this folder in turn contains a file ("final.out.txt"), and a folder named after the "$JOB_NAME" entry (see e.g. in 3.1.).

For a summary of the final results, you may want to open the "Final_parsed.txt" file which is also located in the same folder as the "final.out.txt" file.

The folder named after the "$JOB_NAME" entry contains eight (08) to ten (10) folders (which titles are self explanatory), and the "repclass.log file". The "repclass.log file" records information about events such as failure(s) during the process.

	6.2. READING OUTPOUTS

The following would help comprehend the output in "final.out.txt" file:
	
		C()  means this is the classification under CLASS (i for Retrotransposons and ii for Transposons).

		SC() means this is the classification under SUB-CLASS (DNA under Transposon; LTR & Non-LTR under Retrotransposon).

		SF() means this is the classification under SUPER-FAMILY. Refer to manuscript for details.

		H->  means this is the classification obtained using the Homology method.
		
		S->  means this is the classification obtained using the Structural method. 

			S_LTR -> using LTR script,

			S_SSR using Short Sequence Repeat script (refer manuscript for details).

		T->  means this is the classification obtained using Target Side Duplication (TSD) method.


	All the three methods (H,S, & T) can give all the three levels of classifications (C, SC, & SF).

