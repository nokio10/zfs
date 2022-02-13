# ZFS 

## Определение наилучшего алгоритма сжатия
```
[vagrant@server ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   64G  0 disk
|-sda1   8:1    0  2.1G  0 part [SWAP]
`-sda2   8:2    0 61.9G  0 part /
sdb      8:16   0    1G  0 disk
sdc      8:32   0    1G  0 disk
sdd      8:48   0    1G  0 disk
sde      8:64   0    1G  0 disk
sdf      8:80   0    1G  0 disk
sdg      8:96   0    1G  0 disk
sdh      8:112  0    1G  0 disk
sdi      8:128  0    1G  0 disk
[root@server ~]# zpool create otus1 mirror /dev/sdb /dev/sdc
[root@server ~]# zpool create otus2 mirror /dev/sdd /dev/sde
[root@server ~]# zpool create otus3 mirror /dev/sdf /dev/sdg
[root@server ~]#  zpool create otus4 mirror /dev/sdh /dev/sdi
[root@server ~]# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   960M   105K   960M        -         -     0%     0%  1.00x    ONLINE  -
otus2   960M   105K   960M        -         -     0%     0%  1.00x    ONLINE  -
otus3   960M   105K   960M        -         -     0%     0%  1.00x    ONLINE  -
otus4   960M   105K   960M        -         -     0%     0%  1.00x    ONLINE  -
[root@server ~]# zfs set compression=lzjb otus1
[root@server ~]# zfs set compression=lz4 otus2
[root@server ~]# zfs set compression=gzip-9 otus3
[root@server ~]# zfs set compression=zle otus4
[root@server ~]# zfs get all | grep compression
otus1  compression           lzjb                   local
otus2  compression           lz4                    local
otus3  compression           gzip-9                 local
otus4  compression           zle                    local
[root@server ~]# for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
--2022-02-13 14:56:00--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40784369 (39M) [text/plain]
Saving to: '/otus1/pg2600.converter.log'

pg2600.converter.log          100%[=================================================>]  38.89M  6.67MB/s    in 14s

2022-02-13 14:56:15 (2.72 MB/s) - '/otus1/pg2600.converter.log' saved [40784369/40784369]

--2022-02-13 14:56:15--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40784369 (39M) [text/plain]
Saving to: '/otus2/pg2600.converter.log'

pg2600.converter.log          100%[=================================================>]  38.89M  7.40MB/s    in 6.2s

2022-02-13 14:56:22 (6.30 MB/s) - '/otus2/pg2600.converter.log' saved [40784369/40784369]

--2022-02-13 14:56:22--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40784369 (39M) [text/plain]
Saving to: '/otus3/pg2600.converter.log'

pg2600.converter.log          100%[=================================================>]  38.89M  4.71MB/s    in 8.7s

2022-02-13 14:56:31 (4.47 MB/s) - '/otus3/pg2600.converter.log' saved [40784369/40784369]

--2022-02-13 14:56:31--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 40784369 (39M) [text/plain]
Saving to: '/otus4/pg2600.converter.log'

pg2600.converter.log          100%[=================================================>]  38.89M  7.70MB/s    in 6.2s

2022-02-13 14:56:38 (6.26 MB/s) - '/otus4/pg2600.converter.log' saved [40784369/40784369]

[root@server ~]# ls -l /otus*
/otus1:
total 22015
-rw-r--r--. 1 root root 40784369 Feb  2 09:01 pg2600.converter.log

/otus2:
total 17970
-rw-r--r--. 1 root root 40784369 Feb  2 09:01 pg2600.converter.log

/otus3:
total 10948
-rw-r--r--. 1 root root 40784369 Feb  2 09:01 pg2600.converter.log

/otus4:
total 31406
-rw-r--r--. 1 root root 40784369 Feb  2 09:01 pg2600.converter.log
[root@server ~]# zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
otus1  21.6M   810M     21.5M  /otus1
otus2  17.7M   814M     17.6M  /otus2
otus3  10.8M   821M     10.7M  /otus3
otus4  39.1M   793M     38.9M  /otus4
[root@server ~]#  zfs get all | grep compressratio | grep -v ref
otus1  compressratio         1.81x                  -
otus2  compressratio         2.22x                  -
otus3  compressratio         3.64x                  -
otus4  compressratio         1.00x                  -
```
## Определение настроек пула

```
[root@server ~]# wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download%E2%80%99'
Incomplete or invalid multibyte sequence encountered
--2022-02-13 15:00:05--  https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download%E2%80%99
Resolving drive.google.com (drive.google.com)... 173.194.73.194
Connecting to drive.google.com (drive.google.com)|173.194.73.194|:443... connected.
HTTP request sent, awaiting response... 302 Moved Temporarily
Location: https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/9cufrjhpvagf852a2fqlab30387ekfvo/1644764400000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download%E2%80%99 [following]
Incomplete or invalid multibyte sequence encountered
Warning: wildcards not supported in HTTP.
--2022-02-13 15:00:10--  https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/9cufrjhpvagf852a2fqlab30387ekfvo/1644764400000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download%E2%80%99
Resolving doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)... 64.233.164.132
Connecting to doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)|64.233.164.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 7275140 (6.9M) [application/x-gzip]
Saving to: 'archive.tar.gz'

archive.tar.gz                100%[=================================================>]   6.94M  8.01MB/s    in 0.9s

2022-02-13 15:00:11 (8.01 MB/s) - 'archive.tar.gz' saved [7275140/7275140]

[root@server ~]# ls
archive.tar.gz
[root@server ~]# tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
[root@server ~]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
 action: The pool can be imported using its name or numeric identifier, though
        some features will not be available without an explicit 'zpool upgrade'.
 config:

        otus                         ONLINE
          mirror-0                   ONLINE
            /root/zpoolexport/filea  ONLINE
            /root/zpoolexport/fileb  ONLINE
[root@server ~]# zpool import -d zpoolexport/ otus
[root@server ~]# zpool status
  pool: otus
 state: ONLINE
status: Some supported features are not enabled on the pool. The pool can
        still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(5) for details.
config:

        NAME                         STATE     READ WRITE CKSUM
        otus                         ONLINE       0     0     0
          mirror-0                   ONLINE       0     0     0
            /root/zpoolexport/filea  ONLINE       0     0     0
            /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: otus1
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0

errors: No known data errors

  pool: otus2
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus2       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sde     ONLINE       0     0     0

errors: No known data errors

  pool: otus3
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus3       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdf     ONLINE       0     0     0
            sdg     ONLINE       0     0     0

errors: No known data errors

  pool: otus4
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus4       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdh     ONLINE       0     0     0
            sdi     ONLINE       0     0     0

errors: No known data errors

[root@server ~]# zpool get all otus
NAME  PROPERTY                       VALUE                          SOURCE
otus  size                           480M                           -
otus  capacity                       0%                             -
otus  altroot                        -                              default
otus  health                         ONLINE                         -
otus  guid                           6554193320433390805            -
otus  version                        -                              default
otus  bootfs                         -                              default
otus  delegation                     on                             default
otus  autoreplace                    off                            default
otus  cachefile                      -                              default
otus  failmode                       wait                           default
otus  listsnapshots                  off                            default
otus  autoexpand                     off                            default
otus  dedupratio                     1.00x                          -
otus  free                           478M                           -
otus  allocated                      2.09M                          -
otus  readonly                       off                            -
otus  ashift                         0                              default
otus  comment                        -                              default
otus  expandsize                     -                              -
otus  freeing                        0                              -
otus  fragmentation                  0%                             -
otus  leaked                         0                              -
otus  multihost                      off                            default
otus  checkpoint                     -                              -
otus  load_guid                      6376804791156293597            -
otus  autotrim                       off                            default
otus  feature@async_destroy          enabled                        local
otus  feature@empty_bpobj            active                         local
otus  feature@lz4_compress           active                         local
otus  feature@multi_vdev_crash_dump  enabled                        local
otus  feature@spacemap_histogram     active                         local
otus  feature@enabled_txg            active                         local
otus  feature@hole_birth             active                         local
otus  feature@extensible_dataset     active                         local
otus  feature@embedded_data          active                         local
otus  feature@bookmarks              enabled                        local
otus  feature@filesystem_limits      enabled                        local
otus  feature@large_blocks           enabled                        local
otus  feature@large_dnode            enabled                        local
otus  feature@sha512                 enabled                        local
otus  feature@skein                  enabled                        local
otus  feature@edonr                  enabled                        local
otus  feature@userobj_accounting     active                         local
otus  feature@encryption             enabled                        local
otus  feature@project_quota          active                         local
otus  feature@device_removal         enabled                        local
otus  feature@obsolete_counts        enabled                        local
otus  feature@zpool_checkpoint       enabled                        local
otus  feature@spacemap_v2            active                         local
otus  feature@allocation_classes     enabled                        local
otus  feature@resilver_defer         enabled                        local
otus  feature@bookmark_v2            enabled                        local
otus  feature@redaction_bookmarks    disabled                       local
otus  feature@redacted_datasets      disabled                       local
otus  feature@bookmark_written       disabled                       local
otus  feature@log_spacemap           disabled                       local
otus  feature@livelist               disabled                       local
otus  feature@device_rebuild         disabled                       local
otus  feature@zstd_compress          disabled                       local
[root@server ~]# zfs get all otus
NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  4:00 2020  -
otus  used                  2.04M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclmode               discard                default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.01M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1020K                  -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              off                    default
otus  redundant_metadata    all                    default
otus  overlay               on                     default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default

[root@server ~]# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -
[root@server ~]#  zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default
[root@server ~]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
[root@server ~]# zfs get compression otus
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local
[root@server ~]# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```

## Работа со снапшотом, поиск сообщения от преподавателя

```
[root@server ~]# wget -O otus_task2.file --no-check-certificate 'https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download'
--2022-02-13 15:10:32--  https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
Resolving drive.google.com (drive.google.com)... 173.194.73.194
Connecting to drive.google.com (drive.google.com)|173.194.73.194|:443... connected.
HTTP request sent, awaiting response... 302 Moved Temporarily
Location: https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/mmiossnccn9s9nlgkihqtfphrq0940i2/1644765000000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download [following]
Warning: wildcards not supported in HTTP.
--2022-02-13 15:10:36--  https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/mmiossnccn9s9nlgkihqtfphrq0940i2/1644765000000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download
Resolving doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)... 64.233.164.132
Connecting to doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)|64.233.164.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5432736 (5.2M) [application/octet-stream]
Saving to: 'otus_task2.file'

otus_task2.file               100%[=================================================>]   5.18M  8.97MB/s    in 0.6s

2022-02-13 15:10:37 (8.97 MB/s) - 'otus_task2.file' saved [5432736/5432736]
[root@server ~]# zfs receive otus/test@today < otus_task2.file
[root@server ~]# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
[root@server ~]# cat /otus/test/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```

