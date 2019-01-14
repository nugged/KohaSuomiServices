package KohaSuomiServices::Model::Compare;
use Mojo::Base -base;

use Modern::Perl;
use utf8;

use Try::Tiny;
use JSON::Patch qw(diff patch);

sub getMandatory {
    my ($self, $source, $target) = @_;

    
    my ($numberpatch, $charpatch) = $self->findMandatory($target);
    my $sorted;
    if ($numberpatch || $charpatch) {

        foreach my $nfield (@{$numberpatch}) {
            my $valid;
            foreach my $f (@{$source->{fields}}) {
                if ($f ne $nfield) {
                    $valid = $nfield;
                }
            }
            push @{$source->{fields}}, $valid;
        }

        my $fields = $self->sortFields($source->{fields});
        $source->{fields} = $fields;

        foreach my $cfield (@{$charpatch}) {
            push @{$source->{fields}}, $cfield;
        }
    }
}

sub findMandatory {
    my ($self, $target) = @_;

    my %mandatory = ("CAT" => 1, "035" => "a");

    my ($numberpatch, $charpatch);

    foreach my $field (@{$target->{fields}}) {
        my $tag = $field->{tag};
        if ($mandatory{$field->{tag}} && $field->{tag} =~ s/^[0-9]//g) {
            $field->{tag} = $tag;
            push @{$numberpatch}, $field;
        }

        if ($mandatory{$field->{tag}} && $field->{tag} =~ s/^[A-Za-z]//g) {
            $field->{tag} = $tag;
            push @{$charpatch}, $field;
        }
    }

    return ($numberpatch, $charpatch);
}

sub sortFields {
    my ($self, $fields) = @_;

    my $hash;
    my $count = 1;

    foreach my $field (@{$fields}) {
        $hash->{$count} = $field;
        $count++;
    }

    my $sorted; 

    foreach my $key (sort {$hash->{$a}->{'tag'} <=> $hash->{$b}->{'tag'}} keys %$hash) {
        push @{$sorted}, $hash->{$key};
    }

    return $sorted;
}

1;