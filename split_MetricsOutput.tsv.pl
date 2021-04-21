#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;

my $metrics = $ARGV[0];
my $DIR = dirname($metrics);
my $samples = (`grep "^Metric" $metrics`)[1];
chomp $samples;
my @sample_list = split(/\t/, $samples);
open (METRICS, $metrics) || die $!;
my $analysis_status = 0;
my $dna_metrics = 0;
my $header = 0;
while (<METRICS>) {
  if (/^\[Analysis/) {
    $analysis_status = 1;
    $header = 1;
  } elsif (/^\[DNA/) {
    $dna_metrics = 1;
    $analysis_status = 0;
    $header = 1;
  } elsif (/^\[/) {
    $analysis_status = 0;
    $dna_metrics = 0;
    $header = 1;
  } else {
    $header = 0;
  }
  if ($header or !$_ or (!$analysis_status and !$dna_metrics)) {
    for (my $i = 3; $i <= $#sample_list; $i++) {
      open (RESULTS, ">>$DIR/$sample_list[$i]/$sample_list[$i]_MetricsOutput.tsv") || die $!;
      print RESULTS $_;
      close RESULTS;
    }
   } elsif ($analysis_status) {
      chomp;
      my @data = split(/\t/, $_);
      for (my $i = 3; $i <= $#sample_list; $i++) {
        open (RESULTS, ">>$DIR/$sample_list[$i]/$sample_list[$i]_MetricsOutput.tsv") || die $!;
        if (@data) {
          print RESULTS "$data[0]\t$data[$i-2]\n";
        } else {
          print RESULTS "\n";
        }
        close RESULTS;
      }
  } elsif ($dna_metrics) {
      chomp;
      my @data = split(/\t/, $_);
      for (my $i = 3; $i <= $#sample_list; $i++) {
        open (RESULTS, ">>$DIR/$sample_list[$i]/$sample_list[$i]_MetricsOutput.tsv") || die $!;
        if (@data) {
          my $results = join "\t", @data[0,1,2,$i];
          print RESULTS "$results\n";
        } else {
          print RESULTS "\n";
        }
        close RESULTS;
      }

  }
}
