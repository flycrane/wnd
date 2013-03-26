#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;


my $ua = Mojo::UserAgent->new;

open FH, "hiapk.conf" or die $!;
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

    # my $dom = $ua->get($url)->res->dom->find("div#Soft_SearchList ul > li.list_item");

    my $post = "http://apk.hiapk.com//search?action=FindSearchSoftList";
    my $page = 1;

    while(1)
    {
        last if($page > 10000); # for safety
        my $tx = $ua->post($post => {Referer => 'http://apk.hiapk.com/', 'Content-Type' => 'application/x-www-form-urlencoded'} => "curPageIndex=$page&keyword=$keyword&sortType=1&categoryId=0");
        last if (! $tx->success);
        
        my $dom = $tx->res->dom->find('a.list_down_link');
        last if (! @$dom); # invalid request, page > max

        for my $t (@$dom)
        {
            my $down =$t->{"href"};
            $down = "http://apk.hiapk.com/".$down;
            my $t = $ua->max_redirects(5)->head($down => {Referer => 'http://apk.hiapk.com/'});
            # print $t->{"previous"}->{"res"}->{"content"}->{"headers"}->{"headers"}->{"location"}->[0]->[0]."\n";
            print $t->req->url->to_string."\n";
            $sum++;
        }
        $page++;
    }

    return $sum;
}

