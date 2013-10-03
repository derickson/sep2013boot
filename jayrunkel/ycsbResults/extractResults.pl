#!/usr/bin/perl -w
# extractResults.pl --- Extract results from ycsb log
# Author: Jay Runkel <jayrunkel@RunkelMac.local>
# Created: 01 Oct 2013
# Version: 0.01


use warnings;
use strict;

my $commandLineRegEx = '^Command line:.*-threads\s(\d+).*mongodb.maxconnections=(\d+)';
my $overallRegEx = '^\[OVERALL\].*(RunTime|Throughput).*?(\d+\.\d+)$';

sub printHeader($$$$$) {
    my $label = uc(shift);
    my $threadMin = shift;
    my $connMin = shift;
    my $connMax = shift;
    my $results = shift;

    my $resultRef;
#    print "$threadMin - $connMin - $connMax - $results\n";
    
    print "$label\n";
    print "Thread";

    my $t= $threadMin;
    for (my $c = $connMin; $c <= $connMax; $c++) {
        my $key = $t . " " . $c;
        $resultRef = $results->{$key};
        if ($resultRef) {
            print ",Conn $c";
        }
    }
    
    print "\n";
}

sub printResults($$$$$$) {
    my $parameter = shift;
    my $threadMin = shift;
    my $threadMax = shift;
    my $connMin = shift;
    my $connMax = shift;
    my $results = shift;

    my $validRow = 0;
    # Print results
    for (my $t = $threadMin; $t <= $threadMax; $t++) {
        $validRow = 0;

        for (my $c = $connMin; $c <= $connMax; $c++) {
            my $key = $t . " " . $c;
            my $resultRef = $results->{$key};
            if ($resultRef) {
                $validRow =1;
                print "$t" if $c == $connMin;
                print ",$resultRef->{$parameter}";
            }
        }
        print "\n" if $validRow;
    }
}




my $file = $ARGV[0] or die "Need to provide log file on the command line\n";
my $line;
my $keepGoing = 1;
my $foundSummary = 0;
my %results = ();
my $key;
my $threadMin = 1000000;
my $threadMax = 0;
my $connMin=1000000;
my $connMax=0;
my $resultRef;



print "File: $file\n";


open(my $fh, '<', $file) or die "Could not open '$file' $!\n";
 while ( $line = <$fh>) {
     my %result = ();
     
     if ($line =~ m/$commandLineRegEx/) {
#         print "Threads: $1 - Connections: $2\n";
         $result{'threads'} = $1;
         $result{'connections'} = $2;
         $threadMin = $1 if $threadMin > $1;
         $threadMax = $1 if $threadMax < $1;
         $connMin = $2 if $connMin > $2;
         $connMax = $2 if $connMax < $2;
         
         $foundSummary = 0;
         $keepGoing = 1;
             
         while ((defined $fh) && ($line = <$fh>) && $keepGoing) {
#             print "$line\n";
             
             if ($line =~ m/$overallRegEx/) {
                 $foundSummary = 1;
#                 print $line;
#                 print "Summary - $1 : $2\n";
                 $result{$1} = $2;
             }
             elsif ($foundSummary) {     #We previously found summary results, but now there aren't anymore
                 $foundSummary = 1;
                 $keepGoing = 0;
             }
         }
         $key = $result{'threads'} . " " . $result{'connections'};
         $results{$key} = \%result;
         #push(@results, \%result);
     }
}



printHeader("Throughput", $threadMin, $connMin, $connMax, \%results);
printResults("Throughput", $threadMin, $threadMax, $connMin, $connMax, \%results);

print "\n\n";

printHeader("RunTime", $threadMin, $connMin, $connMax, \%results);
printResults("RunTime", $threadMin, $threadMax, $connMin, $connMax, \%results);

    

#print "Threads,Connections,RunTime,Throughput\n";
# foreach my $resultRef (@results) {
#     print "$resultRef->{'threads'},$resultRef->{'connections'},$resultRef->{'RunTime'},$resultRef->{'Throughput'}\n";
#     # print "$resultRef->{'threads'}\n";
#     # print "$resultRef->{'connections'}\n";
#     # print "$resultRef->{'RunTime'}\n";
#     # print "$resultRef->{'Throughput'}\n";
#}

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
