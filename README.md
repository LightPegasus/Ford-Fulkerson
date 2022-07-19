# Ford-Fulkerson

To compile createMatrix.c:
  gcc -w -o createMatrix createMatrix.c

To run createMatrix:
  ./createMatrix <# of Vertices>

To compile FFA2.chpl:
  chpl FFA2.chpl --fast
  
To run:
  ./FFA2 -nl <#locales> --f=sample.txt --V=<# of Vertices>
