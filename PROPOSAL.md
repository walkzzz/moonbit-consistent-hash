# Consistent Hashing - Project Proposal

## Hackathon Direction

Web 与网络基础设施

## Problem Statement

分布式缓存系统中，使用传统取模哈希在节点增减时会导致大量键重新映射，引发缓存雪崩。需要一种哈希方案使得节点变化只影响相邻键。

## Solution

实现一致哈希算法，支持虚拟节点（replicas）和有界负载（bounded loads）。当节点增减时，只有该节点负责的键需要迁移，最小化数据移动。

## Scope (In)

- 一致哈希环核心结构
- 添加/移除节点
- 虚拟节点（可配置副本数）
- 键到节点的映射
- 有界负载均衡（bounded loads）
- 完整的单元测试

## Scope (Out)

- 网络通信层（纯算法实现）
- 实际缓存存储
- 节点健康检查/故障转移

## Differentiation from Existing Ecosystem

mooncakes.io 上有 moonshardkit（1个），但本项目专注虚拟节点+有界负载算法的完整实现和文档化，边界更清晰。

## Milestones

- M1: 哈希环和节点添加/移除
- M2: 虚拟节点支持
- M3: 键路由逻辑
- M4: 有界负载均衡
- M5: 完整测试套件（含节点增减场景）

## API Preview

```moonbit
let ch = @consistent_hash.new(replicas=150)
ch.add_node("node1")
ch.add_node("node2")
ch.add_node("node3")
let node = ch.get_node("user:12345")
ch.remove_node("node2")
let node2 = ch.get_node("user:12345")
```

## Testing Plan

- Unit tests for all public API functions
- Edge case tests (empty input, single element, maximum size)
- Property-based tests where applicable
- Performance benchmarks for key operations

## License

Apache-2.0
