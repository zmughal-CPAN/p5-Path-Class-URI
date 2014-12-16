# NAME

Path::Class::URI - Serializes and deserializes Path::Class objects as file:// URI

# SYNOPSIS

    use Path::Class;
    use Path::Class::URI;

    my $file = file('bob', 'john.txt');
    my $uri  = $file->uri; # file:bob/john.txt

    file('', 'tmp', 'bar.txt')->uri; # file:///tmp/bar.txt

    my $file = file_from_uri("file:///tmp/bar.txt"); # or URI::file object
    $fh = $file->open;

# DESCRIPTION

Path::Class::URI is an extension to Path::Class to serialize file path
from and to _file://_ form URI objects.

This module encodes and decodes non URI-safe characters using its
literal byte encodings. If you call _uri_ methods on Win32 Path::File
objects, you'll get local filename encodings.

If you want to avoid that and always use UTF-8 filename encodings in
URI, see [Path::Class::Unicode](https://metacpan.org/pod/Path::Class::Unicode) bundled in this distribution.

# METHODS

- uri (Path::Class::Entity)

        $uri = $file->uri;
        $uri = $dir->uri;

    returns URI object representing Path::Class file and directory.

- from\_uri (Path::Class::Entity)

        $file = Path::Class::File->from_uri($uri);
        $dir  = Path::Class::Dir->from_uri($uri);

    Deserializes URI object (or string) into Path::Class objects.

- file\_from\_uri, dir\_from\_uri

    Shortcuts for those _from\_uri_ methods. Exported by default.

# AUTHOR

Tatsuhiko Miyagawa <miyagawa@cpan.org>

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[Path::Class](https://metacpan.org/pod/Path::Class), [URI::file](https://metacpan.org/pod/URI::file)
