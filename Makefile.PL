use inc::Module::Install;
name 'Path-Class-URI';
all_from 'lib/Path/Class/URI.pm';

requires 'Path::Class';
requires 'URI';
requires 'Exporter::Lite';
requires 'Scalar::Util';

build_requires 'Test::More';
use_test_base;
auto_include_deps;
author_tests('xt');
WriteAll;
