package Maybe;

use strict;
use warnings;

use Maybe::Just;
use Maybe::Nothing;

use Exporter qw(import);

our @EXPORT_OK = qw(just nothing is_maybe);

my $NOTHING = ();

sub just {
    my ($a) = @_;
    return Maybe::Just->new($a);
}

sub nothing {
    unless ( defined $NOTHING ) {
        $NOTHING = Maybe::Nothing->new;
    }
    return $NOTHING;
}

sub is_maybe {
    my ($a) = @_;
    return Maybe::Just::is_maybe_just($a)
      || Maybe::Nothing::is_maybe_nothing($a);
}

1;
