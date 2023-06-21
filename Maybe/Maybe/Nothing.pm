package Maybe::Nothing;

use strict;
use warnings;

sub new {
    my ($class) = @_;
    my $undef = ();
    return bless \$undef, $class;
}

sub is_maybe_nothing {
    my ($a) = @_;
    my $isa = eval { $a->isa('Maybe::Nothing') };
    if ($@) {
        return '';
    }
    return $isa;
}

sub fmap {
    my ( $self, undef ) = @_;
    return $self;
}

sub to_string {
    my (undef) = @_;
    return 'Maybe::Nothing';
}

1;
