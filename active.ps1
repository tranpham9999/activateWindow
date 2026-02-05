$encodedKey = "V0JXS1ItTlE0NjQtS1JQQjQtOUdKN1ItVk1IMjY=" # Key của bạn
$webAppUrl = "https://script.google.com/macros/s/AKfycbx7OSD2j3YOhCLV2BNvdaiuq5QEvlyYQpl4BRE5So0osiuqLTV68lL3kZwHZyYzsdwl/exec"
$compName = $env:COMPUTERNAME

Write-Host "--- System Activation Tool v2 ---" -ForegroundColor Cyan

# Hàm gửi Log chuẩn (xử lý Redirect của Google)
function Send-Log ($action, $statusMsg) {
    $fullUrl = "$($webAppUrl)?compName=$compName&action=$action&note=$statusMsg"
    try {
        # Sử dụng -FollowRelink để đảm bảo dữ liệu tới được Google Script
        Invoke-WebRequest -Uri $fullUrl -Method Get -MaximumRedirection 5 -UseBasicParsing > $null
    } catch {}
}

# 1. Ghi log bắt đầu
Send-Log "start" "Initiated"

# 2. Giải mã Key
try {
    $realKey = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedKey))
} catch {
    Send-Log "error" "Base64 Decode Failed"
    Write-Host "[!] Key Base64 bi loi!" -ForegroundColor Red
    exit
}

# 3. Kích hoạt và kiểm tra lỗi
Write-Host "Executing Activation..." -ForegroundColor White
$install = cscript //nologo c:\windows\system32\slmgr.vbs /ipk $realKey
if ($LASTEXITCODE -ne 0) {
    $msg = "Invalid Key (0xC004F050)"
    Send-Log "error" $msg
    Write-Host "[!] $msg" -ForegroundColor Red
    exit
}

$active = cscript //nologo c:\windows\system32\slmgr.vbs /ato
if ($active -like "*successfully*") {
    Send-Log "success" "Activated Successfully"
    Write-Host "[OK] Thanh cong!" -ForegroundColor Green
} else {
    Send-Log "error" "Activation Failed"
    Write-Host "[!] Kich hoat that bai!" -ForegroundColor Red
}