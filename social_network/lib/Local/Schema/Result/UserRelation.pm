use utf8;
package Local::Schema::Result::UserRelation;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("user_relation");

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "friend_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);


__PACKAGE__->set_primary_key("user_id", "friend_id");


__PACKAGE__->belongs_to(
  friend => "Local::Schema::Result::User",
  { id => "friend_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

__PACKAGE__->belongs_to(
  user => "Local::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

1;
