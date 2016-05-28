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

# my $parser = XML::LibXML->new();
# my $doc    = $parser->parse_file($ARGV[1]);
print STDERR "Parsing done.\n";

#foreach my $name ($xpc->findnodes('//x:text/parent::*')) { # http://zvon.org/comp/r/tut-XPath_1.html#Pages~List_of_XPaths
#foreach my $name ($xpc->findnodes('//x:text/preceding-sibling::*')) { # http://stackoverflow.com/questions/17040254/how-to-select-a-node-using-xpath-if-sibling-node-has-a-specific-value
foreach my $name ($xpc->findnodes('//x:g[x:text]/x:title')) { # NS needs to be repeated for every node specidfication!!! http://stackoverflow.com/questions/4083550/why-does-xmllibxml-find-no-nodes-for-this-xpath-query-when-using-a-namespace#4083929
    my $nameVal= $name->to_literal;
    #print $name, "\n";
    my $fname= $xpc->findvalue('..//x:text', $name);
    #foreach my $group ($xpc->findnodes("//x:g[contains(\@class,'node')]")) { # match attribute: http://stackoverflow.com/questions/4135784/xpath-how-to-match-a-class-of-characters-in-an-attribute
    foreach my $group ($xpc->findnodes("//x:g[starts-with(x:title/text(),'$nameVal')]")) { # match value: http://stackoverflow.com/questions/10647147/xpath-querying-when-xml-format-varies

	#print $fname, "\n";
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
    	#print $group, "\n";

	#print $_ . "\n" foreach ($xpc->findvalue(".//x:title", $group)) # use . for relative path! http://www.w3.org/TR/xpath/#path-abbrev    http://stackoverflow.com/questions/17730027/not-able-to-get-value-of-element-in-xpath-context-in-perl
    }
}

print $doc->toString;

