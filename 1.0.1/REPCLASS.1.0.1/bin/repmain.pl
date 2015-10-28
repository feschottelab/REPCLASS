#!/usr/bin/perl

#################################################################
# REPCLASS       	- repmain.pl                            #
#                                                               #
# Repmain is the main repclass program				#
#                                                               #
# 10/18/2005                                                    #
# Nirmal Ranganathan                                            #
#################################################################

#################################################################
# Things to do before starting
# 
# 1. Set the environment variable "REPCLASS" to the location where REPCLASS is installed
# 2. Modify the user config file for the current run and set the parameters accordingly
# 
#################################################################


# Version 1.0.0
# - Initial release
# Version 1.0.1
# - Fixed BUG 1 (write flag set for fasta index file)
# - Multi-users capability



#use strict;
use Benchmark;
use File::Copy;
use bytes;


my $start = new Benchmark;

print "\n\n\nRunning repmain\n\n";


# Check if the required arguments are passed
if (@ARGV != 2) {
    print "Usage: repmain.pl <User conf file> <TE sequence>\n";
    exit(0);
}

print "\nProcessing Repeat: $ARGV[1]\n";

# Load Configuration file
do "$ARGV[0]";
#do "$ENV{REPCLASS}/conf/repclass.conf";
#our $REPCLASS_CONF;

do "$REPCLASS_CONF";



# Initialize configuration file variables
#our $EXEREPM;
our $GENOME_FILE;
our $MODULES;
our $TEMPCHOICE;
our $HOMOLOGY_TBLASTX_OUTPUT;
our $HOMOLOGY_OUTPUT;
our $REPBASE_INDEX;
our $JOB_DIR;
our $SEQUENCES;
our $HOMOLOGY_TBLASTX_PARAM;
our $BIOPERL;
our $TSD_FLANKING;
our $GENOME_INDEX;
our $TSD_BLASTN_OUTPUT;
our $TSD_BLASTN_PARAM;
our $TSD_OUTPUT;
our $TSDCONF;
our $PROGRAMS;
our $HELITRON;
our $TIR;
our $LTR;
our $SSR;
our $File;


push (@INC, $BIOPERL);

# Load the Bioperl modules. Change the location of the Bioperl modules
# in the repclass configuration file
require Bio::SearchIO;
require Bio::Search::HSP::BlastHSP;
require Bio::Search::HSP::GenericHSP;
require Bio::SeqIO;
require Bio::Seq;
require Bio::Index::Fasta;
require Bio::Tools::SeqPattern;

# Global Variables
my $file;

# Redirect STDERR to log file
open STDERR, ">> $JOB_DIR/repclass.log" or print STDERR "Couldn't open log file: $!";

# Extract just the file name and not the whole path
if ($ARGV[1] =~ m/^[A-Za-z0-9_\/-]*\/([A-Za-z0-9_\.-]*)$/) {
    $file = $1;
    print "\nFile name is: "; print $file; print "\n";
}
else {
    $file = $ARGV[1];
}

# Put the sequence in an array
open (SEQUENCE, "$SEQUENCES/$file") or die "Cannot open file - $SEQUENCES/$file - $!\n";
my @seq;
foreach my $line (<SEQUENCE>) {
    chomp($line);
    $line =~ s/\s*\n$//;
    if ($line !~ m/^>/) {
	push(@seq, split(//, $line));
    }
}

close SEQUENCE;

# open the temporary file containing the module chosen by the user
open(CHOICE, "$TEMPCHOICE") || die "\nCan not open $TEMPCHOICE: $!\n";
my $moduleNb = <CHOICE>;
chomp($moduleNb);
close CHOICE;

print "\nrepmain module Nb: $moduleNb\n";


##############################################################################
## START OF HOMOLOGY SEARCH
##############################################################################
if($moduleNb =~ /(1|4|5|7)/) {
	print "\nStarting HOMOLOGY search...\n";
{
# Run the tblastx search
system("$HOMOLOGY_TBLASTX_PARAM -i $SEQUENCES/$file -o $HOMOLOGY_TBLASTX_OUTPUT/$file") && die "$file: Couldn't run $HOMOLOGY_TBLASTX_PARAM: $!\n";
#print "\n\n";
#print "************************************** FIRST *********************";
#print "\n\n";
#print $HOMOLOGY_TBLASTX_PARAM;
#print "\n\n";

# Open and parse the Homology tblastx output
open (BLASTFILE, "$HOMOLOGY_TBLASTX_OUTPUT/$file") or die "$file: Homology tblastx output not available - $!\n";
open (HOMOLOGY, "> $HOMOLOGY_OUTPUT/$file") or die "$file: Homology output file couldn't be created - $!\n";

my $startflag = 0;
my $count = 0;
my (%matches,%SC, %SF, %GP, %FM, %SG, %KW, %probability);
my $IDflag = 0;

# Extract the best 10 evalues
foreach my $line (<BLASTFILE>) {
    if ($line =~ m/^>/) {
        last;
    }
    if ($line =~ m/^Sequences producing/) {
	$startflag = 1;
	next;
    }
	
    if ($startflag and $count < 10) {
        if ($line =~ m/^\n/) { next; }
        chomp($line);
        if ($line =~ m/NONE/i) {
	    last;
	}
	my ($hitID, $rf, $hs, $evalue, $n) = split(/\s+/, $line);

	if(!exists($matches{$hitID})) { 
	    $matches{$hitID} = $evalue;
	    my ($dec, $mant) = split(/e-/, $evalue);
	    $probability{$hitID} = $mant/100;
	    $count++;
	}	
    }
}

foreach my $id (keys %matches) {

    # Open the repbase index file
    open (INDEX, $REPBASE_INDEX) or die "$file: Cannot open the Repbase index - $!\n";

    ##Remove: foreach my $line (<INDEX>) {

    foreach my $line (<INDEX>) {
    	if ($line =~ m/^ID\s+$id/) {
	    $IDflag = 1;
     	}
    	if ($IDflag) {
	    chomp($line);
	    $line =~ s/\s+$//;

	    # Subclass
	    if ($line =~ m/^SC\s+([A-Za-z0-9\/_\s\-]+)/) {
	    	if (!exists($SC{lc($1)})) {
		    $SC{lc($1)} = $probability{$id};
		    $SC{lc($1).'k'} = 1;
	    	}
	    	else {
		    $SC{lc($1)} += $probability{$id};
		    $SC{lc($1).'k'}++; 
	    	}
	    }

	    # Superfamily
	    elsif ($line =~ m/^SF\s+([A-Za-z0-9\/_\s\-]+)/) {
	        if (!exists($SF{lc($1)})) {
		    $SF{lc($1)} = $probability{$id};
		    $SF{lc($1).'k'} = 1;
	    	}
	    	else {
		    $SF{lc($1)} += $probability{$id};
		    $SF{lc($1).'k'}++;
		}
	    }

	    # Group
	    elsif ($line =~ m/^GP\s+([A-Za-z0-9\/_\s\-]+)/) {
	    	if (!exists($GP{lc($1)})) {
		    $GP{lc($1)} = $probability{$id};
		    $GP{lc($1).'k'} = 1;
	        }
	    	else {
	 	    $GP{lc($1)} += $probability{$id};
		    $GP{lc($1).'k'}++;
	    	}
	    }

	    # Family
	    elsif ($line =~ m/^FM\s+([A-Za-z0-9\/_\s\-]+)/) {
	    	if (!exists($FM{lc($1)})) {
		    $FM{lc($1)} = $probability{$id};
		    $FM{lc($1).'k'} = 1;
	     	}
		else {
		    $FM{lc($1)} += $probability{$id};
		    $FM{lc($1).'k'}++;
	    	}
	    }

	    # Subgroup
	    elsif ($line =~ m/^SG\s+([A-Za-z0-9\/_\s\-]+)/) {
		print "$1\n";
	    	if (!exists($SG{lc($1)})) {
		    $SG{lc($1)} = $probability{$id};
		    $SG{lc($1).'k'} = 1;
	    	}
	    	else {
	 	    $SG{lc($1)} += $probability{$id};
		    $SG{lc($1).'k'}++;
	    	}
	    }

	    # Keywords
	    elsif ($line =~ m/^KW/) {
		if ($line =~ m/^KW\s+([A-Za-z0-9\/_;\s\.\-]+)/) {
	    	    my @list = split(/;/, lc($1));
	    	    foreach my $keyword (@list) {
	    	    	if (!exists($KW{$keyword})) {
		    	    $KW{$keyword} = $probability{$id};
		    	    $KW{$keyword.'k'} = 1;
		    	}
		    	else {
		    	    $KW{$keyword} += $probability{$id};
		    	    $KW{$keyword.'k'}++;
		    	}
	    	    }
		}
	        $IDflag = 0;
	        last;
	    }
	}
    }
    close(INDEX);
    $IDflag = 0;
}

print HOMOLOGY "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print HOMOLOGY "<TE name=\"$file\">\n";
&confidence(\%SC, $count, "SUBCLASS");
&confidence(\%SF, $count, "SUPERFAMILY");
&confidence(\%GP, $count, "GROUP");
&confidence(\%FM, $count, "FAMILY");
&confidence(\%SG, $count, "SUBGROUP");
&confidence(\%KW, $count, "KEYWORD");
print HOMOLOGY "</TE>";

close(BLASTFILE);
close(HOMOLOGY);

}

print "\n...End of HOMOLOGY search.\n";
} #end if
##
##
####################################################################
## END OF HOMOLOGY SEARCH
####################################################################


####################################################################
## START OF TSD SEARCH
####################################################################
if($moduleNb =~ /(2|4|6|7)/) {
	print "\nStarting TSD search\n";
{

if($GENOME_FILE ne "") {
# Perform the blastn for TSD search
system("$TSD_BLASTN_PARAM -i $SEQUENCES/$file -o $TSD_BLASTN_OUTPUT/$file") && die "$file: Couldn't run $TSD_BLASTN_PARAM: $!\n";

#print "\n\n";
#print "************************************** SECOND *********************";
#print "\n\n";
#print $TSD_BLASTN_PARAM;
#print "\n\n";



# Open the TSD flanking output file
open (TSDFLANKING, "> $TSD_FLANKING/$file") or die "$file: Couldn't create tsdflaking output: $!\n";

my (%final, %fiveprime, %threeprime, %rcfinal, %rcfiveprime, %rcthreeprime);
my ($qlen, $qname, $sname, $qstart, $hstart, $hend, $qend, $strand);
                                                                                                                                         
# Open the indexed file
my $inx = Bio::Index::Fasta->new (-filename => "$GENOME_INDEX", -write_flag => 0); #BUG 1 (write flag was set, removed it)
                                                                           
my $srchIO = Bio::SearchIO->new('-format' => 'blast', '-file' => "$TSD_BLASTN_OUTPUT/$file");
while (my $result = $srchIO->next_result()) {
    $qname = $result->query_name(); # Query Name
    $qlen = $result->query_length(); # Query Length
                
    print TSDFLANKING "#Query Name: $qname, $qlen\n#--------\n";
    while (my $hit = $result->next_hit()) {
        $sname = $hit->name(); # subject name
			
    	while (my $hsp = $hit->next_hsp()) {
	    $qstart = $hsp->start('query');
	    $hstart = $hsp->start('hit');
	    $qend = $hsp->end('query');
	    $hend = $hsp->end('hit');
	    $strand = $hsp->strand;
	    my @list;
	    $list[0] = $sname; # Subject name
	    $list[1] = $hstart; # Hit Start
	    $list[2] = $hend; # Hit End
				
	    if ($strand == 1) {
	     	if ($qstart == 1 and $qend == $qlen) {	
		    @{$final{$hstart}} = @list;
	    	}
	    	elsif ($qstart == 1) {
		    @{$fiveprime{$hstart}} = @list;
 	     	}
	    	elsif ($qend == $qlen) {
	            @{$threeprime{$hstart}} = @list;
	    	}			
	    }
	    elsif ($strand == -1) {
	    	if ($qstart == 1 and $qend == $qlen) {
            	    @{$rcfinal{$hstart}} = @list;
            	}
            	elsif ($qstart == 1) {
            	    @{$rcfiveprime{$hstart}} = @list;
            	}
            	elsif ($qend == $qlen) {
            	    @{$rcthreeprime{$hstart}} = @list;
           	}
            }
    	}
    }
}

# Get matching sequences	
foreach my $fp_start (keys %fiveprime) {
    my @flist = map {$_} @{$fiveprime{$fp_start}};
    my $accflank = $fp_start+($qlen*2);
    foreach my $tp_start (keys %threeprime) {
    	my @tlist = map {$_} @{$threeprime{$tp_start}};
   
        if ($tp_start < $accflank and $tp_start > $fp_start and $flist[0] eq $tlist[0]) {
	    my @list;
	    $list[0] = $flist[0]; # Subject Name
	    $list[1] = $flist[1]; # Hit Start
	    $list[2] = $tlist[2]; # Hit End

            @{$final{$fp_start}} = @list;
            delete($threeprime{$tp_start});
       	}
    }
}	 

# Reverse Complement
foreach my $fp_start (keys %rcfiveprime) {
    my @flist = map {$_} @{$rcfiveprime{$fp_start}};
    my $accflank = $fp_start+($qlen*2);
    foreach my $tp_start (keys %rcthreeprime) {
      	my @tlist = map {$_} @{$rcthreeprime{$tp_start}};
                                                                                                                                         
      	if ($tp_start < $accflank and $tp_start > $fp_start and $flist[0] eq $tlist[0]) {
            my @list;
            $list[0] = $flist[0]; # Subject Name
            $list[1] = $flist[1]; # Hit Start
            $list[2] = $tlist[2]; # Hit End
                                                                                                                                         
            @{$rcfinal{$fp_start}} = @list;
            delete($rcthreeprime{$tp_start});
      	}
    }
}


# Fetch the subsequence
foreach my $start_ts (keys %final) {
    my @flist = map {$_} @{$final{$start_ts}};
    my $seqin = $inx->fetch($flist[0]);
    if (!($flist[1]-50 < 0 or $flist[2]+50 > $seqin->length())) {
    	my $subs = $seqin->subseq($flist[1]-50, $flist[1]-1);
    	my $p3 = $seqin->subseq($flist[2]+1, $flist[2]+50);
                                                                                                
    # Create a sequence in fasta format
    #my $seqobj = new Bio::Seq(-seq => "$subs", -display_id => "$qname");

    	print TSDFLANKING "$subs  $p3\n";
    }

    # Create a sequence file for each family
    #my $seqio_obj = new Bio::SeqIO(-file => "> $qname", -format => 'fasta');
    #$seqio_obj->write_seq($seqobj);
}

print TSDFLANKING "#-----\n";
# Reverse Complement
foreach $start (keys %rcfinal) {
    my $subs, $p3;
    my @flist = map {$_} @{$rcfinal{$start}};
    my $seqin = $inx->fetch($flist[0]);
    if (!($flist[1]-50 < 0 or $flist[2]+50 > $seqin->length())) {
	
	my $subs = $seqin->subseq($flist[1]-50, $flist[1]-1);
    	my $p3 = $seqin->subseq($flist[2]+1, $flist[2]+50);

    	# Reverse Complement
    	my $pattern = new Bio::Tools::SeqPattern(-seq => $subs, -type => 'dna');
    	my $patobj = $pattern->revcom();
    	my $revcom1 = $patobj->expand();
    	$pattern = new Bio::Tools::SeqPattern(-seq => $p3, -type => 'dna');
    	$patobj = $pattern->revcom();
    	my $revcom2 = $patobj->expand(); 

    	print TSDFLANKING "$revcom2  $revcom1\n";
    }
                                                                                                                                         
}

close TSDFLANKING;

################# END OF FLANKING RETRIEVAL ###################### 


# Open the Flanking sequences files
open(FLANKING, "$TSD_FLANKING/$file") or die "$file: Cannot open file - $!\n";

my %all_tsd;
my @all_tsd_length;
my $tsd_index = 0;
my $num_elements = 0;


open (TSDOUTPUT, ">$TSD_OUTPUT/$file") or die "$file: Cannot create file $TSD_OUTPUT/$file - $!";

foreach my $line (<FLANKING>) {
    if ($line !~ m/^#/ ) {
	$num_elements++;
        my ($left, $right) = split(/\s+/, $line);
	my @left = split(//, $left);
	my @right = split(//, $right);

	# Find the TSD sequence
	my $tsd_length = &tsd_search(\@left, \@right);
	
	if ($tsd_length != 0) {
	    
	    # Get the TSD Sequence
            my @tsd_sequence = [];
            for (my $i=0; $i<$tsd_length; $i++) {
                $tsd_sequence[$i] = $right[$i];
            }

	    @{$all_tsd{$tsd_index}} = @tsd_sequence;
 	    $all_tsd_length[$tsd_index] = $tsd_length;
	    $tsd_index++;
	}
    }
}

# Find the consensus length of the TSD's
my %consensus_length = ();
my $max = 0;
my $max_length = 0;

print TSDOUTPUT "Query: $file\n";

if ($num_elements == 0 or scalar(@all_tsd_length) == 0) {
    print TSDOUTPUT "No TSD could be found for this element\n";
    goto ENDTSD;
}

for (my $i=0; $i < scalar(@all_tsd_length); $i++) {
    if (exists($consensus_length{$all_tsd_length[$i]})) {
	$consensus_length{$all_tsd_length[$i]}++;
    }
    else {
	$consensus_length{$all_tsd_length[$i]} = 1;
    }
}

my ($nextmax, $nextmax_length);

foreach my $key (sort {$consensus_length{$a} <=> $consensus_length{$b}} keys %consensus_length) {
    $max = $consensus_length{$key};
    $max_length= $key;

    print TSDOUTPUT "$key-$consensus_length{$key}-$num_elements\n";
    if ($consensus_length{$key+1} > $consensus_length{$key-1}) { 
	$nextmax = $consensus_length{$key+1};
	$nextmax_length = $key+1;    
    }
    else {
	$nextmax = $consensus_length{$key-1};
        $nextmax_length = $key-1;
    }
}

# If the length is 1 then its not a TSD
if ($max_length == 1) {
    print TSDOUTPUT "No TSD could be found for this element\n";
    goto ENDTSD;
}

my $consensus_len = 0;
#print "$max_length-$max-$num_elements\n$nextmax_length-$nextmax-$num_elements\n";
if ($max > ($num_elements*0.5)) {
    if ($max > ($num_elements*0.9)) {
	print TSDOUTPUT "90% Consensus Length: $max_length\n";
    }
    else {
    	print TSDOUTPUT "Consensus Length: $max_length\n";
    }
    $consensus_len = $max_length;
	
}
else {
    print TSDOUTPUT "There is no consensus on the length but the maximum occurance length is  : $max_length\n";
    my $count=0; 
    for (my $n=5; $n < 31; $n++) {
	if (exists($consensus_length{$n})) {
	    $count += $consensus_length{$n};
	}
    }
    if ($max > 50) {
	$consensus_len = $max_length;
    }
    elsif ($count > ($num_elements*0.5)) {
	$consensus_len = 530;
    }
    else {
	goto ENDTSD;
    }
}

my $x = 0;
my @final_tsd;
# Find the consensus sequence for further analysis
foreach my $key (keys %all_tsd) {
    if (scalar(@{$all_tsd{$key}}) == $max_length) {
	for(my $y=0; $y<scalar(@{$all_tsd{$key}}); $y++) {
	    $final_tsd[$x][$y] = ${$all_tsd{$key}}[$y];
	}
	$x++;	
    }
} 

for (my $k=0; $k<scalar(@final_tsd); $k++) {
    for (my $l=0; $l<$max_length; $l++) {
	print TSDOUTPUT $final_tsd[$k][$l];
    }
    print TSDOUTPUT "\n";
}

print TSDOUTPUT "---------------------------------------------\n";

# Find the consensus of the sequences
my $consensus = &tsd_consensus(*TSDOUTPUT, \@final_tsd, $max, $max_length);
print TSDOUTPUT "---------------------------------------------\n";

my $conflag = 1;


if ($num_elements > 5) {
# 1. TSD of conserved length and sequence
if (!($consensus_len == 0 or $consensus_len == 530)) {
	if ($consensus eq "TA") {
		copy("$TSDCONF/ta.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
		$conflag = 0;
	}
	elsif ($consensus =~ m/^T[A-Za-z]A$/) {
		copy("$TSDCONF/tna.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
		$conflag=0;
	}
	elsif ($consensus eq "TTAA") {
		copy("$TSDCONF/ttaa.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
		$conflag=0;
	}
	elsif ($consensus eq "TTTAAA") {
		copy("$TSDCONF/tttaaa.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
		$conflag=0;
	}
}

if ($conflag) {
# 2. Conserved consensus length within family
	if ($consensus_len == 2) {
		copy("$TSDCONF/2.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
	}
	elsif ($consensus_len == 3) {
		copy("$TSDCONF/3.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
	}
	elsif ($consensus_len == 4) {
		copy("$TSDCONF/4.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
	}
	elsif ($consensus_len == 5) {
		copy("$TSDCONF/5.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
	}
	elsif ($consensus_len == 6) {
		copy("$TSDCONF/6.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
	}
	elsif ($consensus_len == 7 or $consensus_len == 8) {
		copy("$TSDCONF/7-8.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
	}
	elsif ($consensus_len > 8 and $consensus_len < 12) {
		copy("$TSDCONF/9-11.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
	}
	elsif ($consensus_len == 530) {
		copy("$TSDCONF/5-30.xml", "$TSD_OUTPUT/$file.xml") or die "Cannot copy file\n";
	}
	elsif ($consensus_len > 30) {
		copy("$TSDCONF/sat.xml", "$TSD_OUTPUT/$file.xml") or  die "Cannot copy file\n";
	}
	#else {
	#	print NOTSD "$file\n";
	#}
}
}
#else {
#	print NOTSD "$file\n";
#}

ENDTSD: close TSDOUTPUT;

} ### end of if($GENOME_INDEX ne "")
else {
        print "\nTSD SEARCH aborted because there is no target genome file.\nYou may provide one if you want to run this module.\n";
}
}

print "\n...End of TSD search.\n";
} ### end if $moduleNb
##
##
###################################################################
## END OF TSD SEARCH
###################################################################


###################################################################
## START OF STRUCTURAL SEARCH
###################################################################

if($moduleNb =~ /(3|5|6|7)/) {
        print "\nStarting STRUCTURAL search...\n";
# Block for structural search variables
{

###################### HELITRON SEARCH ############################

###if($GENOME_FILE ne "") {

print "\n...STR search: starting HELITRON search...\n";

#print "\nSequence file location:\n$SEQUENCES/$file\n";

 
# Palindrome
system("palindrome -sequence $SEQUENCES/$file -minpallen 5 -maxpallen 70 -gaplimit 70 -nummismatches 0 -nooverlap -outfile $HELITRON/$file.pal") && die "$file: Couldn't run palindrome: $!\n";

###check if the palindrome command failed to execute
#$File = "PALINDROME";
#&chkEXEC;

# Weightage for each factor of Helitron
# TSD A - T  	= 0.15
# 5' TC  	= 0.15
# 3' CTRR	= 0.2
# Palindrome with GC rich (85%)	= 0.5	

my $confidence = 0;

if($GENOME_FILE ne "") {
# Look for A(5') T(3') end of flankings
open (FLANKING, "$TSD_FLANKING/$file") || die "$file: Cannot open file $TSD_FLANKING/$file - $!\n";

#my $confidence = 0;
my $num_copies = 0;
my $positive_helitron = 0;

print "\n...STR search: ... HELITRON search...looking at flankings...\n";

foreach my $line (<FLANKING>) {
    chomp($line);
    if ($line !~ m/^#/) {
	$num_copies++;
	my ($left, $right) = split(/\s+/, $line);
	my @left = split(//, $left);
	my @right = split(//, $right);
	    
     	my $flanking_size = scalar(@left);
	if ($left[$flanking_size-1] eq "A" and $right[0] eq "T") {
	    $positive_helitron++;
	}
    }
}

   
if ($num_copies != 0) {
    $confidence += ($positive_helitron/$num_copies)*0.15;
}
close FLANKING;
} # end of if($GENOME_FILE ne "")

print "\n...STR search: ... HELITRON search... looking for TC at 5' of sequence and CTRR...\n";

# Look for TC at 5' of sequence and CTRR

# Check for upto five bp sequences
for (my $i=0; $i<5; $i++) {
    if (uc($seq[$i]) eq  "T" and uc($seq[$i+1]) eq "C") {
	$confidence += 0.15;
   	last;
    }
}

print "\n...STR search: ... HELITRON search... looking for CTRR on 3' end...\n";

my $sequence_length = scalar(@seq);
# Look for CTRR on 3' end
for (my $i=$sequence_length-1; $i>$sequence_length-6; $i--) {
    if (uc($seq[$i]) eq "A" or uc($seq[$i]) eq "G") {
	if (uc($seq[$i-1]) eq "A" or uc($seq[$i-1]) eq "G") {
	    if(uc($seq[$i-2]) eq "T" and uc($seq[$i-3]) eq "C") {
	    	$confidence += 0.20;
		last;
	    }
	}
    }
}

print "\n...STR search: ... HELITRON search... looking for  palindrome towards the end of the sequence\n and also for its rich GC content...\n";

# Look for the palindrome towards the end of the sequence and also for its rich GC content
open (PAL, "$HELITRON/$file.pal") or die "$file: Cannot open file - $HELITRON/$file.pal - $!\n";

my ($start1, $end1, $seq1);
my $start2 = 0;
my $end2 = 0;
my $seq2 = "";

foreach my $line (<PAL>) {
    chomp($line);

    if ($line =~ m/([0-9]+)\s+([ATCGatcg]+)\s+([0-9]+)/) {
	$start1 = $start2;
	$seq1 = $seq2;
	$end1 = $end2;
	$start2 = $1;
	$seq2 = $2;
	$end2 = $3;
    }
}
close PAL;


my $pal_len = 0;
my $gc_count = 0;
my $pal_confidence = 0;
if ($start2 > $sequence_length-20 and $end2-$end1 < 6) {
    my @a1 = split(//, $seq1);
    my @a2 = split(//, $seq2);

    $pal_len = scalar(@a1);
    for (my $i=0; $i < $pal_len; $i++) {
	if (uc($a1[$i]) eq "G" or uc($a1[$i]) eq "C") {
	    $gc_count++;
	}
	if (uc($a1[$i]) eq "G" or uc($a1[$i]) eq "C") {
	    $gc_count++;
	}	    
    }
}

print "\n...STR search: ... HELITRON search... calculating confidence...\n";

if ($pal_len != 0) {
    $pal_confidence = ($gc_count/($pal_len*2))*0.5;
    $confidence += $pal_confidence;
}
 
if ($confidence > 0.70 || $pal_confidence > 0.40) {
    copy("$TSDCONF/helitron.xml", "$TSD_OUTPUT/$file.xml") or die "$file: Cannot copy file - $!\n";
} 

##if($GENOME_FILE ne "") {
if ($confidence < 0.70 and $pal_confidence > 0.40) {
    open (TSDOUTPUT, ">>$TSD_OUTPUT/$file") or die "$file: Cannot create file $TSD_OUTPUT/$file - $!";
    $pal_len *= 2;
    print TSDOUTPUT "Palindrome Length: $pal_len\n";
    close (TSDOUTPUT); 
}
##} # end if($GENOME_FILE ne "") {

#close FLANKING;
#close PAL;

print "\n...End of HELITRON search (STR module).\n";
###} # end if $GENOME_FILE ne ""
####################### End of Helitron search #########################

print "\n...STR search: starting TIRs search...\n";

#print "\nSequence file location:\n$SEQUENCES/$file\n";

##################### TERMINAL INVERTED REPEAT #########################
system("einverted -sequence $SEQUENCES/$file -gap 12 -threshold 50 -match 3 -mismatch -4 -maxrepeat 10000 -outfile $TIR/$file.inv -outseq $TIR/$file.fasta") && die "$file: Couldn't run einverted: $!\n";

#print "\n\n";
#print "************************************** THIRD *********************";
#print "\n\n";
#print $PROGRAMS
#print "\n\n";


open (TIR, "$TIR/$file.inv") or die "$file: Cannot open file $TIR/$file.inv : $!\n";

if (-s TIR){
    #  Open sequence file to find the length of sequence and for further processing
    my $seq_length = scalar(@seq);
    my ($start1, $end1, $seq1);
    my $start2 = 0;
    my $end2 = 0;
    my $seq2 = "";

    #open(umi,">>$TIR/umi.txt");
    #print umi $file;
    #print umi "  ";
    #print umi $seq_length;
    #print umi "\n";
    #close(umi);

    # Parse the .inv file generated by einverted	
    foreach my $line (<TIR>) {
	chomp($line);
	if ($line =~ m/([0-9]+)\s+([ATCGatcg-]+)\s+([0-9]+)/) {
	    $start1 = $start2;
	    $seq1 = $seq2;
	    $end1 = $end2;
	    $start2 = $1;
	    $seq2 = $2;
	    $end2 = $3;
    	}
	if (($start1 == 1 or $start1 < 30) and ($start2 == $seq_length or $start2 > $seq_length-30)) {
	    copy("$TSDCONF/dnatransposon.xml", "$TIR/$file.xml") or die "$file: Cannot copy file : $!\n";
	    open(OUT,">>$TIR/$file.out");
	    print OUT "TIR Length : ";
	    print OUT  $end1-$start1+1;
	    close(OUT);

	last;
	}
    }
}
close TIR;

######################### END OF TERMINAL INVERTED REPEAT ################################

print "\n...End of TIRs search (STR module).\n\n... STR search: starting LTRs search...\n";

######################### START OF LONG TERMINAL REPEAT ##################################

my $mismatch = 0;
my $match = 0;
my $w1start = 0;
my $w1end = 9;
my $w2start = $w1end+1;
my $w2end = $w1end+$w2start;
my $count = 0;

open (LTR, ">$LTR/$file") or die "$file: Cannot create $LTR/$file : $!\n"; 

while ($w2end < scalar(@seq)) {
    # Get both the windows
    my (@window1, @window2);
    for(my $i=0; $i <= $w1end-$w1start; $i++) {
	$window1[$i] = $seq[$w1start+$i];
    }
    for (my $i=0; $i <= $w2end-$w2start; $i++) {
	$window2[$i] = $seq[$w2start+$i];
    }

    # Compare the current complete window
    for (my $j = 0; $j < scalar(@window1); $j++) {
	if ($window1[$j] eq $window2[$j]) {
	    $match = 1;
	}
	else {
	    if ($mismatch > abs(($w1end-$w1start)/10)) {
		$w1end = $w1start + 9;
		$w2start++;
		$w2end++;
		$match = 0;
		$mismatch = 0;
		last;
	    }
	    else {
		$mismatch++;
		$match=1;
	    }
	}
    }

    while ($match) {
	$w1end++;
	$w2end++;

        # If the initial windows match up
	if ($w2end <= scalar(@seq)) {
            $window1[scalar(@window1)] = $seq[$w1end];
            $window2[scalar(@window2)] = $seq[$w2end];
        }
	else {
	    $match = 0;
	    if (!($w2start < $w1end)) {
	    	&print_ltr(*LTR, \@seq, $w1start, $w1end-1, $w2start, $w2end-1);
	    }
	    last;
	}

        if ($window1[scalar(@window1)-1] eq $window2[scalar(@window2)-1]) {
 	     $match=1;
	}
	else {

	    if ($mismatch > abs(($w1end-$w1start)/10)) {
		if (($w1end-$w1start) > 9 and $w2end > scalar(@seq)-10 and !($w2start < $w1end)) {
		    &print_ltr(*LTR, \@seq, $w1start, $w1end, $w2start, $w2end);
		}

		$w1end = $w1start + 9;
		$w2start++;
		$w2end = $w2start + 9;
		$mismatch = 0;
		$match = 0;
		$count = 0;
	    }
	    else {
		$mismatch++;
	    }
	}
    }
    $mismatch = 0; 
}

close LTR;

if (-s "$LTR/$file") {
    copy("$TSDCONF/ltr.xml", "$LTR/$file.xml") or die "$file: Cannot copy file - $!\n";
    open(OUT,">>$LTR/$file.out");
    print OUT "LTR Length : ";
    print OUT  $w1end-$w1start-1;
    close(OUT);

}

######################### END OF LONG TERMINAL REPEAT  #################################

print "\n...End of LTRs search (STR module).\n\n...STR search: starting SSRs search...\n";

######################### START OF SSR ################################################

my $flag = 0;
my $val = 0;
my @threeprime_seq;
my $limit;

open (SSR, ">$SSR/$file") or die "$file: Cannot open file $SSR/$file - $!\n";

if (scalar(@seq) > 100) {
	$limit = scalar(@seq)-100;
}
else {
	$limit = scalar(@seq);
}
for (my $i = $limit; $i<scalar(@seq); $i++) {
	$threeprime_seq[$val++] = $seq[$i]; 
}

my $polya = 0;
# Find polyA
for (my $i=scalar(@threeprime_seq)-1; $i>-1; $i--) {
	if (uc($threeprime_seq[$i]) eq "A") {
		$polya++;
	}
	else {
		last;
	}
}

if ($polya > 6) {
	print SSR "Poly A Tail\n";
}


my %score;
#$score{1} = 10;
$score{2} = 6;
$score{3} = 5;
$score{4} = 4;
$score{5} = 3;

$ssrseq = "";
my %store;
for (my $j=2; $j<6; $j++) {
    for (my $i=0; $i<scalar(@threeprime_seq); $i++) {
	$flag=1;
	my $tmp = "";
	my $tmp1 = "";
	my $count = 0;
	while($flag) {
	    for (my $x=$i; $x<$i+$j; $x++) {
		$tmp .= $threeprime_seq[$x];
	    }
	    for (my $y=$i+$j; $y<$i+$j*2; $y++) { 
		$tmp1 .= $threeprime_seq[$y];
	    }
	    if ($tmp eq $tmp1) {
		if (!exists($store{$tmp})) {
	   	    $store{$tmp} = 2;
		}
		else {
		    $store{$tmp}++;
		}
		    $i += $j;
		    if ($i > scalar(@threeprime_seq)) { $flag=0; }
		    $tmp = "";
		    $tmp1 = "";
	    }
	    else {
		$flag = 0;
		if ($store{$tmp} > $score{$j}-1) {
	  	    print SSR "$tmp: $store{$tmp}\n";
		    $ssrseq = $tmp;
		}
		delete($store{$tmp});
	    }
	}
    }
} 
close SSR;

if (-s "$SSR/$file") {
    copy("$TSDCONF/nonltr.xml", "$SSR/$file.xml") or die "$file: Cannot copy file - $!\n";

    open(OUT,">>$SSR/$file.out");
    if ($polya > 6)
    {
        print OUT "Poly 'A' length: $polya";
    }
    else
    {
	print OUT "SSR: $ssrseq";
    }
    close(OUT);
}

print "\n...End of SSR and STRUCTURAL search.\n";
} ### end if $moduleNb
######################## End of SSR ###############################


}

###################################################################
## Subroutine to print the long terminal repeats for a TE
sub print_ltr {
    my ($fh, $seq, $w1start, $w1end, $w2start, $w2end) = @_;

        print $fh $w1start+1 . "\t";
	for (my $j=0; $j < $w1end-$w1start; $j++) {
	     print $fh $seq->[$w1start+$j];
        }
	print $fh "\t$w1end\n\t";
 	for (my $j=0; $j < $w1end-$w1start; $j++) {
	     if ($seq->[$w1start+$j] eq $seq->[$w2start+$j]) {
		print $fh "|";
	     }
	     else { print $fh " "; }
	}
	print $fh "\t\n";
	print $fh $w2start+1 . "\t";
	for (my $j=0; $j < $w2end-$w2start; $j++) {
	     print $fh $seq->[$w2start+$j];
	}
	print $fh "\t$w2end\n";
}


##########################################################
# Look for a TSD in the given seqeuence
# Return the length and sequence
##########################################################
sub tsd_search {
    my ($left, $right) = @_;

    # Declare the flags
    my $flag_5_9 = 1;
    my $flag_10 = 2;

    # Get the size of the flanking
    my $flanking_size = scalar(@$left);
    my $left_index = 0;
    my $right_index = 0;
    my $left_pointer = 0;

    # Check each character 
    while ($left_index < $flanking_size) {
	if ($left->[$left_index] eq $right->[$right_index]) {
	    $left_index++;
	    $right_index++;
	}
	elsif ($left_pointer < ($flanking_size-9) and $flag_10 != 0) {
                $flag_10--;
		$left_index++;
                $right_index++;
        }
	elsif ($left_pointer < ($flanking_size-4) and $left_pointer > ($flanking_size-10) and $flag_5_9 != 0) {
		$flag_5_9--;
		$left_index++;
		$right_index++;
	}
	else {
	    $flag_5_9 = 1;
	    $flag_10 = 2;
	    $left_pointer++;
	    $left_index = $left_pointer;
	    $right_index = 0;
	}
    }

    #for (my $i=0; $i<$right_index; $i++) {
	#print "$right->[$i]";
    #}
    return $right_index;   
}
###########################################################

###########################################################
# This subroutine finds the consensus sequence based on 
# IUPAC-IUB codes and displays sthe percentage for each
# letter.
###########################################################
sub tsd_consensus {
    my ($fh, $sequences, $seq_total, $seq_length) = @_;
    my ($A, $C, $T, $G);
    my %nucleotide_counts;

    for (my $y=0; $y<$seq_length; $y++) {
	# Initialize nucleotide counts to zero
	$A=0; $C=0; $T=0; $G=0;
	for (my $x=0; $x<$seq_total; $x++) {
	    if ($sequences->[$x][$y] eq "A") { $A++; }
	    elsif ($sequences->[$x][$y] eq "C") { $C++; }
	    elsif ($sequences->[$x][$y] eq "T") { $T++; }
	    elsif ($sequences->[$x][$y] eq "G") { $G++; }
	}
	$nucleotide_counts{$y}{'A'} = $A;
	$nucleotide_counts{$y}{'C'} = $C;
	$nucleotide_counts{$y}{'T'} = $T;
	$nucleotide_counts{$y}{'G'} = $G;
    }

    my $final_consensus = "";
    # Print the percentages
    print $fh "0\tA%\tC%\tG%\tT%\n";
    foreach my $outer (sort keys %nucleotide_counts) {
	print $fh "\n" . $outer+1;
	foreach my $inner (sort keys %{$nucleotide_counts{$outer}}) {
	    print $fh "\t";
	    my $percentvalue = sprintf("%.2f", $nucleotide_counts{$outer}{$inner}*100/$seq_total);
	    print $fh "$percentvalue";
	}
	print $fh "\t";
	my @sorted_keys = sort {$nucleotide_counts{$outer}{$b} <=> $nucleotide_counts{$outer}{$a}} keys %{$nucleotide_counts{$outer}};

	if ($nucleotide_counts{$outer}{$sorted_keys[0]} > ($seq_total*0.75)) {
	    print $fh $sorted_keys[0];
	    $final_consensus .= $sorted_keys[0];
	}
	elsif (($nucleotide_counts{$outer}{$sorted_keys[0]}+$nucleotide_counts{$outer}{$sorted_keys[1]}) > ($seq_total*0.80)) {
	    if (($sorted_keys[0] eq "A" and $sorted_keys[1] eq "G") or ($sorted_keys[0] eq "G" and $sorted_keys[1] eq "A")) {
		print $fh "R";
		$final_consensus .= "R";
	     }
	    elsif (($sorted_keys[0] eq "C" and $sorted_keys[1] eq "T") or ($sorted_keys[0] eq "T" and $sorted_keys[1] eq "C")) {
		print $fh "Y";
		$final_consensus .= "Y";
	    }
	    elsif (($sorted_keys[0] eq "G" and $sorted_keys[1] eq "C") or ($sorted_keys[0] eq "C" and $sorted_keys[1] eq "G")) {
		print $fh "S";
		$final_consensus .= "S";
	    }
	    elsif (($sorted_keys[0] eq "A" and $sorted_keys[1] eq "T") or ($sorted_keys[0] eq "T" and $sorted_keys[1] eq "A")) {
		print $fh "W";
		$final_consensus .= "W";
	    }
	    elsif (($sorted_keys[0] eq "G" and $sorted_keys[1] eq "T") or ($sorted_keys[0] eq "T" and $sorted_keys[1] eq "G")) {
		print $fh "K";
		$final_consensus .= "K";
	    }
	    elsif (($sorted_keys[0] eq "A" and $sorted_keys[1] eq "C") or ($sorted_keys[0] eq "C" and $sorted_keys[1] eq "A")) {
		print $fh "M";
		$final_consensus .= "M";
	    }
	    if (($sorted_keys[0] eq "C" or $sorted_keys[0] eq "G" or $sorted_keys[0] eq "T") and ($sorted_keys[1] eq "C" or $sorted_keys[1] eq "G" or $sorted_keys[1] eq "T") and ($sorted_keys[2] eq "C" or $sorted_keys[2] eq "G" or $sorted_keys[2] eq "T")) {
		print $fh "B";
		$final_consensus .= "B";
	    }
	    elsif (($sorted_keys[0] eq "A" or $sorted_keys[0] eq "G" or $sorted_keys[0] eq "T") and ($sorted_keys[1] eq "A" or $sorted_keys[1] eq "G" or $sorted_keys[1] eq "T") and ($sorted_keys[2] eq "A" or $sorted_keys[2] eq "G" or $sorted_keys[2] eq "T")) {
		print $fh "D";
		$final_consensus .= "D";
	    }
	    elsif (($sorted_keys[0] eq "A" or $sorted_keys[0] eq "C" or $sorted_keys[0] eq "T") and ($sorted_keys[1] eq "A" or $sorted_keys[1] eq "C" or $sorted_keys[1] eq "T") and ($sorted_keys[2] eq "A" or $sorted_keys[2] eq "C" or $sorted_keys[2] eq "T")) {
		print $fh "H";
		$final_consensus .= "H";
	    }
	    elsif (($sorted_keys[0] eq "A" or $sorted_keys[0] eq "C" or $sorted_keys[0] eq "G") and ($sorted_keys[1] eq "A" or $sorted_keys[1] eq "C" or $sorted_keys[1] eq"G") and ($sorted_keys[2] eq "A" or $sorted_keys[2] eq "C" or $sorted_keys[2] eq "G")) {
		print $fh "V";
		$final_consensus .= "V";
	    }
	}
	else {
	    print $fh "N";
	    $final_consensus .= "N";
	}
	print $fh "\n";
    }
    return $final_consensus;
}
###########################################################


# Procedure to calculate the confidence scores
sub confidence() {
    my ($list, $count, $type) = @_;
    my ($confidence, $keyconf);

    foreach my $key (keys %$list) {
       	$confidence = $list->{$key}/$count;
	$keyconf = ($list->{$key.'k'}/$count)*100;
		
	if ($keyconf > 100) { $keyconf = 100; }
		
       	if ($confidence > 1) { $confidence = 100; }
        else { $confidence = $confidence*100; }
       	if (($key !~ m/k$/) and ($keyconf > 35)) {
            printf HOMOLOGY "\t<$type confidence=\"%.2f\" keyconfidence=\"%.2f\">$key</$type>\n", $confidence, $keyconf;
        }
    }
}
########################################################


my $finish = new Benchmark;
my $exectime = timediff($finish, $start);
print "Time taken : ", timestr($exectime), " \n";

