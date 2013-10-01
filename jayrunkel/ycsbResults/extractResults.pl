#!/usr/bin/perl -w
# extractResults.pl --- Extract results from ycsb log
# Author: Jay Runkel <jayrunkel@RunkelMac.local>
# Created: 01 Oct 2013
# Version: 0.01

use warnings;
use strict;

my $commandLineRegEx = '^Command line:.*-threads\s(\d+).*mongodb.maxconnections=(\d+)';
my $overallRegEx = '^\[OVERALL\].*(RunTime|Throughput).*?(\d+\.\d+)$';

my $file = $ARGV[0] or die "Need to provide log file on the command line\n";
my $line;
my $keepGoing = 1;
my $foundSummary = 0;
my @results = ();


open(my $fh, '<', $file) or die "Could not open '$file' $!\n";
 while ( $line = <$fh>) {
     my %result = ();
     
     if ($line =~ m/$commandLineRegEx/) {
         print "Threads: $1 - Connections: $2\n";
         $result{'threads'} = $1;
         $result{'connections'} = $2;

         $foundSummary = 0;
         $keepGoing = 1;
             
         while (($line = <$fh>) && $keepGoing) {
#             print "$line\n";
             
             if ($line =~ m/$overallRegEx/) {
                 $foundSummary = 1;
                 print $line;
                 print "Summary - $1 : $2\n";
                 $result{$1} = $2;
             }
             elsif ($foundSummary) {     #We previously found summary results, but now there aren't anymore
                 $foundSummary = 1;
                 $keepGoing = 0;
             }
         }
         push(@results, \%result);
     }
}

my $resultRef;
foreach my $resultRef (@results) {
    print "$resultRef->{'threads'},$resultRef->{'connections'},$resultRef->{'RunTime'},$resultRef->{'Throughput'}\n";
    # print "$resultRef->{'threads'}\n";
    # print "$resultRef->{'connections'}\n";
    # print "$resultRef->{'RunTime'}\n";
    # print "$resultRef->{'Throughput'}\n";
         

}

__END__

=head1 NAME

extractResults.pl - Describe the usage of script briefly

=head1 SYNOPSIS

extractResults.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for extractResults.pl, 

=head1 AUTHOR

Jay Runkel, E<lt>jayrunkel@RunkelMac.localE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Jay Runkel

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
