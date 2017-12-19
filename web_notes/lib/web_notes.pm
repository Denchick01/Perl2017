package web_notes;
use utf8;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Core::Request::Upload;
use Crypt::RandPasswd;
use Digest::MD5 qw(md5_hex);
use Crypt::PasswdMD5 qw(random_md5_salt);
use Digest::CRC qw(crc64);
use HTML::Entities;
use YAML::Tiny;

my $SALT = config->{sys_salt};
my $salt_length = config->{salt_length };
my $upload_dir = config->{upload_dir};
my $max_text_size = config->{max_text_size}; 

our $VERSION = '0.1';

get '/create_account' => sub { 
    template 'create_account' => { 'title' => 'web_notes' }, { layout => undef };
};

post '/create_account' => sub {
    my $username       = params->{"username"};
    my $login          = params->{"login"};
    my $new_password_1 = params->{"new_password_1"};
    my $new_password_2 = params->{"new_password_2"};

    $username =~ s/\s+//go;
    $login =~ s/\s+//go;
    $new_password_1 =~ s/\s+//go;
    $new_password_2 =~ s/\s+//go;

    my $rs = schema('default')->resultset('User');

    if (not ($username  and $login and $new_password_1 and $new_password_2)) {
        response->status(400);
        return template 'create_account' => { 'title' => 'web_notes', 'err' => ['Fill in all the fields']}, { layout => undef };
    }

    my $login_res = $rs->search({login => $login})->count();

    if ($login_res > 0) {
        response->status(400);
        return template 'create_account' => { 'title' => 'web_notes', 'err' => ['login is busy']}, { layout => undef };
    } 
  
    if ($new_password_1 ne $new_password_2) {
        response->status(400);
        return template 'create_account' => { 'title' => 'web_notes', 'err' => ['Passwords do not match']}, { layout => undef };
    }

    my $salt = random_md5_salt($salt_length);

    my $hash = md5_hex("$salt$new_password_1$SALT");

    $rs->create({login => $login, password => $hash, 
             user_name => $username, salt => $salt});

    redirect '/login';
};

hook before => sub { 
    if (!session('user_login') && request->dispatch_path !~ /^\/(login|create_account)/o) {
        redirect "/login?requested_path=".request->dispatch_path;
    }
};


get '/login' => sub {
     template 'login' => { 'title' => 'web_notes'}, { layout => undef };    
};


post '/login' => sub {

    my @err;

    my $login = params->{"login"};
    my $password = params->{"password"};

    $login =~ s/\s+//go;
    $password =~ s/\s+//go;
 
    my $rs = schema('default')->resultset('User');

    my $user = $rs->search({login => $login})->single();

    if (not defined $user) {
        push @err, "Invalid login";
    }
    else {
           
        my $salt = $user->salt;
        if (md5_hex("$salt$password$SALT") eq $user->password &&
            $login eq $user->login) {
            session user_login => $login;
            session user_id => $user->id;
            return redirect params->{"requested_path"} // '/';
        } 
        else { 
            push @err, "Invalid password";
        }
    }

    template 'login' => { 'title' => 'web_notes', err => \@err }, { layout => undef };    
};

get '/logout' => sub {
    app->destroy_session;
    redirect '/';    
};

get '/' => sub {
    #Формирую токен 
    my $new_token = md5_hex($SALT . time());    
    #Токен в куку
    session csrf_token => $new_token ;

    template 'index' => { 'title' => 'web_notes', csrf_token => $new_token };
};

post '/' => sub {
    my $title = params->{'title'};
    my $text  = params->{'text'};
    my $users = params->{'users'};
    my $csrf_token = params->{'csrf'};
    my $csrf_c_token = session('csrf_token');
    my @err;

    #Проверяем токен на валидность
    if ($csrf_token ne $csrf_c_token) {
        redirect '/';
    }

    my $user_id    = session('user_id');
    my $user_login = session('user_login');   

    if (!$title) {
        push @err, "Enter the title";
        return  template 'index' => { 'title' => 'web_notes', err=> \@err, user_text => $text, user_title => $title, user_users => $users };
    }


    if (length $text > $max_text_size) { 
        push @err, "Character limit exceeded for text!";
        return  template 'index' => { 'title' => 'web_notes', err=> \@err, user_text => $text, user_title => $title, user_users => $users };
    }   

    my %valid_users;
    my %invalid_users;

    my $rs = schema('default')->resultset('User');

    for my $add_user (split m/\s*[,;\s]\s*/o, $users)  {
        my $add_user_res = $rs->search({login => $add_user})->single();
        if ($add_user_res) {
            $valid_users{$add_user_res->id}++ if ($add_user ne $user_login);
            next;
        }
        $invalid_users{encode_entities($add_user, '<>&"')}++;
    }

    if (keys %invalid_users) {
        my $err_msg = "Invalide user". (keys %invalid_users > 1 ? "s" : "") . ": ";
        for (keys %invalid_users) {
            $err_msg .= "$_ ";
        }
        push @err, $err_msg;

        return  template 'index' => { 'title' => 'web_notes', err=> \@err, user_text => $text, user_title => $title, user_users => $users };
    }


    $rs = schema('default')->resultset('Note');  
 
    my $note_id = '';
    my $try_count = 10; 

    while (!$note_id) {
        unless(--$try_count) {
            $note_id = undef;
             last;
        }
      
        $note_id = crc64($text.$user_id.$user_login.$note_id.time());
        eval {
            $rs->create({id => \['CAST(? as signed)', $note_id], creator_id => $user_id, 'note_text' => $text,
                 create_time => \'NOW()', title => $title});
        } or do {
            $note_id = undef;
        }
    }
    unless ($note_id) {
         push @err, "Try latter";
         return  template 'index' => { 'title' => 'web_notes', err => \@err, user_text => $text, user_title => $title, user_users => $users };
    }

    $valid_users{$user_id}++;
    $rs = schema('default')->resultset('UserLinksToNote');    
   
    for my $add_user_id (keys %valid_users) {
        $rs->create({user_id => $add_user_id, note_id => \['CAST(? as signed)', $note_id]});
    }

    my $upload_file =  upload('note_files');

    if ($upload_file) {
        my $note_dir = get_upload_dir() . $note_id;

        if (-d $note_dir) {
            rmdir $note_dir;
        }
    
        mkdir $note_dir or  die "Can't create new dir: '$note_dir' for uploading file $!";

        my $file_name = $upload_file->filename;
 
        $file_name =~ s/^.*(\\|\/)//;

        $upload_file->copy_to("$note_dir/$file_name") or die "Can't save file: $file_name: $!";
    
        $rs = schema('default')->resultset('NoteFile');

        $rs->create({note_id => \['CAST(? as signed)', $note_id], 
                     file_name => $file_name, 
                     file_type => $upload_file->type, 
                     file_path => "$note_dir/$file_name"});
    }

    redirect '/note/'. id_from_num_to_hex($note_id);
};


get '/notes' => sub {
    my $check       = params->{"check"} // '';
    my $user_id     = session('user_id');
    my $max_notes_on_page = 10;

    my @notes;
  
    my $rs = schema('default')->resultset('User');

    $rs = $rs->search({'me.id' => $user_id});
    my $whose;

    if ($check eq "my") {
        $whose = 'My notes';
        $rs = $rs->search_related('notes');
        $rs = $rs->search({}, {order_by => {-desc => 'create_time'}, rows => $max_notes_on_page});

        for my $user_note ($rs->all()) {
            push @notes, { id => id_from_num_to_hex($user_note->id), 
                           title => encode_entities($user_note->title, '<>&"'), 
                           creator => encode_entities($user_note->creator->login, '<>&"'), 
                           create_time => $user_note->create_time};
        }
   }
    else {
        $whose = 'All notes';
        $rs = $rs->search_related('user_links_to_notes');
        $rs = $rs->search_related('note');
        $rs = $rs->search({}, {order_by => {-desc => 'create_time'}, rows => $max_notes_on_page});

        for my $user_note ($rs->all()) {
            push @notes, { id => id_from_num_to_hex($user_note->id), 
                           title => encode_entities($user_note->title,  '<>&"'), 
                           creator => encode_entities($user_note->creator->login, '<>&"'), 
                           create_time => $user_note->create_time};
        }
 
    }

    template 'notes' => { 'title' => 'web_notes', whose => $whose, 'notes' => \@notes };
};


get qr{\/note\/([a-f0-9]{16})} => sub {
    my ($id) = splat;

    $id = id_from_hex_to_num($id);

    
    my $rs = schema('default')->resultset('Note');

    my $note = $rs->search(\['id = CAST(? as signed)', $id])->single();

    unless ($note) {
        send_error("Page not found", 404);
    }    

    my $title = encode_entities($note->title, '<>&"');
    my @text  = split "\n", $note->note_text;

    
    for (@text) {
        $_ = encode_entities($_, '<>&"');
        s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
        s/^\s/&nbsp;/g;
    }

    my @note_files;

    for my $nfile ($note->note_files) {        
        push @note_files, {file_name => encode_entities($nfile->file_name, '<>&"'), file_id => $nfile->id};
    }



    template 'noteout' => { 'title' => 'web_notes', note_title => $title, 
                             'note_create_time' => $note->create_time, 
                             'note_creator_login' => encode_entities($note->creator->login, '<>&"'),
                              note_text => \@text,
                             'note_creator_name' => encode_entities($note->creator->user_name, '<>&"'),
                             'note_files' => \@note_files};
};

get qr{\/download\/(\d+)} => sub {
    my ($file_id) = splat;
    
    my $file = schema('default')->resultset('NoteFile')->find($file_id);
    
    unless ($file) {
        send_error("File not found", 404);
    }

    send_file($file->file_path, system_path => 1, content_type => $file->file_type, 
                                filename  => encode_entities($file->file_name, '<>&"'));
   
};


sub get_upload_dir {
    return config->{appdir}.'/'.$upload_dir.'/';
}

sub id_from_num_to_hex {
    my $id = shift;
    return unpack 'H*', pack 'Q', $id;
}

sub id_from_hex_to_num {
    my $id = shift;
    return unpack 'Q', pack 'H*', $id;
}
true;
