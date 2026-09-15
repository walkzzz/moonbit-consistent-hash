// Benchmarks for consistent_hash

///|
test "bench_add_nodes_10" {
  let ch = ConsistentHash::new(150)
  for i = 0; i < 10; i = i + 1 {
    ch.add_node("node_" + i.to_string())
  }
}

///|
test "bench_add_nodes_50" {
  let ch = ConsistentHash::new(150)
  for i = 0; i < 50; i = i + 1 {
    ch.add_node("node_" + i.to_string())
  }
}

///|
test "bench_get_10000_keys" {
  let ch = ConsistentHash::new(150)
  for i = 0; i < 10; i = i + 1 {
    ch.add_node("node_" + i.to_string())
  }
  for i = 0; i < 10000; i = i + 1 {
    let _ = ch.get("key_" + i.to_string())
  }
}

///|
test "bench_get_10000_keys_50_nodes" {
  let ch = ConsistentHash::new(150)
  for i = 0; i < 50; i = i + 1 {
    ch.add_node("node_" + i.to_string())
  }
  for i = 0; i < 10000; i = i + 1 {
    let _ = ch.get("key_" + i.to_string())
  }
}

///|
test "bench_remove_and_get" {
  let ch = ConsistentHash::new(150)
  for i = 0; i < 20; i = i + 1 {
    ch.add_node("node_" + i.to_string())
  }
  for i = 0; i < 10; i = i + 1 {
    ch.remove_node("node_" + i.to_string())
  }
  for i = 0; i < 5000; i = i + 1 {
    let _ = ch.get("key_" + i.to_string())
  }
}

///|
test "bench_distribution_10000" {
  let ch = ConsistentHash::new(150)
  for i = 0; i < 10; i = i + 1 {
    ch.add_node("node_" + i.to_string())
  }
  let keys : Array[String] = []
  for i = 0; i < 10000; i = i + 1 {
    keys.push("key_" + i.to_string())
  }
  let _ = ch.distribution(keys)
}

///|
test "bench_get_replicas_10000" {
  let ch = ConsistentHash::new(150)
  for i = 0; i < 10; i = i + 1 {
    ch.add_node("node_" + i.to_string())
  }
  for i = 0; i < 10000; i = i + 1 {
    let _ = ch.get_replicas("key_" + i.to_string(), 3)
  }
}
