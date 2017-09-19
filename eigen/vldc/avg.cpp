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

#define THREAD_NUM 20
#define CLUSTER_NUM 5
#define ITEM_NUM 3

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

typedef struct _result {
  int cluster_no[CLUSTER_NUM];  
  double item_sum[CLUSTER_NUM][ITEM_NUM];
  pthread_mutex_t mutex;    
} result_t;
result_t result;

typedef struct _thread_arg {
    int id;
    int rows;
    int columns;
} thread_arg_t;

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int i, j, k;
    int label = 0;
    long tmpNo;
    int my_cluster_no[CLUSTER_NUM];
    double my_item_sum[CLUSTER_NUM][ITEM_NUM]; 

    string fname = "/dev/vldc_data" + std::to_string(targ->id);
    string fname_label = "/dev/vldc_label" + std::to_string(targ->id) +  ".labeled";      
   
    for(i=0;i<CLUSTER_NUM;i++)
      {
	my_cluster_no[i]=0;
	for(j=0;j<ITEM_NUM;j++)
	  my_item_sum[i][j]=0;
      }

    /* A, B, C, D, E */
    Eigen::MatrixXd res = readCSV(fname, targ->rows,targ->columns);
    /* L */
    Eigen::MatrixXd res_label = readCSV(fname_label, targ->rows,targ->columns);

    // Eigen::MatrixXd res2 = res.leftCols(1);
    Eigen::MatrixXd res3 = res.rightCols(3);
    
    for(i=0; i< res.rows(); i++)
      {
	tmpNo = res_label.row(i)(0);
	my_cluster_no[tmpNo]++;

	for(j=0; j < ITEM_NUM; j++)
	  my_item_sum[tmpNo][j] += res3.row(i).col(j)(0);
      }

    pthread_mutex_lock(&result.mutex);

    for(i=0; i<CLUSTER_NUM; i++)
      {
	result.cluster_no[i] += my_cluster_no[i];
	
	for(j=0; j < ITEM_NUM; j++)
	  result.item_sum[i][j] += my_item_sum[i][j];
      }
            
    pthread_mutex_unlock(&result.mutex);
    
    return;
}

int main(int argc, char *argv[])
{
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    int i,j;

    double avg_item_tmp[ITEM_NUM];
    MatrixXd centroid(CLUSTER_NUM,ITEM_NUM);
    
    /* 処理開始 */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        targ[i].rows = atoi(argv[1]);
	targ[i].columns = atoi(argv[2]);
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }

    /* 終了を待つ */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    std::string ofname = "centroid";      
    ofstream outputfile(ofname);
    
    for(i=0; i<CLUSTER_NUM; i++)
      {
	// std::cout << result.cluster_no[i] << endl;
	for(j=0; j<ITEM_NUM-1; j++)
	  {
	    avg_item_tmp[j] = result.item_sum[i][j] / result.cluster_no[i];
	    centroid(i,j) = avg_item_tmp[j];    
	    outputfile << avg_item_tmp[j] << ","; 
	    
	  }

        avg_item_tmp[j] = result.item_sum[i][j] / result.cluster_no[i];
	centroid(i,j) = avg_item_tmp[j];    
	outputfile << avg_item_tmp[j]; 

	outputfile << std::endl;
      }

      outputfile.close();
    
    std::cout << centroid << endl;
}

