all: test

test:
   nvcc -arch=compute_50 -o prime main.cu prime.cpp prime.hpp -Xcompiler -fopenmp

clean:
		rm -rf *.o
