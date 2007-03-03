<?php
# POD WikiMedia extension

# (c) by Tels http://bloodgate.com 2007

# Takes text between <pod> </pod> tags, and runs it through the
# external script "podcnv", which generates an HTML from it.

$wgExtensionFunctions[] = "wfPODExtension";
 
function wfPODExtension() {
    global $wgParser;

    # register the extension with the WikiText parser
    # the second parameter is the callback function for processing the text between the tags

    $wgParser->setHook( "pod", "renderPOD" );
}

# for Special::Version:

$wgExtensionCredits['parserhook'][] = array(
	'name' => 'POD extension',
	'author' => 'Tels',
	'url' => 'http://wwww.bloodgate.com/wiki/',
	'version' => 'v0.02',
);
 
# The callback function for converting the input text to HTML output
function renderPOD( $input ) {
    global $wgInputEncoding;

    if( !is_executable( "extensions/podcnv" ) ) {
	return "<strong class='error'><code>extensions/podcnv</code> is not executable</strong>";
    }

    $cmd = "extensions/podcnv ".  escapeshellarg($input) . " " . escapeshellarg($wgInputEncoding);
    $output = `$cmd`;

    if (strlen($output) == 0) {
	return "<strong class='error'>Couldn't execute <code>extensions/podcnv</code></strong>";
    }

    return $output;
}
?>
