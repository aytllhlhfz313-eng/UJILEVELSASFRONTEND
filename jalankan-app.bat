@echo off
REM Jalankan aplikasi Contre Store di browser.
REM
REM Kenapa tidak pakai "flutter run -d chrome"?
REM Perintah itu memakai layanan debug Flutter web (DWDS) yang di mesin ini
REM gagal menyambung ke Chrome dalam batas 5 detik, sehingga prosesnya mati
REM dengan "Failed to establish connection with the web debug service".
REM Skrip ini memakai build release + server statis, yang tidak memerlukan
REM layanan debug tersebut.

cd /d "%~dp0"

echo ============================================
echo  Membangun aplikasi Contre Store (release)
echo ============================================
call flutter build web --release --no-web-resources-cdn
if errorlevel 1 (
    echo.
    echo [GAGAL] Build tidak berhasil. Periksa pesan di atas.
    pause
    exit /b 1
)

echo.
echo Backend harus sudah jalan di http://localhost:5000
echo Membuka http://localhost:8080 ...
start "" http://localhost:8080

call npx --yes serve build/web -l 8080
