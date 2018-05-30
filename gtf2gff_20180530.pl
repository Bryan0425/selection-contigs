#!/usr/bin/perl -w
use strict;

open GTF,$ARGV[0];
open GFF,">$ARGV[1]";
my %hash;
my %hsexon;
my %hsdirection;
my $id;
my %hsscaf;
my $source="";
while (<GTF>){
		next if /^#/;  #skip comment lines
		last if /^__(END|DATA)__$/;  #stop at end of code marker

		$_=~s/[\r\n]+//g;
		my @ar=split(/\t/, $_);
		#print "$ar[0]\n";test	
		(my $name)=($ar[8]=~/transcript_id \"(.*?)\"\;/);#获取转录本的id
		if ($ar[2] eq "exon"){
			$id++;
			$source=$ar[1];  #永远不变
			my $exon="$ar[0]\t$source\texon\t$ar[3]\t$ar[4]\t$ar[5]\t$ar[6]\t$ar[7]\tParent\=$name\;Name\=$name\n";			
			$hash{$name}.="$exon"; #{$exon}限制变量名 套入哈希 id=key 内容=value
			$hsexon{$name}.="$ar[3]\t$ar[4]\t";  #exon 起止	
			$hsdirection{$name}=$ar[6]; #转录本（exon）的正负义链
			$hsscaf{$name}=$ar[0]; #exon来源的contig
		}
}


foreach my $key (sort keys %hsexon){  #遍历所有key！
	my @ar=split(/\t/,$hsexon{$key});  #exon起始终止变为数组元素变量
	my @sar=sort {$a<=>$b} @ar;  #从小到大排列 以上都是同一个key
	my $last=@sar-1;
	my $left=$sar[0];
	my $right=$sar[$last];
	print GFF "$hsscaf{$key}\t$source\ttranscript\t$left\t$right\t\.\t$hsdirection{$key}\t\.\tID\=$key\;Name\=$key\n";   #输出转录本行
	print GFF "$hash{$key}";  #输出exon行
}

close GTF;
close GFF;
