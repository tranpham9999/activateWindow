$v2          =          "https://script.google.com/macros/s/AKfycbzYQZbMtY5IMw44S8XxEJ3KLwgB01kHrrw-4LZxQ3BRsO_rX97DoRVCiMFDtiNSWvdD/exec"
$v3=$env:COMPUTERNAME

Write-Host "--- Windows Activation System ---" -ForegroundColor Cyan

$v4 = Read-Host "Vui long nhap mat khau kich hoat"

try {
    # Gửi yêu cầu lên Server
    # Server sẽ trả về: Key (nếu đúng), "WRONG_PASS", hoặc "LIMIT_EXCEEDED"
    $v5 = Invoke-RestMethod -Uri "$($v2)?compName=$v3&action=check_pass&pass=$v4" -Method Get -MaximumRedirection 5
    
    # Kiểm tra phản hồi
    if ($v5 -eq "WRONG_PASS") {
        Write-Host "[X] Mat khau khong dung!" -ForegroundColor Red
    } 
    elseif ($v5 -eq "LIMIT_EXCEEDED") {
        Write-Host "[X] Mat khau nay da het luot su dung!" -ForegroundColor Red
    }
    # Nếu phản hồi dài hơn 20 ký tự, hệ thống hiểu đó là Key
    elseif ($v5.Length -gt 20) { 
        Write-Host "[V] Xac thuc thanh cong! Dang tien hanh kich hoat..." -ForegroundColor Green
        
        Write-Host "[+] Dang cai dat Key vao he thong..." -ForegroundColor White
        
        # Cài đặt trực tiếp Key nhận được từ Server ($v5)
        # > $null 2>&1 giúp ẩn hoàn toàn Key khỏi màn hình console
        cscript //nologo c:\windows\system32\slmgr.vbs /ipk $v5 > $null 2>&1
        
        Write-Host "[+] Dang ket noi voi Microsoft de kich hoat..." -ForegroundColor White
        $v7 = cscript //nologo c:\windows\system32\slmgr.vbs /ato
        
        if ($v7 -like "*successfully*") {
            # Gửi báo cáo thành công về Server để ghi log
            Invoke-RestMethod -Uri "$($v2)?compName=$v3&action=success" -Method Get -MaximumRedirection 5
            Write-Host "[OK] Windows da duoc kich hoat thanh cong!" -ForegroundColor Green
        } else {
            Write-Host "[!] Kich hoat that bai. Vui long kiem tra lai ket noi mang." -ForegroundColor Red
        }
    } 
    else {
        # Trường hợp Server trả về lỗi lạ (ví dụ lỗi Config sheet)
        Write-Host "[X] Loi tu may chu: $v5" -ForegroundColor Red
    }
} catch {
    Write-Host "[X] Loi ket noi den he thong." -ForegroundColor Red
}