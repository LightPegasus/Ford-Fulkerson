/*
 * Darrin Egan
 *
 * Create a nxn matrix
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int createMatrix(int max) {
    FILE *fp;
    int num;
    srand((unsigned int)time(NULL));
    int weights[max+1][max+1];
/*
    for(int i = 0; i < max; i++){
        for(int j = 0; j < max; j++){
            weights[i][j] = 1 + (rand() % (2*max));
        }
    }

    fp = fopen("sample.txt", "w+");
    
    for(int i = 0; i < max; i++){
        for(int j = 0; j < max; j++){
            if (i == j){
                weights[i][j] = 0;
                fprintf(fp, "%d ", weights[i][j]);
            } else {
                weights[j][i] = weights[i][j];
                fprintf(fp, "%d ", weights[i][j]);
            }
        }
        fprintf(fp, "\n");
    }
    fclose(fp);*/
    
    for (int i = 0; i < max; i++) {
        for (int j = 0; j < max; j++) {
            weights[i][j] = 0;
        }}
    int x, y;
    double nnz = floor(max * max * .6); //number of non-zeroes
    for (int i = 0; i < nnz; i++) {
        x = (rand() % (max));
        y = (rand() % (max));
        if ((x != y) && (x != max-1) && (y != 0)) {
            weights[x][y] = 1 + (rand() % (2 * max));
        }
        else {
            i--;
        }
    }
    
    fp = fopen("sample.txt", "w+");
    
    for(int i = 0; i < max; i++){
        for(int j = 0; j < max; j++){
            fprintf(fp, "%d ", weights[i][j]);
        }
        fprintf(fp, "\n");
    }
    fclose(fp);
    

}

int main(int argc, char**argv) {
    if (argv[1] <= 0) {
        printf("Cannot have a file that is less than 1\n");
        return 0;
    }

    createMatrix(atoi(argv[1]));
    return 0;
}
