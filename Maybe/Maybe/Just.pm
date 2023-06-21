package Maybe::Just;

use strict;
use warnings;

use Maybe;

sub new {
    my ( $class, $value ) = @_;
    return bless \$value, $class;
}

sub is_maybe_just {
    my ($a) = @_;
    my $isa = eval { $a->isa('Maybe::Just') };
    if ($@) {
        return '';
    }
    return $isa;
}

sub fmap {
    my ( $self, $fn ) = @_;
    my $a = $fn->($$self);
    if ( Maybe::is_maybe($a) ) {
        return $a;
    }
    else {
        return Maybe::Just->new($a);
    }
}

sub to_string {
    my ($self) = @_;
    return "Maybe::Just($$self)";
}

1;
