package UR::Value::Boolean;
use strict;
use warnings;

require UR;
our $VERSION = "0.39"; # UR $VERSION;

UR::Object::Type->define(
    class_name => 'UR::Value::Boolean',
    is => ['UR::Value::Text'],
);

1;
