use Irssi;
use strict;
use FileHandle;

use vars qw($VERSION %IRSSI);

$VERSION = "0.9.8.1";
%IRSSI = (
    authors     => 'Andreas \'ads\' Scherbaum <ads@wars-nicht.de>',
    name        => 'screen_away',
    description => 'set (un)away, if screen is attached/detached',
    license     => 'GPL v2',
    url         => 'none',
);

# /set screen_away_active ON/OFF/TOGGLE
# /set screen_away_repeat <integer>
# /set screen_away_message <string>
# /set screen_away_window <string>
# /set screen_away_nick <string>
#
# active means, that you will be only set away/unaway, if this flag is set, default is ON
# repeat is the number of seconds, after the script will check the screen status again, default is 5 seconds
# message is the away message sent to the server, default: not here ...
# window is a window number or name, if set, the script will switch to this window, if it sets you away, default is '1'
# nick is the new nick, if the script goes away will only be used it not empty

my $timer_name = undef;
my $away_status = 0;
my %old_nicks = ();
my %away = ();

Irssi::theme_register(
[
 'screen_away_crap', 
 '{line_start}{hilight ' . $IRSSI{'name'} . ':} $0'
]);

my $screen_away_used = 0;

if (!defined($ENV{STY})) {
  Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'screen_away_crap', "could not open status file for parent process (pid: " . getppid() . "): $!");
  return;
}

my ($socket_pid, $socket_name, $socket_path);
my $socket = `LC_ALL="C" screen -ls`;
my $running_in_screen = 0;

if ($socket !~ /^No Sockets found/s) {
  $socket_pid = substr($ENV{'STY'}, 0, index($ENV{'STY'}, '.'));
  $socket_path = $socket;
  $socket_path =~ s/^.*\d+ Sockets? in ([^\n]+)\..*$/$1/s;
  $socket_name = $socket;
  $socket_name =~ s/^.+?($socket_pid\.\S+).+$/$1/s;
  if (length($socket_path) != length($socket)) {
    $screen_away_used = 1;
  } else {
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'screen_away_crap',
      "error reading screen informations from:");
    Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'screen_away_crap',
      "$socket");
    return;
  }
}

if ($screen_away_used == 0) {
  return;
}

$socket = $socket_path . "/" . $socket_name;

Irssi::settings_add_bool('misc', $IRSSI{'name'} . '_active', 1);
Irssi::settings_add_int('misc', $IRSSI{'name'} . '_repeat', 5);
Irssi::settings_add_str('misc', $IRSSI{'name'} . '_message', "not here ...");
Irssi::settings_add_str('misc', $IRSSI{'name'} . '_window', "1");
Irssi::settings_add_str('misc', $IRSSI{'name'} . '_nick', "");

screen_away();

sub screen_away {
  my ($away, @screen, $screen);
  if (Irssi::settings_get_bool($IRSSI{'name'} . '_active') == 1) {
    if ($away_status == 0) {
      Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'screen_away_crap',
        "activating $IRSSI{'name'} (interval: " . Irssi::settings_get_int($IRSSI{'name'} . '_repeat') . " seconds)");
    }
    my @screen = stat($socket);
    if (($screen[2] & 00100) == 0) {
      $away = 1;
    } else {
      $away = 2;
    }
    if ($away == 1 and $away_status != 1) {
      if (length(Irssi::settings_get_str($IRSSI{'name'} . '_window')) > 0) {
        Irssi::command('window goto ' . Irssi::settings_get_str($IRSSI{'name'} . '_window'));
      }
      Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'screen_away_crap', "Set away");
      my $message = Irssi::settings_get_str($IRSSI{'name'} . '_message');
      if (length($message) == 0) {
        $message = "not here ...";
      }
      my ($server);
      foreach $server (Irssi::servers()) {
        if (!$server->{usermode_away}) {
          $away{$server->{'tag'}} = 0;
          $server->command("AWAY " . (($server->{chat_type} ne 'SILC') ? "-one " : "") . "$message") if (!$server->{usermode_away});
          if (length(Irssi::settings_get_str($IRSSI{'name'} . '_nick')) > 0) {
            if (Irssi::settings_get_str($IRSSI{'name'} . '_nick') ne $server->{nick}) {
              $old_nicks{$server->{'tag'}} = $server->{nick};
              $server->command("NICK " . Irssi::settings_get_str($IRSSI{'name'} . '_nick'));
            }
          }
        } else {
          $away{$server->{'tag'}} = 1;
        }
      }
      $away_status = $away;
    } elsif ($away == 2 and $away_status != 2) {
      Irssi::printformat(MSGLEVEL_CLIENTCRAP, 'screen_away_crap', "Reset away");
      my ($server);
      foreach $server (Irssi::servers()) {
        if ($away{$server->{'tag'}} == 1) {
          $away{$server->{'tag'}} = 0;
          next;
        }
        $server->command("AWAY" . (($server->{chat_type} ne 'SILC') ? " -one" : "")) if ($server->{usermode_away});
        if (defined($old_nicks{$server->{'tag'}}) and length($old_nicks{$server->{'tag'}}) > 0) {
          $server->command("NICK " . $old_nicks{$server->{'tag'}});
          $old_nicks{$server->{'tag'}} = "";
        }
      }
      $away_status = $away;
    }
  }
  register_screen_away_timer();
  return 0;
}

sub register_screen_away_timer {
  if (defined($timer_name)) {
    Irssi::timeout_remove($timer_name);
  }
  $timer_name = Irssi::timeout_add(Irssi::settings_get_int($IRSSI{'name'} . '_repeat') * 1000, 'screen_away', '');
}