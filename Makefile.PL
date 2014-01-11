use inc::Module::Install;

name 'Varsel';
all_from 'lib/Varsel.pm';

requires 'Catalyst::Runtime' => '5.7014';
requires 'Catalyst::Model::DBIC::Schema';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Cache::FastMmap';
requires 'Catalyst::Plugin::Scheduler';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::PageCache';
requires 'Catalyst::View::Email';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::View::Email';
requires 'Catalyst::View::TT';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'Class::Accessor::Fast';
requires 'Data::Validate::Email';
requires 'DateTime';
requires 'Email::MIME::Creator';
requires 'HTML::ScriptLoader';
requires 'NetAddr::IP';
requires 'Params::Validate';
requires 'Weather::YR';
requires 'XML::RSS';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
