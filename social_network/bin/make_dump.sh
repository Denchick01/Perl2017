#!/bin/bash
dbicdump -o dump_directory=../lib -o debug=1 Local::Schema 'DBI:mysql:database=Social_Network' denis_t 12345
