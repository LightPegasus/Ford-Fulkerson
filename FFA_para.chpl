/*
 * Darrin Egan
 * 
 * Implementation of the Ford-Fulkerson Max Flow algorithm in the chapel language
 * Parallel
 */

use LinkedLists;
use Time;
use IO;
use List;
use BlockDist;
use DistributedBag;
use Set;

config var V: int = 6; // number of vertices in the graph
config var f: string;
var t: Timer;
var total_t: Timer;
var bfs_t: Timer;

/* Function that uses BFS algorithm to find a path from the source 's' to
 * sink 't' in the residual graph, and it stores the path in the parent array
 * 
 * Return: true if path from source to sink exists
 * reGraph: a residual matrix with its capacities
 * s: the source vertex
 * t: the sink vertex
 * parent: stores the path from source to sink
 */
proc bfs(resGraph: [], s: int, t: int, parent: [] int) 
{
  bfs_t.start(); //start timer
  
  var visited: [0..V-1] bool = false;
  var found: bool = false;
  
  visited[s] = true;
  parent[s] = -1; 
  var SetCurF = new DistBag(int, Locales); //Current Frontier
  var SetNextF = new DistBag(int, Locales); //Next Frontier
  SetCurF.add(s); //start with the root vertex

  while (!SetCurF.isEmpty()) {
    coforall loc in Locales with(ref SetNextF, ref found) { on loc {
      forall i in SetCurF with (ref found){
        if i.locale.id == loc.id {
          var SetNeighbor = new set(int);
          forall k in 0..V-1 with (ref SetNeighbor){ //Find all neighbors of i
            if (resGraph[i, k] > 0 && visited[k] == false) { //dont add zero (e.g. no connection)
              SetNeighbor.add(k);
            }
          }
          forall j in SetNeighbor with (ref found) {
            if (j == t) {
              parent[j] = i;
              found = true;
            }
            else {
              SetNextF.add(j);
              parent[j] = i;
              visited[j] = true;
            }
          }
        }
      }   
    }} //end of coforall and loc  
    SetCurF <=> SetNextF;
    SetNextF.clear();
  }
  return false;
}//End of bfs function

/* Function that implements the Ford-Fulkerson Max Flow algorithm
 * 
 * Return: the maxium flow from s to t
 * graph: an edge matrix that contains the capacities
 * s: source vertex
 * t: sink vertex
 */

proc FordFulkerson(resGraph: [], s: int, t: int) 
{ 
  // array that stores the path by BFS
  var parent: [0..V-1] int;
  var max_flow: int = 0; // no flow initially
  
  while (bfs(resGraph, s, t, parent)) {
    bfs_t.stop();
    // Find the minimum residual capacity of the edges
    var path_flow: int = max(int);
    var q = new list((int, int));  
    
    var v: int = t;
    while (v != s) {
      q.append((v, parent[v]));
      v = parent[v];
    }
    
    const Space = {0..q.size-1}; 
    var D = Space dmapped Block(Space);    
    var A: [D] (int, int) = q.toArray();
   
    forall i in A with (min reduce path_flow) do
      path_flow = min(path_flow, resGraph[i(1), i(0)]);
  
    // Update residual capacities of the edges and reverse edges along the path
    forall i in A with (ref resGraph) {
      resGraph[i(1), i(0)] -= path_flow;
      resGraph[i(0), i(1)] += path_flow;
    }

    // Add path flow to overall flow
    max_flow += path_flow;
    
  }
  return max_flow;
} //End of the FordFulkerson function

/* Function that reads from a file to store the capacities
 * 
 * Return: a matrix that contains the capacities from each vertex
 * graph: uninitialized matrix
 */
proc readFile(graph: []){
  var fp = open(f, iomode.r).reader();
  var arr: [0..V-1, 0..V-1] int;
  
  fp.read(arr);
  graph = arr; 

  fp.close();
} //End of readFile function

total_t.start();
var g: [0..V-1, 0..V-1] int;
 
readFile(g);

t.start();
var max_flow = FordFulkerson(g, 0, V-1);
t.stop();

total_t.stop();
writeln("The maximum possible flow is ", max_flow);
writeln("BFS algorithm: ", bfs_t.elapsed());
writeln("Ford-Fulkerson: ", t.elapsed());
writeln("For total time: ", total_t.elapsed());
