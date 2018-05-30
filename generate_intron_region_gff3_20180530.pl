#!/usr/bin/perl -w

=head1 Name

	generate_intron_region_gff3.pl

=head1 Description

	This script was designed to generate a new gff3 format file containing intron region information based on a sorted gff3 format file.

=head1 Version

	Author: Xiao Chen, seanchen607@gmail.com
	Version: 1.0 Date: 2016/11/21

=head1 Usage

	perl generate_intron_region_gff3.pl  <GFF3_input>  <GFF3_output>

=head1 Example
  
	perl generate_intron_region_gff3.pl  T_thermophila_June2014.gff3  T_thermophila_June2014_with_intron.gff3

=cut

use strict;
die `pod2text $0` unless (@ARGV == 2);
my $file1 = $ARGV[0];
my $file2 = $ARGV[1];

print STDERR "\nAdding intron region information to gff3 file...\n";
open(IN, $file1) or die "Cannot open file:$!";

############ Show Progress ############
my $lines_total = 0;
my $lines = 0;
my $percent2 =0;
foreach (<IN>) {
	$lines_total++;
}
close IN;
#######################################

open(OUT1, ">$file2") or die "Cannot output to file:$!";
open(IN, $file1) or die "Cannot open file:$!";

my $last_gene;
my $last_end;
#my $last_id;
my $last_parent;
my $last_name;

while (<IN>) {
	############ Show Progress ############
	$lines++;
	my $percent=int(100*$lines/$lines_total);
	if ($percent2<$percent) {
		$percent2=$percent;
		print STDERR "$percent2\%\n";
	}
	#######################################
	my $line = $_;

	my @ar = split /\t/, $_;
	my $gene = "";
	if ($ar[8] && $ar[8] =~ /Name=(.+?)\n/) {  #注意一定是转录本和exon都有的的标签
		$gene = $1; #mRNA_id
	}
	
	if ($ar[2] =~ /exon/i) {
		my $start = $ar[3];
		my $end = $ar[4];
		#my $id = "";
		my $parent = "";
		my $name = "";
		if ($ar[8] =~ /Parent=(.+?)\;Name=(.+?)\n/) {
			#$id = $1; #cds/exon的id
			$parent = $1;
			$name = $2;
		}
		
		if ($last_gene and $last_gene eq $gene and $start-1 > $last_end) {  #1.存在2.同一个转录本3.后者比前者大（也同时滤掉CDS和exon重复）
			$ar[2] = "intron";
			$ar[3] = $last_end+1;
			$ar[4] = $start-1;
			$ar[5] = ".";
			$ar[6] = ".";
			$ar[7] = ".";
			#$last_id =~ s/(cds|exon)/intron/; #intron_id
			#$last_name =~ s/(c|e)/i/; #intron_name  无用的其实哈哈哈因为没有特色名字
			$ar[8] = "Parent=$last_parent\;Name=$last_name\n"; #parent都是转录本不用变
			my $newline = join "\t", @ar; #重组信息
			
			print OUT1 $newline;
		}
		$last_gene = $gene;
		$last_end = $end;
		#$last_id = $id;
		$last_parent = $parent;
		$last_name = $name;
	}
	
	print OUT1 $line;
}

#######################################################################

print STDERR "\nJob finished!\n";

#######################################################################

