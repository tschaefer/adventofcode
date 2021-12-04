#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Carp qw(croak carp);

sub get_most_common_bit {
    my ( $Numbers, $Position ) = @_;

    my %Seen;
    for ( @{$Numbers} ) {
        my $Bit = substr $_, $Position, 1;
        $Seen{$Bit}++;
    }

    return $Seen{0} > $Seen{1} ? 0 : 1;
}

sub get_least_common_bit {
    my ( $Numbers, $Position ) = @_;

    my %Seen;
    for ( @{$Numbers} ) {
        my $Bit = substr $_, $Position, 1;
        $Seen{$Bit}++;
    }

    return $Seen{1} < $Seen{0} ? 1 : 0;
}

sub get_oxygen_generator_rating {
    my @Ratings = @_;

    my $Position = 0;
    while ( scalar @Ratings > 1 ) {
        my $Bit = get_most_common_bit( \@Ratings, $Position );
        @Ratings = grep { $Bit == substr $_, $Position, 1 } @Ratings;

        $Position++;
    }

    return $Ratings[-1];
}

sub get_co2_generator_rating {
    my @Ratings = @_;

    my $Position = 0;
    while ( scalar @Ratings > 1 ) {
        my $Bit = get_least_common_bit( \@Ratings, $Position );
        @Ratings = grep { $Bit == substr $_, $Position, 1 } @Ratings;

        $Position++;
    }

    return $Ratings[-1];
}

sub convert_binary_string_to_decimal {
    my $Binary = shift;

    return unpack "N", pack "B32", substr "0" x 32 . ( $Binary + 0 ), -32;
}

sub Run {
    my @Numbers;
    open my $FileHandle, '<', 'input'
      or croak( sprintf "%s: input", $OS_ERROR );
    push @Numbers, $_ while (<$FileHandle>);
    close $FileHandle or carp( sprintf "%s: input", $OS_ERROR );

    my @OxygenRatings = @Numbers;
    my @CO2Ratings    = @Numbers;

    my $OxygenGeneratorRating = get_oxygen_generator_rating(@OxygenRatings);
    my $CO2GeneratorRating    = get_co2_generator_rating(@CO2Ratings);

    $OxygenGeneratorRating =
      convert_binary_string_to_decimal($OxygenGeneratorRating);
    $CO2GeneratorRating = convert_binary_string_to_decimal($CO2GeneratorRating);

    my $LifeSupportRating = $OxygenGeneratorRating * $CO2GeneratorRating;

    printf "The life support rating of the submarine is %d "
      . "the product of the oxygen generator rating %d and CO2 generator rating %d.\n",
      $LifeSupportRating, $OxygenGeneratorRating, $CO2GeneratorRating;

    return 0;
}

exit Run();
