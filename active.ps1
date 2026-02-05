$v1=                                                                                                                                                                                                                     "V0JXS1ItTlE0NjQtS1JQQjQtOUdKN1ItVk1IMjY="
$v2=                                                                                                                                                                                                                    "https://script.google.com/macros/s/AKfycby2GEgWLZ8cQ0GW2rEPiES7aa9Mfj50YjwTOOgg3mEuj65Jbi3R_s2bZk4ckXnnRJRo/exec"
$v3=$env:COMPUTERNAME

Write-Host "--- Windows Activation System ---" -ForegroundColor Cyan

$v4 = Read-Host "Vui long nhap mat khau kich hoat"

try {
    $v5 = Invoke-RestMethod -Uri "$($v2)?compName=$v3&action=check_pass&pass=$v4" -Method Get -MaximumRedirection 5
    
    if ($v5 -eq "GRANTED") {
        Write-Host "[V] Xac thuc thanh cong! Dang tien hanh kich hoat..." -ForegroundColor Green
        
        $v6 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($v1))
        
        Write-Host "[+] Dang cai dat Key vao he thong..." -ForegroundColor White
        cscript //nologo c:\windows\system32\slmgr.vbs /ipk $v6 > $null 2>&1
        
        Write-Host "[+] Dang ket noi voi Microsoft de kich hoat..." -ForegroundColor White
        $v7 = cscript //nologo c:\windows\system32\slmgr.vbs /ato
        
        if ($v7 -like "*successfully*") {
            Invoke-RestMethod -Uri "$($v2)?compName=$v3&action=success" -Method Get -MaximumRedirection 5
            Write-Host "[OK] Windows da duoc kich hoat thanh cong!" -ForegroundColor Green
        } else {
            Write-Host "[!] Kich hoat that bai. Vui long kiem tra lai ket noi mang." -ForegroundColor Red
        }
    } 
    elseif ($v5 -eq "LIMIT_EXCEEDED") {
        Write-Host "[X] Mat khau nay da het luot su dung!" -ForegroundColor Red
    } 
    else {
        Write-Host "[X] Mat khau khong dung!" -ForegroundColor Red
    }
} catch {
    Write-Host "[X] Loi ket noi den he thong." -ForegroundColor Red
}