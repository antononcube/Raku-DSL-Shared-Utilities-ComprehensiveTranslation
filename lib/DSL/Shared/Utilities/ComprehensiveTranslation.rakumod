
# Most likely a better place for this file is a separate GitHub/Raku repository/package.
# The functionality here is not "shared" -- it is "overall."

use v6;

use DSL::Shared::Utilities::MetaSpecsProcessing;
use JSON::Marshal;

unit module DSL::Shared::Utilities::ComprehensiveTranslation;

#-----------------------------------------------------------
use DSL::English::ClassificationWorkflows;
use DSL::English::DataQueryWorkflows;
use DSL::English::EpidemiologyModelingWorkflows;
use DSL::English::LatentSemanticAnalysisWorkflows;
use DSL::English::QuantileRegressionWorkflows;
use DSL::English::RecommenderWorkflows;
use DSL::English::SearchEngineQueries;
use DSL::English::FoodPreparationWorkflows;
use DSL::English::DataAcquisitionWorkflows;

#-----------------------------------------------------------
# DSL target to DSL module
#-----------------------------------------------------------

my %moduleToPythonTarget =

        "DSL::English::ClassificationWorkflows" => "Python-ClCon",
        "DSL::English::DataQueryWorkflows" => "Python-pandas",
        "DSL::English::EpidemiologyModelingWorkflows" => "Python-ECMMon",
        "DSL::English::LatentSemanticAnalysisWorkflows" => "Python-LSAMon",
        "DSL::English::QuantileRegressionWorkflows" => "Python-QRMon",
        "DSL::English::RecommenderWorkflows" => "Python-SMRMon",
        "DSL::English::SearchEngineQueries" => "Python-pandas";


my %moduleToRTarget =

        "DSL::English::ClassificationWorkflows" => "R-ClCon",
        "DSL::English::DataQueryWorkflows" => "R-tidyverse",
        "DSL::English::EpidemiologyModelingWorkflows" => "R-ECMMon",
        "DSL::English::LatentSemanticAnalysisWorkflows" => "R-LSAMon",
        "DSL::English::QuantileRegressionWorkflows" => "R-QRMon",
        "DSL::English::RecommenderWorkflows" => "R-SMRMon",
        "DSL::English::SearchEngineQueries" => "R-tidyverse",
        "DSL::English::FoodPreparationWorkflows" => "R-base",
        "DSL::English::DataAcquisitionWorkflows" => "R-base";


my %moduleToWLTarget =

        "DSL::English::ClassificationWorkflows" => "WL-ClCon",
        "DSL::English::DataQueryWorkflows" => "WL-System",
        "DSL::English::EpidemiologyModelingWorkflows" => "WL-ECMMon",
        "DSL::English::LatentSemanticAnalysisWorkflows" => "WL-LSAMon",
        "DSL::English::QuantileRegressionWorkflows" => "WL-QRMon",
        "DSL::English::RecommenderWorkflows" => "WL-SMRMon",
        "DSL::English::SearchEngineQueries" => "WL-SMRMon",
        "DSL::English::FoodPreparationWorkflows" => "WL-System",
        "DSL::English::DataAcquisitionWorkflows" => "WL-System";


my %specToModuleToTarget =
        "Python" => %moduleToPythonTarget,
        "R" => %moduleToRTarget,
        "WL" => %moduleToWLTarget;

# Make target-to-module rules by inverting the module-to-target rules
my %targetToModule = reduce( { $^a.push( $^b.invert ) }, {}, |%specToModuleToTarget.values );

# Make target-to-module rules by inverting the module-to-target rules and modifying the targets, e.g. "R-LSAMon" to "R::LSAMon"
my %targetToModule2 = reduce( { $^a.push( $^b.deepmap({ $_.subst( '-', '::' ):g }).invert ) }, {}, |%specToModuleToTarget.values );

# Join the two target-to-module dictionaries
%targetToModule = %targetToModule , %targetToModule2;

#-----------------------------------------------------------
# DSL module to DSL grammar
#-----------------------------------------------------------
my %moduleToDSLGrammar =

        "DSL::English::ClassificationWorkflows" => DSL::English::ClassificationWorkflows::Grammar,
        "DSL::English::DataQueryWorkflows" => DSL::English::DataQueryWorkflows::Grammar,
        "DSL::English::EpidemiologyModelingWorkflows" => DSL::English::EpidemiologyModelingWorkflows::Grammar,
        "DSL::English::LatentSemanticAnalysisWorkflows" => DSL::English::LatentSemanticAnalysisWorkflows::Grammar,
        "DSL::English::QuantileRegressionWorkflows" => DSL::English::QuantileRegressionWorkflows::Grammar,
        "DSL::English::RecommenderWorkflows" => DSL::English::RecommenderWorkflows::Grammar,
        "DSL::English::SearchEngineQueries" => DSL::English::SearchEngineQueries::Grammar,
        "DSL::English::FoodPreparationWorkflows" => DSL::English::FoodPreparationWorkflows::Grammar,
        "DSL::English::DataAcquisitionWorkflows" => DSL::English::DataAcquisitionWorkflows::Grammar;

#-----------------------------------------------------------
# DSL module to DSL workflow code function
#-----------------------------------------------------------
my %moduleToDSLFunction =

        "DSL::English::ClassificationWorkflows" => "ToClassificationWorkflowCode",
        "DSL::English::DataQueryWorkflows" => "ToDataQueryWorkflowCode",
        "DSL::English::EpidemiologyModelingWorkflows" => "ToEpidemiologyModelingWorkflowCode",
        "DSL::English::LatentSemanticAnalysisWorkflows" => "ToLatentSemanticAnalysisWorkflowCode",
        "DSL::English::QuantileRegressionWorkflows" => "ToQuantileRegressionWorkflowCode",
        "DSL::English::RecommenderWorkflows" => "ToRecommenderWorkflowCode",
        "DSL::English::SearchEngineQueries" => "ToSearchEngineQueryCode",
        "DSL::English::FoodPreparationWorkflows" => "ToFoodPreparationWorkflowCode",
        "DSL::English::DataAcquisitionWorkflows" => "ToDataAcquisitionWorkflowCode";


#-----------------------------------------------------------
# Shortcuts for DSL module specs
#-----------------------------------------------------------
my %englishModuleFunctions =

        "DSL::English::ClassificationWorkflows" => &ToClassificationWorkflowCode,
        "DSL::English::DataQueryWorkflows" => &ToDataQueryWorkflowCode,
        "DSL::English::EpidemiologyModelingWorkflows" => &ToEpidemiologyModelingWorkflowCode,
        "DSL::English::LatentSemanticAnalysisWorkflows" => &ToLatentSemanticAnalysisWorkflowCode,
        "DSL::English::QuantileRegressionWorkflows" => &ToQuantileRegressionWorkflowCode,
        "DSL::English::RecommenderWorkflows" => &ToRecommenderWorkflowCode,
        "DSL::English::SearchEngineQueries" => &ToSearchEngineQueryCode,
        "DSL::English::FoodPreparationWorkflows" => &ToFoodPreparationWorkflowCode,
        "DSL::English::DataAcquisitionWorkflows" => &ToDataAcquisitionWorkflowCode;


#-----------------------------------------------------------
# Module shortcut rules
#-----------------------------------------------------------
my %englishModuleShortcuts =

        ClCon => "DSL::English::ClassificationWorkflows",
        ClassificationWorkflows => "DSL::English::ClassificationWorkflows",
        "DSL::English::ClassificationWorkflows" => "DSL::English::ClassificationWorkflows",

        DataQueryWorkflows => "DSL::English::DataQueryWorkflows",
        "DSL::English::DataQueryWorkflows" => "DSL::English::DataQueryWorkflows",

        ECMMon => "DSL::English::EpidemiologyModelingWorkflows",
        EpidemiologyModelingWorkflows => "DSL::English::EpidemiologyModelingWorkflows",
        "DSL::English::EpidemiologyModelingWorkflows" => "DSL::English::EpidemiologyModelingWorkflows",

        LSAMon => "DSL::English::LatentSemanticAnalysisWorkflows",
        LatentSemanticAnalysisWorkflows => "DSL::English::LatentSemanticAnalysisWorkflows",
        "DSL::English::LatentSemanticAnalysisWorkflows" => "DSL::English::LatentSemanticAnalysisWorkflows",

        QRMon => "DSL::English::QuantileRegressionWorkflows",
        QuantileRegressionWorkflows => "DSL::English::QuantileRegressionWorkflows",
        "DSL::English::QuantileRegressionWorkflows" => "DSL::English::QuantileRegressionWorkflows",

        SMRMon => "DSL::English::RecommenderWorkflows",
        RecommenderWorkflows => "DSL::English::RecommenderWorkflows",
        "DSL::English::RecommenderWorkflows" => "DSL::English::RecommenderWorkflows",

        "SearchEngineQueries" => "DSL::English::SearchEngineQueries",
        "DSL::English::SearchEngineQueries" => "DSL::English::SearchEngineQueries",

        "FoodPrep" => "DSL::English::FoodPreparationWorkflows",
        "FoodPreparation" => "DSL::English::FoodPreparationWorkflows",
        "DSL::English::FoodPreparationWorkflows" => "DSL::English::FoodPreparationWorkflows",

        "DataAcquirer" => "DSL::English::DataAcquisitionWorkflows",
        "DataAcquisition" => "DSL::English::DataAcquisitionWorkflows",
        "DSL::English::DataAcquisitionWorkflows" => "DSL::English::DataAcquisitionWorkflows";


#-----------------------------------------------------------
my %languageDispatch =
        English => %englishModuleShortcuts;

#-----------------------------------------------------------
#| Finds most applicable DSL grammar.
proto dsl-most-applicable(Str $command, %dslToGrammar = %moduleToDSLGrammar, Int :$n = 10, Str :$norm = 'sum', Int :$batch = 64, Int :$degree = 1) is export {*};
#= Uses parsing residuals -- the DSL grammar with the smallest count of un-parsed characters is the most applicable.

multi dsl-most-applicable(Str $command, %dslToGrammar = %moduleToDSLGrammar, Int :$n = 10, Str :$norm = 'sum', Int :$batch = 64, Int :$degree = 1) {

    die "The argument \$n is expected to be a postive integer." unless $n > 0;

    # "Elegant" version, but enumerates all DSLs.
    # my @pairs = map({ $_.key => get-dsl-parser-residual($_.value, $command, :$norm) }, %dslToGrammar.pairs);

    # "Optimized" version, stops as soon as
    # the residual is 0 and the attempted grammar is not 'DSL::English::SearchEngineQueries'.
    my @pairs;
    if $degree <= 1 {
        for %dslToGrammar.kv -> $k, $v {
            my $pres = get-dsl-parser-residual($v, $command, :$norm);
            @pairs = @pairs.append( $k => $pres);
            last if $pres == 0 and $k ne 'DSL::English::SearchEngineQueries';
        }
    } else {
        # Using the "elegant" version for parallel execution.
        # @pairs = race %dslToGrammar.pairs.race(:$batch, :$degree).map({ $_.key => get-dsl-parser-residual($_.value, $command, :$norm) });

        @pairs = race for %dslToGrammar.list.race( :$batch, :$degree ) -> $p {
            my $pres = get-dsl-parser-residual($p.value, $command, :$norm);
            $p.key => $pres
        }
    }

    @pairs = @pairs.sort({ $_.value });

    return $n < @pairs.elems ?? @pairs[^$n] !! @pairs;
}

#-----------------------------------------------------------
#| Picks most applicable DSL grammar.
proto dsl-pick(Str $command, %dslToGrammar = %moduleToDSLGrammar, Str :$norm = 'sum', Int :$degree = 1) is export {*};

multi dsl-pick(Str $command, %dslToGrammar = %moduleToDSLGrammar, Str :$norm = 'sum', Int :$degree = 1) {
    my @pairs = dsl-most-applicable($command, %dslToGrammar, n => 3, :$norm, :$degree, batch => max( floor(%dslToGrammar.elems / $degree), 1));

    my @pairs2 = grep( { not( $_.key eq "DSL::English::SearchEngineQueries" ) }, @pairs );

    if @pairs.elems == @pairs2.elems {
        return @pairs.min({ $_.value }).key;
    }

    my %res = Hash.new( @pairs );
    my Int $minVal2 = @pairs.min({ $_.value }).value;

    if %res{"DSL::English::SearchEngineQueries"} == 0 and $minVal2 > 15 {
        return "DSL::English::SearchEngineQueries";
    } else {
        return @pairs2.min({ $_.value }).key;
    }
}

#-----------------------------------------------------------
#| Get AST tree for a given command and (detected) DSL.
sub get-ast(Str:D $command, Str:D $dsl) {
    my $gram = %moduleToDSLGrammar{$dsl};

    $gram.parse($command, rule => 'workflow-commands-list')
}

#-----------------------------------------------------------
#|( Translates natural language commands into programming code.
    * C<$command> is a string with one or many commands (separated by ';').
    * C<$language> is the natural language to translate from.
    * C<$format> is the format of the output one of 'raku' or 'json'.
    * C<$guessGrammar> is a Boolean whether to guess the DSL grammar of C<$command>.
    * C<$defaultTargetsSpec> is a programming language name, one of 'Python', 'R', 'WL'.
    * C<$degree> is a positive integer for the degree parallelism.
    * C<$ast> should Match object be returned for the key "CODE"?
)
proto ToDSLCode(Str $command,
                Str :$language = 'English',
                Str :$format = 'hash',
                Bool :$guessGrammar = True,
                Str :$defaultTargetsSpec = 'R',
                Int :$degree = 1,
                Bool :$ast = False) is export {*};

multi ToDSLCode(Str $command,
                Str :$language = 'English',
                Str :$format = 'hash',
                Bool :$guessGrammar = True,
                Str :$defaultTargetsSpec = 'R',
                Int :$degree = 1,
                Bool :$ast = False) {

    die "Unknown natural language: $language." unless %languageDispatch{$language}:exists;

    die "Unknown default targets spec: $defaultTargetsSpec." unless %specToModuleToTarget{$defaultTargetsSpec}:exists;

    # Get DSL specifications
    my %dslSpecs = get-dsl-spec($command, 'any');

    # Get DSL module
    if not (%dslSpecs and %dslSpecs{'DSL'}:exists) {

        die "No DSL module specification command." unless $guessGrammar;

        if %dslSpecs{'DSLTARGET'}:exists and %targetToModule{%dslSpecs{'DSLTARGET'}}:exists {
            # Restrict the DSL guessing to the specified target DSLs
            my %small = %moduleToDSLGrammar{ |%targetToModule{%dslSpecs{'DSLTARGET'}} }:p;
            %dslSpecs = %dslSpecs, 'DSL' => dsl-pick( $command, %small);
        } else {
            %dslSpecs = %dslSpecs, 'DSL' => dsl-pick( $command, %moduleToDSLGrammar, :$degree );
        }
    }

    my Str $dsl = %dslSpecs{'DSL'};
    $dsl = %languageDispatch{$language}{$dsl};

    die "Unknown DSL spec: $dsl." unless  %languageDispatch{$language}{$dsl}:exists;

    # Get DSL target
    my Str $dslTarget = %specToModuleToTarget{$defaultTargetsSpec}{$dsl};

    $dslTarget = %dslSpecs{'DSLTARGET'}:exists ?? %dslSpecs{'DSLTARGET'} !! $dslTarget;

    # Get DSL function
    my &dslFunc = %englishModuleFunctions{$dsl};

    # DSL translate
    my $code = $ast ?? get-ast($command, $dsl) !! &dslFunc($command, $dslTarget);

    # Get user specifications
    my %userSpecs = get-user-spec($command);

    if not (%userSpecs and %userSpecs{'USERID'}:exists) {
        %userSpecs = %userSpecs, 'USERID' => '';
    } elsif %userSpecs{'USERID'} (elem) <NONE NULL> {
        %userSpecs = %userSpecs, 'USERID' => '';
    }

    # Result
    my %rakuRes = Hash.new(%dslSpecs,  %userSpecs, { CODE => $code, DSL => $dsl, DSLTARGET => $dslTarget, DSLFUNCTION => &dslFunc.raku });
    %rakuRes = %rakuRes, %userSpecs;
    %rakuRes = %rakuRes.sort({ $^a.key });

    if $format.lc (elem) <object hash> {
        return %rakuRes;
    } elsif $format.lc eq 'raku' {
        return %rakuRes.raku;
    } elsif $format.lc eq 'json' {
        return marshal(%rakuRes);
    } elsif $format.lc eq 'code' {
        return %rakuRes<CODE>;
    } else {
        warn "Unknown format: $format. Using 'Hash' instead.";
        return %rakuRes;
    }
}

#-----------------------------------------------------------
#|( Translates natural language commands into Abstract Syntax Trees (ASTs).
    * C<$command> is a string with one or many commands (separated by ';').
    * C<$language> is the natural language to translate from.
    * C<$format> is the format of the output one of 'raku' or 'json'.
    * C<$guessGrammar> is a Boolean whether to guess the DSL grammar of C<$command>.
    * C<$defaultTargetsSpec> is a programming language name, one of 'Python', 'R', 'WL'.
)
sub ToDSLSyntaxTree(Str $command,
                Str :$language = 'English',
                Str :$format = 'hash',
                Bool :$guessGrammar = True,
                Str :$defaultTargetsSpec = 'R',
                Int :$degree = 1) is export {

    # Call ToDSLCode
    my %ast = ToDSLCode($command, :$language, format => 'hash', :$guessGrammar, :$defaultTargetsSpec, :$degree):ast;

    # Result
    my %rakuRes = %ast<DSL> => %ast<CODE>;

    if $format.lc (elem) <object hash> {
        return %rakuRes;
    } elsif $format.lc eq 'raku' {
        return %rakuRes.raku;
    } elsif $format.lc eq 'json' {
        return marshal( %( %ast<DSL> => %ast<CODE>.raku ) );
    } elsif $format.lc eq 'code' {
        return %ast<CODE>;
    } else {
        warn "Unknown format: $format. Using 'Hash' instead.";
        return %rakuRes;
    }
}
#= This function uses C<ToDSLCode> with C<ast => True>.