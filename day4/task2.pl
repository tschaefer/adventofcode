#!/usr/bin/env perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Carp qw(croak carp);
use List::Util qw(all sum);

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
    for my $Line (@Input) {
        if ( !$Line ) {
            $RowIndex = 0;
            $BoardsIndex++;
            next;
        }
        $Line =~ s/^\s//;

        my @BoardRow;
        for my $Number ( split /\s+/, $Line ) {
            push @BoardRow, { Number => $Number, Marked => 0 };
        }
        push @{ $Setup{Boards}->{$BoardsIndex}->{Numbers}->[ $RowIndex++ ] },
          @BoardRow;
        $Setup{Boards}->{$BoardsIndex}->{Marked} = 0;
    }

    return \%Setup;
}


sub mark_number {
    my ( $Board, $DrawNumber ) = @_;

    for my $Row ( @{ $Board->{Numbers} } ) {
        for my $Number ( @{$Row} ) {
            if ( $Number->{Number} == $DrawNumber ) {
                $Number->{Marked} = 1;
                last;
            }
        }
    }

    return;
}

sub check_board_rows {
    my $Board = shift;

    for my $Row ( @{ $Board->{Numbers} } ) {
        if ( all { $_->{Marked} == 1 } @{$Row} ) {
            $Board->{Marked} = 1;
            last;
        }
    }

    return;
}

sub check_board_columns {
    my $Board = shift;

    my $Index = 0;
    my @Columns;
    while ( $Index < 5 ) {
        for my $Row ( @{ $Board->{Numbers} } ) {
            push @{ $Columns[$Index] }, $Row->[$Index];
        }
        $Index++;
    }

    for my $Column (@Columns) {
        if ( all { $_->{Marked} == 1 } @{$Column} ) {
            $Board->{Marked} = 1;
            last;
        }
    }

    return;
}

sub play_board {
    my ( $Board, $DrawNumber ) = @_;

    mark_number( $Board, $DrawNumber );
    check_board_rows($Board);
    check_board_columns($Board);

    return $Board->{Marked};
}

sub find_loser_board {
    my $Setup = shift;

    my ( $LoserBoard, $LoserDrawNumber );
  DRAW:
    for my $DrawNumber ( @{ $Setup->{DrawNumbers} } ) {
        $LoserDrawNumber = $DrawNumber;

      BOARD:
        for my $BoardIndex ( sort keys %{ $Setup->{Boards} } ) {
            my $Board = $Setup->{Boards}->{$BoardIndex};
            next BOARD if ($Board->{Marked});
            $LoserBoard = $BoardIndex;

            play_board( $Board, $DrawNumber );
            last DRAW if ( all { $_->{Marked} } values %{ $Setup->{Boards} });
        }
    }

    return {
        BoardIndex => $LoserBoard,
        DrawNumber => $LoserDrawNumber,
    };
}

sub calculate_board_sum {
    my $Board = shift;

    my $Sum = 0;
    for my $Row ( @{ $Board->{Numbers} } ) {
        for my $Number ( @{$Row} ) {
            next if ( $Number->{Marked} );
            $Sum += $Number->{Number};
        }
    }

    return $Sum;
}

sub Run {
    my $Input  = slurp_input('input');
    my $Setup  = setup_bingo($Input);
    my $Result = find_loser_board($Setup);

    my $LoserBoardSum =
      calculate_board_sum( $Setup->{Boards}->{ $Result->{BoardIndex} } );
    my $FinalScore = $LoserBoardSum * $Result->{DrawNumber};

    printf "The bingo loser board %d final score is %d "
      . "the product of the board sum %d and loser draw number %d.\n",
      $Result->{BoardIndex}, $FinalScore, $LoserBoardSum, $Result->{DrawNumber};

    return 0;
}

exit Run();
