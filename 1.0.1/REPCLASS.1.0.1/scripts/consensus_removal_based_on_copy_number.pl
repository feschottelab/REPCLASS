#!/usr/bin/perl

use POSIX;

if(@ARGV != 6)
{
    print "  Usage: to_get_copynumber.pl <input blast output> <input fasta filename> <output filename> <user threshold> <matchlength> <matchaccuracy>\n";
    print "\n";
    print " input blast output - blastn output of the library of consensus sequences (e.g. repeatscout output).\n";
    print " input fasta file   - library of consensus sequences (e.g. repeatscout output).\n";
    print " output filename    - file where you would like to store the output.\n";
    print " user threshold     - copynumber threshold. all the consensus sequences in the input fasta file having copynumber                              less than or equal to this threshold will be classified as bad repeats.\n";
    print " match length       - minimum % of the consensus length that should match the genome to be counted as a copy. \
                       usual value 0.50 (for 50%).\n";
    print " match accuracy     - minimum % of accuracy required for a match to be considered as a copy. \
                      usual value '0.85' (for 85% i.e. 15% mismatch).\n";
    print " output format: same as input fasta file with all bad repeats removed.\n";   
    exit(0);
}


$filename0 = $ARGV[0];
$filename1 = $ARGV[1];
$filename2 = $ARGV[2];
$ucnt = $ARGV[3];
$matchlength = $ARGV[4];
$matchaccuracy = $ARGV[5];
#$bucket = $ARGV[6];

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
	
	if ($first == 1)
        {
            @repeatnumber = split("=  ",$line);
	    $lookforseqlength = 1;
	    $lookforFirstMatch = 1;
        }
        else
        {
	    $count += 1;
	    if ($copynumber <= $ucnt)
	    {
		$BadOnes += 1;
		$repeatnumber[1] =~ s/^\s+//;
		$repeatnumber[1] =~ s/\s+$//;
		push(@BadRepeats,$repeatnumber[1]);
	    }
	    #$index = ceil($copynumber/$bucket);
	    #$distribution[$index] += 1; 
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

if ($copynumber <= $ucnt)
{
    $BadOnes += 1;
    $repeatnumber[1] =~ s/^\s+//;
    $repeatnumber[1] =~ s/\s+$//;
    push(@BadRepeats,$repeatnumber[1]);
}
#i$index = ceil($copynumber/$bucket);
#$distribution[$index] += 1;


#for ($i = 0; $i < @distribution; $i = $i + 1)
#{
    #print $i;
   # print "  ";
  #  print $distribution[$i];
 #   print "\n";
#}



#for($i = 0; $i < @BadRepeats; $i += 1)
#{
    #print $BadRepeats[$i];
    #print "\n";
#}


if (@BadRepeats > null)
{
    open(DAT,"$filename1") || die("Could not open the file!");
    @orig_data = <DAT>;
    close(DAT);

    open(COLLATE,">>$filename2") || die("Could not open the file!");
    $count = 0;
    $ripoff = 0;
    $totalcount = $BadOnes;
    $skip = 0;

    foreach $line (@orig_data){
	if (index($line,">",0) ne -1)
	{
	    #print "Skip is: "; print $skip; print "\n";
	    #print "Bad Repeat is: "; print "\n"; 
	    #print $BadRepeats[count]; print "\n";
	    #print "Line is: "; print $line; print "\n";
	    if (!$skip && $line =~ m/$BadRepeats[$count]/)
	    {
		#print $BadRepeats[$count];
		#print "\n";
		$ripoff = 1;
		$count++;
                if ($count == ($totalcount))
                {
                    $skip = 1;
                }
	    }
	    else
	    {
		if ($ripoff == 1)
		{
		    $ripoff = 0;
		}

		print COLLATE $line;
	    }
	}
	else
	{
	    if ($ripoff == 0)
	    {
		print COLLATE $line;
	    }
	}
    }
    close(COLLATE);
}
else
{
    print " No Bad Repeats!!\n\n";
}
