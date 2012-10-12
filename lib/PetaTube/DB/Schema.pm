package PetaTube::DB::Schema;
use strict;
use warnings;
use utf8;

use Teng::Schema::Declare;

table {
    name 'peta';
    pk 'id';
    columns qw/id digest url title view_count video_count created_at updated_at/;
};
