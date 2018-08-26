#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse
import datetime
import hashlib
import os
from functools import partial

# magic winsxs number = 17514

# find /media/andyceo/226267706267479D -type f -iname pshed.dll -exec sh -c 'echo "$(stat -c "%y" "$1") $(md5sum "$1")"' _ {} \; | sort
# sfc /scannow /Offbootdir=c:\ /Offwindir=c:\windows
# DISM.exe /Image:<path_to_image_directory> [/Get-Packages | /Get-PackageInfo | /Add-Package | /Remove-Package ] [/Get-Features | /Get-FeatureInfo | /Enable-Feature | /Disable-Feature ] [/Cleanup-Image]

# reg load hklm\temp <drive letter for windows directory>\windows\system32\config\software
# ex: reg load hklm\temp c:\windows\system32\config\software
# reg delete “HKLM\temp\Microsoft\Windows\CurrentVersion\Component Based Servicing\SessionsPending” /v Exclusive
# reg unload HKLM\temp
# dism.exe /image:<drive letter for windows directory> /Get-Packages
# dism.exe /image:<drive letter for windows directory> /remove-package /packagename:<package name>

FILES = [
    # 'System32/config/system',
    # 'Atipcie.sys',
    # 'ntoskrnl.exe',
    'System32/xNtKrnl.exe',
    'System32/hal.dll',
    'System32/kdcom.dll',
    'System32/mcupdate_GenuineIntel.dll',
    'System32/PSHED.DLL',
    'System32/clfs.sys',
    'System32/ci.dll',
    'System32/drivers/oem-drv64.sys',
    'System32/drivers/Wdf01000.sys',
    'System32/drivers/WdfLdr.sys',
    'System32/drivers/acpi.sys',
    'System32/drivers/wmilib.sys',
    'System32/drivers/msisadrv.sys',
    'System32/drivers/pci.sys',
    'System32/drivers/vdrvroot.sys',
    'System32/drivers/iusb3hcs.sys',
    'System32/drivers/partmgr.sys',
    'System32/drivers/volmgr.sys',
    'System32/drivers/volmgrx.sys',
    'System32/drivers/mountmgr.sys',
    'System32/drivers/atapi.sys',
    'System32/drivers/ataport.sys',
    'System32/drivers/msahci.sys',
    'System32/drivers/pciidex.sys',
    'System32/drivers/iaStorA.sys',
    'System32/drivers/storport.sys',
    'System32/drivers/fltMgr.sys',
    'System32/drivers/fileinfo.sys',
    'System32/drivers/ntfs.sys',
    'System32/drivers/msrpc.sys',
    'System32/drivers/ksecdd.sys',
    'System32/drivers/cng.sys',
    'System32/drivers/pcw.sys',
    'System32/drivers/fs_rec.sys',
    'System32/drivers/ndis.sys',
    'System32/drivers/netio.sys',
    'System32/drivers/ksecpkg.sys',
    'System32/drivers/tcpip.sys',
    'System32/drivers/FWPKCLNT.SYS',
    'System32/drivers/vmstorfl.sys',
    'System32/drivers/volsnap.sys',
    'System32/drivers/spldr.sys',
    'System32/drivers/rdyboost.sys',
    'System32/pwdrvio.sys',
    'System32/drivers/mup.sys',
    'System32/drivers/iaStorF.sys',
    'System32/drivers/hwpolicy.sys',
    'System32/drivers/fvevol.sys',
    'System32/drivers/disk.sys',
    'System32/drivers/Classpnp.sys',
    'System32/drivers/amdxata.sys',
    'System32/drivers/amdkmpfd.sys',
]


def get_file_info(filepath, scan_missing=True):
    directory, filename = os.path.split(filepath)

    if os.path.isfile(filepath):
        path = directory + '/' + filename
        ctime = os.stat(path).st_ctime
        cdate = datetime.datetime.utcfromtimestamp(int(ctime)).isoformat()

        with open(path, mode='rb') as f:
            md5 = hashlib.md5()
            for buf in iter(partial(f.read, 128), b''):
                md5.update(buf)
        md5sum = md5.hexdigest()

        return {'ctime': ctime, 'cdate': cdate, 'md5sum': md5sum, 'path': path, 'filename': filename}
    elif scan_missing:
        print()
        print('not file!', filepath)
        os.system(
            'find /media/andyceo/226267706267479D -type f -iname {} -exec sh -c \'echo "$(stat -c "%y" "$1") $(md5sum "$1")"\' _ {{}} \; | sort'.format(
                filename))
        print()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Restore Windows 7 Safe Mode files from original image')
    parser.add_argument('-w', '--windir', metavar='/media/win7', help='Windows 7 directory')
    parser.add_argument('-o', '--origdir', metavar='/media/winimg', help='Windows 7 directory with original files')
    parser.add_argument('-b', '--backupdir', metavar='/media/win7backup', help='Windows 7 backup directory')
    args = parser.parse_args()

    for entry in FILES:
        wfilepath = args.windir + '/' + entry
        winfo = get_file_info(wfilepath)

        # print('{} {} {}'.format(winfo['md5sum'], winfo['cdate'], wfilepath))
        # os.system(
        #     'find /media/andyceo/226267706267479D/Windows/winsxs -type f -iname {} -exec sh -c \'echo "$(md5sum "$1")"\' _ {{}} \; | sort | grep 17514'.format(
        #         winfo['filename']))
        # print()
        # continue

        ofilepath = args.origdir + '/' + entry
        oinfo = get_file_info(ofilepath, False)
        if winfo and oinfo:
            if winfo['md5sum'] == oinfo['md5sum']:
                print('[PASS]: {} {} {} {}'.format(winfo['md5sum'], winfo['cdate'], oinfo['cdate'], winfo['filename']))
            else:
                print('[FAIL]: {} != {} {} {} {}'.format(
                    winfo['md5sum'], oinfo['md5sum'], winfo['cdate'], oinfo['cdate'], winfo['filename']))
        elif winfo and not oinfo:
            print('[PASS]: {} {} {}, original file missing'.format(winfo['md5sum'], winfo['cdate'], winfo['filename']))
