#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use File::Slurp;

BEGIN { unshift( @INC, './lib' ) }

BEGIN {
    use Test::Most;
    use_ok('Bio::PanGenome::SplitGroups');
}

my $obj;

# test 1 - 100% shared CGN
ok( $obj = Bio::PanGenome::SplitGroups->new(
  groupfile   => 't/data/split_groups/paralog_clusters1',
  fasta_files => [ 't/data/split_groups/paralogs1.fa', 't/data/split_groups/paralogs2.fa' ],
  outfile     => 'blah.out',
  _do_sorting => 1
), 'initalise object');

$obj->split_groups;
ok( -e 'blah.out', 'output file exists' );
is(read_file('blah.out'), read_file('t/data/split_groups/paralog_exp_clusters1'), 'split group output correct for test 1');

# test 2 - partial sharing of CGN
ok( $obj = Bio::PanGenome::SplitGroups->new(
  groupfile   => 't/data/split_groups/paralog_clusters2',
  fasta_files => [ 't/data/split_groups/paralogs1.fa', 't/data/split_groups/paralogs2.fa' ],
  outfile     => 'blah2.out',
  _do_sorting => 1
), 'initalise object');

$obj->split_groups;
ok( -e 'blah2.out', 'output file exists' );
is(read_file('blah2.out'), read_file('t/data/split_groups/paralog_exp_clusters2'), 'split group output correct for test 2');

# test 3 - one gene with no shared CGN
ok( $obj = Bio::PanGenome::SplitGroups->new(
  groupfile   => 't/data/split_groups/paralog_clusters3',
  fasta_files => [ 't/data/split_groups/paralogs1.fa', 't/data/split_groups/paralogs2.fa' ],
  outfile     => 'blah3.out',
  _do_sorting => 1
), 'initalise object');

$obj->split_groups;
ok( -e 'blah3.out', 'output file exists' );
is(read_file('blah3.out'), read_file('t/data/split_groups/paralog_exp_clusters3'), 'split group output correct for test 3');

# test 4 - paralogs inside paralogs (inception paralog)
ok( $obj = Bio::PanGenome::SplitGroups->new(
  groupfile   => 't/data/split_groups/paralog_clusters4',
  fasta_files => [ 't/data/split_groups/paralogs1.fa', 't/data/split_groups/paralogs2.fa', 't/data/split_groups/paralogs3.fa' ],
  outfile     => 'blah4.out',
  _do_sorting => 1
), 'initalise object');

$obj->split_groups;
ok( -e 'blah4.out', 'output file exists' );
is(read_file('blah4.out'), read_file('t/data/split_groups/paralog_exp_clusters4'), 'split group output correct for test 4');

unlink( "blah.out" );
unlink( "blah2.out" );
unlink( "blah3.out" );
unlink( "blah4.out" );

done_testing();
