#!/usr/bin/perl

use File::Copy;
use POSIX;

if(@ARGV != 3)
{
    print "  Usage: repeatlength_distribution.pl <input filename> <output filename> <bucket>\n";
    print "\n";
    print " input filename  - library of consensus sequences whose length/charactercount you would like to know.\n";
    print " output filename - file where you would like to store the output.\n";
    print " bucket          - distribution bucket.\n";
    print " output format:\n";
    print "0 <number of consensuses whose character count falls between 0*bucket and 1*bucket>\n";
    print "1 <number of consensuses whose character count falls between 1*bucket and 2*bucket>\n";
    print "2 <number of consensuses whose character count falls between 2*bucket and 3*bucket>\n";
    print "...\n";

    exit(0);
}


$InputFilename = $ARGV[0];
$OutputFilename = $ARGV[1];
$DistributionBucket = $ARGV[2];

@DistributionArray = {};

print " Input filename:      "; print $InputFilename; print "\n";
print " Output filename:     "; print $OutputFilename; print "\n";
print " Distribution bucket: "; print $DistributionBucket; print "\n";

open(INPUT,"$InputFilename") || die("Could not open the INPUT file!");
@InputData = <INPUT>;
close(INPUT);

open(OUTPUT,">>$OutputFilename") || die("Could not open the OUTPUT file!");

$RepeatLength = 0;
$RepeatDistribution = 0;

foreach $InputLine (@InputData){
    if (index($InputLine,">",0) ne -1){
        if ($RepeatLength > 0)
        {
	    $RepeatDistribution = &GetRepeatDistribution($RepeatLength,$DistributionBucket);
	    $DistributionArray[$RepeatDistribution]++;
	    &WriteToOUTPUT($RepeatIdentifier,$RepeatLength,$RepeatDistribution);
	    
        }

	$RepeatIdentifier = &GetRepeatIdentifier($InputLine);
	$RepeatLength = 0;
    }
    elsif ($line =~ m/^\s*\n$/){
        next;
    }
    else {
        @InputLine = split(//,$InputLine);
        foreach $InputChar (@InputLine){
	    if($InputChar !~ m/\n$/)
	    {
		#print $InputChar;
		$RepeatLength++;
	    }
        }
    }
}

$RepeatDistribution = &GetRepeatDistribution($RepeatLength,$DistributionBucket);
$DistributionArray[$RepeatDistribution]++;
&WriteToOUTPUT($RepeatIdentifier,$RepeatLength,$RepeatDistribution);

&PrintDistribution(@DistributionArray);

close(OUTPUT);

print "EXIT(0)\n";

sub GetRepeatIdentifier
{
    if(index($_[0],"=",0) ne -1)
    {
	@LineParts = split(/=/,$_[0]);
    }
    else
    {
	@LineParts = split(/>/,$_[0]);
    }

    return($LineParts[1]);
}


sub WriteToOUTPUT
{
    
    print OUTPUT $_[0]; 
    print OUTPUT " "; 
    print OUTPUT $_[1]; 
    print OUTPUT " "; 
    print OUTPUT $_[2];
    print OUTPUT "\n";
    
}

sub GetRepeatDistribution()
{
    return(ceil($_[0]/$_[1]));
}

sub PrintDistribution()
{
    print OUTPUT "\n\nDistribution:\n";
    $ArrayIndex = 0;
    foreach (@_)
    {
	$ArrayIndex++;
	print OUTPUT $ArrayIndex;
        print OUTPUT " ";
	if($_[$ArrayIndex] =~ m/^\s*$/)
	{
	    print OUTPUT "0";
	}
	else
	{
	    print OUTPUT $_[$ArrayIndex];
	}
	print OUTPUT "\n";
    }
}
