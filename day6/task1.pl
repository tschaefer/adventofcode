#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Carp qw(croak carp);

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

    my @Swarm = split m{,}, $Data;

    return \@Swarm;
}

sub simulate_population_evolution {
    my ( $Swarm, $Generation ) = @_;

    for ( 1 .. $Generation ) {
        my @NewFishes;
        for my $Fish ( @{$Swarm} ) {
            if ( !$Fish ) {
                $Fish = 6;
                push @NewFishes, 8;
                next;
            }

            $Fish--;
        }
        push @{$Swarm}, @NewFishes;
    }

    return {
        Swarm    => $Swarm,
        Quantity => scalar @{$Swarm},
        Generation => $Generation,
    };
}

sub Run {
    my $Data   = slurp_input('input');
    my $Swarm  = release_swarm($Data);
    my $Result = simulate_population_evolution( $Swarm, 80 );

    printf "The submarine lanternfish simulation calculated an amount of %d "
        . "fishes after %d days.\n", $Result->{Quantity}, $Result->{Generation};

    return 0;
}

exit Run();
