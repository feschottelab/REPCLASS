#!/usr/bin/perl

use POSIX;

if(@ARGV != 5)
{
    print "  Usage: copynumber_distribution.pl <input filename> <matchlength> <matchaccuracy> <bucket> <output filename>\n";
    print "\n";
    print " input filename  - blastn output of the library of consensus sequences whose copynumber you would like to know.\n";
    print " match length    - minimum % of the consensus length that should match the genome to be counted as a copy. \
                   usual value 0.50 (for 50%).\n";
    print " match accuracy  - minimum % of accuracy required for a match to be considered as a copy. \
                   usual value '0.85' (for 85% i.e. 15% mismatch).\n";
    print " bucket          - distibution bucket.\n";
    print " output filename - file where you would like to store the output.\n";
    print " output format:\n";
    print "0 <number of consensuses whose copynumber falls between 0*bucket and 1*bucket>\n";
    print "1 <number of consensuses whose copynumber falls between 1*bucket and 2*bucket>\n";
    print "2 <number of consensuses whose copynumber falls between 2*bucket and 3*bucket>\n";
    print "...\n";

    exit(0);
}

$filename0 = $ARGV[0];
$matchlength = $ARGV[1];
$matchaccuracy = $ARGV[2];
$bucket = $ARGV[3];
$filename4 = $ARGV[4];

open(DAT,"$filename0") || die("Could not open the file!");

$copynumber = 0;
$lookforseqlength = 0;
$first = 1;
@distribution = ();
$count = 0;
@BadRepeats = ();
$BadOnes = 0;

while (<DAT>)
{
    $line = $_;
    chomp($line);
    if (index($line,"Query=",0) ne -1)
    {
	#print $line; print "\n";
	
	if ($first == 1)
        {
            @repeatnumber = split("=  ",$line);
	    $lookforseqlength = 1;
	    $lookforFirstMatch = 1;
        }
        else
        {
	    $count += 1;
	    #print $repeatnumber[1]; print "  ";
	    $index = ceil($copynumber/$bucket);
	    #print "$index";  print "\n";
	    $distribution[$index] += 1; 
            $copynumber = 0;
            @repeatnumber = split("=  ",$line);
            $lookforseqlength = 1;
	    $lookforFirstMatch = 1;
        }
	next;
    }
    elsif ($lookforseqlength == 1)
    {
	#print "X"; print "\n";
	@split = split(/\(/,$line);
        @length = split(" ",$split[1]);
        $lookforseqlength = 0;
        $seqString = $length[0];
	#print $seqString; print "\n";
	
	if ($first == 0)
	{
	    $minScore = (($seqString * 0.5)-($seqString * 0.20)) * 1.94;
            $minEvalue = ($seqString * $DBLength)/(2**$minScore);
            #print $minEvalue; print "\n";
	}
	
	$first = 0;
	next;
    }
     elsif($lookforFirstMatch == 1)
     {
        if(index($line,">",0) ne -1)
        {
            @split = split(/>/,$line);
            $firstmatch = $split[1];
            $lookforFirstMatch = 0;
        }
    }
    elsif(index($line,"Identities = ",0) ne -1)
    {
        #print $line; print "\n";
        @split = split(/Identities = /,$line);
        @length = split("/",$split[1]);
        @num = split(/\(/,$length[1]);
        #print $num[0]; print"\n";
        #print $length[0]; print"\n";
        #print $num[0]/$seqString; print "\n";
        #print $length[0]/$num[0]; print "\n";
        if((($num[0]/$seqString)>$matchlength) && (($length[0]/$num[0])>$matchaccuracy))
        {
            $copynumber+=1;
        } 
        #print $copynumber; print "\n";
    }

}

close(DAT);

$count += 1;
#print $repeatnumber[1]; print "  ";
$index = ceil($copynumber/$bucket);
#print "$index";  print "\n";
$distribution[$index] += 1;

#print "\n\n\n\n";


open(DAT,"$filename1") || die("Could not open the file!");

for ($i = 0; $i < @distribution; $i = $i + 1)
{
    print DAT $i;
    print DAT "  ";
    print DAT $distribution[$i];
    print DAT "\n";
}

close(DAT);
