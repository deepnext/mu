# Do not edit this file - Generated by MiniPerl6
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
use MiniPerl6::Perl5::Match;
package KindaPerl6::Visitor::MetaClass; sub new { shift; bless { @_ }, "KindaPerl6::Visitor::MetaClass" } sub visit { my $self = shift; my $List__ = \@_; my $node; my $node_name; do {  $node = $List__->[0];  $node_name = $List__->[1]; [$node, $node_name] }; do { if (($node_name eq 'CompUnit')) { my  $module = [];push(@{$module}, Call->new( 'hyper' => '','arguments' => [Val::Buf->new( 'buf' => $node->name(), )],'method' => 'create','invocant' => Val::Buf->new( 'buf' => 'Class::MOP::Class', ), ));do { for my $item ( @{$node->body()->body()} ) { do { if (Main::isa($item, 'Method')) { push(@{$module}, Call->new( 'hyper' => '','arguments' => [Val::Buf->new( 'buf' => $item->name(), ), Sub->new( 'name' => '','sig' => $item->sig(),'block' => $item->block(), )],'method' => 'add_method','invocant' => Call->new( 'hyper' => '','arguments' => [],'method' => 'HOW','invocant' => Val::Buf->new( 'buf' => $node->name(), ), ), )) } else {  } };do { if ((Main::isa($item, 'Decl') && ($item->decl() eq 'has'))) { push(@{$module}, Call->new( 'hyper' => '','arguments' => [Call->new( 'hyper' => '','arguments' => [Val::Buf->new( 'buf' => $item->var()->name(), )],'method' => 'new','invocant' => Val::Buf->new( 'buf' => 'Class::MOP:::Attribute', ), )],'method' => 'add_attribute','invocant' => Call->new( 'hyper' => '','arguments' => [],'method' => 'HOW','invocant' => Val::Buf->new( 'buf' => $node->name(), ), ), )) } else {  } } } };do { for my $item ( @{$node->body()->body()} ) { do { if ((Main::isa($item, 'Method') || (Main::isa($item, 'Decl') && ($item->decl() eq 'has')))) {  } else { push(@{$module}, $item) } } } };return(Module->new( 'name' => $node->name(),'body' => Lit::Code->new( 'pad' => {  },'state' => {  },'sig' => Sig->new( 'invocant' => (undef),'positional' => [],'named' => {  }, ),'body' => $module, ), )) } else {  } }; return((undef)) }
;
1;
