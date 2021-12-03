#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Carp qw(croak carp);

sub Run {

    my @Numbers;
    open my $FileHandle, '<', 'input'
      or croak( sprintf "%s: input", $OS_ERROR );
    push @Numbers, $_ while (<$FileHandle>);
    close $FileHandle or carp( sprintf "%s: input", $OS_ERROR );

    my @ZeroOne;
    for my $Number (@Numbers) {
        my $Index = 0;
        $Number =~ s/\s*$//;
        for my $Bit ( split //, $Number ) {
            my $Key = $Bit ? 'One' : 'Zero';
            $ZeroOne[ $Index++ ]->{$Key} += 1;
        }
    }

    my ( $GammaRate, $EpsilonRate );
    for (@ZeroOne) {
        $_->{One}  ||= 0;
        $_->{Zero} ||= 0;
        $GammaRate   .= $_->{One} > $_->{Zero} ? 1 : 0;
        $EpsilonRate .= $_->{One} > $_->{Zero} ? 0 : 1;
    }

    $GammaRate = unpack "N", pack "B32",
      substr "0" x 32 . ( $GammaRate + 0 ), -32;
    $EpsilonRate = unpack " N", pack "B32",
      substr "0" x 32 . ( $EpsilonRate + 0 ), -32;

    my $PowerConsumption = $GammaRate * $EpsilonRate;

    printf "The power consumption of the submarine is %d "
      . "the product of the gamma rate %d and epsilon rate %d.\n",
      $PowerConsumption, $GammaRate, $EpsilonRate;

    return 0;
}

exit Run();
