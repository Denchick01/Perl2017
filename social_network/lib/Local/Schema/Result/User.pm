use utf8;
package Local::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("user");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 108 },
  "second_name",
  { data_type => "varchar", is_nullable => 1, size => 108 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
  user_relation_users => "Local::Schema::Result::UserRelation",
  { "foreign.friend_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->many_to_many(
  whose_friend => 'user_relation_users', 
  'user'
);


__PACKAGE__->has_many(
  user_relation_friends => "Local::Schema::Result::UserRelation",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->many_to_many(
  user_friends => 'user_relation_friends', 
 'friend'
);


sub obj_to_hash {
    my $obj = shift @_;
    my %res;
    
    $res{$obj->id} = {first_name => $obj->first_name,
                          second_name => $obj->second_name};

    return \%res;
}


#select * from user where user.id in ((select ff.all_f  from (select friend_id as all_f from user_relation where user_id = 1 or user_id = 5 union all select user_id as all_f from user_relation where friend_id = 1 or friend_id = 5) as ff group by all_f having count(all_f) > 1))
sub search_mutual_friends {
    my ($self, $user2_id, $rs_s) = @_;
    my %mutual_friends = ();
    my $rs;
    my $user1_id = $self->id;

    if ($user1_id == $user2_id) {
        $rs = $rs_s->search_friends_for_users($user1_id);
    }
    else {
        $rs = $rs_s->search_friends_for_users($user1_id, $user2_id)->search({}, {group_by => ['friend.id'], having => \'count(friend.id) > 1'});

    }

    return $rs->all_to_hash();
}


    
1;
