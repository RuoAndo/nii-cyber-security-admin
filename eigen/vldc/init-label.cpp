#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <pthread.h>

#include <string>
#include <iostream>
#include <fstream>
#include <eigen3/Eigen/Dense>

#include <eigen3/Eigen/Core>
#include <eigen3/Eigen/SVD>

#include <random>

#define THREAD_NUM 700
#define CLUSTER_NUM 20
static int cluster_no[CLUSTER_NUM];

using namespace Eigen;
using namespace std;

Eigen::MatrixXd avg;

Eigen::MatrixXd readCSV(std::string file, int rows, int cols) {
  
  std::ifstream in(file.c_str());

  std::string line;

  int row = 0;
  int col = 0;

  Eigen::MatrixXd res = Eigen::MatrixXd(rows, cols);

  if (in.is_open()) {

    while (std::getline(in, line)) {

      char *ptr = (char *) line.c_str();
      int len = line.length();

      col = 0;

      char *start = ptr;
      for (int i = 0; i < len; i++) {

	if (ptr[i] == ',') {
	  res(row, col++) = atof(start);
	  start = ptr + i + 1;
	}
      }
      res(row, col) = atof(start);

      row++;
    }

    in.close();
  }
  return res;
}

typedef struct _thread_arg {
    int id;
    int rows;
    int columns;
} thread_arg_t;

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;
    int label = 0;
      
    string fname = "/dev/vldc_data_" + std::to_string(targ->id);

    Eigen::MatrixXd res = readCSV(fname, targ->rows,targ->columns);
    Eigen::MatrixXd res2 = res.leftCols(5);

    std::string ofname = "/dev/vldc_label_" + std::to_string(targ->id);      
    ofstream outputfile(ofname);

    std::random_device rnd;
    
    for(i=0; i< res2.rows(); i++)
	{

	  label = rnd() % CLUSTER_NUM;
	  
	  outputfile << label;

	  /*
	  for(k=0;k<res2.row(i).cols()-1 ;k++)
	    {
	      outputfile << res2.row(i).col(k) << ",";
	    }
	  
	  outputfile << res2.row(i).col(k); 
	  */
      
	  outputfile << std::endl;

	}

      outputfile.close();

      std::cout << "thread ID: " << targ->id << " - done." << std::endl;
      
    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];

    int i;

    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
	/* size of data */
        targ[i].rows = atoi(argv[1]);
	targ[i].columns = atoi(argv[2]);
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);
}
