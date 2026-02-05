# 1. Khai báo
$encodedKey = "VzI2OU4tV0ZHV1gtWVZDOUItNEo2QzktVDgzR1g="
# V0JXS1ItTlE0NjQtS1JQQjQtOUdKN1ItVk1IMjY #key real
# VzI2OU4tV0ZHV1gtWVZDOUItNEo2QzktVDgzR1g= #key test
$webAppUrl = "https://script.google.com/macros/s/AKfycby7rigZWYIDqe2_YPpGZlrQiBj5IsRLQYSTBZnuLvwvyh3kd3AtyGu4X43ipz4BHPRd/exec"
$compName = $env:COMPUTERNAME

Write-Host "--- Windows Activation Tool v3 ---" -ForegroundColor Cyan

# Hàm gửi Log xử lý Redirect của Google
function Send-GLog ($act, $msg) {
    $fullUrl = "$($webAppUrl)?compName=$compName&action=$act&note=$msg"
    try {
        # Tham số -MaximumRedirection 5 là cực kỳ quan trọng để ghi được vào Sheet
        Invoke-WebRequest -Uri $fullUrl -Method Get -MaximumRedirection 5 -UseBasicParsing -TimeoutSec 10 > $null
    } catch {}
}

# Bước 1: Ghi log bắt đầu
Write-Host "[+] Dang ket noi voi he thong..."
Send-GLog "start" "Initiated"

# Bước 2: Giải mã Key và Kích hoạt
try {
    $realKey = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedKey))
    
    Write-Host "[+] Dang thiet lap Key..." -ForegroundColor White
    $install = cscript //nologo c:\windows\system32\slmgr.vbs /ipk $realKey
    
    if ($LASTEXITCODE -ne 0) {
        Send-GLog "error" "Invalid Key (0xC004F050)"
        Write-Host "[!] Key khong hop le cho phien ban Windows nay." -ForegroundColor Red
        exit
    }

    Write-Host "[+] Dang kich hoat..." -ForegroundColor White
    $active = cscript //nologo c:\windows\system32\slmgr.vbs /ato
    
    if ($active -like "*successfully*") {
        Send-GLog "success" "Activated Successfully"
        Write-Host "[OK] Kich hoat va ghi log thanh cong!" -ForegroundColor Green
    } else {
        Send-GLog "error" "Activation Failed"
        Write-Host "[!] Kich hoat that bai (Check DNS/Network)." -ForegroundColor Red
    }
} catch {
    Write-Host "[!] Co loi xay ra." -ForegroundColor Red
}