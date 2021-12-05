#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Carp qw(croak carp);
use List::Util qw(max);

sub slurp_input {
    my $File = shift;

    my $FileHandle;
    my $Data = do {
        local $RS = undef;
        open $FileHandle, '<', $File or croak( sprintf "%s: input", $OS_ERROR );
        <$FileHandle>;
    };
    close $FileHandle or carp( sprintf "%s: input", $OS_ERROR );

    return $Data;
}

sub setup_coordinates {
    my $Data = shift;

    my @Entries = split /\n/, $Data;

    my @Coordinates;
    for my $Entry (@Entries) {
        my ( $Start, $End ) = split / -> /, $Entry;

        my %Coordinate;
        ( $Coordinate{X1}, $Coordinate{Y1} ) = split /,/, $Start;
        ( $Coordinate{X2}, $Coordinate{Y2} ) = split /,/, $End;

        push @Coordinates, \%Coordinate;
    }

    return \@Coordinates;
}

sub determine_max_coordinates {
    my $Coordinates = shift;

    my ( @X, @Y );
    for my $Coordinate ( @{$Coordinates} ) {
        for my $Key ( keys %{$Coordinate} ) {
            if ( $Key =~ m{X} ) {
                push @X, $Coordinate->{$Key};
            }
            else {
                push @Y, $Coordinate->{$Key};
            }
        }
    }

    my $XMax = max @X;
    my $YMax = max @Y;

    return {
        XMax => $XMax + 1,
        YMax => $YMax + 1,
    };
}

sub create_diagram {
    my ( $XMax, $YMax ) = @_;

    my @Diagram;
    my $Y = $YMax;
    while ( $Y-- ) {
        my $X = $XMax;
        while ( $X-- ) {
            $Diagram[$Y][$X] = 0;
        }
    }

    return \@Diagram;
}

sub draw_critical_path {
    my ( $Diagram, $Coordinates ) = @_;

    for my $Line ( @{$Coordinates} ) {

        if ( $Line->{X1} == $Line->{X2} ) {
            if ( $Line->{Y1} < $Line->{Y2} ) {
                for my $Y ( $Line->{Y1} .. $Line->{Y2} ) {
                    $Diagram->[$Y][ $Line->{X1} ]++;
                }
            }
            else {
                for my $Y ( $Line->{Y2} .. $Line->{Y1} ) {
                    $Diagram->[$Y][ $Line->{X1} ]++;
                }
            }
            next;
        }

        if ( $Line->{Y1} == $Line->{Y2} ) {
            if ( $Line->{X1} < $Line->{X2} ) {
                for my $X ( $Line->{X1} .. $Line->{X2} ) {
                    $Diagram->[ $Line->{Y1} ][$X]++;
                }
            }
            else {
                for my $X ( $Line->{X2} .. $Line->{X1} ) {
                    $Diagram->[ $Line->{Y1} ][$X]++;
                }
            }
            next;
        }

    }

    return;
}

sub count_multi_crossed_points {
    my $Diagram = shift;

    my $Sum = 0;
    for my $Row ( @{$Diagram} ) {
        for my $Point ( @{$Row} ) {
            $Sum++ if ( $Point >= 2 );
        }
    }

    return $Sum;
}

sub Run {
    my $Data        = slurp_input('input');
    my $Coordinates = setup_coordinates($Data);
    my $Max         = determine_max_coordinates($Coordinates);
    my $Diagram     = create_diagram( $Max->{XMax}, $Max->{YMax} );

    draw_critical_path( $Diagram, $Coordinates );
    my $PointCount = count_multi_crossed_points($Diagram);

    printf "The count of the most dangerous area points "
      . "the submarine should avoid is %d.\n", $PointCount;

    return 0;
}

exit Run();
