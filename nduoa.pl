#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;


my $ua = Mojo::UserAgent->new;
my $json = Mojo::JSON->new;

open FH, "nduoa.conf" or die $!;
while(my $line = <FH>)
{
    chomp($line);
    next if($line =~ m/^#/);
    if ($line =~ m/(\S+):(\S+)/)
    {
        print "Processing $1\n";
        my $ret = process($2);
        print "$1 Total found: $ret\n";
    }
}

close FH;


sub process
{
    my ($keyword) = @_;
    my $sum = 0;

    my $get = "http://www.nduoa.com/search?q=";
    my $page = 1;

    while(1)
    {
        last if($page > 30); # in case site error
        my $url = $get.$keyword."&page=$page";

        my $dom = $ua->get($url => {Referer => 'http://www.nduoa.com/'})->res->dom->find('ul#searchList li > div.btn');       
        last if(! @$dom);

        for my $i (@$dom)
        {
            my $a = $i->[0]->{'tree'}->[5]->[2];

            if ($a->{'data-name'} =~ m/\x{70AE}\x{70AE}\x{5175}/)
            {
                my $id = "$a->{'data-id'}";
                my $down = 'http://www.nduoa.com/apk/download/'.$id.'?from=ndoo';
                my $t= $ua->max_redirects(0)->head($down => {Referer => 'http://www.nduoa/'});
                print $t->res->headers->location."\n";
                $sum++;
            }
        }
        $page++;
    }
    return $sum;
}

