#!/usr/bin/perl -w

# This is a basic IRC Bot for running a channel. 

use strict;
use Net::IRC;

my $happy = new Net::IRC;
my $channel = "#testchan";
my %ops;

print "Connecting...\n";

my $connection = $happy->newconn(Server   => ($ARGV[0]  ||  'irc.efnet.org'),
			 Port     => 6667,
			 Nick     => 'happy',
			 Ircname  => 'happy',
			 Username => 'happy')
    or die "Can't connect to server.\n";

my $named_response = "Happiness is mandatory. Do not make me enforce it!";

sub connected {
	my $self = shift;
	
	print "Joining $channel...\n";
	$self->join($channel);
}

sub initalize {
    my ($self, $event) = @_;
    my (@args) = ($event->args);
    shift (@args);
    
    print "*** @args\n";
}

sub new_user {
    my ($self, $event) = @_;
    my ($channel) = ($event->to)[0];
    my $op_flag = checkOps($event->nick);
    
    printf "*** %s (%s) has joined channel %s\n",
    $event->nick, $event->userhost, $channel;
    $self->mode($channel, "+v", $event->nick);  

    if ($op_flag == 2) {
        $self->mode($channel, "+o", $event->nick);      
    } elsif ($op_flag == 1) {
        $self->mode($channel, "+h", $event->nick);      
    }


}

sub privateMessage {
    my ($self, $event) = @_;
    my ($nick) = $event->nick;
    my $command = ($event->args())[0];
    my $op_flag = checkOps($nick);
    print "*$nick*  ", $command, "\n";


    if ( $command =~ m/add hop/gi ) {
        if ($op_flag == 2) {
            $command =~ s/add hop//gi; 
            $command =~ s/\s+?//gi;
            $command =~ s/\n+?//gi;

            $ops{lc($command)} = 1;
            saveOps();
            $self->privmsg($nick, "hop added");
        }
    } elsif ( $command =~ m/add op/gi ) {
        if ($op_flag == 2) {
            $command =~ s/add op//gi; 
            $command =~ s/\s+?//gi;
            $command =~ s/\n+?//gi;

            $ops{lc($command)} = 2;
            saveOps();
            $self->privmsg($nick, "Op added");
        }
    } elsif ( $command =~ m/list op/gi ) {
        if ($op_flag == 1 || $op_flag == 2) {
            $self->privmsg($nick, "Listing Ops");
            foreach my $k (keys %ops) {
                if ($ops{$k} == 2) {
                    $self->privmsg($nick, "op: $k");
                } else {
                    $self->privmsg($nick, "hop: $k");
                }
            }
        }
    } elsif ( $command =~ m/hop/gi ) {
        if ($op_flag == 1) {
            $self->mode($channel, "+h", $event->nick); 
            $self->privmsg($nick, "Half-Op Initiated!");   
        }
    } elsif ( $command =~ m/op/gi ) {
        if ($op_flag == 2) {
            $self->mode($channel, "+o", $event->nick);   
            $self->privmsg($nick, "Op-Initiated!");   
        }
    } else { 
        $self->privmsg($nick, "I am happy, are you happy?");   
    }
}

sub publicMessage {
    my ($self, $event) = @_;
    my @to = $event->to;
    my ($nick, $mynick) = ($event->nick, $self->nick);
    my ($arg) = ($event->args())[0];
    
    print "<$nick> $arg\n";
    if ($arg =~ /$mynick/i) {                   
	   $self->privmsg($channel, &dispCannedResp()); 
    }
}


sub stolenNick {
    my ($self) = shift;

    $self->nick("AngryBot");
    $self->privmsg(['happy'], "Please vacate the name - happy - so that I may resume my duties. When the name is vacated please send a private message to me with the word reconnect in it."); 
}

sub dced {
	my ($self, $event) = @_;

	print "Disconnected from ", $event->from(), " (",
	      ($event->args())[0], "). Attempting to reconnect...\n";
	$self->connect();
}

sub dispCannedResp { 
    return $named_response;
}

sub loadOps {
    open(FH, "<ops.txt");
        while (my $l = <FH>) { 
            $l =~ s/\s+?//gi; 
            $l =~ s/\n+?//gi; 
            $ops{$l} = 2;
            print "Op: $l\n";
        }
    close(FH);
    open(FH, "<hops.txt");
        while (my $l = <FH>) { 
            $l =~ s/\s+?//gi; 
            $l =~ s/\n+?//gi; 
            $ops{$l} = 1;
            print "hop: $l\n";
        }
    close(FH);
}

sub saveOps {
    open(FH, ">ops.txt");
    open(FH2, ">hops.txt");
        foreach my $k (keys %ops) {
            if ($ops{$k} == 2) {
                print FH "$k\n";
            } else {
                print FH2 "$k\n";
            }
        }
    close(FH);
    close(FH2);
}

sub checkOps {
    my $name = lc(shift);
    $name =~ s/\s+?\n+?//gi;
    print "Checking Perms: $name\n";

    if (exists $ops{$name}) {
        return $ops{$name};
    }
}
print "Someone set us up the handlers...\n";

$connection->add_handler('msg',    \&privateMessage);
$connection->add_handler('public', \&publicMessage);
$connection->add_handler('join',   \&new_user);

$connection->add_global_handler([ 251,252,253,254,302,255 ], \&initalize);
$connection->add_global_handler('disconnect', \&dced);
$connection->add_global_handler(376, \&connected);
$connection->add_global_handler(433, \&stolenNick);

loadOps();
print "Prepare to die...\n";
$happy->start;
