#!/bin/bash
dbicdump -o dump_directory=../lib -o debug=1 Local::Schema 'DBI:mysql:database=Web_notes' denis_t 12345
