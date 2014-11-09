default[:noosfero][:ruby] = {}

default[:noosfero][:ruby][:env] = {
  RUBY_GC_MALLOC_LIMIT: 90000000,
  # don't really help
  #RUBY_HEAP_SLOTS_GROWTH_FACTOR: 1.25,
  #RUBY_HEAP_MIN_SLOTS: 800000,
  #RUBY_FREE_MIN: 600000,
}

default[:noosfero][:ruby][:allocator] = 'jemalloc'

