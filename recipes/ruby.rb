
if node[:noosfero][:ruby][:use_tcmalloc]
  package 'libtcmalloc-minimal4'
  node.set[:noosfero][:ruby][:env][:LD_PRELOAD] = '/usr/lib/libtcmalloc_minimal.so.4'
end
