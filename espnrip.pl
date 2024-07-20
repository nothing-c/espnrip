use v5.10; use HTTP::Tiny;

# from https://www.espn.com/espn/news/story?page=rssinfo
our %f = (
    nfl => 'https://www.espn.com/espn/rss/nfl/news',
    nba => 'https://www.espn.com/espn/rss/nba/news',
    mlb => 'https://www.espn.com/espn/rss/mlb/news',
    nhl => 'https://www.espn.com/espn/rss/nhl/news',
    cbb => 'https://www.espn.com/espn/rss/ncb/news',
    cfb => 'https://www.espn.com/espn/rss/ncf/news'
    );

sub rip($) {
    my $u=shift;
    my @r;
    my $h=HTTP::Tiny->new(); my $r=$h->get($u); die "No pull!" unless $r->{success}; my @x = split /<item>/,$r->{content};
    for (grep !/rss/,@x) { my @y=split /></,$_; $y[1]=~s/^.+\[(.+)\]{2}/$1/; $y[4]=~s/^.*\[(.+)\]{2}/$1/;my $l=(grep /\[https:/,@y)[0]; $l=~s/^.*\[(.+)\]{2}/$1/;push @r,[$y[1],$y[4],$l];}
    return @r;
}

sub serve(@) {
    my $r;
    for (@_) { $r.=sprintf "<article><h2><a href=\"%s\">%s</a></h2><p>%s</p></article>\n",$_->[2],$_->[0],$_->[1],; }
    return $r;
}

open my $F,'>',"./espn-rip.html" or die "Could not open outfile";
print $F "<!DOCTYPE html><head></head><body>Generated " . localtime;
for (sort keys %f) { print $F "<h1>".uc $_."</h1>"; print $F serve rip $f{$_} };
print $F "</body></html>";
close $F;
