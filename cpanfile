requires 'Exporter::Lite';
requires 'ExtUtils::MakeMaker', '7.04';
requires 'Path::Class';
requires 'Scalar::Util';
requires 'Test::More';
requires 'URI';

on build => sub {
    requires 'ExtUtils::MakeMaker';
};
