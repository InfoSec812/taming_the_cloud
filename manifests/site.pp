## Put any GLOBAL settings for all nodes HERE in the site.pp file.

## Set the default PATH variable for 'exec' types
Exec { path => "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin" }

## Set the file bucket for storing previous versions of files after changes
filebucket { main: server => 'lou1' }

## Set the puppet_last_update value for use as a 'fact' in MCollective
$puppet_last_update = inline_template("<%= Time.now.to_i %>")

import "classes/*.pp"
import "nodes/*.pp"
