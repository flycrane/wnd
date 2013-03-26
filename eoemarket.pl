#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;


my $ua = Mojo::UserAgent->new;
my $json = Mojo::JSON->new;

open FH, "eoemarket.conf" or die $!;
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

    my $get = 'http://eoemarket.com/search/apps/?keyword=';
    my $page = 1;

    while(1)
    {
        last if($page > 30); # in case site error
        my $url = $get.$keyword."&pageNum=$page";

        my $dom = $ua->get($url => {Referer => 'http://www.eoemarket.com/'})->res->dom;
        last if (! @$dom);

        my $dom1= $dom->find('a.free_down');
        last if (! @$dom1);

        for my $i (@$dom1)
        {
            my $down = $i->{'href'};
            my $t= $ua->max_redirects(5)->head($down => {Referer => 'http://www.eoemarket.com/'});
            # print $t->res->headers->location."\n";
            # print $t->{"previous"}->{"res"}->{"content"}->{"headers"}->{"headers"}->{"location"}->[0]->[0]."\n";
            print $t->req->url->to_string."\n";
            
            $sum++;
        }
        
        my $dom2 = $dom->find("div.pageinner");
        last if (! @$dom2);

        my $string = $dom2->[0]->[0]->{'tree'}->[4]->[1];
        last if (! $string);
        if ($string =~ m/(\d+)\/(\d+)/)
        {
            last if ($1 == $2);
        }

        $page++;
    }
    return $sum;
}

