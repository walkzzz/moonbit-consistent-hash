// Whitebox tests for consistent_hash

///|
test "empty_ring_get" {
  let ch = ConsistentHash::new(10)
  assert_true(ch.get("key1") is None)
}

///|
test "single_node" {
  let ch = ConsistentHash::new(10)
  ch.add_node("node1")
  assert_eq(ch.get("key1"), Some("node1"))
  assert_eq(ch.get("key2"), Some("node1"))
  assert_eq(ch.get("any_key"), Some("node1"))
}

///|
test "multiple_nodes" {
  let ch = ConsistentHash::new(150)
  ch.add_node("node1")
  ch.add_node("node2")
  ch.add_node("node3")
  let result = ch.get("user:12345")
  assert_true(result is Some(_))
  let node = match result {
    Some(n) => n
    None => ""
  }
  assert_true(node == "node1" || node == "node2" || node == "node3")
}

///|
test "remove_node" {
  let ch = ConsistentHash::new(150)
  ch.add_node("node1")
  ch.add_node("node2")
  ch.add_node("node3")
  assert_eq(ch.node_count(), 3)
  ch.remove_node("node2")
  assert_eq(ch.node_count(), 2)
  let result = ch.get("user:12345")
  match result {
    Some(node) => assert_true(node != "node2")
    None => assert_true(false)
  }
}

///|
test "add_duplicate_node" {
  let ch = ConsistentHash::new(10)
  ch.add_node("node1")
  ch.add_node("node1")
  assert_eq(ch.node_count(), 1)
  assert_eq(ch.virtual_node_count(), 10)
}

///|
test "remove_nonexistent_node" {
  let ch = ConsistentHash::new(10)
  ch.add_node("node1")
  ch.remove_node("node2")
  assert_eq(ch.node_count(), 1)
}

///|
test "node_count" {
  let ch = ConsistentHash::new(10)
  assert_eq(ch.node_count(), 0)
  ch.add_node("a")
  ch.add_node("b")
  ch.add_node("c")
  assert_eq(ch.node_count(), 3)
}

///|
test "virtual_node_count" {
  let ch = ConsistentHash::new(150)
  ch.add_node("node1")
  assert_eq(ch.virtual_node_count(), 150)
  ch.add_node("node2")
  assert_eq(ch.virtual_node_count(), 300)
}

///|
test "get_nodes" {
  let ch = ConsistentHash::new(10)
  ch.add_node("a")
  ch.add_node("b")
  ch.add_node("c")
  let nodes = ch.get_nodes()
  assert_eq(nodes.length(), 3)
}

///|
test "get_replicas" {
  let ch = ConsistentHash::new(150)
  ch.add_node("node1")
  ch.add_node("node2")
  ch.add_node("node3")
  let replicas = ch.get_replicas("key1", 2)
  assert_eq(replicas.length(), 2)
  // Should be different nodes
  assert_true(replicas[0] != replicas[1])
}

///|
test "get_replicas_more_than_nodes" {
  let ch = ConsistentHash::new(150)
  ch.add_node("node1")
  ch.add_node("node2")
  let replicas = ch.get_replicas("key1", 5)
  assert_eq(replicas.length(), 2)
}

///|
test "distribution" {
  let ch = ConsistentHash::new(150)
  ch.add_node("node1")
  ch.add_node("node2")
  ch.add_node("node3")
  let keys : Array[String] = []
  for i = 0; i < 300; i = i + 1 {
    keys.push("key_" + i.to_string())
  }
  let dist = ch.distribution(keys)
  // Each node should get some keys
  assert_true(dist.get("node1").unwrap_or(0) > 0)
  assert_true(dist.get("node2").unwrap_or(0) > 0)
  assert_true(dist.get("node3").unwrap_or(0) > 0)
  // Total should equal number of keys
  let total = dist.get("node1").unwrap_or(0) +
    dist.get("node2").unwrap_or(0) +
    dist.get("node3").unwrap_or(0)
  assert_eq(total, 300)
}

///|
test "consistency_same_key" {
  let ch = ConsistentHash::new(150)
  ch.add_node("node1")
  ch.add_node("node2")
  ch.add_node("node3")
  // Same key should always map to same node
  let r1 = ch.get("my_key")
  let r2 = ch.get("my_key")
  let r3 = ch.get("my_key")
  assert_eq(r1, r2)
  assert_eq(r2, r3)
}

///|
test "minimal_relocation" {
  let ch = ConsistentHash::new(150)
  ch.add_node("node1")
  ch.add_node("node2")
  ch.add_node("node3")
  let keys : Array[String] = []
  for i = 0; i < 100; i = i + 1 {
    keys.push("key_" + i.to_string())
  }
  // Record original mapping
  let original : Map[String, String] = Map([])
  for key in keys {
    match ch.get(key) {
      Some(node) => original[key] = node
      None => ()
    }
  }
  // Add a new node
  ch.add_node("node4")
  // Count how many keys moved
  let mut moved = 0
  for key in keys {
    match ch.get(key) {
      Some(new_node) =>
        match original.get(key) {
          Some(old_node) => if old_node != new_node { moved = moved + 1 }
          None => ()
        }
      None => ()
    }
  }
  // With consistent hashing, most keys should stay
  // Only about 1/4 should move (the ones that were on node4's portion)
  assert_true(moved < 50)
}
