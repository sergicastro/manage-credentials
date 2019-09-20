# manage-credentials
![Ruby Action](https://github.com/sergicastro/manage-credentials/workflows/Ruby/badge.svg)
[![Build Status](https://travis-ci.org/sergicastro/manage-credentials.svg?branch=master)](https://travis-ci.org/sergicastro/manage-credentials)
[![Code Climate](https://codeclimate.com/github/sergicastro/manage-credentials/badges/gpa.svg)](https://codeclimate.com/github/sergicastro/manage-credentials)
[![Test Coverage](https://codeclimate.com/github/sergicastro/manage-credentials/badges/coverage.svg)](https://codeclimate.com/github/sergicastro/manage-credentials/coverage)
[![Issue Count](https://codeclimate.com/github/sergicastro/manage-credentials/badges/issue_count.svg)](https://codeclimate.com/github/sergicastro/manage-credentials)

Command line program to manage credentials in the abq api

```
$>> managecredentials
Commands:
  managecredentials add <provider> <enterprise>      # Adds the credentials for <provider> into the <enterprise>
  managecredentials help [COMMAND]                   # Describe available commands or one specific command
  managecredentials list <enterprise>                # List the attached credientials of the <enterprise>
  managecredentials list_providers [remote]          # Lists the config file providers. --remote option will list the remote ones
  managecredentials printkeys <provider>             # Print the provider keys
  managecredentials release <provider> <enterprise>  # Release the credentials for <provider> from the <enterprise>
  managecredentials set_location <new_location>      # Sets the new api location
  managecredentials show_location                    # Shows the current api location
```
