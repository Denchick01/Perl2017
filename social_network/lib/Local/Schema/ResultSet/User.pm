use utf8;
package Local::Schema::ResultSet::User;

use strict;
use warnings;
use 5.10.0;

use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw{Helper::ResultSet::SetOperations});

sub search_nofriends {
    my ($self) = @_;

    my $rs = $self->search({ 'user_relation_users.user_id' => undef, 'user_relation_users.friend_id' => undef},{
        join => ['user_relation_users', 'user_relation_friends']
    });

    return $rs;
}

sub search_friends_for_users {
    my ($self, @users) = @_;
   
    my @prep_req = map { ("me.id" => $_) } @users;

    my $rs_u = $self->search({'me.id' => {-in => \@users}});

    my %find_friends;

    my $rs_f1 = $rs_u->search_related('user_relation_friends');
    $rs_f1 = $rs_f1->search_related('friend');


    my  $rs_f2 = $rs_u->search_related('user_relation_users');
    $rs_f2 = $rs_f2->search_related('user');

    return $rs_f1->union_all($rs_f2);
}


sub all_to_hash {
    my $rs_objs = shift @_;
    my @res;

    for my $obj ($rs_objs->all()) {
        push @res, %{$obj->obj_to_hash()};
    }

    return {@res};
}



sub search_num_handshakes {
    my ($self, $user1_id, $user2_id) = @_;
    my $current_layer = 0;

    if ($user1_id == $user2_id) {
        return $current_layer;
    }

    my %pp_queue;
    my %np_queue1; 
    my %np_queue2;


    %np_queue1 = map {$_ => 1} keys %{$self->search_friends_for_users($user1_id)->all_to_hash()};
    %np_queue2 = ($user2_id => 1);


    $current_layer = 1;
    while (keys %np_queue1 > 0 && keys %np_queue2 > 0) {
        for my $friend (keys %np_queue2) {
            if (exists $np_queue1{$friend}) {
                return $current_layer;
            }
        }
       
        ++$current_layer;

        if (not $current_layer % 2) {
            %pp_queue = (%pp_queue, %np_queue1);
            %np_queue1 = map {$_ => 1} 
                             grep {not exists $pp_queue{$_}} 
                                 keys %{$self->search_friends_for_users(keys %np_queue1)->all_to_hash()};

        }
        else {
            %pp_queue = (%pp_queue, %np_queue2);
            %np_queue2 = map {$_ => 1} 
                             grep {not exists $pp_queue{$_}} 
                                 keys %{$self->search_friends_for_users(keys %np_queue2)->all_to_hash()};
        }

    }
 
    return $current_layer;
}

1;
