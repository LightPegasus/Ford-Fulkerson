/*
 * Darrin Egan
 *
 * Implementation of the Ford-Fulkerson Max Flow algorithm in the chapel language
 * Serially
 */

use LinkedLists;
use Time;
use IO;

config var V: int = 6; // number of vertices in the graph
config var f: string;
var t: Timer;
var total_t: Timer;

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
  var visited: [0..V-1] bool = false;
  var queue = new LinkedList(int);

  // add the source vertex to visited array and queue
  queue.append(s);
  visited[s] = true;
  parent[s] = -1;

  // BFS algorithm
  while (queue.size != 0) {
    var u = queue.pop_front();

    for i in 0..(V-1) {
      if (visited[i] == false && resGraph[u, i] > 0) {
        // If the path from source to sink exists,
        // then set its parent and return true
        if (i == t) {
          parent[i] = u;
          return true;
        }
	queue.append(i);
        parent[i] = u;
        visited[i] = true;
      }
    }
  }

  // Did not find path from source to sink
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
  var u, v: int;

  // array that stores the path by BFS
  var parent: [0..V-1] int;

  var max_flow: int = 0; // no flow initially

  while (bfs(resGraph, s, t, parent)) {
    // Find the minimum residual capacity of the edges
    var path_flow: int = max(int);
    v = t;
    while (v != s) {
      u = parent[v];
      path_flow = min(path_flow, resGraph[u, v]);
      v = parent[v];
    }
    
    // Update residual capacities of the edges and reverse edges along the path
    v = t;
    while (v != s) {
      u = parent[v];
      resGraph[u, v] -= path_flow;
      resGraph[v, u] += path_flow;
      v = parent[v];
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
  return graph;
} //End of readFile function
total_t.start();
var g: [0..V-1, 0..V-1] int;

g = readFile(g);

t.start();
var max_flow = FordFulkerson(g, 0, 5);
t.stop();

total_t.stop();
writeln("The maximum possible flow is ", max_flow);
writeln("Ford-Fulkerson: ", t.elapsed());
writeln("Total Time: ", total_t.elapsed());
