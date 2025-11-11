@echo off
chcp 65001 >nul
title Разметка диска под Windows (EFI + MSR + OS + Recovery)

echo ====================================================
echo   СКРИПТ РАЗМЕТКИ ДИСКА ПОД WINDOWS (EFI + MSR + OS + Recovery)
echo ====================================================
echo.
echo Доступные диски:
echo ----------------
echo list disk > "%TEMP%\list_disks.txt"
diskpart /s "%TEMP%\list_disks.txt"
echo ----------------
set /p DISKNUM=Введите номер диска, который нужно разметить: 
echo.

set SCRIPT=%TEMP%\diskpart_script.txt
del "%SCRIPT%" >nul 2>&1

(
    echo select disk %DISKNUM%
    echo clean
    echo convert gpt
    echo rem === EFI System Partition ===
    echo create partition efi size=300
    echo format quick fs=fat32 label=EFI
    echo assign letter=S
    echo rem Ждём завершения форматирования
    echo exit
) > "%SCRIPT%"

echo Выполняется создание EFI-раздела...
diskpart /s "%SCRIPT%"
timeout /t 2 >nul

(
    echo select disk %DISKNUM%
    echo rem === MSR Partition ===
    echo create partition msr size=16
    echo exit
) > "%SCRIPT%"
echo Создание MSR-раздела...
diskpart /s "%SCRIPT%"
timeout /t 2 >nul

(
    echo select disk %DISKNUM%
    echo rem === Основной раздел (Windows) ===
    echo create partition primary
    echo shrink desired=800
    echo format quick fs=ntfs label=Windows
    echo assign letter=W
    echo exit
) > "%SCRIPT%"
echo Создание основного раздела...
diskpart /s "%SCRIPT%"
timeout /t 2 >nul

(
    echo select disk %DISKNUM%
    echo rem === Recovery Partition ===
    echo create partition primary
    echo format quick fs=ntfs label=Recovery
    echo set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac
    echo gpt attributes=0x8000000000000001
    echo assign letter=R
    echo list volume
    echo exit
) > "%SCRIPT%"
echo Создание раздела Recovery...
diskpart /s "%SCRIPT%"

echo.
echo =========================================
echo Разметка завершена успешно!
echo =========================================
pause
exit /b
