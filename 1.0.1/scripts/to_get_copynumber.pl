#!/usr/bin/perl

use POSIX;

$filename0 = $ARGV[0];
$matchlength = $ARGV[1];
$matchaccuracy = $ARGV[2];
$filename1 = $ARGV[3];

if(@ARGV != 4)
{
    print "  Usage: to_get_copynumber.pl <input filename> <matchlength> <matchaccuracy> <output filename>\n";
    print "\n";
    print " input filename  - blastn output of the library of consensus sequences (e.g. repeatscout output) whose copynumber you would like \				 to know.\n";
    print " match length    - minimum % of the consensus length that should match the genome to be counted as a copy. \
                   usual value 0.50 (for 50%).\n";
    print " match accuracy  - minimum % of accuracy required for a match to be considered as a copy. \
                   usual value '0.85' (for 85% i.e. 15% mismatch).\n";
    print " output filename - file where you would like to store the output.\n";
    print " output format:\n";
    print "<consensus name/number 1> <copynumber 1> <first match label 1>\n";
    print "<consensus name/number 2> <copynumber 2> <first match label 2>\n";
    print "...\n";

    exit(0);
}

open(DAT,"$filename0") || die("Could not open the file!");
open(COLLATE,">>$filename1") || die("Could not open the file!");

$copynumber = 0;
$lookforseqlength = 0;
$first = 1;
$count = 0;

while (<DAT>)
{
    $line = $_;
    chomp($line);
    if (index($line,"Query=",0) ne -1)
    {
	if ($first == 1)
        {
            @repeatnumber = split("=  ",$line);
	    $lookforseqlength = 1;
	    $lookforFirstMatch = 1;
        }
        else
        {
	    $count += 1;
	    print COLLATE $repeatnumber[1]; print COLLATE "  ";
            print COLLATE $copynumber;      print COLLATE "  ";
	    print COLLATE $firstmatch;      print COLLATE "  ";
	    print COLLATE "\n";
            $copynumber = 0;
            @repeatnumber = split("=  ",$line);
            $lookforseqlength = 1;
	    $lookforFirstMatch = 1;
        }
	next;
    }
    elsif ($lookforseqlength == 1)
    {
	@split = split(/\(/,$line);
        @length = split(" ",$split[1]);
        $lookforseqlength = 0;
        $seqString = $length[0];
	
	if ($first == 0)
	{
	    $minScore = (($seqString * 0.5)-($seqString * 0.20)) * 1.94;
            $minEvalue = ($seqString * $DBLength)/(2**$minScore);
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
        @split = split(/Identities = /,$line);
        @length = split("/",$split[1]);
        @num = split(/\(/,$length[1]);
        if((($num[0]/$seqString)>$matchlength) && (($length[0]/$num[0])>$matchaccuracy))
        {
            $copynumber+=1;
        } 
    }

}

close(DAT);

$count += 1;
print COLLATE $repeatnumber[1]; print COLLATE "  ";
print COLLATE $copynumber;      print COLLATE "  ";
print COLLATE $firstmatch;      print COLLATE "  ";

print COLLATE "\n\n\n\n";

