# ZFS installation example

## How to use
1. Run command
`vagrant up server`
If comand completed with error, just run `vagrant up server` again
```
A customization command failed:

["storagectl", :id, "--name", "SATA Controller", "--add", "sata"]
```
2.  `vagrant ssh server`
3. Check that disks was added
```
lsblk
sdb      8:16   0    1G  0 disk
sdc      8:32   0    1G  0 disk
sdd      8:48   0    1G  0 disk
sde      8:64   0    1G  0 disk
sdf      8:80   0    1G  0 disk
sdg      8:96   0    1G  0 disk
```
4. check that file system successfully installed 'zfs version'
5. Try to create new pool `zpool create mypool sdb sdc`
6. Verify output
   ` zpool list`
   `zpool status`
    
