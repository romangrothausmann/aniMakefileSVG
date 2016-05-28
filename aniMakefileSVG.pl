#!/usr/bin/perl

use strict;

use XML::LibXML;
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


my $doc = XML::LibXML->load_xml(location => $ARGV[1]);
my $xpc = XML::LibXML::XPathContext->new($doc);     # create the XPath evaluator
$xpc->registerNs(x => 'http://www.w3.org/2000/svg'); # declare the namespace (NS) as x
print STDERR "Parsing done.\n";


foreach my $name ($xpc->findnodes('//x:g[x:text]/x:title')) { # NS needs to be repeated for every node specidfication!!! http://stackoverflow.com/questions/4083550/why-does-xmllibxml-find-no-nodes-for-this-xpath-query-when-using-a-namespace#4083929
    my $nameVal= $name->to_literal;
    my $fname= $xpc->findvalue('..//x:text', $name);
    foreach my $group ($xpc->findnodes("//x:g[starts-with(x:title/text(),'$nameVal')]")) { # match value: http://stackoverflow.com/questions/10647147/xpath-querying-when-xml-format-varies

	my @f= grep { /\Q$fname\E/ } @list; # http://perlmeme.org/howtos/perlfunc/grep_function.html  escape special symbols: http://stackoverflow.com/questions/2001176/how-can-i-escape-meta-characters-when-i-interpolate-a-variable-in-perls-match-o#2001239
	my @words= split /\s+/, $f[0];
	my $beg= ($words[0] - $min);
	my $dur= ($words[1] - $words[0]);

	if($beg >= 0 && $dur > 0){
	    my $node = $doc->createElement('animate'); # might need createElementNS: http://stackoverflow.com/questions/2358635/using-xmllibxml-how-do-i-create-namespaces-and-child-elements-and-make-them-w
	    $node->setAttribute('attributeName', "opacity");
	    $node->setAttribute('from', ".1");
	    $node->setAttribute('to', "1");
	    $node->setAttribute('begin', sprintf('%ds', $beg));
	    $node->setAttribute('dur', sprintf('%ds', $dur));
	    $node->setAttribute('fill', "freeze");
	    $group->appendChild($node);

	    $group->setAttribute('style', "opacity:0.1"); # default opacity for nodes of the graph
	}
    }
}

print $doc->toString;

