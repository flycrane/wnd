#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;


my $ua = Mojo::UserAgent->new;
my $json = Mojo::JSON->new;

open FH, "apk91.conf" or die $!;
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

    my $get = 'http://apk.91.com/game/Android/search/';
    my $page = 1;

    while(1)
    {
        last if($page > 60); # in case site problem
        my $url = "$get${page}_5_$keyword";

        my $dom = $ua->get($url => {Referer => 'http://apk.apk91.com/'})->res->dom->find('div.game_list3_r > a');
        last if(! @$dom);

        for my $i (@$dom)
        {
            my $link = $i->{"href"};
            my $dom2 = $ua->max_redirects(0)->get($link => {Referer => 'http://apk.apk91.com/'})->res->dom->at('a.link1');
            last if (! @$dom2);
            
            my $apk = "http://apk.91.com".$dom2->{'href'};
            
            my $dom3 = $ua->max_redirects(0)->get($apk => {Referer => 'http://apk.apk91.com/'});
            last if (! $dom3);

            print $dom3->res->headers->location."\n";

            $sum++;
        }

        $page++;
    }
    return $sum;
}

