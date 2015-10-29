# REPCLASS
This tool facilitates transposable elements consensus classification.

More information can be found here:
http://gbe.oxfordjournals.org/cgi/pmidlookup?view=long&pmid=20333191


Please open use the "Issues" tab on the right or email 4urelie.k (at) gmail (dot) com for questions


Some notes to run it:
 - If you are on CentOS, you will need to install XML:XPath (with cpan as root, or in a folder that's in your $PATH)
 - You don't need to create the file "mytempchoice". 
 - With this version of Repclass you will want to run the option 7 (run all 3 modules)
 - If there are "/" in names of your repeats, RC will crash (it creates folders using repeat names)
 - If you have to re-run the job, you need to delete previous run files
 - Wublast doesn't like some letters in consensus sequences and it would make Repclass crash. Just use this command line on your input file: sed '/>/! s/[QLSR]/N/g' input.seqs.fa > input.seqs.WBok.fa
