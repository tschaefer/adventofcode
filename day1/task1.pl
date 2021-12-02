#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Carp qw(croak carp);

sub Run {
    my @Numbers;
    open my $FileHandle, '<', 'input' or croak(sprintf "%s: input", $OS_ERROR);
    push @Numbers, $_ while(<$FileHandle>);
    close $FileHandle or carp(sprintf "%s: input", $OS_ERROR);

    my $Index = scalar @Numbers - 2;
    my ( $Next, $Count );
    for my $Current (0..$Index) {
        $Next = $Current + 1;

        $Count++ if ($Numbers[$Next] > $Numbers[$Current]);
    }

    printf "The number of times a depth measurement increases is %d", $Count;

    return 0;
};

exit Run();
