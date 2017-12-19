use utf8;
package Local::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';


__PACKAGE__->table("users");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "login",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 15 },
  "password",
  { data_type => "char", default_value => "", is_nullable => 0, size => 32 },
  "user_name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 15 },
  "salt",
  { data_type => "char", default_value => "", is_nullable => 0, size => 12 },
);

__PACKAGE__->set_primary_key("id");


__PACKAGE__->add_unique_constraint("users_idx_login", ["login"]);


__PACKAGE__->has_many(
  "notes",
  "Local::Schema::Result::Note",
  { "foreign.creator_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);



__PACKAGE__->has_many(
  "user_links_to_notes",
  "Local::Schema::Result::UserLinksToNote",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->many_to_many(
   all_user_notes => "user_links_to_notes",
   "note"
);

1;
