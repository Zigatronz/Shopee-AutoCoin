del /q "CollectCoin Firefox via QR.exe"
pyinstaller -F "CollectCoin Firefox via QR.py"
move "dist\CollectCoin Firefox via QR.exe" "CollectCoin Firefox via QR.exe"
rmdir /s /q build
rmdir /s /q dist
rmdir /s /q __pycache__
del /q "CollectCoin Firefox via QR.spec"