#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;

my $pre = "http://apk.gfan.com/Aspx/UserApp/"; # paopaobing
my $suf = "-1.shtml";

my $ua = Mojo::UserAgent->new;

open FH, "gfan.conf" or die $!;
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
    my ($mid) = @_;
    my $sum = 0;
    my $num = 1;
   
    while(1)
    {
        my $url = $pre.$mid."-".$num.$suf;
        my $dom = $ua->get($url)->res->dom->find("div.downloadOper > a");

        my $cnt = @$dom;
        last if ($cnt == 0);

        $num++;
        $sum += $cnt;
        
        for my $t (@$dom)
        {
            # my $down = $t->[0]->{"tree"}->[9]->[7]->[4]->[2]->{"href"}."\n";
            my $down = $t->{'href'};
            my $tx = $ua->max_redirects(5)->head($down);
            # print $tx->{"previous"}->{"res"}->{"content"}->{"headers"}->{"headers"}->{"location"}->[0]->[0]."\n";
            print $tx->req->url->to_string."\n";
        }

        last if($cnt < 30); # max games pe page
    }

    return $sum;
}

