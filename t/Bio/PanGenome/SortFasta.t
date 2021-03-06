#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::SortFasta');
}

my $obj;


ok( $obj = Bio::PanGenome::SortFasta->new(
  input_filename   => 't/data/out_of_order_fasta.fa',
), 'initalise object');


ok($obj->sort_fasta, 'sort the fasta file');
ok(-e 't/data/out_of_order_fasta.fa.sorted.fa', 'the new file exists');

is(read_file('t/data/out_of_order_fasta.fa.sorted.fa'), read_file('t/data/expected_out_of_order_fasta.fa.sorted.fa'), 'check order of sorted fasta');



done_testing();
