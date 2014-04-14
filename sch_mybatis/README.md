Description
===========
This cookbook performs the following tasks:
1. Installs and configures the mybatis framework.
2. Downloads bootstrap and migration scripts for a web address or git.
3. Runs a bootstrap. This is only done once and is optional.
4. Runs a migration

Requirements
============
The cookbook depends on the java and application cookbooks. 
Additionally the following attributes should be set in a role or environment file:

		:git_security_type 
		:git_repo 
		:migrate_to_version
		:git_scripts_dir 
		:db_name
		:db_name 
		:db_port 
		:db_username
		:db_password
		:create_mybatis_changelog_table

A sample of how these are configured in an evironments file is below. Note the oauth token is included in the git URL.

	:mybatis => {
		:git_security_type =>  "oauth",
		:git_repo =>  "https://a62cbf9f8e255bdbf443e8fb6dd779bb9765da6d:@github.com/ScholasticInc/samee-ebooks.git",
		:migrate_to_version => "20121212161322",
		:git_scripts_dir => 	"/usr/local/mybatis/git_space/db",
		:db_name => "dbsamee",
		:db_port => "3306",
		:db_username =>"samee",
		:db_password => "e1e1e1e1",
		:create_mybatis_changelog_table => "true"
	}


Attributes
==========
default[:mybatis][:source] = "mybatis-3.0.6-migrations.zip"
default[:mybatis][:version] = "3.0.6"
default[:mybatis][:install_folder] = "/usr/local/mybatis"
default[:mybatis][:installed_name] = "mybatis_exe"
default[:mybatis][:migrations_working_folder] = "/usr/local/mybatis/migrations/testdb"
default[:mybatis][:create_mybatis_changelog_table] = true # if true, changelog table is only created on initial mybatis migration
default[:mybatis][:environment] = "development"
default[:mybatis][:db_name] = "" # the database to run migrations against
default[:mybatis][:db_driver] = "com.mysql.jdbc.Driver"
default[:mybatis][:db_url] = "jdbc:mysql://#{node[:ipaddress]}"
default[:mybatis][:db_port] = "" # if this is blank mybatis will use the node[:samconnect][:iondb.....] values
default[:mybatis][:db_username] = "" # if db_port (above) is blank mybatis will use the node[:samconnect][:iondb.....] values
default[:mybatis][:db_password] = "" # if db_port (above) is blank mybatis will use the node[:samconnect][:iondb.....] values
default[:mybatis][:run_bootstrap] = false # change to true if you want mybatis to run a bootstrap at first use
default[:mybatis][:bootstrap_file_in_git] = false
default[:mybatis][:bootstrap_script_location] = "" # For example "http://somerepo.com/repositories/releases/0.1.9b"
default[:mybatis][:bootstrap_script_name] = "" # for example "ion.db.populate-0.1.9b.zip"
default[:mybatis][:bootstrap_script_username] = "" #this is only used if not configured for git
default[:mybatis][:bootstrap_script_password] = "" #again only used if not conifgured for git
default[:mybatis][:migrate_command] = "version" 
default[:mybatis][:migrate_to_version] = "" # override this to the version nuber 'XXXXX' to upgrade (or downgrade) to a specific config
default[:mybatis][:migration_scripts] = Array.new # array of URL's
default[:mybatis][:use_git_repo] = true
default[:mybatis][:git_security_type] = "oauth" # must be either "oauth" or "deploy_key"
default[:mybatis][:git_repo_destination] = "/usr/local/mybatis/git_space"
default[:mybatis][:git_repo] = "" # for examlpe git@github.com:fred/fred.git"
default[:mybatis][:git_scripts_dir] = "/usr/local/mybatis/git_space/current/dbscripts/myBatis"
default[:mybatis][:deploy_key] = "" # must use \n instead of CRLF and have standard begining and ending ---- delimiters ----
default[:mybatis][:deploy_revision] = "master"
Usage
=====
add "recipe[mybatis]" to a run list.
configure your mybatis attributes in an environment file, see the example in the requirements section
