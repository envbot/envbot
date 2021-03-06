#!/usr/bin/perl
use strict;
use Safe;

my $expr = shift;

my $cpt = new Safe;

#Basic variable IO and traversal

$cpt->permit(':base_core');

$SIG{ALRM} = sub {
	die "Alarm";
};

alarm(4);

my $ret = $cpt->reval($expr);

if ($@) {
	print $@;
} else {
	print $ret;
}
