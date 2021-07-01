backupManager
=====

A backup manager tool.

Build
-----
    $ rebar3 compile

For the login it is used the loginWindow application : https://github.com/Taba92/loginWindow

LEGEND: For /sep/ i mean * 

CONFIGURATION:
    Launch the script **install**, that will create a default user *root* with password *passwd1111111111*.
    It also creates the default storage for the *root* user.

ATTENTION:
    ***Every invocation of the configuration script install, remove all files in Credentials and DirectoriesBackup folders and recreate the default user***.

USAGE BUTTONS:
    ADD DIRECTORY: add a directory in the directories storage to be included in the backup.
    REMOVE DIRECTORY: remove a directory from the directories storage.
    START BACKUP: search for the first hard disk and create a backup for each directory in the directories storage.
                   
The **root folder** of the backup have the below format:
    Year/sep/Month/sep/Day/sep/Hour/sep/Minute/sep/Second recovered at the time of the backup.

Inside the root folder, foreach directory of backup in the storage, there is a sub-folder:
    1) The file *metadata.meta* that contain the source directory
    2) The *directory tree folder* that contain the physical directory tree backupped

FUTURE DEVELOPMENTS: 
    1) The first external storage medium found will not be used, but you can choose it before the backup.
    2) Translate the GUI in English.
    3) Support for windows OS. 
