echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
#modprobe uio_pci_generic
#dpdk-devbind.py --unbind --force 0000:00:09.0
#dpdk-devbind.py --unbind --force 0000:00:08.0
#dpdk-devbind.py --bind=uio_pci_generic 0000:00:09.0
#dpdk-devbind.py --bind=uio_pci_generic 0000:00:08.0
dpdk-devbind.py -s
