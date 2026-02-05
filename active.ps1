# 1. Thông tin cấu hình
$encodedKey = "VzI2OU4tV0ZHV1gtWVZDOUItNEo2QzktVDgzR1g=" # Dán chuỗi Base64 ở Bước 1 vào đây
$webAppUrl = "https://script.google.com/macros/s/AKfycbw-Sb9WH2bcA7sU0sYgWcfJw5mJe9r9IHn8aufrp69yoMUZQIV9Es-mMG_pgspwQcJC/exec"
$deploymentID = "AKfycbw-Sb9WH2bcA7sU0sYgWcfJw5mJe9r9IHn8aufrp69yoMUZQIV9Es-mMG_pgspwQcJC"
$compName = $env:COMPUTERNAME

Write-Host "Dang kiem tra quyen kich hoat..." -ForegroundColor Cyan

try {
    # 2. Hoi Google Sheet xem may nay duoc phep dung key khong
    $status = Invoke-RestMethod -Uri "$($webAppUrl)?compName=$compName" -Method Get

    if ($status -eq "GRANTED") {
        # 3. Giai ma key trong RAM
        $decodedBytes = [System.Convert]::FromBase64String($encodedKey)
        $realKey = [System.Text.Encoding]::UTF8.GetString($decodedBytes)

        Write-Host "Dang kich hoat Windows..." -ForegroundColor Green
        
        # Thuc thi lenh (Dung cscript de chay ngam, khong hien popup)
        cscript //nologo c:\windows\system32\slmgr.vbs /ipk $realKey
        cscript //nologo c:\windows\system32\slmgr.vbs /ato
        
        Write-Host "Hoan tat kich hoat cho may $compName" -ForegroundColor Green
    } 
    else {
        Write-Host "Loi: Key nay da duoc su dung tren may tinh nay hoac bi tu choi!" -ForegroundColor Red
    }
} catch {
    Write-Host "Khong the ket noi den he thong xac thuc." -ForegroundColor Red
}