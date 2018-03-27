<%namespace file="ie.mako" name="ie"/>
<%
import os
import shutil
import time
import subprocess

# Sets ID and sets up a lot of other variables
ie_request.load_deploy_config()
ie_request.attr.docker_port = 3838


# Create tempdir in galaxy
#temp_dir = ie_request.temp_dir
#PASSWORD = ie_request.notebook_pw
#USERNAME = "galaxy"

# Did the user give us an RData file?
#if hda.datatype.__class__.__name__ == "RData":
#    shutil.copy( hda.file_name, os.path.join(temp_dir, '.RData') )
#will put the right file here  
#data type definition
#/galaxy-central/lib/galaxy/datatypes  

dataset = ie_request.volume(hda.file_name, '/srv/shiny-server/samples/chromato_visu/inputdata.dat', how='ro')

ie_request.launch(volumes=[dataset],env_override={
    'PUB_HOSTNAME': ie_request.attr.HOST,
})

## General IE specific
# Access URLs for the notebook from within galaxy.
# TODO: Make this work without pointing directly to IE. Currently does not work
# through proxy.
notebook_access_url = ie_request.url_template('${PROXY_URL}/?')
#notebook_access_url = ie_request.url_template('${PROXY_URL}/samples/MY_APP/?')
#notebook_access_url = ie_request.url_template('${PROXY_URL}/?bam=http://localhost/tmp/bamfile.bam')
#notebook_pubkey_url = ie_request.url_template('${PROXY_URL}/rstudio/auth-public-key')
#notebook_access_url = ie_request.url_template('${PROXY_URL}/rstudio/')
#notebook_login_url =  ie_request.url_template('${PROXY_URL}/rstudio/auth-do-sign-in')

root = h.url_for( '/' )

%>
<html>
<head>
${ ie.load_default_js() }
</head>
<body style="margin:0px">
<script type="text/javascript">

        ${ ie.default_javascript_variables() }
        var notebook_access_url = '${ notebook_access_url }';
        ${ ie.plugin_require_config() }

        requirejs(['interactive_environments', 'plugin/bam_iobio'], function(){
            display_spinner();
        });

        toastr.info(
            "Loading data into the App",
            "...",
            {'closeButton': true, 'timeOut': 5000, 'tapToDismiss': false}
        );

        var startup = function(){
           // Load notebook
           requirejs(['interactive_environments', 'plugin/bam_iobio'], function(){
           //requirejs(['interactive_environments'], function(){
                load_notebook(notebook_access_url);
           });

        };
        // sleep 5 seconds
        // this is currently needed to get the vis right
        // plans exists to move this spinner into the container
        setTimeout(startup, 5000);

</script>
<div id="main">
</div>
</body>
</html>
