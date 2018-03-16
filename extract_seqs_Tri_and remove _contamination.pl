#!/usr/bin/perl -w

=pod
-----潘博 Bryan Pan-----
-----bopan2016@163.com-----
-----March 17th 2018-----
=cut

use strict;
use Getopt::Long;
my ($infile,$outfile,$list,$help,@line,$temp,$ID),;
GetOptions(
	"i|input=s"=>\$infile,
	"o|out=s"=>\$outfile,
	"h|help:s"=>\$help,
);
($infile && -s $infile)||$help||die & Usage();

open IN1, "<Tri_human.tab";
open OUT1, ">contig_id";
while(<IN1>){
	@line = split("\t", $_);
	print OUT1 "$line[0]\n";
}
close IN1;
close OUT1;


#####remove duplication#####
open IN2, "<contig_id";
open OUT2, ">contig_list";
$temp = "";
while(<IN2>){
	if(not $temp eq $_){
	print OUT2;
	$temp = $_;
}
}
close IN2;
close OUT2;

#####contamination#####
open IN3, "<contig_list";
my %listids;
while(<IN3>){
	chomp;
	$listids{$_}=1;
}
close IN3;
$/=">";
open IN, $infile||die $!;
<IN>;
open OUT3, ">Tri_human_contamination.fa";
while(<IN>){
	chomp;
	s/^\s+//g;
	my $id;
	$id = $1 if(/^(\S+)/);
	print OUT3 ">$_" if($listids{$id});
}
close IN;
close OUT3;
$/="\n";


#####genome#####
open IN3, "<contig_list";
my %ta;
my $i; 
while(<IN3>){
	chomp;
	$ta{$_} = ++$i; 
}
close IN3;

open IN, $infile;
open OUT4, ">genome_contig_list";
while(<IN>){
	chomp $_;
	if(/^>(.*)/){
		$ID=$1;
		print OUT4 "$ID\n";
	}else{
		$_.=~s/(.*)//g;
	}
	$ID=undef;
}
close IN;
close OUT4;


open IN4, "<genome_contig_list";
open COMM_AB, ">comm.txt";
my $countAB;
my @B;
while(<IN4>){
	chomp;
	unless(defined $ta{$_}){
		push @B, $_;
	}else{
		$ta{$_} = 0;
		$countAB++;
		print COMM_AB $_ ."\n";
	}	
}
close IN4;
print "$countAB contigs both in total and contamination\n";
close COMM_AB;

open DIFF_A, ">contamination_contigs_id.txt";
my $countA;
my %tt = reverse %ta;
foreach (sort keys %tt) {
    $countA += $_>0? print DIFF_A $tt{$_}."\n":0;
}

print "$countA lines in contamination but not in total\n";
close DIFF_A;



open DIFF_B, ">genome_contigs_id.txt";
my $countB = scalar @B; 
print DIFF_B $_."\n" foreach @B; 
print "$countB lines in total but not in contamination\n";

if ($countA == 0 and $countB ==0 ){
    print STDOUT "The two files are identical\n";
    }

close DIFF_B;


open LIST, "<genome_contigs_id.txt";
my %glistids;
while (<LIST>){
	chomp;
	$glistids{$_}=1;
}
close LIST;
$/=">";
open IN, $infile||die $!;
<IN>;
open OUT,">$outfile"||die $!;
while(<IN>){
	chomp;
	s/^\s+//g;
	my $gid;
	$gid=$1 if(/^(\S+)/);
	print OUT ">$_",if($glistids{$gid});
}
close IN;
close OUT;
$/="\n";

unlink("contig_id");
unlink("contig_list");
unlink("genome_contig_list");


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

