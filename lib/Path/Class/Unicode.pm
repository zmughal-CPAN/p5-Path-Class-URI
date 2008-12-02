package Path::Class::Unicode;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use Exporter::Lite;
our @EXPORT = qw( ufile udir ufile_from_uri udir_from_uri );

use Encode ();
use Path::Class;
use URI::file;
use Scalar::Util qw(blessed);

sub ufile {
    __PACKAGE__->new(file(@_));
}

sub udir {
    __PACKAGE__->new(dir(@_));
}

sub Path::Class::File::ufile {
    my $file = shift;
    ufile(_decode_filename($file), @_);
}

sub Path::Class::Dir::udir {
    my $dir = shift;
    udir(_decode_filename($dir), @_);
}

sub ufile_from_uri {
    my $uri = shift;
    if ($^O eq "MSWin32") {
        $uri =~ s!^file:///!file://!g; # remove leading slash for absolute
        $uri = URI->new($uri) unless blessed $uri;
        ufile(Encode::decode_utf8($uri->file('win32')));
    } else {
        $uri = URI->new($uri) unless blessed $uri;
        ufile(Encode::decode_utf8($uri->file('unix')));
    }
}

sub udir_from_uri {
    my $uri = shift;
    if ($^O eq "MSWin32") {
        $uri =~ s!^file:///!file://!g; # remove leading slash for absolute
        $uri = URI->new($uri) unless blessed $uri;
        udir(Encode::decode_utf8($uri->file('win32')));
    } else {
        $uri = URI->new($uri) unless blessed $uri;
        udir(Encode::decode_utf8($uri->file('unix')));
    }
}

sub new {
    my($class, $path) = @_;
    bless { path => $path }, $class;
}

sub uri {
    my $self = shift;
    my $path = Encode::encode_utf8($self->{path}->stringify);
    if ($^O eq "MSWin32") {
        $path =~ tr!\\!/!; # can't use backslash as separator
        $path = "/$path" if $self->is_absolute; # make "file:///x:/foo/bar/"
    }
    if ($self->is_absolute) {
        return URI->new("file://$path");
    } else {
        return URI->new("file:$path");
    }
}

our $encoding;

sub init_encoding {
    unless ($encoding) {
        $encoding = 'utf-8';
        if ($^O eq 'MSWin32') {
            eval {
                require Win32::API;
                Win32::API->Import('kernel32', 'UINT GetACP()');
                $encoding = 'cp'.GetACP();
            };
        }
    }
}

sub stringify {
    my $self = shift;
    init_encoding();
    Encode::encode($encoding, $self->{path}->stringify);
}

sub _decode_filename {
    init_encoding();
    my $filename = shift;
    Encode::decode($encoding, "$filename");
}

sub open {
    my $self = shift;
    my $class = $self->is_dir ? "IO::Dir" : "IO::File";
    $class->new($self->stringify, @_);
}

sub next {
    my $self = shift;
    $self->{path}->{dh} = $self->open unless $self->{path}->{dh};
    my $file = $self->{path}->next;
    $file = Encode::encode($encoding, $file) if $file;
    $file;
}

use overload (
    q[""] => 'stringify',
    fallback => 1,
);

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    (my $method = $AUTOLOAD) =~ s/.*:://;
    $self->{path}->$method(@_);
}

sub DESTROY { }

1;
__END__

=encoding utf-8

=for stopwords TODO UTF-8 filenames cp932 mattn

=head1 NAME

Path::Class::Unicode - Maps Unicode filenames to local encoding and code pages

=head1 SYNOPSIS

  use Path::Class::Unicode;

  # Use ufile() to create Unicode objects
  my $fn   = "\x{55ed}.txt";
  my $file = ufile("path", $fn);

  my $fh = $file->open;

  my $fn   = "\x{55ed}.txt";
  my $file = ufile("/path", $fn);
  my $uri  = $file->uri;  # file:///path/%E5%97%AD.txt (always utf-8)

  my $fh   = ufile_from_uri($uri)->open;

=head1 DESCRIPTION

Path::Class::Unicode is a Path::Class extension to handle Unicode
file names by mapping them to local encodings when stringified. It maps
to UTF-8 for all UNIX systems including Mac OS X and uses Windows code
page (like cp932 for Japanese) in Win32 systems.

It's very useful if you store file paths using URI representation like
L<file://> and uses URI escaped UTF-8 characters for non-ASCII
characters. See L<Path::Class::URI> for details.

=head1 TODO

It would be nice if we could proxy filehandles using Win32API::File.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@cpan.orgE<gt>

mattn

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
