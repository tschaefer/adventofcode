#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Carp qw(croak carp);

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

sub setup_bingo {
    my $Data = shift;

    my @Input = split /\n/, $Data;

    my %Setup;

    $Setup{DrawNumbers} = [ split /,/, shift @Input ];
    shift @Input;

    my $BoardsIndex = 0;
    my $RowIndex    = 0;
    for (@Input) {
        if ( !$_ ) {
            $RowIndex = 0;
            $BoardsIndex++;
            next;
        }
        $_ =~ s/^\s//;

        my @BoardRow = split /\s+/, $_;
        push @{ $Setup{Boards}->{$BoardsIndex}->[ $RowIndex++ ] }, @BoardRow,;
    }

    return \%Setup;
}

sub play_bingo {
    my $Setup = shift;

    my ( $WinnerBoard, $WinnerDraw );
  DRAW:
    for my $Draw ( @{ $Setup->{DrawNumbers} } ) {
        $WinnerDraw = $Draw;
        while ( my ( $BoardIndex, $Board ) = each %{ $Setup->{Boards} } ) {
            $WinnerBoard = $BoardIndex;

            for my $Row ( @{$Board} ) {
                my $Index = -1;
                for my $Number ( @{$Row} ) {
                    $Index++;
                    splice @{$Row}, $Index, 1 if ( $Number == $Draw );
                    last DRAW if ( !@{$Row} );
                }
            }

        }
    }

    return {
        DrawNumber => $WinnerDraw,
        BoardIndex => $WinnerBoard,
    };
}

sub calculate_board_sum {
    my @Board = @_;

    my $Sum = 0;
    for my $Row (@Board) {
        for my $Number ( @{$Row} ) {
            $Sum += $Number;
        }
    }

    return $Sum;
}

sub Run {
    my $Input = slurp_input('input');
    my $Setup = setup_bingo($Input);
    my $Result = play_bingo($Setup);

    my $WinnerBoardSum =
      calculate_board_sum( @{ $Setup->{Boards}->{$Result->{BoardIndex}} } );
    my $FinalScore = $WinnerBoardSum * $Result->{DrawNumber};

    printf "The bingo winner board %d final score is %d "
      . "the product of the board sum %d and winner draw number %d.\n",
      $Result->{BoardIndex}, $FinalScore, $WinnerBoardSum, $Result->{DrawNumber};

    return 0;
}

exit Run();
