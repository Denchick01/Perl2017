use utf8;
package Local::Schema::Result::Note;

use strict;
use warnings;

use base 'DBIx::Class::Core';


__PACKAGE__->table("notes");


__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", default_value => 0, is_nullable => 0 },
  "creator_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "note_text",
  { data_type => "text", is_nullable => 0 },
  "create_time",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);


__PACKAGE__->set_primary_key("id");


__PACKAGE__->belongs_to(
  "creator",
  "Local::Schema::Result::User",
  { id => "creator_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

__PACKAGE__->has_many(
  "note_files",
  "Local::Schema::Result::NoteFile",
  { "foreign.note_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


__PACKAGE__->has_many(
  "user_links_to_notes",
  "Local::Schema::Result::UserLinksToNote",
  { "foreign.note_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

1;
