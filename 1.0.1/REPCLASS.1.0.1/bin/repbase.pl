#!/usr/bin/perl

#################################################################
# REPCLASS       - repbase.pl		                        #
#                                                               #
# Creates the Keyword listings from Repbase update's embl file  #
#                                                               #
# 09/18/2005                                                    #
# Nirmal Ranganathan                                            #
#################################################################

#use strict;
#use warnings;

# Check if the user configuration file is provided
if (!$ARGV[0]) {
    print "Usage: repbase.pl <repclass conf file> \n";
    exit(0);
}


# Load the Configuration file
#do "/home/umesh/Repclass/conf/repclass.conf";
require("$ARGV[0]");
##do "/home/software/REPCLASS/conf/repclass.conf";


# Declaration of configuration file variables
our $REPBASE_EMBL;
our $TMP;
our $REPBASE_INDEX;

# Local variables
my $keyword = "$TMP/keywords";
my $tempde = "";
my $tempkw = "";
my $DE = "false";
my $KW = "false";

# Open the complete repbase embl file
open (REP_EMBL, $REPBASE_EMBL) or die "Couldn't open file $_\n";

# Temporary index file
open (KEYWORD, "> $keyword") or die "Couldn't create temporary file $_\n";

# Extract the description and keywords fields
foreach my $line (<REP_EMBL>) {
	chomp($line);
	if ($line =~ m/^ID/) {
		if($DE =~ m/^true/)
		{	    
	        	print KEYWORD "$tempde\n";
		}
		if($KW =~ m/^true/)
		{
			print KEYWORD "$tempkw\n";
		}
		print KEYWORD "$line\n";
		$DE = "false";
		$KW = "false";
	}
	elsif ($line =~ m/^DE/) {
		if ($DE eq "false") { 
			$tempde = $line;
			$DE = "true";
		}
		else {
			$line =~ s/^DE\s*/ /;
			$tempde .= $line;
		}
	}
	elsif ($line =~ m/^KW/) {
		if ($KW eq "false") {
			$tempkw = $line;
			$KW = "true";
		}
		else {
			$line =~ s/^KW\s*/ /;
			$tempkw .= $line;
		} 
	}
}

# Close the files
close(REP_EMBL) or die  "Couldn't close file handle $!";
close(KEYWORD) or die "Couldn't close file handle $!";


# Create the repbase index
# Open the keyword files
open (KEYWORD, $keyword) or die "Cannot open temporary keywords file $_\n";

# Open repbase index file
open (INDEX, "> $REPBASE_INDEX") or die "Cannot create repbase index file $_\n";;

# Various types of classification declarations
my ($sc, $sf, $fm, $gp, $sg);

foreach my $line (<KEYWORD>) {
	chomp($line);
	if ($line =~m/^ID[\s]*([a-zA-Z0-9_-]+)/) {
		print INDEX "\nID  $1\n";
	}
	elsif($line =~ m/^DE/) {
		$sc = subclass($line);
		$sf = superfamily($line);
		$gp = group($line);
		$fm = family($line);
		$sg = subgroup($line);	
	}
	elsif ($line =~ m/^KW/) {
		$line =~ s/^KW\s*//;
		$line =~ s/\.//;
		
		if ($sc eq "") {
			$sc = subclass($line);
		}
		else {
			$tmp = subclass($line);
			if ($tmp ne $sc) {
				$sc = $tmp;
			}
		}
		if  ($sf eq "") {
			$sf = superfamily($line);
		}
		if ($gp eq "") {
			$gp = group($line);
		}
		if ($fm eq "") {
			$fm = family($line);
		}
		if ($sg eq "") {
			$sg = subgroup($line);
		}

		print INDEX "SC  $sc\n";
		print INDEX "SF  $sf\n";
		print INDEX "GP  $gp\n";
		print INDEX "FM  $fm\n";
		print INDEX "SG  $sg\n";
	
		my @keywords = split(/;[\s]*/, $line);
		
		print INDEX "KW  ";	
		foreach my $keyword (@keywords) {
			if (($keyword !~ m/(^LTR)|(\sLTR)|(retrotransposon)|(transposon)|(long terminal repeat)|(family)|(group)|(clade)/i) and ($keyword !~ m/$sf/i) and ($keyword !~ m/$gp/i) and ($keyword !~ m/$fm/i) and ($keyword !~ m/$sg/i)){
				print INDEX "$keyword;";
			}
		}
		print INDEX "\n";
	}
}

close(KEYWORD) or die "Couldn't close keywords file $_\n";
close(INDEX) or die "Couldn't close index file $_\n";

# Delete the temporary file
unlink($keyword) or die "Couldn't delete file $keyword: $!\n";

sub superfamily() {
	my $line = shift;
	my $sf;

	if ($line =~ m/([A-Za-z0-9\/\._-]+)[\s-]+(superfamily)/i) {
		$sf = $1;
	}
	else {
		$sf = "";
	}

	if ($line =~ m/([A-Za-z0-9\/\._-]+)[\s-]+(clade)/i) {
		if ($sf eq "") {
			$sf = $1;
		}
		else {
			$sf .= "/" . $1;
		}
	}

	return $sf;
}

sub group() {
	my $line = shift;
	my $gp;
	
	if ($line =~ m/([A-Za-z0-9\/\._-]+)[\s-]+(group)/i) {
		$gp = $1;
	}
	else {
		$gp = "";
	}
	
	if ($line =~ m/([A-Za-z0-9\/\._-]+)[\s-]+(subfamily)/i) {
		if ($line !~ m/(subfamily of)/i) {
			if ($gp eq "") {
				$gp = $1;
			}
			else {
				$gp .= "/" . $1;
			}
		}
	}
	
	if ($line =~ m/([A-Za-z0-9\/\._-]+)[\s-]+(subclade)/i) {
		if ($gp eq "") {
			$gp = $1;
		}
		else {
			$gp .= "/" . $1;
		}
	}

	return $gp;
}

sub family() {
	my $line = shift;
	my $fm;

	if ($line =~ m/([A-Za-z0-9\/\._-]+)[\s-]+(family)/i) {
		if ($line !~ m/(group family)|(family of)/i) {
			$fm = $1;
		}
		else {
			$fm = "";
		}
	}
	else {
		$fm = "";
	}
	
	return $fm;
}

sub subgroup() {
	my $line = shift;
	my $sg;
	
	if ($line =~ m/([A-Za-z0-9\/\._-]+)[\s-]+(subgroup)/i) {
		$sg = $1;
	}
	else {
		$sg = "";
	}
	
	return $sg;
}

sub subclass() {
	my $line = shift;
	my $sc;
	
	if ($line =~ m/(non-LTR)[\s-]*(retrotransposon)[s]*|(non)[\s_-]*((LTR)|(long terminal repeat))/i) {
		$sc = "Non-LTR Retrotransposon";
#		print  "SC  $sc\n";
	}
	elsif ($line =~ m/(LTR)[\s-]*(retrotransposon)[s]*|(long terminal repeat)|(LTR)|(retrotransposon)[s]*/i) {
		$sc = "LTR Retrotransposon";
#		print "SC  $sc\n";
	}
	elsif ($line =~ m/(Helitron)|(helicase)|(helitron)|(HELITRON)/i) {
		$sc = "Helitron";
	}
	elsif ($line =~ m/(DNA transposon)[s]*|(\stransposon)[s]*/i) {
		$sc = "DNA Transposon";
#		if ($line =~ m/(non)[\s-]*(autonomous)/i) {
#			print "SC  Non-autonomous $sc\n";
#		}
#		elsif ($line =~ m/autonomous/i) {
#			print "SC  Autonomous $sc\n";
#		}
#		else {
#			print "SC  $sc\n";
#		}
	}
	else {
		$sc = "";
	}

	return $sc;
}

print "\nThe repbase index file was successfully created.\n\n";
