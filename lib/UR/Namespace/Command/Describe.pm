package UR::Namespace::Command::Describe;
use strict;
use warnings;
use UR;

UR::Object::Type->define(
    class_name => __PACKAGE__,
    #is => 'UR::Namespace::Command::RunsOnModulesInTree',
    is => 'Command',
    has => [
        type => {
            is_optional => 0,
            shell_args_position => 99,
            doc => 'the name of the class to describe'
        },
    ],
    doc => 'show class properties, relationships, meta-data',
);

sub sub_command_sort_position { 3 }

sub help_synopsis {
    return <<EOS
ur describe UR::Object

ur describe Acme::Order Acme::Product Acme::Order::LineItem

EOS
}

# The class metadata has lots of properties that we're not interested in
our @CLASS_PROPERTIES_NOT_TO_PRINT = qw(
    generated
    short_name
    is
    all_class_metas
);
    
sub execute {
    my $self = shift;
    my $class_name = $self->type;
   
    eval "require $class_name";
    my $class_meta = UR::Object::Type->get($class_name);
    unless ($class_meta) {
        $self->error_message("No class found for $class_name!  Check the spelling, and if this is a new class be sure you are inside its source tree...");
        return;
    }

    my $view = UR::Object::Type->create_view(
                    perspective => 'default',
                    toolkit => 'text',
                    aspects => [
                        'namespace', 'table_name', 'data_source_id', 'is_abstract', 'is_final',
                        'is_singleton', 'is_transactional', 'schema_name', 'meta_class_name',
                        'first_sub_classification_method_name', 'sub_classification_method_name',
                        {
                            label => 'Properties',
                            name => 'properties',
                            subject_class_name => 'UR::Object::Property',
                            perspective => 'description line item',
                            toolkit => 'text',
                            aspects => ['is_id', 'property_name', 'column_name', 'data_type', 'is_optional' ],
                        },
                        {
                            label => "References",
                            name => 'all_id_by_property_metas',
                            subject_class_name => 'UR::Object::Property',
                            perspective => 'reference description',
                            toolkit => 'text',
                            aspects => [],
                        },
                        {
                            label => "Referents",
                            name => 'all_reverse_as_property_metas',
                            subject_class_name => 'UR::Object::Property',
                            perspective => 'reference description',
                            toolkit => 'text',
                            aspects => [],
                        },
                    ],
                );
    unless ($view) {
        $self->error_message("Can't initialize view");
        return;
    }

    $view->subject($class_meta);
    $view->show();
}

1;
