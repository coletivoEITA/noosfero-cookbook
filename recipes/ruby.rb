
case node[:noosfero][:ruby][:allocator]
when 'jemalloc'
  package 'libjemalloc1'
  node.set[:noosfero][:ruby][:env][:LD_PRELOAD] = `sh -c "ldconfig -p | grep jemalloc | cut -d' ' -f 4"`.split("\n").first
when 'tcmalloc'
  package 'libtcmalloc-minimal4'
  node.set[:noosfero][:ruby][:env][:LD_PRELOAD] = '/usr/lib/libtcmalloc_minimal.so.4'
end
