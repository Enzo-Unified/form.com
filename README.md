# Form.com
This public repo for Form.com provides an overview and sample pipelines to enable the creation of a data lake and to integration with the Form.API using DataZen. 

# Conventions

The jobs provided in this repo depend on the following connections; if the connection names are not the same as the ones documented here, you will be prompted to change them. However, a few places may still require manual modification for the jobs to run successfully.

* __form_token__: A session-based authentication to Form.com that returns a security token
* __form_noToken__: A session-based authentication to Form.com that does not return a security token
* __sql__: A database connection to a SQL Server database (the jobs provided here all point to the database name specified in the connection)

## Where to Find and Replace Connections
Generally, connections are found in the following places in jobs:

- The source connection (automatically detected and replaced) 
- The target connection (automatically detected and replaced)
- The connection used by a Dynamic Parameter for HTTP jobs
- The connection used by the Log Settings for HTTP sources, if any
- The connections used by Data Pipeline components (some components require a connection to function), for both source and target pipelines
- The connection used by HTTP Finalization Options when logging is enabled 


