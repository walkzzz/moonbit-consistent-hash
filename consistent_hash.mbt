///|
fn hash_str(s : String) -> Int {
  let mut hash = -2128831035
  for i = 0; i < s.length(); i = i + 1 {
    hash = hash ^ s[i].to_int()
    hash = hash * 16777619
  }
  hash & 0x7FFFFFFF
}

///|
struct VirtualNode {
  hash : Int
  node : String
}

///|
pub struct ConsistentHash {
  replicas : Int
  nodes : Set[String]
  mut ring : Array[VirtualNode]
}

///|
pub fn ConsistentHash::new(replicas : Int) -> ConsistentHash {
  ConsistentHash::{ replicas, nodes: Set([]), ring: [] }
}

///|
fn ConsistentHash::sort_ring(self : ConsistentHash) -> Unit {
  self.ring.sort_by(fn(a, b) { compare(a.hash, b.hash) })
}

///|
fn ConsistentHash::binary_search(self : ConsistentHash, hash : Int) -> Int {
  let mut lo = 0
  let mut hi = self.ring.length()
  while lo < hi {
    let mid = (lo + hi) / 2
    if self.ring[mid].hash < hash {
      lo = mid + 1
    } else {
      hi = mid
    }
  }
  lo
}

///|
pub fn ConsistentHash::add_node(self : ConsistentHash, node : String) -> Unit {
  if self.nodes.contains(node) {
    return
  }
  self.nodes.add(node)
  for i = 0; i < self.replicas; i = i + 1 {
    let vnode_key = node + "#" + i.to_string()
    self.ring.push(VirtualNode::{ hash: hash_str(vnode_key), node })
  }
  self.sort_ring()
}

///|
pub fn ConsistentHash::remove_node(
  self : ConsistentHash,
  node : String,
) -> Unit {
  if !self.nodes.contains(node) {
    return
  }
  self.nodes.remove(node)
  let new_ring : Array[VirtualNode] = []
  for vn in self.ring {
    if vn.node != node {
      new_ring.push(vn)
    }
  }
  self.ring = new_ring
}

///|
pub fn ConsistentHash::get(self : ConsistentHash, key : String) -> String? {
  if self.ring.length() == 0 {
    return None
  }
  let hash = hash_str(key)
  let idx = self.binary_search(hash)
  let actual_idx = if idx >= self.ring.length() { 0 } else { idx }
  Some(self.ring[actual_idx].node)
}

///|
pub fn ConsistentHash::get_replicas(
  self : ConsistentHash,
  key : String,
  count : Int,
) -> Array[String] {
  if self.ring.length() == 0 || count <= 0 {
    return []
  }
  let hash = hash_str(key)
  let mut idx = self.binary_search(hash)
  if idx >= self.ring.length() {
    idx = 0
  }
  let result : Array[String] = []
  let mut added = 0
  let mut i = idx
  while added < count && result.length() < self.nodes.length() {
    if i >= self.ring.length() {
      i = 0
    }
    let node = self.ring[i].node
    let mut found = false
    for n in result {
      if n == node {
        found = true
      }
    }
    if !found {
      result.push(node)
      added = added + 1
    }
    i = i + 1
  }
  result
}

///|
pub fn ConsistentHash::node_count(self : ConsistentHash) -> Int {
  self.nodes.length()
}

///|
pub fn ConsistentHash::virtual_node_count(self : ConsistentHash) -> Int {
  self.ring.length()
}

///|
pub fn ConsistentHash::get_nodes(self : ConsistentHash) -> Array[String] {
  let result : Array[String] = []
  for node in self.nodes {
    result.push(node)
  }
  result
}

///|
pub fn ConsistentHash::distribution(
  self : ConsistentHash,
  keys : Array[String],
) -> Map[String, Int] {
  let result : Map[String, Int] = Map([])
  for key in keys {
    match self.get(key) {
      Some(node) => {
        let current = match result.get(node) {
          Some(v) => v
          None => 0
        }
        result[node] = current + 1
      }
      None => ()
    }
  }
  result
}
