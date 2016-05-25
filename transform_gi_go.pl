#!/usr/bin/env perl

#Author: Zhang Wei
#Date:   06/01/2016
#Email:  admin\@ncrna.net

use strict;
use warnings;
use Getopt::Long;

my ($gene2gi,$gi2go,$output,$help);
GetOptions(
	"gene2gi|i:s"=>\$gene2gi,
	"gi2go|d:s"=>\$gi2go,
	"gene2go|o:s"=>\$output,
	"h|help"=>\$help
);
my $usage="
perl $0 -i gene2gi.txt -d gi2go.txt -o gene2go.txt

";

$gi2go ||= "/fda/db/GO/BLAST4GO/gi_go.fm";

die $usage if ($help);
die $usage unless (defined $gi2go && -f $gi2go && defined $gene2gi && -f $gene2gi && defined $output);

## 先去掉那些无GO号的GI，然后再做分析

open GENE2GI, "<", $gene2gi or die "Cannot open Query File $gene2gi:$!\n";
my %hash = ();
my @lines = ();
my %annot = ();

while(<GENE2GI>){
	chomp;
	my ($gene,$gis) = (split /\t/, $_)[0,1];
	push @lines, $_;
	if (defined $gis){
		for my $gi (split /; /, $gis){
			$hash{$gi} = 1;
		}
	}
}
close GENE2GI;

open GI2GO, "<", $gi2go or die "Cannot open Database $gi2go:$!\n";
while(<GI2GO>){
	chomp;
	my ($gi,$go) = (split /\t/, $_)[0,1];
	next unless defined $go;
	if (exists $hash{$gi}){
		$annot{$gi} = $go;
	}
}
close GI2GO;

open OUTPUT, ">", $output or die "Cannot create Output file $output:$!\n";
for my $line (@lines){
	my ($gene,$gis)= split /\t/, $line, 2;
	unless (defined $gis){
		print OUTPUT "$gene\n";
		next;
	}
	my @GOS = ();
	for my $gi (split /; /, $gis){
		if (defined $annot{$gi}){
			push @GOS, split /; /, $annot{$gi};
		}
	}
	my %tmp = map{$_=>1}@GOS;
	print OUTPUT $gene, "\t", join(", ", keys %tmp), "\n"; ## 如果把这里的逗号改为分号，是个大坑
}
close OUTPUT;
