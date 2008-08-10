package Varsel::Controller::Feed::RSS2;

use strict;
use warnings;
use utf8;

use base 'Catalyst::Controller';

use DateTime;
use XML::RSS;

=head1 NAME

Varsel::Controller::Feed::RSS2 - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 rss2(B<$c>, B<$geo>, B<@times>)

=cut

sub rss2 : Private {
    my ( $self, $c, $geo, @times ) = @_;

    my $yr_model        = $c->model('YR::Locationforecast');
    my $forecasts_ref   = $yr_model->forecasts($geo);
    my @forecasts       = ();

    for my $time (@times) {
        my $forecast_ref = $yr_model->filter_nearest_forecast(
            $time,
            $forecasts_ref
        );

        $forecast_ref = $yr_model->combine_forecast_types($forecast_ref);

        $forecast_ref->{'symbol_string'}
            = $c->model('YR::Forecast::Symbol::Stringify')
                ->filter($forecast_ref->{'symbol_no'});

        $forecast_ref->{'winddirection_string'}
            = $c->model('YR::Forecast::WindDirection::Stringify')
                ->filter($forecast_ref->{'winddirection'});

        push @forecasts, $forecast_ref;
    }

    my $now = DateTime->now(time_zone => 'local');

    my $rss = XML::RSS->new(version => '2.0');

    my $description     = 'Værvarsel for de neste tre dagene';
    my $pubDate         = $now->strftime('%a, %d %b %Y %H:%M:%S');

    utf8::encode($description);
    utf8::encode($pubDate);

    $rss->channel(
        'title'         => 'Varsel feed',
        'link'          => $c->uri_for('/'),
        'language'      => 'no',
        'description'   => $description,
        'copyright'     => 'Copyright 2008 Knut-Olav Hoven',
        'pubDate'       => $pubDate,
        'lastBuildDate' => $pubDate,
    );

    $rss->image(
        'title'         => 'Varsel RSS 2 feed',
        'url'           => $c->uri_for('/favicon.ico'),
        'link'          => $c->uri_for('/'),
        'width'         => 16,
        'height'        => 16,
        'description'   => 'Varsel ikon',
    );

    for my $forecast (@forecasts) {
        my $title       = sprintf(
            '%s',
            $forecast->{'fc_from'}->strftime('%a %d. %b kl %H:%M')
        );
        
        my $description_fmt = '%s, %d grader og %d %s nedbør';

        utf8::encode($title);
        utf8::encode($description_fmt);

        my $description = sprintf(
            $description_fmt,
            $forecast->{'symbol_string'},
            $forecast->{'temp_value'},
            $forecast->{'precip_value'},
            $forecast->{'precip_unit'}
        );

        $rss->add_item(
            'title'         => $title,
            'description'   => $description,
        );
    }

    return $rss;
}

sub update_feed_description : Private {
    my ( $self, $rss, $desc) = @_;
    $rss->channel('description' => $desc);
}

=head2 print(B<$c>, B<$rss>)

This method prints an L<XML::RSS> feed object.

It sets the content type and body on the Catalyst response object.

=cut

sub print : Private {
    my ( $self, $c, $content ) = @_;

    $c->response->content_type('application/xml');
    $c->response->body($content);
}

=head2 get_times_list(B<$count>, B<@dayhours>)

Returns a list of date times matching a list of hours by day.
The B<$count> parameter specifies the number of dates to return.

=cut

sub get_times_list : Private {
    my ( $self, $count, @dayhours ) = @_;

    my @times = ();

    my $now         = DateTime->now(time_zone => 'local');
    my $dt_counter  = $now->clone;


    # We break out when reaching the number of date times we want
    my $counter = 0;

    COUNTER:
    while (1) {
        for my $hour (@dayhours) {
            $dt_counter->set_hour($hour);

            # We need to compare it with current time to avoid times back in
            # time the first day
            my $cmp = DateTime->compare($now, $dt_counter);
            if ($cmp < 0) {
                my $dt = $dt_counter->clone;
                push @times, $dt;

                last COUNTER if ++$counter >= $count;
            }
        }

        $dt_counter->add('days' => 1);
    }

    return @times;
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
