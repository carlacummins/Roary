package Bio::PanGenome::QC::ShredAssemblies;

# ABSTRACT: slice .fa assemblies into "reads" for kraken input

=head1 SYNOPSIS

=cut

use Moose;
use Bio::SeqIO;
use File::Basename;
use Cwd;
with 'Bio::PanGenome::JobRunner::Role';

has 'gff_files'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'read_size'        => ( is => 'rw', isa => 'Int',      default => 150 );
has 'output_directory' => ( is => 'rw', isa => 'Str',      lazy_build => 1 );

sub _build_output_directory {
	return getcwd;
}

sub _extract_nuc_fasta {
	my ($self, $gff) = @_;

	my $prefix = basename( $gff, ".gff" );
	my $outfile = $self->output_directory . "/$prefix.fna";
	my $cmd = "sed -n '/##FASTA/,//p' $gff | grep -v \'##FASTA\' > $outfile";

	system( $cmd );
	return $outfile;
}

sub shred {
	my $self = shift;

	foreach my $f ( @{ $self->gff_files } ){
		# read seq and shred into reads
		my $fasta = $self->_extract_nuc_fasta($f);
		my $seqio = Bio::SeqIO->new( -file => $fasta, -format => 'fasta' );

		my @reads;
		my $seq;
		while( $seq = $seqio->next_seq() ){
			push( @reads, @{ $self->_shredded_seq($seq->{primary_seq}->{seq}) } );
		}

		# write to file
		my $prefix = basename( $f, ".gff" );
		my $outfile = $self->output_directory . "/$prefix.shred.fa";
		open( OUTFH, '>',  $outfile ) or die "Couldn't write to $outfile: $!";
		my $c = 1;
		foreach my $r ( @reads ){
			print OUTFH ">" . $prefix . "_$c\n";
			print OUTFH "$r\n";
			$c++;
		}
		close OUTFH;
	}
	1;
}

sub _shredded_seq {
	my ( $self, $seq ) = @_;
	chomp $seq;

	my $size = $self->read_size;
	my $unpack = "(A$size)*";
	my @reads = unpack( $unpack, $seq );

	my $last = pop @reads;
	push( @reads, $last ) unless $last eq ''; # deal with trailing empty entries

	return \@reads;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;