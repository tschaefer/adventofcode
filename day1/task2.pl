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

    my $Index = scalar @Numbers - 3;
    my @Sums;
    for my $Current (0..$Index) {
        my $Sum = $Numbers[$Current] + $Numbers[$Current +1] + $Numbers[$Current + 2];

        push @Sums, $Sum;
    }

    $Index = scalar @Sums - 2;
    my ( $Next, $Count );
    for my $Current (0..$Index) {
        $Next = $Current + 1;

        $Count++ if ($Sums[$Next] > $Sums[$Current]);
    }

    printf "There are %d sums that are larger than previous sum.\n", $Count;

    return 0;
};

exit Run();
