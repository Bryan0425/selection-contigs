#!/usr/bin/perl -w

=pod
-----潘博 Bryan Pan-----
-----bopan2016@163.com-----
-----March 15th 2018-----
=cut

use strict;
use Getopt::Long;
my ($infile,$outfile,$list,$help,$a,$b,$i,$j,@cov,@len,$name);
GetOptions(
	"i|input=s"=>\$infile,
	"o|out=s"=>\$outfile,
	"h|help:s"=>\$help,
);
($infile && -s $infile)||$help||die & Usage();

open IN, $infile||die $!;
open OUT1, '>cov_temp';
open OUT2, '>cov_final';
open OUT3, '>len_temp';
open OUT4, '>len_final';
open LISTOUT, '>list_contigs';

#####cov#####
while(<IN>){
chomp;
if($_ =~ /^.*cov_(.*)/){
my $i = $1;
my $a = $_;
print OUT1 "$a\t$i\n";}
}
close IN;
close OUT1;

open IN1, 'cov_temp';
while(<IN1>){
@cov = split("\t");
if($cov[1] >= 5){
print OUT2 "$cov[0]\n"}
}
close IN1;
close OUT2;

#####len#####
open IN2, 'cov_final';
while(<IN2>){
chomp;
if($_ =~ /^.*length_(.*)_cov_.*/){
my $j = $1;
my $b = $_;
print OUT3 "$b\t$j\n";}
}
close IN2;
close OUT3;

open IN3, 'len_temp';
while(<IN3>){
@len = split("\t");
if($len[1] >= 400){
print OUT4 "$len[0]\n"}
}
close IN3;
close OUT4;

#####id#####
open IN4, 'len_final';
while (<IN4>) {
chomp;
if ($_ =~ /^>(.*)/) {
$name = $1;
print LISTOUT "$name\n";}
}
close IN4;
close LISTOUT;

#####seqs#####
open LISTIN, 'list_contigs';
my %listids;
while (<LISTIN>){
	chomp;
	$listids{$_}=1;
}
close LISTIN;
$/=">";
open IN, $infile||die $!;
<IN>;
open OUT,">$outfile"||die $!;
while(<IN>){
	chomp;
	s/^\s+//g;
	my $id;
	$id=$1 if(/^(\S+)/);
	print OUT ">$_" if($listids{$id});
}
close IN;
close OUT;
$/="\n";

#####remove useless file#####

unlink ("cov_temp");
unlink ("cov_final");
unlink ("len_temp");
unlink ("len_final");

#####info#####

sub Usage{
	my $info="
	Usage:perl $0 -i <infile> -l <genlist> -o <outfile>
Options:
	-i|input <str> set input fa file
	-l|list <str> inputfa id list seperated by '\\n' 'in this script is already inputted'
	-o|out <str> set outfile file
	-h|help set outfile file
";
	print $info;
	exit 0;	
}


=bug log
1.{}
2.handlename-input-output-different
3.scalar name!
=cut