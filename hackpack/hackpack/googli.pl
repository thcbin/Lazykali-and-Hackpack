#!/usr/bin/perl 

use LWP::UserAgent; 
use HTTP::Request::Common;
use LWP::Simple;

system(clear);
print " #################################################\n";
print " #       www.Top-Hat-Sec.com                     #\n";
print " #                                               #\n";
print " # by :xd00sry                                   #\n";
print " #################################################\n";


print "\e[1;34m==> \e[0m\e[1;40mEnter the hash :\e[0m";
$hash=<STDIN>;
chop($hash);
if ($hash eq '')
{
    print "\e[1;33m [!] Error No Hash entered!\e[0m\n";
    exit(0);
}

print "\e[1;41m Ok !\e[0m\n";
$url = "https://goog.li/?q=$hash"; 
$lwp = LWP::UserAgent->new(); 
$lwp->agent("Mozilla/5.0 (X11; U; Linux i686 (x86_64); de; rv:1.9.1.8) Gecko/20100202 Firefox/3.5.8");
$connect = $lwp -> get($url);
 
print "====>   "; 
if ($connect->content =~ /<span><b>(.*)<\/b><\/span><\/abbr>/)
{ 
print "Result : \e[0m\e[1;32;40m$1\e[0m\n"; 
} else { 
print "Result : \e[1;31mHash not Found\e[0m\n";
}  
