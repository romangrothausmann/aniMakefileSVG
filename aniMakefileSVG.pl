#!/usr/bin/perl

use strict;
# use warnings;

use XML::LibXML;
use List::Util qw( min max );
use POSIX; # for: floor

sub hsv2rgb { # http://www.perlmonks.org/?node_id=139486
    my ( $h, $s, $v ) = @_;

    if ( $s == 0 ) {
        return $v, $v, $v;
    }

    $h /= 60;
    my $i = floor( $h );
    my $f = $h - $i;
    my $p = $v * ( 1 - $s );
    my $q = $v * ( 1 - $s * $f );
    my $t = $v * ( 1 - $s * ( 1 - $f ) );

    if ( $i == 0 ) {
        return $v, $t, $p;
    }
    elsif ( $i == 1 ) {
        return $q, $v, $t;
    }
    elsif ( $i == 2 ) {
        return $p, $v, $t;
    }
    elsif ( $i == 3 ) {
        return $p, $q, $v;
    }
    elsif ( $i == 4 ) {
        return $t, $p, $v;
    }
    else {
        return $v, $p, $q;
    }
}


die "Usage: $0 stime.lst SVG aSVG\n" if @ARGV != 3;

## read in whole stime.lst
open(F,$ARGV[0]); # http://www.tek-tips.com/viewthread.cfm?qid=1068323
my @list=<F>;
close(F);

my @matrix; # separate from @list because @list is needed for grep later on!
foreach my $line (@list){ # http://perlmaven.com/how-to-read-a-csv-file-using-perl
  chomp $line;
  my @fields= split ' ', $line;
  push (@matrix, [@fields]); # http://stackoverflow.com/questions/14018358/pushing-array-as-an-item-to-another-array-not-creating-multidimensional-array#14018742
}

# print $list[1][1], "\n";
# print @{$list[0]}, "\n"; # row! http://perl-seiten.privat.t-online.de/html/perl_array.html

my @stimeA= map $_->[0], @matrix; # extract column: http://www.perlmonks.org/?node_id=416416
my @etimeA= map $_->[1], @matrix; # alternative: Text::CSV_XS with $csv->fields(); http://stackoverflow.com/questions/3199000/how-to-print-all-values-of-an-array-in-perl

my @durA= map {$etimeA[$_] - $stimeA[$_]} 0..$#etimeA; # @etimeA - @stimeA not possible: http://stackoverflow.com/questions/7079685/how-to-subtract-values-in-2-different-arrays-in-perl#7080649
  
## get smallest stime
my $stimeMin= min(@stimeA); # http://stackoverflow.com/questions/10701210/how-to-find-maximum-and-minimum-value-in-an-array-of-integers-in-perl
print STDERR "stimeMin: $stimeMin\n"; # http://stackoverflow.com/questions/10478884/are-there-rules-which-tell-me-what-form-of-stdout-stderr-sdtin-i-have-to-choose

## get longest duration
my $durMax= max(@durA);
print STDERR "durMax: $durMax\n";

my $etimeMax= max(@etimeA);
my $totDur= ($etimeMax - $stimeMin)/1e3;
print STDOUT $totDur, "\n"; # STDOUT preserved for this output (used in Makefile)
printf STDERR "totDur: %fs\n", $totDur; # STDOUT preserved for this output (used in Makefile)


my $doc = XML::LibXML->load_xml(location => $ARGV[1]);
my $xpc = XML::LibXML::XPathContext->new($doc);     # create the XPath evaluator
$xpc->registerNs(x => 'http://www.w3.org/2000/svg'); # declare the namespace (NS) as x
print STDERR "Parsing done.\n";


### create dummy loop as timing reference
## https://codepen.io/danjiro/post/how-to-make-svg-loop-animation
my $root = $doc->documentElement();
my $node = $doc->createElement('animate');
$node->setAttribute('id', "timer");
$node->setAttribute('attributeName', "visibility");
$node->setAttribute('from', "hide");
$node->setAttribute('to', "hide");
$node->setAttribute('begin', "0;timer.end");
$node->setAttribute('dur', sprintf('%ds', ceil($totDur)));
$root->appendChild($node);

foreach my $name ($xpc->findnodes('//x:g[x:text]/x:title')) { # NS needs to be repeated for every node specidfication!!! http://stackoverflow.com/questions/4083550/why-does-xmllibxml-find-no-nodes-for-this-xpath-query-when-using-a-namespace#4083929
    my $nameVal= $name->to_literal;
    my $fname= $xpc->findvalue('..//x:text', $name);
    foreach my $group ($xpc->findnodes("//x:g[starts-with(x:title/text(),'$nameVal')]")) { # match value: http://stackoverflow.com/questions/10647147/xpath-querying-when-xml-format-varies

	my @f= grep { /\Q$fname\E/ } @list; # http://perlmeme.org/howtos/perlfunc/grep_function.html  escape special symbols: http://stackoverflow.com/questions/2001176/how-can-i-escape-meta-characters-when-i-interpolate-a-variable-in-perls-match-o#2001239
	my @words= split /\s+/, $f[0];
	my $beg= ($words[0] - $stimeMin);
	my $dur= ($words[1] - $words[0]);

	if($beg >= 0 && $dur > 0){
	    my $node = $doc->createElement('animate'); # might need createElementNS: http://stackoverflow.com/questions/2358635/using-xmllibxml-how-do-i-create-namespaces-and-child-elements-and-make-them-w
	    $node->setAttribute('attributeName', "opacity");
	    $node->setAttribute('from', ".1");
	    $node->setAttribute('to', "1");
	    $node->setAttribute('begin', sprintf('timer.begin+%dms', $beg)); # start relative to timer
	    $node->setAttribute('dur', sprintf('%dms', $dur));
	    $node->setAttribute('fill', "freeze");
	    $group->appendChild($node);

	    $group->setAttribute('style', "opacity:0.1"); # default opacity for nodes of the graph

	    
	    my @rgb= hsv2rgb(85 - $dur * 85 / $durMax, 1, 1);
	    @rgb= map int($_ * 255), @rgb;
	    foreach my $ell ($xpc->findnodes('.//x:ellipse', $group)) {
		# $ell->setAttribute('fill', sprintf("hsl(%d,100\%,50\%)", 85 - $dur * 85 / $durMax)); # hsl supported by firefox but not by gpac
		$ell->setAttribute('fill', sprintf("rgb(%s)", join(",", @rgb)));
	    }
	}

	if ($group->getAttribute('class') eq "node"){ # http://stackoverflow.com/questions/14046669/perl-string-compare-with-eq-vs
	    ## replace title of gv-nodes with fname
	    foreach my $title ($xpc->findnodes('.//x:title/text()', $group)) {
		# printf(STDERR "%s : %s\n", $title->to_literal,  $fname);
		$title->setData($fname); # http://www.perlmonks.org/?node_id=900439
	    }
	    ## shorten fname in text nodes
	    foreach my $text ($xpc->findnodes('.//x:text/text()', $group)) {
		$text->setData($fname =~ s/.*_([^_\.]+\.[^\.]*)/\1/ ? $1 : $fname); # http://www.perlmonks.org/bare/?node_id=216467
	    }
	}
	
    }
}
print STDERR "All done.\n";

exit $doc->toFile($ARGV[2], 1); # 0: as read; 1: indent; 2: extra \n; http://search.cpan.org/dist/XML-LibXML/lib/XML/LibXML/Document.pod

