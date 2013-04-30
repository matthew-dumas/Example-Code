#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>

using namespace std; 

struct GNODE {             // structure to hold global node information
	int number;            // node number
	float x;               // node locations
	float y;
	float z; 
	bool type;             // false is fixed voltage, true is free
	float value;           // if false provide value
	int shared[6];         // elements the node is in/ max 6 for triangular
};

struct LNODE {            // local node structure for storing bookkeeping info
	int number;           // local number
	int globalnumber;     // corresponding global number
};

struct ELEMENT {          // For storing element data
	int number;           // element number
	LNODE N1;             // Nodes that makeup each element
	LNODE N2;
	LNODE N3; 
};


GNODE *test;         // Nodes under test (all of them)
ELEMENT *E ;         // elements in mesh 

float **stiffness;   // global stiffness matrix

bool CE(int);        // for making local C matricies
bool C();            // for making global c matrix
float WE(int , float ); // Not used--- for getting We
float VE( int , float , float  ); // Not used, for estimating V at a point (x,y)
float alpha(float , float , int , int ) ; // not used, weighting function for VE
bool GenerateMesh();                      // for generating a mesh in usable form, by hand
bool LoadMesh();                          // for loading my saved mesh
float** LoadC(int e);                     // for loading local C matricies 
bool NewNodes();                          // for saving solved data

int nodes = 0;                            // number of nodes
int elements = 0;                         // number of elements

float UNDEF = -999.999;                   // error values
int UNDEF2 = -1000; 

int main() { 
	
	int flag = 0;    // always need a flag of some sort 

	// Get the mesh information 

	cout << "How many elements are in the mesh?" << endl; 
	cin >> elements; 

	cout << "How many global nodes are there? " << endl; 
	cin >> nodes; 

	// make arrays of global nodes and elements

	test = new GNODE[nodes]; 
	E = new ELEMENT[elements]; 

	// load or make mesh?

	cout << "Load file, or make new file? (0 = load, 1=new) " << endl; 
	cin >> flag; 

	if (flag == 1) { 
		flag = 0; 
		GenerateMesh();
	} else { 
	   flag = 0; 
	    LoadMesh();
	}
  
	// Loop over elements to make local stiffness matrix

	for (int e=0; e < elements ; e++) { 
		if (!(CE(e))) { 
			cout << "Error creating local stiffness matrix: " << e <<  endl;
		}
	}

	// Generate global stiffness matrix

	if (!(C())) { 
		cout << "Error creating global stiffness matrix" << endl;
	}

	// variables for location data
	int *LOC; 
	int vnum=0; 
	int loop=0;


	// make location matrix for calculations
	LOC = new int[nodes]; 

	// set it to error values
	for(int i=0; i< nodes; i++) { 
		LOC[i] = -999;
	}

	// find out how many free nodes there are
	for (int e=0; e < nodes ; e++) { 
		if (test[e].type) { 
			LOC[loop] = e;       // note free node global number
			test[e].value = 0;   // assume free nodes are 0
			loop++;              // independant looping for areas of interest
		}
	}

	// get ready to sum, and do a total number of loops for accuracy
	float sum = 0;
	int total_loops = 1000;     // tremendous overkill, but why not?

	while ((total_loops > 0) ) {      // iteratively solve the matrix equation 

		for (int vv = 0; vv < nodes; vv++) {        // select the node to solve this time
           if (LOC[vv] > 0) {                       // if it's not an error node
				for (int i = 0; i < nodes; i++) {   // then do the sum. 
					if ( i != LOC[vv]) { 
						sum += test[i].value * stiffness[LOC[vv]][i]; 
					}
				}
				test[LOC[vv]].value = -(1/(stiffness[LOC[vv]][LOC[vv]]))*sum;  // weight the sum
				sum=0;                                                         // reset sum for new node
				total_loops--;
			}
		}
	}

	cout << "Saving new nodes file..." << endl; 

	// save the solution nodal file with all voltages and which nodes were free
	if (NewNodes()) { 
		cout << "Save Successful!" << endl; 
	} else {
		cout << "Failed to save solved file." << endl;
	}

	// output the solutions to screen so you can see them
	for (int e=0; e < nodes ; e++) {
		cout << "Node " << test[e].number << " -> " << test[e].value << " Volts" << endl;
	}

	// pause
	system("pause"); 

	return 0; 
}

bool NewNodes() { 
			ofstream file; 
			file.open("solved.txt",ios::out); // open a solution file

			// if solution file opened fine, output using * delimiters
			if (file.is_open()) { 
           		for(int i = 0; i < nodes ;i++) {
					file << (int)test[i].number << "*" << (bool)test[i].type << "*" ; 
					file << (float)test[i].value << "*" ;
					file << (float)test[i].x << "*" << (float)test[i].y << "*" << (float)test[i].z << "*";

					for (int ii=0; ii<6;ii++) {
						file <<	test[i].shared[ii] << "*";
					}

					file << endl;
				}

			} else {
				cout << "Error Opening Node File!" << endl; 
				return false;
			}

			file.close(); 
			
			return true;
}

bool C() { 
	int ln[3];    // for storing local node numbers
	int gn[3];    // for storing global node numbers
	
	float **c;    // to get C matricies for elements

	c = new float*[3];  //dynamically make it a 3 by 3

	for (int i=0; i<3; i++) {
		c[i] = new float[3]; 
	}

    // make the global stiffness matrix and set it to 0
	stiffness = new float*[nodes]; 

	for( int i=0; i<nodes; i++) { 
		stiffness[i] = new float[nodes]; 
		for(int j=0; j<nodes;j++) { 
			stiffness[i][j] = 0;
		}
	}

	// loop over the elements
	   for (int ee = 0; ee < elements ;ee++) { 
			c = LoadC(ee);                  // load C for the element
		
			ln[0] = E[ee].N1.number;        // get the node numbers
			gn[0] = E[ee].N1.globalnumber;

			ln[1] = E[ee].N2.number;
			gn[1] = E[ee].N2.globalnumber;

			ln[2] = E[ee].N3.number;
			gn[2] = E[ee].N3.globalnumber;

			// add the effect of this element to the corresponding global C values
			for (int i = 0; i < 3; i++) {
				for (int j = 0; j < 3; j++) {
					stiffness[gn[i]-1][gn[j]-1] +=  c[ln[i]-1][ln[j]-1];
				}
			}

	}

	   // output the global c in a csv file for easy checking in excel
		ofstream file; 
		file.open("C.csv", ios::out); 

		if (file.is_open()) { 
			for(int i=0; i < nodes; i++) { 
				for (int j = 0; j < nodes; j++) { 
					file << stiffness[i][j] << ","; 
				}
				file << endl; 
			}
			
			file.close(); 
		} else { 
			cout << "Error writing stiffness matrix" << endl; 
			return false; 
		} 

	return true; 
}

float** LoadC(int e) { 
	float **c; 

	// make a matrix to hold local c
	c = new float*[3]; 

	for (int i=0; i<3; i++) {
		c[i] = new float[3]; 
	}

	// make a character matrix to hold file name
	char t[30]; 
	// convert file name from number to string
	itoa(e,t,10); 

	// open file
	FILE * pFile;
	pFile = fopen (t,"r");

	// if file is open, output in space delimited file
	if ( pFile != 0) {
		for (int i = 0; i<3;i++) {
			fscanf( pFile, "%f %f %f", &c[i][0], &c[i][1], &c[i][2]); 
		}

		fclose(pFile);
	} else { 
		cout << "Error reading Ce number: " << e << endl; 
	}

	return c;  // return C matrix for use
}

bool LoadMesh() { 
	        int flag = 0;
	        ifstream file; 
			file.open("Nodes2.txt",ios::in); 
			string r; 
			size_t l = 0; 
			size_t p = 0;

			// open mesh file using streams
			// if open, get data at pointer
			//   then increment pointer and repeat
			//    until end of file
			if (file.is_open()) { 
           		for(int i = 0; i < nodes ;i++) {
					getline(file, r); 
					
					l = 0;
					p = 0;
					
					l = r.find("*",l+1);
					if (l!=string::npos){
						test[i].number = atoi(r.substr(p,l).c_str()); 
					}
				 
					p=l; 
			
					l = r.find("*",p+1);
					if (l!=string::npos){
						if (atoi(r.substr(p+1,l).c_str()) == 1){
							test[i].type = true;
						} else { 
							test[i].type = false;
						}
					}
					
					p=l; 
					
					if (test[i].type == false) {
					   l = r.find("*",p+1);
					   if (l!=string::npos){
					   	   test[i].value = atof(r.substr(p+1,l).c_str()); 
					   }
				
					   p=l;
					} else { 
						test[i].value = UNDEF;
					}
					 
					l = r.find("*",p+1);
					if (l!=string::npos){
						test[i].x = atof(r.substr(p+1,l).c_str()); 
					}
					p=l; 
	
					l = r.find("*",p+1);
					if ((l)!=string::npos){
						test[i].y = atof(r.substr(p+1,l).c_str()); 
					}
					
					p=l;
				
					
					l = r.find("*",p+1);
					if ((l)!=string::npos){
						test[i].z = atof(r.substr(p+1,l).c_str()); 
					}
				
					p=l;

					l = r.find("*",p+1);
					if ((l)!=string::npos){
						test[i].shared[0] = atoi(r.substr(p+1,l).c_str()); 
					}
				
					p=l;

					l = r.find("*",p+1);
					if ((l)!=string::npos){
						test[i].shared[1] = atoi(r.substr(p+1,l).c_str()); 
					}
					
					p=l;

					l = r.find("*",p+1);
					if ((l)!=string::npos){
						test[i].shared[2] = atoi(r.substr(p+1,l).c_str()); 
					}
			
					p=l;

					l = r.find("*",p+1);
					if ((l)!=string::npos){
						test[i].shared[3] = atoi(r.substr(p+1,l).c_str()); 
					}
				
					p=l;

					l = r.find("*",p+1);
					if ((l)!=string::npos){
						test[i].shared[4] = atoi(r.substr(p+1,l).c_str()); 
					}
				
					
					p=l;
					test[i].shared[5] = atoi(r.substr(p+1,r.length()).c_str()); 
		
				}

			} else {
				cout << "Error Opening Node File!" << endl; 
			}

			file.close(); 


			// repeat comment above, except for elements this time
			file.open("elements2.txt",ios::in);

			if (file.is_open()) { 
           		for(int i = 0; i <= elements-1;i++) {
					getline(file, r); 
					
					l = 0;
					p = 0;
					
					l = r.find("*",l+1);
					
					if (l!=string::npos){
						E[i].number = atoi(r.substr(p,l).c_str()); 
					}
					p = l+1; 

					l = r.find("*",p);
					if (l!=string::npos){
						E[i].N1.number = atoi(r.substr(p,l).c_str()); 
					}
					p = l+1; 

					l = r.find("*",p);
					if (l!=string::npos){
						E[i].N1.globalnumber = atoi(r.substr(p,l).c_str()); 
					}
					p = l+1; 

					l = r.find("*",p);
					if (l!=string::npos){
						E[i].N2.number = atoi(r.substr(p,l).c_str()); 
					}
					p = l+1; 

					l = r.find("*",p);
					if (l!=string::npos){
						E[i].N2.globalnumber = atoi(r.substr(p,l).c_str()); 
					}
					p = l+1; 

					l = r.find("*",p);
					if (l!=string::npos){
						E[i].N3.number = atoi(r.substr(p,l).c_str()); 
					}
					p = l+1; 

			    	E[i].N3.globalnumber = atoi(r.substr(p,r.length()).c_str()); 
			}
			} else {
				cout << "Error Opening Node File!" << endl; 
			}

			file.close(); 
			flag = 0;
			return true; 
}

bool GenerateMesh() { 
	/* This function prompts the user for mesh information. 
	   It takes it in in the form of coordinates per global node.
	   Then it saves that information in the node array. 

	   After that, it asks for information on how the local nodes of each element work
	    with the global nodes. It saves that in that structure. 

	   Finally, it asks the user to save the data. And will save in * delimited file
	   */


	int flag = 0; 
	int num[6];

		for(int i = 0; i < nodes ;i++) {
			test[i].number = i+1; 

			cout << "Enter X coord of global node " << i+1 << ": ";
			cin >> test[i].x; 

			cout << "Enter Y coord of global node " << i+1 << ": ";
			cin >> test[i].y; 
		
			cout << "Enter Z coord of global node " << i+1 << ": ";
			cin >> test[i].z; 
		
			while (flag != 1) { 
				int val = -99; 
				cout << "Is node "<< i+1 << " a fixed (0) or free node (1): ";
				cin >> val; 

				if (val == 0 || val == 1) { 
					if (val == 0) {
						test[i].type = false;
					} else { 
						test[i].type = true;
					}
					flag = 1; 
				} else { 
					cout << "Invalid value" << endl; 
				}

				if (val == 0) { 
					cout << "What is the voltage at the node? " << endl; 
					cin >> test[i].value; 
				} else { 
					test[i].value=UNDEF; 
				}
			}
			flag = 0; 

		}

		for(int i = 0; i <= elements-1;i++) {
			E[i].number = i+1;

			cout << "Enter First Node of Element " << i+1 << ": ";
			cin >> E[i].N1.globalnumber;
			E[i].N1.number = 1;

			cout << "Enter Second Node of Element " << i+1 << ": ";
			cin >> E[i].N2.globalnumber;
			E[i].N2.number = 2;
		
			cout << "Enter Third Node of Element " << i+1 << ": ";
			cin >> E[i].N3.globalnumber;
			E[i].N3.number = 3;	
		}

		int f=0;
     for (int n = 0; n < nodes-1; n++) {
		 f=0;
	   for( int i = 0; i<elements-1;i++) { 
	    	if ( test[i].number == n ) { 
			   num[f] = test[i].number; 
			   f++;
			}

		    for (int a = f; a < 6; a++) { 
				num[a]= UNDEF;
			}

			for (int ii = 0; ii< 6; ii++) {
			    test[i].shared[ii] = num[ii];
			}
     	}
	 }


		flag = 0; 
		cout << "Would you like to save the mesh now? (0 = no, 1 = yes)" << endl; 
		cin >> flag; 

		if (flag == 1) { 
			cout << "Saving, please hold...." << endl; 

			ofstream file; 
			file.open("Nodes.txt",ios::out); 

			if (file.is_open()) { 
           		for(int i = 0; i < nodes ;i++) {
					file << (int)test[i].number << "*" << (bool)test[i].type << "*" ; 
					if (test[i].type == false) { 
						file << (float)test[i].value << "*" ;
					}
					file << (float)test[i].x << "*" << (float)test[i].y << "*" << (float)test[i].z << "*";

					for (int ii=0; ii<6;ii++) {
						file <<	test[i].shared[ii] << "*";
					}

					file << endl;
				}

			} else {
				cout << "Error Opening Node File!" << endl; 
			}

			file.close(); 

			file.open("elements.txt",ios::out);

			if (file.is_open()) { 
           		for(int i = 0; i <= elements-1;i++) {
					file << E[i].number << "*" << E[i].N1.number << "*" << E[i].N1.globalnumber << "*" << E[i].N2.number << "*" << E[i].N2.globalnumber << "*" << E[i].N3.number << "*" << E[i].N3.globalnumber << endl;
				}

			} else {
				cout << "Error Opening Node File!" << endl; 
			}

			file.close(); 
			flag = 0;

		}
		return true;
}

float WE(int e, float epsilon) { // e is element number, epsilon = permittivity 

	// not used. 


	float we = 0; 

	int node[3];

	node[0] = E[e].N1.globalnumber; 
	node[1] = E[e].N2.globalnumber; 
	node[2] = E[e].N3.globalnumber; 

	for (int i=1; i<=3; i++) { 
		for (int j=1; j<=3; j++) { 
			we += VE(e, test[i-1].x, test[i-1].y)*CE(e)*VE(e, test[j-1].x, test[j-1].y); 
		}
	}

	we = we * .5 * epsilon; 

	return we; 
}

bool CE(int e) { 
    int n1,n2,n3; 
	GNODE N1, N2, N3; 
	float p[3],q[3];
	float c[3][3]; 
	char t[30];

	// get the global number for each node in element

	n1 = E[e].N1.globalnumber-1;
	n2 = E[e].N2.globalnumber-1;
	n3 = E[e].N3.globalnumber-1;

	// reduce the structure size for convenience
	N1 = test[n1];
	N2 = test[n2];
	N3 = test[n3];

	// set P and Q initials to 0
	for (int i = 0; i < 3; i++) { 
		p[i] = 0;
		q[i] = 0;
	}

	// Get P and Q values
	p[0] = N2.y-N3.y; 
	p[1] = N3.y-N1.y; 
	p[2] = N1.y-N2.y; 

	q[0] = N3.x-N2.x; 
	q[1] = N1.x-N3.x; 
	q[2] = N2.x-N1.x; 

	float A = 0; // initialize area
	
	A = .5*( (p[1]*q[2])-(p[2]*q[1])); // get area

	// open file to save this local C matrix as element number
	itoa(e,t,10);
	ofstream file; 
	file.open(t,ios::out); 

	// if successfully opened, save it as space delimited
	if (file.is_open()) { 

		for (int i=0;i< 3;i++) { 
			for (int j=0;j< 3 ;j++) { 
				c[i][j] = (1/(4*A)) * ( (p[i]*p[j]) + (q[i]*q[j]));
				file << c[i][j] << " ";
			}
			file << endl;
		}
		
		file.close(); 

	} else {

				cout << "Error Opening C " << t <<  " File! " << endl; 
				return false;
	}
	

	return true;
}

float VE( int e, float x, float y ) {  // e is element number, x and y are locations to find voltage (the nodes!) 
	float sum = 0; 
	int n[3];
	n[0] = E[e].N1.globalnumber;
	n[1] = E[e].N2.globalnumber;
	n[2] = E[e].N3.globalnumber;

	for (int i = 1; i<=3; i++) { 
		sum += alpha( x, y, i, e)* test[n[i-1]].value; 
	}

	return sum; 
}

float alpha(float x, float y, int i, int e) {   // x and y are the points within the element that we want the potential, i is looped 1-3
	int n1,n2,n3; 
	GNODE N1, N2, N3; 
	float alp=0; 

	n1 = E[e].N1.globalnumber;
	n2 = E[e].N2.globalnumber;
	n3 = E[e].N3.globalnumber;

	N1 = test[n1];
	N2 = test[n2];
	N3 = test[n3];

	float A = .5*( (N2.x-N1.x)*(N3.y-N1.y) - (N3.x - N1.x)*(N2.y-N1.y));

	switch(i) { 
		case 1: 
			alp = (1/(2*A))*((N2.x*N3.y-N3.x*N2.y)+(N2.y-N3.y)*x+(N3.x-N2.x)*y);
			break; 
		case 2: 
			alp = (1/(2*A))*((N3.x*N1.y-N1.x*N3.y)+(N3.y-N1.y)*x+(N1.x-N3.x)*y);
			break; 
		case 3: 
			alp = (1/(2*A))*((N1.x*N2.y-N2.x*N1.y)+(N1.y-N2.y)*x+(N2.x-N1.x)*y);
			break;
		default: 
			break; 
	}

	return alp;

}
