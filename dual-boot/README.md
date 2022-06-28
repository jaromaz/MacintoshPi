# Raspberry Pi OS & BMC64 dual-boot

BMC64 is not based directly on Linux and MUST be located on the first partition of the SD card. Therefore, for dual boot to be possible, the content of the first partition of *Raspberry Pi OS* must be moved to the third partition. To this end, you must reduce the size of the second partition, and use the remaining space to create the third one, as shown in the guide below.

In this case, I am using *Fedora Linux* distribution. The SD card's name is *mmcblk0*, but depending on whether the SD card reader is built in or connected via USB, SD cards can be designated in the system as ordinary disk drives (e.g. *sdc*). The partitions are designated as: *p1 p2* and still non-existing *p3*, but sometimes they are marked only with digits. All operations must be carried out from the root use account.

1. Eject the SD card your Raspberry Pi and move it to a computer with an SD card reader and a Linux system running.

2. Insert the SD card to the reader, run ```dmesg``` and ```lsblk``` to check the SD card's name, and unmount all its partitions.

   ```umount /run/media/[username]/*```

3. Check the current size of the SD card's partitions with the command:

   ```fdisk -l /dev/mmcblk0```

in this example, the result is:

   ```
   Device         Boot  Start      End  Sectors  Size Id Type
   /dev/mmcblk0p1        8192   532479   524288  256M  c W95 FAT32 (LBA)
   /dev/mmcblk0p2      532480 60579839 60047360 28.6G 83 Linux
   ```

4. Save the last sector of the first partition - in this case, it is ```532479```.

5. Run error check on the second partition, i.e. the one that must be reduced in size:

   ```e2fsck -f -C 0 /dev/mmcblk0p2```

6. Reduce the size of partition *p2* by the amount that will become the size of the new third boot partition - for *Raspberry Pi OS*, 300-600MB will be enough; so in this case, it will suffice to remove the tailing 6 from 28.6G:

   ```resize2fs /dev/mmcblk0p2 28G```

7. Remove partition *p2* (yes - it must be removed completely, the data on it will remain intact):

   ```fdisk /dev/mmcblk0```, key ```d``` and partition number ```2```.

   ```Partition 2 has been deleted.```

   Press key ```w``` to save the changes.

8. Create new partition *p2* with new size:

   ```fdisk /dev/mmcblk0```, key ```n``` create a new partition, key ```p``` primary, partition number ```2```; in the first sector, enter the value of the first partition's last sector saved earlier, but increased by one, i.e. ```532480``` in this case, the last sector will be calculated automatically based on the size value from Point 6 of this guide, i.e. in this case ```+28G``` (the plus sign is very important); when asked about removing the signature, answer *No*, i.e. press key ```n``` and then ```w```, to save the changes.

9. List all the partitions present on the SD card once again:

   ```fdisk -l /dev/mmcblk0```

   in this case, the result is:

   ```
   Device         Boot  Start      End  Sectors  Size Id Type
   /dev/mmcblk0p1        8192   532479   524288  256M  c W95 FAT32 (LBA)
   /dev/mmcblk0p2      532480 59252735 58720256   28G 83 Linux
   ```
10. This time, note down the second partition's last sector - in this case, it is ```59252735```.

11. Create new third boot partition *p3*:

    ```fdisk /dev/mmcblk0```, key ```n``` create a new partition, key ```p``` primary, partition number ```3```; in the first sector, enter the value of the last saved second partition's sector, but increased by one, i.e. ```59252736``` in this case; for the last sector, select the default value by pressing ```Enter```, thanks to which all the remaining space of the SD card will be filled. Don't save the changes just yet.

12. Change the type of the new partition to *W95 FAT32 (LBA)*:

    Press key ```t```, partition number ```3```, hex code: ```0c``` , and only then press key ```w``` to save the changes.

13. Create the file system on the new third partition using the command:

    ```mkfs.vfat -F 32 /dev/mmcblk0p3```

14. Label the new partition as ```boot2``` using the command:

    ```fatlabel /dev/mmcblk0p3 boot2```

    ignore the warning that will be displayed after this operation.

15. Create three directories (*p1*, *p2* and *p3*) in directory ```/mnt```:

    ```mkdir /mnt/p{1,2,3}```

16. Mount all three partitions in appropriate subdirectories in directory ```/mnt```, i.e. in this case:

    ```mount /dev/mmcblk0p1 /mnt/p1```
    ```mount /dev/mmcblk0p2 /mnt/p2```
    ```mount /dev/mmcblk0p3 /mnt/p3```

17. Move the content of the first partition, i.e. the content of directory ```/mnt/p1/*``` to the third partition using the command:

    ```mv /mnt/p1/* /mnt/p3/```

18. Create directory ```BMC64``` in the second partition's main directory:

    ```mkdir /mnt/p2/BMC64```

19. Display *UUID* and *PARTUUID* of the new partition using the command:

    ```blkid /dev/mmcblk0p3 -o export | grep UUID```

    In this case, the result of the command is:
    ```
    UUID=E1D6-04D5
    PARTUUID=163f3c16-03
    ```

    Save the data.

20. Edit file ```/mnt/p2/etc/fstab``` and check whether *UUID* or *PARTUUID* is used. Use the same naming method also for the third partition.

    In our case, file fstab looks as follows:
    ```
    proc                  /proc           proc    defaults          0       0
    PARTUUID=163f3c16-01  /boot           vfat    defaults          0       2
    PARTUUID=163f3c16-02  /               ext4    defaults,noatime  0       1
    ```
21. Copy the line which contains path ```/boot``` to the end of file ```/mnt/p2/etc/fstab``` - it should now have a similar form: 
    ```
    proc                  /proc           proc    defaults          0       0
    PARTUUID=163f3c16-01  /boot           vfat    defaults          0       2
    PARTUUID=163f3c16-02  /               ext4    defaults,noatime  0       1
    PARTUUID=163f3c16-01  /boot           vfat    defaults          0       2
    ```
22. Replace *UUID* or *PARTUUID* for the first partition ```/boot``` with the value of the third partition saved earlier - after this, example file ```fstab``` looks as follows:
    ```
    proc                  /proc           proc    defaults          0       0
    PARTUUID=163f3c16-03  /boot           vfat    defaults          0       2
    PARTUUID=163f3c16-02  /               ext4    defaults,noatime  0       1
    PARTUUID=163f3c16-01  /boot           vfat    defaults          0       2
    ```
23. In the last line of that file, indicate mounting of the first partition's resource to directory ```/BMC64``` with *read and write* rights for the ```pi``` user - just replace the phrase ```defaults``` in the fourth column with ```rw,uid=1000,gid=1000```. In the second column, replace directory ```/boot``` with ```/BMC64```. The whole example file ```/mnt/p2/etc/fstab``` now has the following form:
    ```
    proc                  /proc           proc    defaults          0       0
    PARTUUID=163f3c16-03  /boot           vfat    defaults          0       2
    PARTUUID=163f3c16-02  /               ext4    defaults,noatime  0       1
    PARTUUID=163f3c16-01  /BMC64          vfat    rw,uid=1000,gid=1000   0  2
    ```

24. Copy *BMC64* program files and all additional files that are necessary for it to run to the first partition.

25. Execute the following command, thanks to which *Raspberry Pi OS* will be started from the third partition:

    ```echo "boot_partition=3" > /mnt/p1/autoboot.txt```

26. Unmount all the SD card's partitions using the command:

    ```umount /mnt/*```

27. Execute command ```eject /dev/mmcblk0```, then eject the SD card and insert it into *Raspberry Pi*.

28. Start *Raspberry Pi* and if *Raspberry Pi OS* starts correctly, execute the following command:

    ```sudo reboot 1``` (or ```mac commodore``` if you have a *MacintoshPi* project installed)

    BMC64 should start.

29. To return to *Raspberry Pi OS* from *BMC64*, just select *F12->Machine->Switch->C64->Restart*. That operation should cause a restart and return to *Raspberry Pi OS*.

