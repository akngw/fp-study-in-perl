package FuncTools;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(alt compose curryn fmap identity merge partial seq tap);

# altは、1番目の関数の実行結果が真値の場合その値を返し、
# 偽値の場合は、２番めの関数の実行結果を返すような関数を返す。
#
# 入力パラメータ:
#     - $fn1: 最初の関数
#     - $fn2: 2番目の関数
#
# 出力:
#     - 生成した関数
#
# 使用例:
#     my $find_or_create_user = alt( \&find_user )->( \&create_user );
#     my $user                = $find_or_create_user->("Momotaro");
sub alt {
    my ($fn1) = @_;
    return sub {
        my ($fn2) = @_;
        return sub {
            my ($a) = @_;
            return ( $fn1->($a) || $fn2->($a) );
        };
    };
}

# composeは与えられた関数の合成関数を返す。
#
# 入力パラメータ:
#     - @fn: 合成する関数のリスト
#
# 出力:
#     - 生成した関数
#
# 使用例:
#     my $test = compose( \&test1, \&test2 );
sub compose {
    my @fn  = @_;
    my $len = scalar @fn;
    if ( $len == 0 ) {
        die 'No arguments specified.';
    }
    elsif ( $len == 1 ) {
        return $fn[0];
    }
    else {
        return _compose(@fn);
    }
}

sub _compose {
    my @fn = @_;
    return sub {
        my @a      = @_;
        my $result = $fn[-1]->(@a);
        for ( my $i = $#fn - 1 ; $i >= 0 ; $i-- ) {
            $result = $fn[$i]->($result);
        }
        return $result;
    };
}

# currynは指定した関数を指定した引数の数を持つものとしてカリー化して返す
#
# 入力パラメータ
#     - $n: 引数の数
#     - $fn: カリー化する関数
#
# 出力:
#     - カリー化した関数
sub curryn {
    my ( $n, $fn ) = @_;
    return partial( \&_curried, $n, $fn );
}

sub _curried {
    my ( $n, $fn, @a ) = @_;
    if ( scalar(@a) >= $n ) {
        return $fn->(@a);
    }
    else {
        return sub {
            my (@b) = @_;
            return _curried( $n, $fn, @a, @b );
        }
    }
}

# fmapは引数の関数をfmapで呼び出す関数を生成して返す
#
# 入力パラメータ
#     - $fn: 関数
#
# 出力:
#     - 生成した関数
sub fmap {
    my ($fn) = @_;
    return sub {
        my ($instance) = @_;
        return $instance->fmap($fn);
    };
}

# identityは引数をそのまま返す
#
# 入力パラメータ
#     - $a: 引数
#
# 出力:
#     - 引数として受け取った値
sub identity {
    return shift;
}

# mergeは、2番目の関数の結果と3番目の関数の結果を1番目の関数で結合する関数を返す
#
# 入力パラメータ
#     - $join: 結果を合成する1番目の関数
#     - $fn1: 2番目の関数
#     - $fn2: 3番目の関数
#
# 出力:
#     - 生成した関数
sub merge {
    my ( $join, $fn1, $fn2 ) = @_;
    return sub {
        my ($a) = @_;
        return $join->( $fn1->($a), $fn2->($a) );
    };
}

# partialは指定関数を部分適用を行った関数を返す
#
# 入力パラメータ:
#     - $fn: 部分適用を行う関数
#     - @a: 部分適用する引数
#
# 出力:
#     - 生成した関数
#
# 使用例:
#     my $add10 = partial(sub { $_[0] + $_[1] }, 10);
#     $add10->(100); # => 110
sub partial {
    my ( $fn, @a ) = @_;
    return sub {
        my @b = @_;
        return $fn->( @a, @b );
    };
}

# seqは指定関数を連続して適用する関数を返す
#
# 入力パラメータ:
#     - @fn: 関数のリスト
#
# 出力:
#     - 生成した関数
#
# 使用例:
#     my $notify = seq( \&send_mail, \&send_slack_message );
sub seq {
    my @fn = @_;
    return sub {
        my ($a) = @_;
        foreach my $fn (@fn) {
            $fn->($a);
        }
    };
}

# tapは引数を使って関数を適用し、引数の値をそのまま返す関数を返す
#
# 入力パラメータ:
#     - $fn: 関数
#
# 出力:
#     - 生成した関数
#
# 使用例:
#     my $tee = tap( \&write_to_a_file );
sub tap {
    my ($fn) = @_;
    return sub {
        my ($a) = @_;
        $fn->($a);
        return $a;
    };
}

1;
