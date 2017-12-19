use utf8;
package Local::Schema::Result::NoteFile;


use strict;
use warnings;

use base 'DBIx::Class::Core';


__PACKAGE__->table("note_files");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "note_id",
  {
    data_type      => "bigint",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "file_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 108 },
  "file_path",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "file_type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 108 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->belongs_to(
  "note",
  "Local::Schema::Result::Note",
  { id => "note_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

1;
