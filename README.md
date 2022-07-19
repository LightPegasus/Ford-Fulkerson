# Ford-Fulkerson

To compile createMatrix.c:
  gcc -w -o createMatrix createMatrix.c

To run createMatrix:
  ./createMatrix <# of Vertices>

To compile FFA_ser.chpl:
  chpl FFA_ser.chpl --fast
  
To run:
  ./FFA_ser -nl <#locales> --f=sample.txt --V=<# of Vertices>

To compile FFA_para.chpl:
  chpl FFA_para.chpl --fast
  
To run:
  ./FFA_para -nl <#locales> --f=sample.txt --V=<# of Vertices>
