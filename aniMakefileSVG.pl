#!/usr/bin/perl

use strict;

use List::Util qw( min );

## read in whole stime.lst
open(F,$ARGV[0]); # http://www.tek-tips.com/viewthread.cfm?qid=1068323
my @list=<F>;
close(F);

## get smallest stime
my $minl= min @list; # http://stackoverflow.com/questions/10701210/how-to-find-maximum-and-minimum-value-in-an-array-of-integers-in-perl
my @mins= split ' ', $minl; # for split ' ' <=> /\s+/
my $min= $mins[0];
print STDERR "Min: $min\n"; # http://stackoverflow.com/questions/10478884/are-there-rules-which-tell-me-what-form-of-stdout-stderr-sdtin-i-have-to-choose

while (<STDIN>){ # graphviz SVG from STDIN
    # print "$1\n" if />(.*)<\/text>/; # http://stackoverflow.com/questions/5617314/perl-regex-print-the-matched-value#5617355
    our @words;
    if (/>(.*)<\/text>/){ # cannot be |...| after if!
    	my @f= grep { /\Q$1\E/ } @list; # http://perlmeme.org/howtos/perlfunc/grep_function.html  escape special symbols: http://stackoverflow.com/questions/2001176/how-can-i-escape-meta-characters-when-i-interpolate-a-variable-in-perls-match-o#2001239
	our @words= split /\s+/, $f[0];
    }

    my $beg= ($words[0] - $min);
    my $dur= ($words[1] - $words[0]);
    if($beg >= 0 && $dur > 0){
	my $aniS= sprintf('<animate attributeName="opacity" from=".1" to="1" begin="%fs" dur="%fs" fill="freeze"/>', $beg , $dur);
	s|(>.*</text>)$|\1\n$aniS|g; # insert animate-line after text-node
    }
    
    s/class="node"/class="node" style="opacity:0.1"/g; # default opacity for nodes of the graph
    print; # output line to STDOUT
}
