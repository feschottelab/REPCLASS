README for REPCLASS
-------------------
**Initial Setup**
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

TABLE OF CONTENT

1. CONFIGURE REPCLASS AND REQUIRED BINARIES

2. DOWNLOAD AND UNZIP REPBASE UPDATE COLLECTION

3. RUNNING REPCLASS

-------------------

**Initial Setup**

Please, read the entire setup process before proceeding, and make sure you understand each step required for a successful setup.

1. CONFIGURE REPCLASS AND REQUIRED BINARIES

	1.1. Go to 'REPCLASS/conf' folder.
	1.2. Open 'repclass.conf' file and make the following modifications:
	
		1.2.1. Configure the '$REPCLASS' entry to the complete location of the REPCLASS folder.
			e.g. $REPCLASS = "/home/software/REPCLASS";

		1.2.2. Configure the '$BIOPERL' entry to the complete location of the BioPerl directory.
			e.g. $BIOPERL = "/usr/bin/perl";

		1.2.3. Configure the '$PROGRAMS' entry to the complete location of the EMBOSS suite executables or binaries.
			e.g. $PROGRAMS = "/home/software/EMBOSS-6.0.1";

		1.2.4. Configure the '$WUBLAST' entry to the complete path of the WU-BLAST directory.
			e.g. $WUBLAST = "/home/software/wublast";

		1.2.5. Follow the instructions in the 'repclass.conf' file for the other entries, and then proceed to 2. when finished.

2. DOWNLOAD AND UNZIP REPBASE UPDATE COLLECTION

	2.1. Download and unzip latest Repbase Update collection (EMBL format) from http://www.girinst.org/server/RepBase/index.php    in the 'REPCLASS/repbase' folder.

		2.1.1. e.g. Link as it appears on Repbase website: 'RepBase14.04.embl.tar.gz'

		2.1.2. The compressed file in the 'REPCLASS/repbase' would be 'RepBase14.04.embl.tar.tar'

		2.1.3. Before you uncompress the file, move it to its definitive location
			e.g. type in:
				cp /Path_to_its_current_location/RepBase14.04.embl.tar.gz  /home/software/REPCLASS/repbase/

		2.1.4. Now, move to the 'REPCLASS/repbase' folder, and then unzip the file in the current directory using the following command:
			tar zxvf RepBase14.04.embl.tar.tar

		2.1.5. You should get a folder named 'RepBase14.04.emb' which contains files with the extension '.ref', and a folder named 'appendix' which also contains files with the same extension.

		2.1.6. You can now proceed to 2.2. but make sure that you are in the same directory where the file was uncompressed namely '/home/software/REPCLASS/repbase'

	2.2. Concatenate all the '.ref' files inside the 'RepBaseXX.XX.embl' folder and its subfolder 'RepBaseXX.XX.embl/appendix' into a single file named 'repbase_all.embl' using the 'cat' command as it follows:
		cat ./RepBase14.04.emb/*.ref  ./RepBase14.04.emb/appendix/*.ref >repbase_all.embl

	2.3. Go to 'REPCLASS/bin' folder and execute the 'repbase.pl' script. This will create a new index file 'repbase.ind' inside the 'REPCLASS/repbase' folder.
		From the command-line, type in: 
			perl ./repbase.pl  /path_to/REPCLASS/conf/repclass.conf

		and then validate.

		Note: Replace 'path_to' by the complete path to the 'REPCLASS' package. For example, if your 'REPCLASS' package is located under the 'software' sub-directory of the 'home' directory, you should type:

			perl ./repbase.pl  /home/software/REPCLASS/conf/repclass.conf

		and then validate your entry.

	2.4. Download and unzip the latest Repbase Update collection (FASTA format)from http://www.girinst.org/server/RepBase/index.php   in the 'REPCLASS/repbase' folder.

		2.4.1. e.g. Link as it appears on Repbase website: 'RepBase14.04.fasta.tar.gz'

		2.4.2. The compressed file in the 'REPCLASS/repbase' folder would be 'RepBase14.04.fasta.tar.tar'

		2.4.3. Before you uncompress the file, move it to its definitive location
			e.g. type in:
				cp /Path_to_its_current_location/RepBase14.04.fasta.tar.gz /home/software/REPCLASS/repbase/

		2.4.4. unzip the file in the current directory using the following command:
			tar zxvf RepBase14.04.fasta.tar.tar

		2.4.5. You should get a folder named 'RepBase14.04.fasta' which contains files with the extension '.ref', and a folder named 'appendix' which also contains files with the same extension.

		2.4.6. You can now proceed to 2.5. but make sure that you are in the same directory where the file was uncompressed namely '/home/software/REPCLASS/repbase'

	2.5. Concatenate all the '.fasta' files inside the 'RepBaseXX.XX.fasta' folder and its subfolder 'RepBaseXX.XX.fasta/appendix' into a single file named 'repbase_all.fasta' using the 'cat' command as it follows:
		cat ./RepBase14.04.fasta/*.ref ./RepBase14.04.fasta/appendix/*.ref >repbase_all.fasta

	2.6. Go to '$WUBLAST' folder and create the subfolder 'db'. From the command-line, type in:
		mkdir db

	And then, generate 'xdf' format files for the 'repbase_all.fasta' file.
		e.g. from the command-line, simply type in:
	./xdformat -n -o db/repbase_all.fasta   /home/software/REPCLASS/repbase/repbase_all.fasta

	This will generate three files with extensions '.xnt', '.xns', and '.xnd'. (you may also refer to 'rc.pl' script in 'REPCLASS/bin' for the command used above).

3. RUNNING REPCLASS

Open the 'README--UserGuide101.txt' file located in 'REPCLASS.1.0.1.documentation' folder and follow the instructions. The user guide tells you where to access the configuration file required for each run, and which parameters to change. This is the last step before running REPCLASS.

