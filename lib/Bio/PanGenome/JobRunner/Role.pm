package Bio::PanGenome::JobRunner::Role;

# ABSTRACT: A role to add job runner functionality

=head1 SYNOPSIS

A role to add job runner functionality
   with 'Bio::PanGenome::JobRunner::Role';

=cut

use Moose::Role;

has 'job_runner'              => ( is => 'rw', isa => 'Str',  default  => 'Local' );
has '_job_runner_class'       => ( is => 'ro', isa => 'Str',  lazy => 1, builder => '_build__job_runner_class' );
has '_memory_required_in_mb'  => ( is => 'rw', isa => 'Int',  default => '200' );
has '_queue'                  => ( is => 'rw', isa => 'Str',  default => 'normal' );
has 'dont_wait'               => ( is => 'rw', isa => 'Bool', default => 0 );
has 'cpus'                    => ( is => 'ro', isa => 'Int',      default => 1 );

sub _build__job_runner_class {
    my ($self) = @_;
    my $job_runner_class = "Bio::PanGenome::JobRunner::" . $self->job_runner;
    eval "require $job_runner_class";
    return $job_runner_class;
}


1;
