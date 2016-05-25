#!/usr/bin/env perl

#Author: Zhang wei
#First author: CJ
#Email: admin\@ncrna.net

use strict;
use warnings;
use Getopt::Long;

my ($tblFile,$giList,$output,$help);
GetOptions(
	"input|i:s"=>\$tblFile,
	"gilist|g:s"=>\$giList,
	"output|o:s"=>\$output,
	"help|h"=>\$help
);
my $usage="
perl $0 -i blastx.tbl -g giList.txt -o Query2Gi.txt

";
$giList ||= "/fda/db/GO/BLAST4GO/giList.txt";
die $usage unless (defined $tblFile && -f $tblFile && defined $giList && -f $giList && defined $output);

## 读取有GO注释的GI信息，这是节约时间的关键
my %hash = ();
open GILIST, "<", $giList or die "Cannot open giList File $giList:$!\n";
while(<GILIST>){
	chomp;
	$hash{$_} = 1;
}
close GILIST;

open OUT, ">", $output or die "Cannot create Output File $output:$!\n";
open TBL, "<", $tblFile or die "Cannot open TBL File $tblFile:$!\n";
my $lines = "";
my $flag = -1;
my $query_pri = "";
 
while(<TBL>){
	my ($query,$subject) = (split/\t/)[0,1];
	last unless defined $query;
	if($query_pri eq ""){
		$query_pri = $query;
		$lines .= $_;
		next;
	}elsif($query_pri eq $query){
		$lines .= $_;
		next;
	}else{
		print OUT parse_tbl($lines),"\n";
		$query_pri = $query;
		$lines = $_;
	}
}
close TBL;
close OUT;

sub parse_tbl{
	my ($lines) = @_;
	my $query_id = (split/\t/,$_)[0];
	my @gis=map {/.*gi\|(\d+).*?.*/g} split /\n/, $lines;
	my @GIS = ();
	for my $gi (@gis){
		if (exists $hash{$gi}){
			push @GIS, $gi;
		}
	}
	return $query_id . "\t" . join("; ",@GIS);
}
