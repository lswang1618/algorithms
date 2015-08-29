from operator import mul
import math


def matrixMultiply(m1, m2):
  	return map(lambda row: map(lambda * column: sum(map(mul, row, column))%1000,*m2) , m1) 
  	

def matrixExponent(m, pow):
	matrix = []
	for i in range(len(m)):
		matrix.append([])
		for j in range(len(m)):
			if (i==j):
				matrix[i].append(1)
			else:
				matrix[i].append(0)
	for i in range(pow):
		matrix = matrixMultiply(matrix, m)
	return matrix

def seq3(k, n, s, c):
	if (n<k+1):
		return s[n-1]
	rev = s[:: -1]
	m1 = []
	m2 = []
	m1.append(c)
	for i in xrange(k-1):
		m1.append([])
		m2.append([])
		m2[i].append(rev[i])
		for j in xrange(k):
			if (i==j):
				m1[i+1].append(1)
			else:
				m1[i+1].append(0)
	m2.append([])
	m2[k-1].append(rev[k-1])

	num = int(math.log((n-1), 2))
	num1 = int(math.log((n-1),2))
	matrixPow = []
	matrixPow.append(m1)
	for i in range(num):
		m1 = matrixExponent(m1, 2)
		matrixPow.append(m1)

	rem = int(n-1-math.pow(2, num))

	while(rem > 1):
		num = int(math.log(rem, 2))
		rem = int(rem-math.pow(2, num))
		for i in range(num1):
			if (i==num):
				m1=matrixMultiply(m1, matrixPow[i])	
	if (rem==1):
		m1 = matrixMultiply(m1, matrixPow[0])
	
	return matrixMultiply(m1, m2)[k-1][0]



index = map(int, raw_input().split())
a_seq = map(int, raw_input().split())
coeffs = map(int, raw_input().split())

print seq3(index[0], index[1]+1, a_seq, coeffs)
