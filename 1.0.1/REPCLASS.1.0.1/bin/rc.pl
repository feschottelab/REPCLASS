#!/usr/bin/perl


print "\n\nRunning rc\n"; ###

# Check if the user configuration file is provided
if (!$ARGV[0]) {
    print "Usage: rc.pl <user conf file> \n";
    exit(0);
}


# Load the configuration files 
# The require command uses the %INC array to determine 
# whether a given filename has already been included
# This step will include the configuration files
# and all their variables in the %INC array
require("$ARGV[0]");
require("$REPCLASS_CONF");


# Initialize configuration file variables
our $DATA;
our $GENOME_FILE;
our $USERBLASTDB;
our $TEMPCHOICE;
our $MODULES;
our $BIN;
our $WUBLAST;
our $BLASTDB;
our $TSDBLASTDB;
our $GENOME_SEQUENCE;
our $File;


# open the temporary file containing the module chosen by the user
open(CHOICE, "$TEMPCHOICE") || die "\nCannot open $TEMPCHOICE: $!\n";
my $moduleNb = <CHOICE>;
chomp($moduleNb);
close CHOICE;


#############################################################
##### Format target genome fasta file if it is provided #####
if($GENOME_FILE ne "") {
	print "\nRunning wublast to generate blastable database of the target genome fasta file (for tsd)\n\n";

	system "$WUBLAST/xdformat -n -o $BLASTDB/$TSDBLASTDB $GENOME_SEQUENCE";

	###check if the WU-BLAST command failed to execute
	$File = "WU-BLAST";
	&CHKexec;
}
#####							#####
########################End WUBLAST/xdformat##########################

#############################################################################
##### Call fasta_index script if a target genome fasta file is provided #####
if($GENOME_FILE ne "") {
	#print "\n\nCalling fasta_index\n\n"; ###

	system "$BIN/fasta_index.pl $ARGV[0]";

	###check if the fasta command failed to execute
	$File = "FASTA INDEX";
	&CHKexec;
}
#####									#####
#######################End fasta_index.pl####################################

################################
##### Call repclass script #####
#print "\n\nPath for BIN: $BIN\n";

#print "\nCalling repclass\n\n"; ###

system "$BIN/repclass $ARGV[0]";

###check if the repclass command failed to execute
$File = "REPCLASS";
&CHKexec;

#####			#####
#####End repclass script#####

#############################
#####Call results script#####
#print "\nRunning results from rc\n\n"; ###

system "$BIN/result.pl $ARGV[0] > $DATA/final.out.txt";

###check if the results command failed to execute
$File = "RESULT";
&CHKexec;

#####			#####
#####End results script######

#print "\n\nPath for results: $BIN\n\n"; ###


###########################################
##########	Subroutine	###########
###check if the command failed to execute##
###########################################
sub CHKexec {
	if($? == -1) {
        	print "\n$File failed: $!\n";
	}
	else
	{
        	printf "\n$File exited with value %d", $? >> 8;
	}
}
