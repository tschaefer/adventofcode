#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Carp qw(croak carp);

sub Run {
    my @Blackbox;
    open my $FileHandle, '<', 'input' or croak(sprintf "%s: input", $OS_ERROR);
    push @Blackbox, $_ while(<$FileHandle>);
    close $FileHandle or carp(sprintf "%s: input", $OS_ERROR);

    my ( $Horizontal, $Depth );
    for my $Log (@Blackbox) {
        my ( $Command, $Unit ) = split m{ }, $Log;

        if ( $Command eq 'forward' ) {
            $Horizontal += $Unit;
        }
        elsif ( $Command eq 'up' ) {
            $Depth -= $Unit;
        }
        elsif ( $Command eq 'down' ) {
            $Depth += $Unit;
        }
    }

    printf "The horizontal position is %d and the depth position is %d.\n"
        . "The product amounts to %d\n", $Horizontal, $Depth, $Horizontal * $Depth;

    return 0;
};

exit Run();
