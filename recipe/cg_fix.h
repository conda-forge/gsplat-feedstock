#pragma once
#include <cooperative_groups.h>
namespace cooperative_groups {
    template<class Group> __device__ __forceinline__
    auto labeled_partition(const Group& g, unsigned int id) {
        return experimental::labeled_partition(g, id);
    }
}
