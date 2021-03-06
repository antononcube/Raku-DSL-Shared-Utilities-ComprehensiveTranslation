#!/usr/bin/env perl6

use Cro::HTTP::Router;
use Cro::HTTP::Server;

use lib './lib';
use lib '.';

use DSL::Shared::Utilities::MetaSpecsProcessing;
use DSL::Shared::Utilities::ComprehensiveTranslation;
use Lingua::NumericWordForms;
use JSON::Marshal;

my @testCommands = (
'create recommender with dfTitanic; recommend by profile male; echo value',
'DSL TARGET WL-SMRMon; create recommender with dfTitanic; recommend by profile male; echo value',
'DSL MODULE SMRMon; create recommender with dfTitanic; recommend by profile male; echo value',
'use dfTitanic; select the columns name, species, mass and height; cross tabulate species over mass',
'use dfStarwars; select species, mass and height; cross tabulate species over mass;',
'DSL MODULE DataQueryWorkflows; USER ID mimiMal233; use dfStarwars; select species, mass and height; cross tabulate species over mass;',
'USER IDENTIFIER 8989-jkko-9009-klkl; I want to eat a Chinese lunch',
'USER IDENTIFIER NONE; I want to eat a Greek protein lunch',
'DSL MODULE FoodPrep; I want to eat a Chinese lunch;'
);

# http://localhost:10000/translate?commands='use dfTitanic;summarize data'
# http://localhost:10000/translate/'DSL MODULE SMRMon; create recommender with dfTitanic; recommend by profile male; echo value'
# http://localhost:10000/translate/'USER ID sezin23; DSL MODULE FoodPrep; I want to eat Chinese protein lunch'
# http://localhost:10000/translate/'I want to eat Chinese protein lunch'
# http://localhost:10000/translate/'use texHamplet; create document term matrix; extract 12 topics; show statistical thesaurus for king and queen'
# http://localhost:10000/translate/'DSL MODULE DataQueryWorkflows; USER ID mimiMal233; use dfStarwars; select species, mass and height; cross tabulate species over mass;'

# http://localhost:10000/translate/numeric/'one hundred twenty three; един милион и двеста хиляди'
# http://localhost:10000/translate/numeric/'one%20hundred%20twenty%20three;%D9%86%D9%88%D8%AF%20%D9%88%20%D9%87%D9%81%D8%AA'
# http://localhost:10000/translate/numeric/'1232; 99034_93'

# The code below follows the examples shown in
#   https://cro.services/docs/intro/getstarted
#   https://cro.services/docs/intro/http-server

my $application = route {
    get -> {
        content 'text/html', ToDSLCode(@testCommands[1], language => "English", format => 'json', :guessGrammar, defaultTargetsSpec => 'WL');;
    }

    get -> 'translate', $commands {
        my Str $commands2 = $commands;
        $commands2 = ($commands2 ~~ / ['"' | '\''] .* ['"' | '\''] /) ?? $commands2.substr(1,*-1) !! $commands2;

        ## Redirecting stderr to a custom $err
        my $err;

        my $*ERR = $*ERR but role {
            method print (*@args) {
                $err ~= @args
            }
        }

        ## Interpret
        my %res = ToDSLCode( $commands2, language => "English", format => 'object', :guessGrammar, defaultTargetsSpec => 'WL');

        ## Combine with custom $err with interpretation result
        %res = %res , %( STDERR => $err );

        content 'text/html', marshal(  %res );
    }

    get -> 'translate', 'foodprep', $commands {
        my Str $commands2 = $commands;
        $commands2 = ($commands2 ~~ / ['"' | '\''] .* ['"' | '\''] /) ?? $commands2.substr(1,*-1) !! $commands2;
        content 'text/html', ToDSLCode( $commands2, language => "English", format => 'json', :guessGrammar, defaultTargetsSpec => 'WL');
    }

    get -> 'translate', 'numeric', $commands {
        my Str $commands2 = $commands;
        $commands2 = ($commands2 ~~ / ['"' | '\''] .* ['"' | '\''] /) ?? $commands2.substr(1,*-1) !! $commands2;

        my $res =  ($commands2 ~~ / ^ [ ';' | \d ]* $ /) ?? to-numeric-word-form($commands2) !! from-numeric-word-form( $commands2, 'automatic', :p);

        content 'text/html', marshal($res);
    }
}

my Cro::Service $service = Cro::HTTP::Server.new:
    :host<localhost>, :port<10000>, :$application;

$service.start;

react whenever signal(SIGINT) {
    $service.stop;
    exit;
}