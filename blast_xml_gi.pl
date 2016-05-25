#!/usr/bin/env perl

#Author: Zhang Wei
#Date:   06/01/2016
#Email:  admin\@ncrna.net

use strict;
use warnings;
use Getopt::Long;

my ($xmlFile,$giList,$output,$help);
GetOptions(
	"input|i:s"=>\$xmlFile,
	"gilist|g:s"=>\$giList,
	"output|o:s"=>\$output,
	"help|h"=>\$help
);
my $usage="
perl $0 -i blastx.xml -g giList.txt -o Query2Gi.txt

";
$giList ||= "/fda/db/GO/BLAST4GO/giList.txt";
die $usage unless (defined $xmlFile && -f $xmlFile && defined $giList && -f $giList && defined $output);

## 读取有GO注释的GI信息，这是节约时间的关键
my %hash = ();
open GILIST, "<", $giList or die "Cannot open giList File $giList:$!\n";
while(<GILIST>){
	chomp;
	$hash{$_} = 1;
}
close GILIST;

open OUT, ">", $output or die "Cannot create Output File $output:$!\n";
open XML, "<", $xmlFile or die "Cannot open XML File $xmlFile:$!\n";
my $lines = "";
my $flag = -1;
while(<XML>){
	chomp;
	next if ($_ !~ /^<Iteration>$/ && $flag < 0);
	if (/^<Iteration>$/){
		$flag = 0;
		$lines = "";
		next;
	}elsif (/^<\/Iteration>$/){
		$flag += 1;
		if ($flag==1){
			print OUT parse_xml($lines),"\n";
		}
		$flag = -1;
		next;
	}else{
		$lines .= "\n$_";
	}
}
close XML;
close OUT;

sub parse_xml{
	my ($lines) = @_;
	my $query_id;
	my $nohit_label;
	if ($lines =~ /Iteration_query-def>(.*?)<\/Iteration_query-def/){
		$query_id = $1;
	}
	if ($lines =~ /No hits found/){
		$nohit_label = 1;
		return $query_id;
	}else{
		my @gis=map {/.*>gi\|(\d+).*?<.*/g} split /\n/, $lines;
		my @GIS = ();
		for my $gi (@gis){
			if (exists $hash{$gi}){
				push @GIS, $gi;
			}
		}
		return $query_id . "\t" . join("; ",@GIS);
		$nohit_label = 1;
		return $query_id;
	}
}
