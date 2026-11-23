# truncate_day_file

A bash script that can be used to create a partial IAGA-2002 file from 
a full day file. It works for either 1-minute or 1-second days files. 
The script could be used for any other text-based data file which has a 
header between 0 and 150 lines long and stores data one record per 
sample following the header.

The bats testing system is used to for automated testing of the script 
(see https://bats-core.readthedocs.io/en/stable/#). To install bats on 
Ubuntu:

```
    sudo apt install bats
```

To run the tests:

```
    bats test/tests.bats
```
