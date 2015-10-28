#!/usr/bin/perl

use File::Copy;
use POSIX;

if(@ARGV != 2)
{
    print "  Usage: to_get_repeatlength.pl <input filename> <output filename>\n";
    print "\n";
    print " input filename  - library of consensus sequences whose length/charactercount you would like to know.\n";
    print " output filename - file where you would like to store the output.\n";
    print " user threshold  - character count threshold. all the consensus sequences in the input file having character count                              less than or equal to this threshold will be classified as bad repeats.\n";
    print " output format: same as input format with all bad repeats removed.\n";
    exit(0);
}


$filename0 = $ARGV[0];
$filename1 = $ARGV[1];
$ucct = $ARGV[2];

open(DAT,"$filename0") || die("Could not open the file!");
@raw_data = <DAT>;
close(DAT);

$startCount = 0;
$charCount = 0;
@distribution = ();
$bucket = 50;
@BadRepeats = ();
$BadOnes = 0;

foreach $line (@raw_data){
    if (index($line,">",0) ne -1){
	if ($startCount == 1)
	{
	    if(index($repeat,"=",0) ne -1)
	    {
		@repeats = split(/=/,$repeat);
	    }
	    else
	    {
		@repeats = split(/>/,$repeat);
	    }
	    if ($charCount <= $ucct)
	    {
		push(@BadRepeats,$repeats[1]);
		$BadOnes += 1;
	    }
	    $charCount = 0;
	}
	$startCount = 1;
	@RepeatNumber  = split("\n",$line);
        $repeat =$RepeatNumber[0];
        next;  
    }
    elsif ($line =~ m/^\s*\n$/){
	@repeats = split(/=/,$repeat);
	if ($charCount <= $ucct)
	{
	    push(@BadRepeats,$repeats[1]);
	}
        $charCount = 0;
        $startCount = 0;
	next;
    }
    else {
	@line = split(//,$line);
	foreach $char (@line){

	    $charCount++;
	}
    }
}


if(index($repeat,"=",0) ne -1)
{
    @repeats = split(/=/,$repeat);
}
            else
{
    @repeats = split(/>/,$repeat);
}


if ($charCount <= $ucct)
{
    push(@BadRepeats,$repeats[1]);
}

if (@BadRepeats > 0)
{
    open(DAT,"$filename0") || die("Could not open the file!");
    @orig_data = <DAT>;
    close(DAT);

    open(COLLATE,">>$filename1") || die("Could not open the file!");
    $count = 0;
    $ripoff = 0;
    $totalcount = @BadRepeats;
    $skip = 0;

    foreach $line (@orig_data){ 
	if (index($line,">",0) ne -1)
	{
	    if(!$skip && (index($line,$BadRepeats[$count],0) ne -1))
	    {
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
    print "No Repeats to delete!!";
}
