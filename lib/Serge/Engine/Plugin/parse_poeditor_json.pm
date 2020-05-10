package Serge::Engine::Plugin::parse_poeditor_json;
use parent Serge::Engine::Plugin::Base::Parser;

use strict;

use JSON -support_by_pp; # -support_by_pp is used to make Perl on Mac happy
use Serge::Mail;
use Serge::Util qw(xml_escape_strref);

sub name {
    return 'POEditor json parser plugin';
}

sub parse {
    my ($self, $textref, $callbackref, $lang) = @_;

    die 'callbackref not specified' unless $callbackref;

    # Parse JSON

    my $messages;
    eval {
        ($messages) = from_json($$textref);
    };
    if ($@ || !$messages) {
        my $error_text = $@;
        if ($error_text) {
            $error_text =~ s/\t/ /g;
            $error_text =~ s/^\s+//s;
        } else {
            $error_text = "from_json() returned empty data structure";
        }

        die $error_text;
    }

    foreach my $msg (@$messages) {
        $msg->{definition} = &$callbackref($msg->{definition}, $msg->{term}, $msg->{context}, undef, $lang);
    }

    # need to force indent_length, otherwise it will be zero when PP extension 'escape_slash' is used
    # (looks like an issue in some newer version of JSON:PP)
    return to_json($messages, {pretty => 1, indent_length => 4, escape_slash => 1});
}

1;