#!/usr/bin/env perl
# This script is ued to extract seq from DB using pos in BED file
use strict;
use warnings;
use Bio::DB::Fasta;
use Bio::SeqIO;

my $usage = "Usage: $0 DB-PATH INFILE OUTFILE";
my $db_path = shift or die $usage;
my $infile = shift or die $usage;
my $outfile = shift or die $usage;

my $db = new Bio::DB::Fasta($db_path);
open(IN, "<$infile") || die "Unable to open $infile: $!";
my $out = new Bio::SeqIO(-file => ">$outfile", -format => 'fasta', -alphabet => 'dna');

# read BED file
my %name2loc;

while(my $line = <IN>) {
	chomp $line;
	my ($chr, $start, $end, $name) = split(/\t/, $line);
	next unless($start > 0 && $end > 0); # not an unmapped
	if(!exists $name2loc{$name}) { # not seen yet
		$name2loc{$name} = "$chr:$start-$end";
		my $seq = $db->seq($chr, $start => $end);
		#my $seq_obj = new Bio::Seq(-seq => $seq, -display_id => $name, -desc => "$chr:$start-$end");
		my $seq_obj = new Bio::Seq(-seq => $seq, -display_id => "$chr:$start-$end");
		$out->write_seq($seq_obj);
	}
}

close(IN);
$out->close();
