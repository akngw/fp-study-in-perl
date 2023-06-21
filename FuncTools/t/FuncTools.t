package t::FuncTools;

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/..";

use FuncTools qw(alt compose curryn fmap identity merge partial seq tap);

subtest 'alt' => sub {
    subtest '3番目の引数の値で1番目の関数を実行した結果の値が真値であればその値を返す' => sub {

        # Arrange
        my $called_for_1st = 0;
        my @arg_for_1st    = ();
        my $called_for_2nd = 0;
        my @arg_for_2nd    = ();

        # Act
        my $got = alt(
            sub {
                @arg_for_1st    = @_;
                $called_for_1st = 1;
                return 111;
            }
        )->(
            sub {
                @arg_for_2nd    = @_;
                $called_for_2nd = 1;
                return 222;
            }
        )->(100);

        # Assert
        is( $got, 111, 'return value' );

        is( $called_for_1st, 1, '1st function is called' );
        is_deeply( \@arg_for_1st, [100], 'arguments for 1st function' );

        is( $called_for_2nd, 0, '2nd function is not called' );
        is_deeply( \@arg_for_2nd, [], 'arguments for 2nd function' );
    };

    subtest '3番目の引数の値で1番目の関数を実行した結果の値が偽値であれば、3番目の引数の値で2⃣番目の関数を実行した結果を返す' =>
      sub {
        # Arrange
        my $called_for_1st = 0;
        my @arg_for_1st    = ();
        my $called_for_2nd = 0;
        my @arg_for_2nd    = ();

        # Act
        my $got = alt(
            sub {
                @arg_for_1st    = @_;
                $called_for_1st = 1;
                return 0;    # return false
            }
        )->(
            sub {
                @arg_for_2nd    = @_;
                $called_for_2nd = 1;
                return 222;
            }
        )->(100);

        # Assert
        is( $got, 222, 'return value' );

        is( $called_for_1st, 1, '1st function is called' );
        is_deeply( \@arg_for_1st, [100], 'arguments for 1st function' );

        is( $called_for_2nd, 1, '2nd function is called' );
        is_deeply( \@arg_for_2nd, [100], 'arguments for 2nd function' );
      };
};

subtest 'compose' => sub {
    subtest '合成した関数を返す' => sub {

        # Arrange
        my $fn1 = sub {
            my ($x) = @_;
            return $x + 1;
        };
        my $fn2 = sub {
            my ($x) = @_;
            return $x * 2;
        };
        my $fn3 = sub {
            my ($x) = @_;
            return $x / 2;
        };

        # Act
        my $got = compose( $fn1, $fn2, $fn3 )->(100);

        # Assert
        my $expected = $fn1->( $fn2->( $fn3->(100) ) );
        is( $got, $expected, 'composed function' );
    };

    subtest '引数の指定がなければ例外を返す' => sub {

        # Act
        my $got = eval { compose() };

        # Assert
        if ($@) {
            ok('exception');
        }
        else {
            fail('exception');
        }
    };

    subtest '引数が一つであればその関数を返す' => sub {

        # Arrange
        my $fn = sub {

            # Do nothing
        };

        # Act
        my $got = compose($fn);

        # Assert
        my $expected = $fn;
        is( $got, $expected, 'return value' );
    };
};

subtest 'curryn' => sub {
    my $sum = sub {
        my ( $a, $b, $c ) = @_;
        return $a + $b + $c;
    };

    subtest 'test1' => sub {

        # Act
        my $curried = curryn( 3, $sum );

        # Assert
        is( $curried->(1)->(10)->(100), 111, 'curried function' );
        is( $curried->( 1, 10 )->(100), 111, 'curried function' );
        is( $curried->( 1, 10, 100 ),   111, 'curried function' );
    };
};

subtest 'identity' => sub {
    subtest '引数をそのまま返す' => sub {

        # Act
        my $got = identity(100);

        # Assert
        my $expected = 100;
        is( $got, $expected, 'return value' );
    };
};

subtest 'merge' => sub {
    subtest '2番目の引数の関数の結果と3⃣番目の引数の結果を1番目の引数の関数で結合する関数を返す' => sub {

        # Arrange
        my $join = sub {
            my ( $a, $b ) = @_;
            return [ $a, $b ];
        };
        my $fn1 = sub {
            my ($a) = @_;
            return $a + 1;
        };
        my $fn2 = sub {
            my ($a) = @_;
            return $a * 2;
        };

        # Act
        my $got = merge( $join, $fn1, $fn2 )->(100);

        # Assert
        is_deeply( $got, [ 101, 200 ], 'return value' );
    };
};

subtest 'partial' => sub {

    subtest '部分適用した関数を返す（2引数）' => sub {

        # Arrange
        my $add = sub {
            my ( $a, $b ) = @_;
            return $a + $b;
        };

        # Act
        my $add10 = partial( $add, 10 );

        # Assert
        is( $add10->(100), 110, '10 + 100' );
        is( $add10->(-10), 0,   '10 + (-10)' );
        is( $add10->(0),   10,  '10 + 0' );
    };

    subtest '部分適用した関数を返す（3引数）' => sub {

        # Arrange
        my $concat3 = sub {
            my ( $a, $b, $c ) = @_;
            return $a . $b . $c;
        };

        # Act
        my $concat3_1 = partial( $concat3, "abc" );
        my $concat3_2 = partial( $concat3, "abc", 999 );

        # Assert
        is( $concat3_1->( 999, 'xyz' ), 'abc999xyz', 'concat3_1' );
        is( $concat3_2->('xyz'),        'abc999xyz', 'concat3_2' );
    };
};

subtest 'seq' => sub {
    subtest '指定された関数を左から右へ順番に適用する関数を返す' => sub {

        # Arrange
        my $called_for_1st = 0;
        my @arg_for_1st    = ();
        my $called_for_2nd = 0;
        my @arg_for_2nd    = ();

        my $fn1 = sub {
            @arg_for_1st    = @_;
            $called_for_1st = 1;
        };
        my $fn2 = sub {
            @arg_for_2nd    = @_;
            $called_for_2nd = 1;
        };

        # Act
        my $got = seq( $fn1, $fn2 );
        $got->(999);

        # Assert
        is( $called_for_1st, 1, '1st function is called' );
        is_deeply( \@arg_for_1st, [999], 'arguments for 1st' );

        is( $called_for_2nd, 1, '2nd function is called' );
        is_deeply( \@arg_for_2nd, [999], 'arguments for 2nd' );
    };
};

subtest 'tap' => sub {
    subtest '2番目の引数の値で1番目の引数の関数を実行し、2番目の引数の値を返す' => sub {

        # Arrange
        my $called      = 0;
        my @arg         = ();
        my $interceptor = sub {
            @arg    = @_;
            $called = 1;
        };

        # Act
        my $got = tap($interceptor)->(100);

        # Assert
        ok( $called, 'interceptor is called' );
        is_deeply( \@arg, [100], 'arguments passed' );
        is( $got, 100, 'return value' );
    };
};

done_testing();

