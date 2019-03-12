package KohaSuomiServices::Model::Biblio::Exporter;
use Mojo::Base -base;

use Modern::Perl;
use utf8;

use Try::Tiny;
use Mojo::UserAgent;
use KohaSuomiServices::Model::Convert;
use Mojo::JSON qw(decode_json encode_json);
use KohaSuomiServices::Model::Biblio::Subfields;
use KohaSuomiServices::Model::Config;
use KohaSuomiServices::Database::Client;

has schema => sub {KohaSuomiServices::Database::Client->new};
has config => sub {KohaSuomiServices::Model::Config->new->service("biblio")->load};


sub find {
    my ($self, $client, $params, $conditions) = @_;
    return $client->resultset('Exporter')->search($params, $conditions);
}

sub insert {
    my ($self, $client, $params) = @_;
    return $client->resultset('Exporter')->new($params)->insert();
}

sub update {
    my ($self, $id, $params) = @_;
    my $client = $self->schema->client($self->config);
    return $client->resultset('Exporter')->find($id)->update($params);
}

sub getExports {
    my ($self, $type, $components) = @_;

    my $params = {type => $type, status => "pending", parent_id => undef};
    $params = {type => $type, status => "pending", parent_id => {'!=', undef}} if defined $components && $components;
    my $order = defined $components && $components ? {order_by => { -asc => [qw/parent_id source_id/] }} : undef;
    my $schema = $self->schema->client($self->config);
    my @data = $self->find($schema, $params, $order);
    return $self->schema->get_columns(@data);

}

sub setExporterParams {
    my ($self, $interface, $type, $status, $source_id, $target_id, $authuser, $parent_id, $force, $componentparts, $fetch_interface) = @_;

    my $exporter->{status} = $status;
    $exporter->{type} = $type;
    $exporter->{source_id} = $source_id;
    $exporter->{target_id} = $target_id if (defined $target_id);
    $exporter->{interface_id} = $interface->{id};
    $exporter->{authuser_id} = $authuser;
    $exporter->{parent_id} = $parent_id;
    $force = 0 unless (defined $force && $force);
    $exporter->{force_tag} = $force;
    $exporter->{componentparts} = defined $componentparts && $componentparts ? $componentparts : 0;
    $exporter->{fetch_interface} = $fetch_interface;

    return $exporter;
}

1;