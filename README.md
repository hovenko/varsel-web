# Varsel

Varsel is a service that sends out notification emails for forecasts when they
become available. This happens approximately 10 days before the actual day.


## Starting the server in debug mode

Run script/varsel\_server.pl -d to test the application.


## Dependencies

Look in doc/Avhengigheter.txt for a list of dependencies. This is in no way
complete (document is in Norwegian).


## UTF-8 in emails

We run utf8::decode on the body (return from Template Toolkit) in the classes:
    Varsel::Model::Profile::Email
    Varsel::Model::Forecast::Email

It depends -very- on the installed packages and locale of which this service
runs on.

utf8::decode on "subject", "to" and "from" email headers should still be done.

