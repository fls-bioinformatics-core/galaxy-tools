testing: stuff for testing the tools
====================================

To run the functional tests installed in a Galaxy instance, run:

    sh run_functional_tests.sh -installed

You will need to set the `GALAXY_TOOL_DEPENDENCY_DIR` environment variable to point
to the location of the the `tool_dependency_dir` as defined in your `universe_wsgi.ini`
file.

As the test framework needs to create a fresh database each time, it can be quite
time-consuming to run the tests (especially if there aren't many). You can set the
`GALAXY_TEST_DB_TEMPLATE` environment variable to point to a previously created
SQLite database to bootstrap this part of the process (making it a lot quicker). 
