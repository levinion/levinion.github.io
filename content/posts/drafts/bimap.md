
```cpp
#include <unordered_map>
#include <optional>

template<typename A, typename B>
class Bimap {
public:
  void store(A a, B b) {
    map1[a] = b;
  }

  void store(B b, A a) {
    map2[b] = a;
  }

  std::optional<B> load(A a) {
    if (map1.contains(a))
      return map1[a];
    return {};
  }

  std::optional<A> load(B b) {
    if (map2.contains(b))
      return map2[b];
    return {};
  }

private:
  std::unordered_map<A, B> map1;
  std::unordered_map<B, A> map2;
};

```