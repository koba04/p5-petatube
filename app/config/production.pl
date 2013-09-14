use File::Spec;
use File::Basename qw(dirname);
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
+{
    'redis' => {
        encoding    => undef,
        name        => 'petatube_deployment',
        server      => 'localhost:6379',
    },
};
