# sudoku

Brute force MC for solving difficult eastern sudoku. There are much more elegant solutions out there, but a
solution is found eventually;)

To build container

``` bash
sudo singularity build sudoku.sif sudoku.def
```

to run 

``` bash
singularity run sudoku.sif
```

or if running running in parallel specify the number of processes 

``` bash
singularity run sudoku.sif -p 2
```
