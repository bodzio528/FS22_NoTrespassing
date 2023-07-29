rem make ZIP archive
tar.exe -a -c -f FS22_NoTrespassing.zip NoTrespassing.lua NoTrespassing_loader.lua modDesc.xml icon_noTrespassing.dds data translations

copy /b/v/y FS22_NoTrespassing.zip FS22_NoTrespassing_update.zip

rem copy ZIP to FS22 mods folder
rem xcopy /b/v/y FS22_NoTrespassing_update.zip "%userprofile%\Documents\My Games\FarmingSimulator2022\mods\FS22_NoTrespassing_update.zip"
rem move /Y FS22_NoTrespassing_update.zip "%userprofile%\Documents\My Games\FarmingSimulator2022\mods\FS22_NoTrespassing_update.zip"
