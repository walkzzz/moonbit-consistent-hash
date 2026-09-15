// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "hackathon/consistent_hash"

version = "0.1.0"

readme = "README.mbt.md"

repository = ""

license = "Apache-2.0"

keywords = [
  "consistent-hashing",
  "distributed",
  "virtual-nodes",
  "bounded-loads",
]

preferred_target = "wasm"

description = "Consistent hashing with virtual nodes and bounded loads for distributed cache and CDN routing."
