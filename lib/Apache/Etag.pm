package Apache::ETag;

use strict;
use warnings;

use Apache::File;
use Apache::Constants qw(:common :http);
use Digest::MD5;

sub handler {
    my $r = shift;

    my $fh = Apache::File->new($r->filename);
    return SERVER_ERROR unless $fh;

    my $md5 = Digest::MD5->new;
    $md5->addfile($fh);

    my $current_etag = '"' . $md5->b64digest . '"';
    $r->header_out("ETag", $current_etag);

    my $proposed_etag = $r->header_in("If-None-Match");

    if ($proposed_etag and ($current_etag eq $proposed_etag)) {
        return HTTP_NOT_MODIFIED;
    } else {
        $r->send_http_header;
        $r->send_fd($fh);
        return OK;
    }
}
