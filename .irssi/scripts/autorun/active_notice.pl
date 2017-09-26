use strict;
use Irssi;

our $VERSION = "1.0";
our %IRSSI = (
    authors     => 'Geert Hauwaerts',
    contact     => 'geert@irssi.org',
    name        => 'active_notice.pl',
    description => 'This script shows notices into the active channel unless it has its own window.',
    license     => 'GNU General Public License',
    url         => 'http://irssi.hauwaerts.be/active_notice.pl',
    changed     => 'Wed Jan 20 22:57:37 CEST 2016',
);

sub notice_move {
    my ($dest, $text, $stripped) = @_;
    my $server = $dest->{server};
    return if (!$server || !($dest->{level} & MSGLEVEL_NOTICES) || $server->ischannel($dest->{target}));
    my $witem  = $server->window_item_find($dest->{target});
    my $awin = Irssi::active_win();
    return if $witem;
    $text =~ s/%/%%/g;
    $awin->print($text, MSGLEVEL_NOTICES);
    Irssi::signal_stop();
}

Irssi::signal_add('print text', 'notice_move');