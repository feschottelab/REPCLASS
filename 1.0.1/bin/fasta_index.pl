#!/usr/bin/perl

#################################################################
# REPCLASS 	        - fasta_index.pl                        #
#                                                               #
# Used to index fasta files for faster execution		#
#                                                               #
# 03/23/2005                                                    #
# Nirmal Ranganathan                                            #
#################################################################

print "\n\nRunning fasta... formatting genome fasta file\n\n";


# Check for required arguments
if (!$ARGV[0]) {
    print "Usage: fasta_index.pl <User Conf File>\n";
    exit(0);
}

#print " Environment variable is $ENV \n\n";

# Load configuration file
do "$ARGV[0]";
#do "/usr/lib/Repclass/conf/repclass.conf";
do "$REPCLASS_CONF";

# Initialize configuration file variables
our $GENOME_SEQUENCE;
our $BIOPERL;


# Bioperl location
push (@INC, $BIOPERL);
 
# Required packages (Indexing a fasta file)
require Bio::Index::Fasta;


my $filename = $GENOME_SEQUENCE;

print $GENOME_SEQUENCE; print \n;

# Index the fasta file and store the indexed file in the same location with extension .idx
$inx = Bio::Index::Fasta->new (-filename => "$filename.idx", -write_flag => 1);
$inx->make_index($filename);

print "\n...End of fasta index script.\n";

