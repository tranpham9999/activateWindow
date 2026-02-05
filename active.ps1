# 1. Thông tin cấu hình
$encodedKey = "V0JXS1ItTlE0NjQtS1JQQjQtOUdKN1ItVk1IMjY=" # Key Pro của bạn
$webAppUrl = "https://script.google.com/macros/s/AKfycby2GEgWLZ8cQ0GW2rEPiES7aa9Mfj50YjwTOOgg3mEuj65Jbi3R_s2bZk4ckXnnRJRo/exec"
$compName = $env:COMPUTERNAME

Write-Host "--- Windows Activation System (Retail/MAK) ---" -ForegroundColor Cyan

# Bước 1: Yêu cầu mật khẩu để bảo vệ Key
$userPass = Read-Host "Vui long nhap mat khau kich hoat"

# Bước 2: Xác thực Password và Quota qua Google Sheet
try {
    # Sử dụng -MaximumRedirection 5 để đảm bảo dữ liệu tới được Google Sheet
    $check = Invoke-RestMethod -Uri "$($webAppUrl)?compName=$compName&action=check_pass&pass=$userPass" -Method Get -MaximumRedirection 5
    
    if ($check -eq "GRANTED") {
        Write-Host "[V] Xac thuc thanh cong! Dang tien hanh kich hoat..." -ForegroundColor Green
        
        # Bước 3: Giải mã Key từ chuỗi Base64 trong RAM
        $realKey = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedKey))
        
        Write-Host "[+] Dang cai dat Key vao he thong..." -ForegroundColor White
        cscript //nologo c:\windows\system32\slmgr.vbs /ipk $realKey
        
        Write-Host "[+] Dang ket noi voi Microsoft de kich hoat..." -ForegroundColor White
        $active = cscript //nologo c:\windows\system32\slmgr.vbs /ato
        
        # Bước 4: Kiểm tra kết quả và ghi log cuối cùng
        if ($active -like "*successfully*") {
            Invoke-RestMethod -Uri "$($webAppUrl)?compName=$compName&action=success" -Method Get -MaximumRedirection 5
            Write-Host "[OK] Windows da duoc kich hoat thanh cong!" -ForegroundColor Green
        } else {
            Write-Host "[!] Kich hoat that bai. Vui long kiem tra lai Key hoac ket noi mang." -ForegroundColor Red
            Write-Host $active
        }
    } 
    elseif ($check -eq "LIMIT_EXCEEDED") {
        Write-Host "[X] Mat khau nay da het luot su dung!" -ForegroundColor Red
    } 
    else {
        Write-Host "[X] Mat khau khong dung!" -ForegroundColor Red
    }
} catch {
    Write-Host "[X] Loi ket noi den he thong xac thuc Google Sheet." -ForegroundColor Red
}