package Serge::Engine::Plugin::parse_lcd_lines;
use parent Serge::Engine::Plugin::Base::Parser;

use strict;

use Encode qw(encode_utf8);

sub name {
    return 'LCD custom parser plugin';
}

sub init {
    my $self = shift;

    $self->SUPER::init(@_);

    $self->merge_schema({
        test => 'STRING',
    });
}

sub validate_data {
    my $self = shift;

    $self->SUPER::validate_data;

    if (defined $self->{data}->{test}) {
    }
}

sub parse {
    my ($self, $textref, $callbackref, $lang) = @_;

    die 'callbackref not specified' unless $callbackref;

    print "*** IMPORT MODE ***\n" if $self->{import_mode};

    my @out;
    my $is_source = 0;
    my %sources;
    my $n = 0;
    my @lines = split(/\n/, $$textref);
    foreach my $line (@lines) {
        $is_source = !$is_source;
        #print $line;
        #print "[$is_source]\n";    
        if ($is_source) {
            my ($src_lang, $index) = $line =~ /^<(\w+)=(\d+)>/;
            
            push @out, $line;
            $line =~ s/^<(\w+)=(\d+)> //;
            $sources{$index} = $line;

            next;
        }
        
        my ($tag) = $line =~ /(<\w+=\d+>)/;
        my ($dest_lang, $index) = $tag =~ /<(\w+)=(\d+)>/;
        my $translation = &$callbackref($sources{$index}, $index, undef, undef, $lang, $index);
        if ($lang) {
            push @out, $tag.' '.$translation;
        }
    }

    return $lang ? join("\n", @out) : undef;
}

1;