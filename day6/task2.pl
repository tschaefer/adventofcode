#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Carp qw(croak carp);
use List::Util qw(sum);

use Data::Printer;

sub slurp_input {
    my $File = shift;

    my $FileHandle;
    my $Data = do {
        local $RS = undef;
        open $FileHandle, '<', $File or croak( sprintf "%s: input", $OS_ERROR );
        <$FileHandle>;
    };
    close $FileHandle or carp( sprintf "%s: input", $OS_ERROR );

    $Data =~ s/^\s+|\s+$//g;

    return $Data;
}

sub release_swarm {
    my $Data = shift;

    my %Swarm;
    for my $FishAge ( 0 .. 8 ) {
        $Swarm{$FishAge} = 0;
    }

    for my $FishAge ( split m{,}, $Data ) {
        $Swarm{$FishAge}++;
    }

    return \%Swarm;
}

sub simulate_population_evolution {
    my ( $Swarm, $Generation ) = @_;

    for ( 1 .. $Generation ) {
        my $CreatorFishes = $Swarm->{0};

        for ( 0 .. 7 ) {
            $Swarm->{$_} = $Swarm->{ $_ + 1 };
        }

        $Swarm->{6} += $CreatorFishes;
        $Swarm->{8} = $CreatorFishes;
    }

    return {
        Swarm      => $Swarm,
        Generation => $Generation,
        Population => sum( values %{$Swarm} ),
    };
}

sub Run {
    my $Data   = slurp_input('input');
    my $Swarm  = release_swarm($Data);
    my $Result = simulate_population_evolution( $Swarm, 256 );

    printf "The submarine lanternfish simulation calculated an population of "
      . "%d fishes after %d days.\n", $Result->{Population},
      $Result->{Generation};

}

exit Run();
