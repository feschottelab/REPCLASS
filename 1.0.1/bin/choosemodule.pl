#!/usr/bin/perl -w

# choosemodule.pl: prompt user to choose the module(s) he wants to run

# Check if the user configuration file is provided
if (!$ARGV[0]) {
    print "Usage: choosemodule.pl <user conf file>\n";
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
our $TEMPCHOICE;


# Initialize module number and modules variables
my %modules = ("1" => "Homology (HOM)", "2" => "Target Site Duplication (TSD)", "3" => "Structural (STR)", "4" => "HOM and TSD", "5" => "HOM and STR", "6" => "TSD and STR", "7" => "HOM, TSD and STR");
my @Allkeys = sort(keys(%modules));
my $moduleNb = 0;

# initialize the temporary file for the choice
open(CHOICE, ">$TEMPCHOICE") || die "\nCannot open $TEMPCHOICE: $!\n";
print CHOICE "", "\n";
close CHOICE;

# Prompt user to choose the module(s) he wants to run
while($moduleNb == 0 || $moduleNb > 7 || $moduleNb =~ /[0-9]*[a-zA-Z]+[0-9]*/ || $moduleNb eq "") {
        
	print "\nPlease, choose any of the numbers below which corresponds to the module(s) that you want to run, and then validate your entry:\n";
	foreach(@Allkeys) {
		print "\n$_ $modules{$_}\n";
	}

	print "\n";

        $moduleNb = <STDIN>;
        chomp($moduleNb);

        # Now check if the answer is an integer between 1 and 7
        if($moduleNb == 0 || $moduleNb > 7 || $moduleNb =~ /[0-9]*[a-zA-Z]+[0-9]*/) {
                print "\n\'$moduleNb\' is an invalid entry.\n";
        }elsif($moduleNb >= 1 && $moduleNb <= 7) {
                # ask the user to confirm the choice
                print "\nYour choice is $moduleNb for the $modules{$moduleNb}\n";

                # open a temporary file to store the module chosen
                print "\nStoring choice\n\n";
                open(CHOICE, ">$TEMPCHOICE") || die "\nCannot open $TEMPCHOICE: $!\n";
                print CHOICE $moduleNb, "\n";
                close CHOICE;
        } # end elsif
        #last
}

