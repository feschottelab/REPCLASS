#!/usr/bin/perl

use File::Copy;
use POSIX;

if(@ARGV != 2)
{
    print "  Usage: to_get_repeatlength.pl <input filename> <output filename>\n";
    print "\n";
    print " input filename  - library of consensus sequences whose length/charactercount you would like to know.\n";
    print " output filename - file where you would like to store the output.\n";
    print " output format:\n";
    print "<consensus name/number 1> <character count 1>\n";
    print "<consensus name/number 2> <character count 2>\n";
    print "...\n"; 
    exit(0);
}


$filename0 = $ARGV[0];
$filename1 = $ARGV[1];

open(DAT,"$filename0") || die("Could not open the file!");
@raw_data = <DAT>;
close(DAT);

open(FINAL,">>$filename1") || die("Could not open the file!");

$startCount = 0;
$charCount = 0;

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
	    print FINAL $repeats[1]; print FINAL "   ";
	    print FINAL $charCount; print FINAL "  ";
	    print FINAL "\n";
	    $charCount = 0;
	}
	$startCount = 1;
	@RepeatNumber  = split("\n",$line);
        $repeat =$RepeatNumber[0];
        next;  
    }
    elsif ($line =~ m/^\s*\n$/){
	@repeats = split(/=/,$repeat);
        print FINAL $repeats[1]; print FINAL "   ";
        print FINAL $charCount; print FINAL "  ";
        print FINAL "\n";
        $charCount = 0;
        $startCount = 0;
	next;
    }
    else {
	@line = split(//,$line);
	foreach $char (@line){

	    #if($char !~ m/\n$/)
	     #{
		 $charCount++;
	     #}
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

print FINAL $repeats[1]; print FINAL "   ";
print FINAL $charCount;  print FINAL "  ";

print FINAL "\n\n\n";

close(FINAL);

