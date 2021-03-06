
#include <iostream>
#include <fstream>
#include "KalmanFilter.h"
#include "timer.h"

// #define LINE_NUM 5000

using namespace std;
// static float measure[LINE_NUM] = {0};

void readFromFile(char *fname, int nData, float *measure)
{
  std::ifstream ifs(fname);
  std::string str;
  int counter;
  
  counter = 0;
  while(getline(ifs,str))
    {
      measure[counter] = std::atof(str.c_str()); 
      counter = counter + 1;
    }
}

int main(int argc, char const *argv[])
{
  int i;
  int nData;

  unsigned int t, travdirtime; 
  
  nData = atoi(argv[2]);
  float* measure = new float[atoi(argv[2])];
  float* org = new float[atoi(argv[2])];
  float* diff = new float[atoi(argv[2])-1];

  readFromFile(argv[1], int(argv[2]), measure);

  for(i=0;i<nData;i++)
    {
      // cout << measure[i] << endl;
    }
  
  MatrixXf A(1, 1); A << 1;
  MatrixXf H(1, 1); H << 1;
  MatrixXf Q(1, 1); Q << 0;
  MatrixXf R(1, 1); R << 0.1;
  VectorXf X0(1); X0 << 0;
  MatrixXf P0(1, 1); P0 << 1;
  
  KalmanFilter filter1(1, 0);

  filter1.setFixed(A, H, Q, R);
  filter1.setInitial(X0, P0);

  VectorXf Z(1);

  ofstream outputfile("prdct");

  start_timer(&t);
  
  for (int i = 0; i < nData; ++i)
  { 
    filter1.predict(); 
    Z << measure[i];
    filter1.correct( Z );   
    // cout << measure[i] << "," << filter1.X << endl;
    outputfile << filter1.X << endl;
   org[i] = filter1.X[0];

    if (i%(nData/10)==0)
      filter1.setInitial(X0, P0);
  }

  travdirtime = stop_timer(&t);
  print_timer(travdirtime);      
  
  outputfile.close();

  ofstream outputfile2("ma");
  for (int i = 0; i < nData -1; ++i)
  {
    diff[i]=fabs(org[i+1]-org[i]);
    outputfile2 << diff[i] << endl;
  }

  outputfile2.close();
  
  return 0;
}
