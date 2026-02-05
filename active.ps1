$encodedKey = "QUFBQUEtQkJCQkItQ0NDQ0MtREREREQtRUVFRUU=" # Thay bằng chuỗi Base64 key của bạn
$webAppUrl = "https://script.google.com/macros/s/AKfycbx7OSD2j3YOhCLV2BNvdaiuq5QEvlyYQpl4BRE5So0osiuqLTV68lL3kZwHZyYzsdwl/exec"
$compName = $env:COMPUTERNAME

Write-Host "--- System Activation Tool ---" -ForegroundColor Cyan

# Bước 1: Ghi log bắt đầu (bắt buộc)
try {
    Invoke-RestMethod -Uri "$($webAppUrl)?compName=$compName&action=start" -Method Get > $null
    Write-Host "[+] Ghi nhan luot chay: $compName" -ForegroundColor Gray
} catch {
    Write-Host "[!] Khong the ket noi de ghi log." -ForegroundColor Yellow
}

# Bước 2: Kiểm tra trạng thái bản quyền hiện tại (Để tránh phí Key)
$status = (Get-CimInstance -Query "SELECT LicenseStatus FROM SoftwareLicensingProduct WHERE ApplicationID = '55c92274-24e0-4aa8-80ce-384b4563721d' AND LicenseStatus = 1")
if ($status) {
    Write-Host "[i] May tinh nay da duoc kich hoat san. Dung script." -ForegroundColor Green
    exit
}

# Bước 3: Kích hoạt
try {
    $realKey = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedKey))
    
    Write-Host "Executing..." -ForegroundColor White
    cscript //nologo c:\windows\system32\slmgr.vbs /ipk $realKey
    cscript //nologo c:\windows\system32\slmgr.vbs /ato

    # Bước 4: Ghi log thành công
    Invoke-RestMethod -Uri "$($webAppUrl)?compName=$compName&action=success" -Method Get > $null
    Write-Host "[OK] Kich hoat va ghi log thanh cong!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Co loi xay ra." -ForegroundColor Red
}