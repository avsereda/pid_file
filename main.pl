#! /usr/bin/perl

use strict;
use warnings;
use v5.24;
use FindBin qw($Bin);
use lib "$Bin/./";
use PidFile;

my $pid_file = PidFile->new( );
if ( $pid_file->is_already_running ) {
    say 'Already running';
    exit 0;
}

sleep 30;

__END__
