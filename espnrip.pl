use v5.10; use HTTP::Tiny; use Getopt::Std;

our $N="./espn-rip.html"; # default output file

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

sub file($) {
    open my $F,'>', shift or die "Could not open outfile";
    print $F "<!DOCTYPE html><head></head><body>Generated " . localtime . "<br>";
    for (sort keys %f) { print $F "<a href=\"#$_\">".uc $_."</a><br>"; }
    for (sort keys %f) { print $F "<h1 id=\"$_\">".uc $_."</h1>"; print $F serve rip $f{$_} };
    print $F "</body></html>"; close $F;
}

sub cgi() {
    say "<!DOCTYPE html><head></head><body>Generated " . localtime . "<br>";
    for (sort keys %f) { say "<a href=\"#$_\">".uc $_."</a><br>"; }
    for (sort keys %f) { say "<h1 id=\"$_\">".uc $_."</h1>"; say serve rip $f{$_} };
    say "</body></html>";
}

sub cli($) {
    my $x=shift;
    if (!(exists $f{$x})) { say "Sport $x does not exist!"; help; exit -1 };
    map {printf "Title: %s\nDescription: %s\nLink: %s\n",$_->[0],$_->[1],$_->[2]} rip $f{$x};
}

sub help() {
    say "espnrip: ESPN RSS feed";
    say "Format: espnrip [-fch] [-F file] [-s sport]";
    say "No arguments: output all sports in human-readable format to STDOUT";
    say "-f: output HTML to default file ($N)";
    say "-c: output as a CGI program";
    say "-F file: output HTML to file";
    say "-s sport: output only entries relating to sport";
    say "-h: display this message";
    say "Sports: NFL, NBA, MLB, NHL, CBB, CFB";
}

getopts 'fcF:s:h';
if ($opt_f) { file $N; }
elsif ($opt_F) { file $opt_F; }
elsif ($opt_c) { cgi; }
elsif ($opt_s) { cli lc $opt_s; }
elsif ($opt_h) { help; }
else { for (keys %f) { cli $_; } }
