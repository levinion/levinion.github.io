header

```cpp
#pragma once

#include <cstddef>
#include <cstdint>
#include <functional>

using uint128_t = __uint128_t;

namespace ura {
struct UINT128_T_Hash {
  size_t operator()(const __uint128_t& val) const {
    const uint64_t hp = static_cast<uint64_t>(val >> 64);
    const uint64_t lp = static_cast<uint64_t>(val);
    const std::hash<uint64_t> hasher;
    return hasher(hp) ^ hasher(lp);
  }
};
} // namespace ura

```

```cpp
std::unordered_map<uint128_t, std::any, UINT128_T_Hash> cache;
```