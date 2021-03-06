
package Bio::PanGenome::Output::GroupsMultifastasNucleotide;

# ABSTRACT:  Take in a set of GFF files and a groups file and output one multifasta file per group with nucleotide sequences.

=head1 SYNOPSIS

Take in a set of GFF files and a groups file and output one multifasta file per group with nucleotide sequences.
   use Bio::PanGenome::Output::GroupsMultifastasNucleotide;
   
   my $obj = Bio::PanGenome::Output::GroupsMultifastasNucleotide->new(
       group_names      => ['aaa','bbb'],
       analyse_groups  => $analyse_groups
     );
   $obj->create_files();

=cut

use Moose;
use File::Path qw(make_path);
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::Output::GroupsMultifastaNucleotide;

has 'gff_files'        => ( is => 'ro', isa => 'ArrayRef',                      required => 1 );
has 'group_names'      => ( is => 'ro', isa => 'ArrayRef',                      required => 0 );
has 'annotate_groups'  => ( is => 'ro', isa => 'Bio::PanGenome::AnnotateGroups', required => 1 );
has 'output_multifasta_files'     => ( is => 'ro', isa => 'Bool',     default  => 0 );

has 'output_directory' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_output_directory');

has '_number_of_groups' => ( is => 'rw', isa => 'Num', lazy_build => 1 );
has 'group_limit'      => ( is => 'rw', isa => 'Num', default => 50000 );

sub _build_output_directory
{
  my ($self) = @_;
  my $output_directory = 'pan_genome_sequences';
  return $output_directory;
}

sub _build__number_of_groups {
  my $self = shift;

  return $self->annotate_groups->_group_counter;
}

sub create_files {
    my ($self) = @_;

    my $num_groups = $self->_number_of_groups;
    my $limit      = $self->group_limit;
    if ( $num_groups > $limit ){
      print STDERR "Number of clusters ($num_groups) exceeds limit ($limit). Multifastas not created. Please check the spreadsheet for contamination from different species.\n";
      return 1;
    }

    make_path($self->output_directory);
    
    # if its output_multifasta_files == false then you want to create the core genome and delete all intermediate multifasta files
    for my $gff_file ( @{ $self->gff_files } ) 
    {
      my $gff_multifasta = Bio::PanGenome::Output::GroupsMultifastaNucleotide->new(
          gff_file             => $gff_file,
          group_names          => $self->group_names,
          output_directory     => $self->output_directory,
          annotate_groups      => $self->annotate_groups,
          output_multifasta_files => $self->output_multifasta_files
      );
      $gff_multifasta->populate_files;
    }
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

