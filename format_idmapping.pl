#!/usr/bin/env perl

#Author: Zhang Wei
#Date:   06/01/2016
#Email:  admin\@ncrna.net

use strict;
use warnings;
use Getopt::Long;

my ($input,$column,$output,$help);
GetOptions(
	"i|input:s"=>\$input,
	"c|column:s"=>\$column,
	"o|output:s"=>\$output,
	"h|help"=>\$help
);

my $usage=<< "USAGE";

SYSNOPSIS

perl $0 -i id_mapping.tb -c column -o id_mapping.fm

The idmapping.tb table includes the following IDs (or ACs) delimited by tab:

1. UniProtKB accession
2. UniProtKB ID
3. EntrezGene
4. RefSeq
5. NCBI GI number
6. PDB
7. Pfam
8. GO
9. PIRSF
10. IPI
11. UniRef100
12. UniRef90
13. UniRef50
14. UniParc
15. PIR-PSD accession
16. NCBI taxonomy
17. MIM
18. UniGene
19. Ensembl
20. PubMed ID
21. EMBL/GenBank/DDBJ
22. EMBL protein_id

USAGE

die $usage if ($help);
die $usage unless (defined $input && -f $input && defined $column && defined $output);

## 分析FLAG
my %flag = ();
while(<DATA>){
	chomp;
	my ($id,$desc) = split /\t/, $_,2;
	$flag{$id} = $desc;
}
if (defined $flag{$column}){
	print STDERR "The column $column ($flag{$column}) is selected.\n";
	$column -= 1;  ## array is 0-based
}else{
	die $usage;
}

open IN, "<", $input or die "Cannot open Input File $input:$!\n";
my %hash = ();
while(<IN>){
	chomp;
	my ($ids,$gos) = (split /\t/, $_)[$column,7];
	$gos =~ s/^[\s+|; ]//;
	$gos =~ s/[;\s*|\s+]$//;
	next unless defined $gos;
	for my $id (split /; /, $ids){
		if (exists $hash{$id}){
			$hash{$id} .= "; $gos";
		}else{
			$hash{$id} = $gos;
		}
	}
}
close IN;

open OUT, ">", $output or die "Cannot create Output File $output:$!\n";
for my $ID (keys %hash){
	my %GOS = map {$_=>1} (split /; /, $hash{$ID});
	print OUT "$ID\t" . join("; ",keys %GOS) . "\n";
}
close OUT;

print STDERR "mission complete.\n";
exit 0;

__DATA__
1	UniProtKB accession
2	UniProtKB ID
3	EntrezGene
4	RefSeq
5	NCBI GI number
6	PDB
7	Pfam
8	GO
9	PIRSF
10	IPI
11	UniRef100
12	UniRef90
13	UniRef50
14	UniParc
15	PIR-PSD accession
16	NCBI taxonomy
17	MIM
18	UniGene
19	Ensembl
20	PubMed ID
21	EMBL/GenBank/DDBJ
22	EMBL protein_id
