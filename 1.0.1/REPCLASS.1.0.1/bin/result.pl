#!/usr/bin/perl


print "\n\nRunning results\n\n";

# Check if the user configuration file is provided
if (!$ARGV[0]) {
    print "Usage: result.pl <user conf file>\n";
    exit(0);
}

# Load the configuration files
do "$ARGV[0]";
#do "/usr/lib/Repclass/conf/repclass.conf";
#do "$ENV{REPCLASS}/conf/repclass.conf";
do "$REPCLASS_CONF";

# Initialize configuration file variables
our $SEQUENCES;
our $TEMPCHOICE;
our $TIR;
our $HOMOLOGY_OUTPUT;
our $TSD_OUTPUT;
our $OUTPUT;
our $LTR;
our $SSR;
our $FINAL_PARSED;

#use lib "/home/agarwal/data11/biology/bioperl/lib/perl5/site_perl/5.6.1";
#push (@INC, "/home/agarwal/data11/biology/Repclass/programs");
#push (@INC, "/data101/home/agarwal/data11/XML-XPath/XML-XPath-1.13");
#push (@INC, "/home/agarwal/data11/biology/bioperl/lib/perl5/site_perl/5.6.1");
require XML::XPath;
#use XML::XPath;

my ($homology, $h_subclass, $h_superfamily, $h_clade, $h_conf, $h_keyconf);	# Homology
my ($tsd, $tsd_class, $tsd_subclass, $tsd_superfamily); # TSD Based
my ($tir, $tir_class, $tir_subclass);		# TIR Based
my ($ltr, $ltr_class, $ltr_subclass);		# LTR Based
my ($ssr, $ssr_class, $ssr_subclass);		# SSR Based
my $h=0;
my $ts=0;
my $ti=0;
my $htsd=0;
my $htir=0;
my $tsdtir=0;
my $all=0;

opendir(SEQUENCES, $SEQUENCES) or die "Couldn't open directory $SEQUENCES: $!\n";

### TO BE removed
#open (ALL,  ">all") or die "Cannot open file ss\n";
#open (HS,  ">hs") or die "Cannot open file ss\n";
#open (TS,  ">ts") or die "Cannot open file ss\n";
#open (H1, ">h") or die "Cannot open file ss\n";
#open (T1, ">t") or die "Cannot open file ss\n";
#open (S1, ">s") or die "Cannot open file ss\n";

#my %tag;
my $tagcc = 0;

#foreach $el (<LESS>) {
#	chomp($el);
#	$tag{$el} = $el;
#}

#open(LIST, ">ciona.list") or die "Cannot create file: $!\n";
#print("one\n");

# open and read the temporary file containing the module chosen by the user
open(CHOICE, "$TEMPCHOICE") || die "\nCannot open $TEMPCHOICE: $!\n";
my $moduleNb = <CHOICE>;
chomp($moduleNb);
close CHOICE;

print "\nMy results module Nb: $moduleNb\n\n";


my $seq_count = 0;

while (defined($file = readdir(SEQUENCES))) {
    next if $file =~ /^\.\.?$/;         # skip . and ..

	$seq_count++;

    $hflag=0;
    $tsdflag=0;
    $sflag=0;
    $s_tirflag=0;
    $s_ltrflag=0;
    $s_ssrflag=0;

    my (@class, @subclass, @superfamily);
    my (@hnodes, @tsdnodes, @tirnodes, @lists, @ltrnodes, @ssrnodes);
    my (@C, @SC, @SF);
    my $module1 = 'H';
    my (@conf, @keyconf);

if($moduleNb =~ /(1|4|5|7)/) {
    # Homology output
    if (-e "$HOMOLOGY_OUTPUT/$file") {
	$homology = XML::XPath->new(filename=>"$HOMOLOGY_OUTPUT/$file");
	$h_subclass = $homology->find('/TE/SUBCLASS');
	$h_superfamily = $homology->find('/TE/SUPERFAMILY');
	$h_keyword = $homology->find('/TE/KEYWORD');
	$h_conf = $homology->find('/TE/SUBCLASS/@confidence');
	$h_keyconf = $homology->find('/TE/SUBCLASS/@keyconfidence');

	if (@hnodes = $h_conf->get_nodelist) {
	    @conf  = map($_->string_value, @hnodes);
	}
	if (@hnodes = $h_keyconf->get_nodelist) {
	    @keyconf = map($_->string_value, @hnodes);
	}

	if (@hnodes = $h_subclass->get_nodelist) {
	    my @list = map($_->string_value, @hnodes);
	    push (@subclass, "H->");
	    push (@subclass, @list);
	    push(@SC, 'H');
	    push(@SC, ' ');
	    push(@SC, @list);
	    if(scalar(@list) != 0) {
		$hflag=1;
	    }
	    if (scalar(@list) == 2) {
		if ($conf[0] > $conf[1] and $keyconf[0] > $keyconf[1]) {
			$subclass[1] = "";
		}
		elsif ($conf[1] > $conf[0] and $keyconf[1] > $keyconf[0]) {
			$subclass[0] = "";
		}
	    }	
	}
	if (@hnodes = $h_superfamily->get_nodelist) {
	    my @list = map($_->string_value, @hnodes);
	    push (@superfamily, "H->");
	    push (@superfamily, @list);
	    push(@SF,'H');
	    push(@SF,' ');
            push(@SF, @list);
	    @hSF = ('H', @list);
	}

	if (@hnodes = $h_keyword->get_nodelist) {
	    my @list = map($_->string_value, @hnodes);
	    foreach $keyword (@list) {
		if ($keyword =~ m/(\bline\b)|(\bsine\b)/i) {
		    for($i=0; $i<scalar(@subclass); $i++) {
			if ($subclass[$i] =~ m/ltr retrotransposon/i) {
			    $subclass[$i] = "non-ltr retrotransposon";
			}
		    }
		    
		    my $tmp = scalar(@superfamily);
		    my $sfcnt = scalar(@SF);
		    if ($keyword =~ m/line/i) {
			$superfamily[$tmp] = "H-> line";
			$SF[$sfcnt] = "H";
			$SF[$sfcnt+1] = " ";
			$SF[$sfcnt+2] = "line";
		    }
		    elsif ($keyword =~ m/sine/i) {
			$superfamily[$tmp] = "H-> sine";
			$SF[$sfcnt+2] = "sine";
		    }
		}	
	    }
	}	
    }
} ### end if CHOICE for HOMOLOGY
    
     # TIR Output  

if($moduleNb =~ /(3|5|6|7)/) {                                                                                        
    if (-e "$TIR/$file.xml") {
        $tir = XML::XPath->new(filename=>"$TIR/$file.xml");
        $tir_class = $tir->find('/TE/CLASS/@name');
        $tir_subclass = $tir->find('/TE/CLASS/SUBCLASS/@name');

        if (@tirnodes = $tir_class->get_nodelist) {
            my @list = map($_->string_value, @tirnodes);
            push (@class, "S_TIR->");
            push (@class, @list);
	    push(@C, 'S');
	    push(@C, 'TIR');
	    push(@C, @list);
        }
        if (@tirnodes = $tir_subclass->get_nodelist) {
            my @list = map($_->string_value, @tirnodes);
            push (@subclass, "S_TIR->");
            push (@subclass, @list);
	    push(@SC, 'S');
	    push(@SC, 'TIR');
	    push(@SC, @list);
            if (scalar(@list) != 0) {
                $sflag=1;
                $s_tirflag = 1;
            }
        }

        open(OUT,"$TIR/$file.out");
        @raw_data = <OUT>;
        close(OUT);

        foreach $line (@raw_data){
            if(index($line,"TIR Length ",0) ne -1)
            {
                @lengthline  = split(": ",$line);                                                                        
                $tirsequencelength = $lengthline[1];
                $s_tirflag = 1;
            }
            next;
        }
    }
} ### end if CHOICE for STRUCTURAL TIR


if($moduleNb =~ /(2|3|4|5|6|7)/) {
    $notsdconsensus = 0;
    $palindrome = 0;
    # TSD Output
    if (-e "$TSD_OUTPUT/$file.xml") {
	
	#push (@class, "T->");
	#push (@subclass, "T->");
	#push (@superfamily, "T->");

	open(DAT,"$TSD_OUTPUT/$file") || die("Could not open the file!: $!\n");
	@raw_data = <DAT>;
	close(DAT);

	$linefound = 0;
	foreach $line (@raw_data){
	    if(index($line,"Consensus Length",0) ne -1)
	    {
		$linefound = 1;
	    }
	    elsif(index($line,"no consensus",0) ne -1)
	    {
		$linefound = 1;
		$notsdconsensus = 1;
	    }
	    elsif (index($line,"Palindrome Length",0) ne -1)
	    {
		$linefound = 1;
		$palindrome = 1;
	    }
	    
	    if($linefound == 1)
	    {
		@consensusline  = split(": ",$line);
                @tsdsequence    = split("\n",$consensusline[1]);
                $tsdsequencelength = $tsdsequence[0];
		$linefound = 0;
	    }

	    next;
	}

	push (@class, "T->");
        push (@subclass, "T->");

	if($tsdsequencelength =~ m/[56]/)
	{
	    if($s_tirflag == 1)
	    {
		push (@class, "ii");
		push(@C, 'T');
		push(@C, ' ');
		push(@C, "ii");
 
		if(($tirsequencelength - 100) > 0)
		{
		    push (@subclass, "maverick");
		    push(@SC, 'T');
		    push(@SC, ' ');
		    push(@SC, "maverick");
		}
		else
		{
		    push (@subclass, "dna transposon");
		    push(@SC, 'T');
		    push(@SC, ' ');
		    push(@SC, "dna transposon");
		    
		    push (@superfamily, "T->");
		    if(($tsdsequencelength - 5) == 0 )
		    {
			push (@superfamily,"transib");
			push(@SF, 'T');
			push(@SF, ' ');
			push(@SF, "transib");
		    }
		    else
		    {
			push (@superfamily,"unknown");
			push(@SF, 'T');
			push(@SF, ' ');
			push(@SF, "unknown");
		    }
		}
	    }
	    else
	    {
		push (@superfamily, "T->");

		push (@class,"i");
		push (@subclass,"ltr retrotransposon");
		push (@superfamily,"ty3/gypsy"); 
		push (@superfamily,"ty1/copia");
		push (@superfamily,"retroviral");

		push(@C, 'T');
		push(@C, ' ');
		push(@C, 'i');
		push(@SC, 'T');
		push(@SC, ' ');
		push(@SC, "ltr retrotransposon");
		push(@SF, 'T');
		push(@SF, ' ');
		push(@SF, "ty3/gypsy ty1/copia retroviral");
	    }
	    $tsdflag = 1;
	}
	else
	{
	    $tsd = XML::XPath->new(filename=>"$TSD_OUTPUT/$file.xml");
	    $tsd_class = $tsd->find('/TE/CLASS/@name');
	    $tsd_subclass = $tsd->find('/TE/CLASS/SUBCLASS/@name');
	    $tsd_superfamily = $tsd->find('/TE/CLASS/SUBCLASS/SUPERFAMILY/@name');

	    if (@tsdnodes = $tsd_class->get_nodelist) {
		my @list = map($_->string_value, @tsdnodes);
		push (@class, @list);
		push(@C, 'T');
		push(@C, ' ');
		push(@C, @list);
	    }
	    if (@tsdnodes = $tsd_subclass->get_nodelist) {
		my @list = map($_->string_value, @tsdnodes);
		push (@subclass, @list);
		push(@SC, 'T');
		push(@SC, ' ');
		push(@SC, @list);
		if (scalar(@list) != 0) {
		    $tsdflag=1;
		}
	    }
	    if (@tsdnodes = $tsd_superfamily->get_nodelist) {
		my @list = map($_->string_value, @tsdnodes);
		push (@superfamily, "T->");
		push (@superfamily, @list);
		push(@SF, 'T');
		push(@SF, ' ');
		push(@SF, @list);
	    }
	}
    }
} ### end if CHOICE for TSD


if($moduleNb =~ /(3|5|6|7)/) {
    # LTR Output
    if (-e "$LTR/$file.xml") {
	
	open(OUT,"$LTR/$file.out");
        @raw_data = <OUT>;
        close(OUT);

        foreach $line (@raw_data){
            if(index($line,"LTR Length ",0) ne -1)
            {
                @lengthline  = split(": ",$line);
                $ltrsequencelength = $lengthline[1];
                $s_ltrflag = 1;
            }
            next;
        }


        $ltr = XML::XPath->new(filename=>"$LTR/$file.xml");
        $ltr_class = $ltr->find('/TE/CLASS/@name');
        $ltr_subclass = $ltr->find('/TE/CLASS/SUBCLASS/@name');
                                                                                                                                         
        if (@ltrnodes = $ltr_class->get_nodelist) {
            my @list = map($_->string_value, @ltrnodes);
	    push (@class, "S_LTR->");
            push (@class, @list);
	    push(@C, 'S');
	    push(@C, 'LTR');
	    push(@C, @list);
        }
        if (@ltrnodes = $ltr_subclass->get_nodelist) {
            my @list = map($_->string_value, @ltrnodes);
	    push (@subclass, "S_LTR->");
	    if(($ltrsequencelength - 100) > 0)
	    {
		push (@subclass, @list);
		push(@SC, 'S');
		push(@SC, 'LTR');
		push(@SC, @list);
		if (scalar(@list) != 0) {
		    $sflag=1;
		}
	    }
	    else
	    {
		push (@subclass, "Short Terminal Repeat");
		push(@SC, 'S');
		push(@SC, 'LTR');
		push(@SC, "Short Terminal Repeat");
		$sflag = 1;
	    }
        }
    }

    # SSR Output
    if (-e "$SSR/$file.xml") {
        $ssr = XML::XPath->new(filename=>"$SSR/$file.xml");
        $ssr_class = $ssr->find('/TE/CLASS/@name');
        $ssr_subclass = $ssr->find('/TE/CLASS/SUBCLASS/@name');
                                                                                                                                         
        if (@ssrnodes = $ssr_class->get_nodelist) {
            my @list = map($_->string_value, @ssrnodes);
	    push (@class, "S_SSR->");
            push (@class, @list);
	    push(@C, 'S');
	    push(@C, 'SSR');
	    push(@C, @list);
        }
        if (@ssrnodes = $ssr_subclass->get_nodelist) {
            my @list = map($_->string_value, @ssrnodes);
	    push (@subclass, "S_SSR->");
            push (@subclass, @list);
	    push(@SC, 'S');
	    push(@SC, 'SSR');
	    push(@SC, @list);
            if (scalar(@list) != 0) {
                $sflag=1;
            }
        }

	open(DAT,"$SSR/$file.out") || die("Could not open the file!");
        @raw_data = <DAT>;
        close(DAT);

	$polyAtrail = 0;
        foreach $line (@raw_data){
	     if(index($line,"Poly 'A' length",0) ne -1)
	     {
		 @lengthline  = split(": ",$line);
		 #$polyAtrail  = $lengthline[1];
		 $ssr_string  = "Poly A trail length is $lengthline[1]\n"; 
	     }
	     elsif(index($line,"SSR",0) ne -1)
	     {
		 @lengthline  = split(": ",$line);
                 $polyAtrail  = $lengthline[1];
		 $ssr_string  = "Short sequence repeated is $lengthline[1]\n";
	     }

	     $s_ssrflag = 1; 
	}
	
    }
} ### end if CHOICE for STRUCTURAL

	
	

	open (OUTFILE, ">$OUTPUT/$file") or die "Couldn't create file $OUTPUT/$file: $!\n";
	
	my $sat=0;

	foreach $c (@class) {
	    if ($c eq "sat") {
		print OUTFILE "satellite";
		$sat=1;
	    }
	}	
	if (!$sat) {
	#print OUTFILE "$file\nCLASS:\n";
	print OUTFILE @class;
	#print OUTFILE "\nSUBCLASS:\n";
	print OUTFILE @subclass;
	#print OUTFILE "\nSUPERFAMILY:\n";
	print OUTFILE @superfamily;

	#print LIST "$file\tIdentified\n";
	if ($hflag and $tsdflag and $sflag) {
		$all++;
		#print ALL "$file\n";
		#print LIST "$file\tHomology\n";
		#print LIST "$file\tTSD\n";
		#print LIST "$file\tStructural\n";
	}
	elsif ($hflag and $tsdflag) {
		$htsd++;
		#print LIST "$file\tHomology\n";
		#print LIST "$file\tTSD\n";
	}
	elsif ($hflag and $sflag) {
		$htir++;
		#print HS "$file\n";
		#print LIST "$file\tHomology\n";
		#print LIST "$file\tStructural\n";
	}
	elsif ($tsdflag and $sflag) {
		$tsdtir++;
		#print TS "$file\n";
		#print LIST "$file\tTSD\n";
		#print LIST "$file\tStructural\n";
	}
	elsif ($hflag) {
		$h++;
		#print H1 "$file\n";
		#print LIST "$file\tHomology\n";
	}
	elsif ($tsdflag) {
		#print LIST "$file\tTSD\n";
		$ts++;
		#print T1 "$file\n";
	}
	elsif ($sflag) {
		#print LIST "$file\tStructural\n";
		$ti++;
		#print S1 "$file\n";
	}
	##### To be removed
	else {
	#	if(exists($tag{$file})) {
			#print UNCLASS "$file\n";
			$tagcc++;
	#	}
	}

	print "$file: C(@class)\tSC(@subclass)\tSF(@superfamily)\n";

	##### parse results #####
	open(FINPARSED, ">>$FINAL_PARSED") || die "\nCannot open $FINAL_PARSED: $!\n";
	
	my $headerC = "C module\tFeature used for C\tClass (C)";
	my $headerSC = "SC module\tFeature used for SC\tSub-Class (SC)";
	my $headerSF = "SF module\tFeature used for SF\tSuper-Family (SF)";

	my $modulecnt = 1;
        my $adjust = 0;
        my ($Ccnt, $SCcnt, $SFcnt) = (scalar(@C), scalar(@SC), scalar(@SF));

        my $nbfields = 6 * $modulecnt;

        if($moduleNb =~ /[1-3]/) {
                $modulecnt = 1;
                $adjust = 0
        } elsif($moduleNb =~ /[4-6]/) {
                $modulecnt = 2;
        } elsif($moduleNb == 7) {
                $modulecnt = 3;
                $adjust = 2
        }

        if($seq_count == 1) {
                print FINPARSED "RepName", "\t", "$headerC\t"x$modulecnt, "$headerSC\t"x$modulecnt, "$headerSF\t"x$modulecnt, "Feature description\n";
        }
	

	my $cntclass = grep />/, @class;
        my $cntsubclass = grep />/, @subclass;
        my $cntsuperfamily = grep />/, @superfamily;

	my($classout, $subclassout, $superfamilyout);
	my($Ctabs, $SCtabs, $SFtabs);

	print FINPARSED "$file\t";
	
	
	if($moduleNb =~ /[1-3]/) { # HOM or TSD or STR
		if($cntclass == 0) {
                        $classout = " ";
			for(my $i = 0; $i <= 2; $i++) {
                        	$Ctabs .= "\t";
				print FINPARSED " \t";
                        }
                }elsif($cntclass == 1) {
                        $classout = join("\t", @C);
			for(my $i = 0; $i <= 2; $i++) {
                                $Ctabs .= "\t";
				print FINPARSED "$C[$i]\t";
                        }
		
                }

                if($cntsubclass == 0) {
                        $subclassout = " ";
			for(my $i = 0; $i <= 2; $i++) {
                                $SCtabs .= "\t";
				print FINPARSED " \t";
                        }
                }elsif($cntsubclass == 1) {
                        $subclassout = join("\t", @SC);
			for(my $i = 0; $i <= 2; $i++) {
                                $SCtabs .= "\t";
				print FINPARSED "$SC[$i]\t";
                        }
		
                }

		if($cntsuperfamily == 0) {
                        $superfamilyout = " ";
			for(my $i = 0; $i <= 2; $i++) {
                                $SFtabs .= "\t";
				print FINPARSED " \t";
                        }
                }elsif($cntsuperfamily == 1) {
                        $superfamilyout = join("\t", @SF);
			for(my $i = 0; $i <= 2; $i++) {
                                $SFtabs .= "\t";
				print FINPARSED "$SF[$i]\t";
                        }
		
                }

	}elsif($moduleNb =~ /(4|5|6)/) { # HOM and TSD, or HOM and STR
		if($cntclass == 0) {
			$classout = " ";
			for(my $i = 0; $i <= 5; $i++) {
                                $Ctabs .= "\t";
				print FINPARSED " \t";
                        }
		}elsif($cntclass == 1) {
                        $classout = join("\t", @C);
			for(my $i = 0; $i <= 2; $i++) {
                                $Ctabs .= "\t";
				print FINPARSED "$C[$i]\t";
                        }
			print FINPARSED "\t"x3;
                }elsif($cntclass == 2) {
                        $classout = join("\t", @C);
			for(my $i = 0; $i <= 5; $i++) {
                                $Ctabs .= "\t";
				print FINPARSED "$C[$i]\t";
                        }
			
                }

		if($cntsubclass == 0) {
                        $subclassout = " ";
			for(my $i = 0; $i <= 5; $i++) {
                                $SCtabs .= "\t";
				print FINPARSED " \t";
                        }
                }elsif($cntsubclass == 1) {
                        $subclassout = join("\t", @SC);
			for(my $i = 0; $i <= 2; $i++) {
                                $SCtabs .= "\t";
				print FINPARSED "$SC[$i]\t";
                        }
			print FINPARSED "\t"x3;
                }elsif($cntsubclass == 2) {
                        $subclassout = join("\t", @SC);
			for(my $i = 0; $i <= 5; $i++) {
                                $SCtabs .= "\t";
				print FINPARSED "$SC[$i]\t";
                        }
			
                }

		if($cntsuperfamily == 0) {
                        $superfamilyout = " ";
			for(my $i = 0; $i <= 5; $i++) {
                                $SFtabs .= "\t";
				print FINPARSED " \t";
                        }
                }elsif($cntsuperfamily == 1) {
                        $superfamilyout = join("\t", @SF);
			for(my $i = 0; $i <= 2; $i++) {
                                $SFtabs .= "\t";
				print FINPARSED "$SF[$i]\t";
                        }
			print FINPARSED "\t"x3;
                }elsif($cntsuperfamily == 2) {
                        $superfamilyout = join("\t", @SF);
			for(my $i = 0; $i <= 5; $i++) {
                                $SFtabs .= "\t";
				print FINPARSED "$SF[$i]\t";
                        }
                }

	}elsif($moduleNb == 7) { # HOM and TSD and STR
                if($cntclass == 0) {
                        $classout = " ";
			for(my $i = 0; $i <= 8; $i++) {
			$Ctabs .= "\t";
				print FINPARSED " \t";
			}
                }elsif($cntclass == 1) {
                        $classout = join("\t", @C);
			for(my $i = 0; $i <= 2; $i++) {
			$Ctabs .= "\t";
				print FINPARSED "$C[$i]\t";
			}
			print FINPARSED "\t"x6;
                }elsif($cntclass == 2) {
                        $classout = join("\t", @C);
			for(my $i = 0; $i <= 5; $i++) {
			$Ctabs .= "\t";
				print FINPARSED "$C[$i]\t";
			}
			print FINPARSED "\t"x3;
                }elsif($cntclass == 3) {
                        $classout = join("\t", @C);
			print FINPARSED join("\t", @C), "\t";
                }

                if($cntsubclass == 0) {
                        $subclassout = " ";
			for(my $i = 0; $i <= 8; $i++) {
			$SCtabs .= "\t";
				print FINPARSED " \t";
			}
                }elsif($cntsubclass == 1) {
			$subclassout = join("\t", @SC);
			for(my $i = 0; $i <= 2; $i++) {
			$SCtabs .= "\t";
				print FINPARSED "$SC[$i]\t";
			}
			print FINPARSED "\t"x6;
                }elsif($cntsubclass == 2) {
                        $subclassout = join("\t", @SC);
			for(my $i = 0; $i <= 5; $i++) {
			$SCtabs .= "\t";
				print FINPARSED "$SC[$i]\t";
			}
			print FINPARSED "\t"x3;
                }elsif($cntsubclass == 3) {
                        $subclassout = join("\t", @SC);
			print FINPARSED join("\t", @SC), "\t";
                }

		if($cntsuperfamily == 0) {
                        $superfamilyout = " ";
			for(my $i = 0; $i <= 8; $i++) {
				$SFtabs .= "\t";
				print FINPARSED " \t";
			}
			
                }elsif($cntsuperfamily == 1) {
                        $superfamilyout = join("\t", @SF);
			for(my $i = 0; $i <= 2; $i++) {
				$SFtabs .= "\t";
				print FINPARSED "$SF[$i]\t";
			}
			print FINPARSED "\t"x6;
	
                }elsif($cntsuperfamily == 2) {
                        $superfamilyout = join("\t", @SF);
			for(my $i = 0; $i <= 5; $i++) {
				$SFtabs .= "\t";
				print FINPARSED "$SF[$i]\t";
			}
			print FINPARSED "\t"x3;
			
                }elsif($cntsuperfamily == 3) {
                        $superfamilyout = join("\t", @SF);
			print FINPARSED join("\t", @SF), "\t";
                }
	}



	if($Ccnt == 0) {
		$Ctabs = 6 * $modulecnt;
	} elsif($Ccnt == 1) {
                $Ctabs = 3 * $modulecnt;
        } elsif($Ccnt == 2) {
                $Ctabs = 0
        }

	if($SCcnt == 0) {
                $SCtabs = 6 * $modulecnt;
        } elsif($SCcnt == 1) {
                $SCtabs = 3 * $modulecnt;
        } elsif($SCcnt == 2) {
                $SCtabs = 0
        }

	if($SFcnt == 0) {
                $SFtabs = 6 * $modulecnt;
        } elsif($SFcnt == 1) {
                $SFtabs = 3 * $modulecnt;
        } elsif($SFcnt == 2) {
                $SFtabs = 0
        }	



	if($tsdflag)
	{
	    if($notsdconsensus == 0 and $palindrome == 0)
	    {
		print "TSD consensus length is $tsdsequencelength\n";
		print FINPARSED "TSD consensus length is $tsdsequencelength\n";
	    }
	    elsif($notsdconsensus == 1) 
	    {
		print "No TSD consensus. Maximum TSD length is $tsdsequencelength\n";
		print FINPARSED "No TSD consensus. Maximum TSD length is $tsdsequencelength\n";
	    }
	    elsif ($palindrome == 1)
	    {
		print "Palindrome length is $tsdsequencelength\n";
		print FINPARSED "Palindrome length is $tsdsequencelength\n";
	    }
	}


	if($s_tirflag)
	{
	    print "TIR consensus length is $tirsequencelength\n";
	    print FINPARSED "TIR consensus length is $tirsequencelength\n";
	}

	if ($s_ltrflag)
	{
	    print "Terminal Repeat consensus length is $ltrsequencelength\n";
	    print FINPARSED "Terminal Repeat consensus length is $ltrsequencelength\n";
	}

	if($s_ssrflag == 1)
	{
	    print $ssr_string;
	    print FINPARSED $ssr_string;
	}

	print "\n";
	print FINPARSED "\n";
	close FINPARSED;
	close OUTFILE;		
    }
}	

print "\nStatistics' Summary:\n\n\nTotal number of sequence queried: $seq_count\n\nTotal number of sequences per module:\n";
print "\n\tALL: $all\n\tHomology and TSD: $htsd\n\tHomology and Structural: $htir\n\tTSD and Structural: $tsdtir\n\tHomology: $h\n\tTSD: $ts\n\tStructural: $ti";

my $totseq_classified = $h + $ts + $ti + $htsd + $htir + $tsdtir + $all;

print "\n\nTotal sequences classified: $totseq_classified";
 
closedir SEQUENCES;
#close LIST;
close UNCLASS;

