head	1.1;
access;
symbols;
locks; strict;
comment	@# @;


1.1
date	2013.03.26.07.22.41;	author txia;	state Exp;
branches;
next	;


desc
@exit
@


1.1
log
@Initial revision
@
text
@#! /usr/bin/perl 

$| = 1;
use strict;
use warnings;

use Mojo;

my $ua = Mojo::UserAgent->new;

open FH, "coolapk.conf" or die $!;
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
    my ($keyword) = @@_;
    my $sum = 0;

    my $pre = 'http://www.coolapk.com/search/?q=';
    my $page = 1;

    while(1)
    {
        my $url = $pre.$keyword.'&p='.$page;

        last if($page > 30); # for safety
        
        my $dom = $ua->get($url => {Referer => 'http://www.coolapk.com/'})->res->dom->find("td.down > a");
        last if (! @@$dom); # invalid request, page > max

        for my $t (@@$dom)
        {
            my $down =$t->{"href"};
            $down = "http://www.coolapk.com".$down;

            my $dom2 = $ua->get($down => {Referer => 'http://www.coolapk.com/'})->res->dom->find('div#mainArea > script');
            next if (! @@$dom2);
            
            my $code = $dom2->[0]->[0]->{"tree"}->[4]->[1];
            next if(! $code);

            if ($code =~ m/apkDownloadUrl\s+=\s+['"](\/dl\?\S+)['"]/)
            {
                my $apk = 'http://www.coolapk.com'.$1;
                my $tx = $ua->max_redirects(5)->head($apk => {Referer => 'http://apk.hiapk.com/'});
                # print $tx->{"previous"}->{"res"}->{"content"}->{"headers"}->{"headers"}->{"location"}->[0]->[0]."\n";
                print $tx->req->url->to_string."\n";
                $sum++;
            }
        }
        $page++;
    }
    return $sum;
}

@
