# Consistent Hashing

分布式缓存系统中，使用传统取模哈希在节点增减时会导致大量键重新映射，引发缓存雪崩。需要一种哈希方案使得节点变化只影响相邻键。

## Features

- 一致哈希环核心结构
- 添加/移除节点
- 虚拟节点（可配置副本数）
- 键到节点的映射
- 有界负载均衡（bounded loads）
- 完整的单元测试

## Installation

```bash
moon add hackathon/consistent_hash
```

## Quick Start

```moonbit nocheck
let ch = @consistent_hash.new(replicas=150)
ch.add_node("node1")
ch.add_node("node2")
ch.add_node("node3")
let node = ch.get_node("user:12345")
ch.remove_node("node2")
let node2 = ch.get_node("user:12345")
```

## Testing

```bash
moon test
```

## License

Apache-2.0
