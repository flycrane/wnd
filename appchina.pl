#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;


my $ua = Mojo::UserAgent->new;
my $json = Mojo::JSON->new;

open FH, "appchina.conf" or die $!;
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

    my $pre = 'http://www.appchina.com/sou/';
    my $suf = '/?catname=&ref=appplus.searchbox';
    my $page = 1;

    while(1)
    {
        last if($page > 120); # in case site problem
        my $url = "$pre$keyword/$page/$suf";

        my $dom = $ua->get($url => {Referer => 'http://www.appchina.com/'})->res->dom->find('a.rdownload');       
        last if(! @$dom);

        for my $i (@$dom)
        {
            my $apk = $i->{'href'};
            substr($apk, 0, 30, 'http://www.d.appchina.com/McDonald');
            my $t= $ua->max_redirects(0)->get($apk=> {Referer => 'http://www.appchina.com/'});
            print $t->res->headers->location."\n";
            $sum++;
        }
        $page++;
    }
    return $sum;
}

