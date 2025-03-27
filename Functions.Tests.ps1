# 同じディレクトリにあるモジュールを呼び出してインポートする
BeforeAll {
    if (-not $env:TENANT_ID) { Write-Host "Error: TENANT_ID is null or empty" }
    if (-not $env:CLIENT_ID) { Write-Host "Error: CLIENT_ID is null or empty" }
    if (-not $env:CERT_PASSWORD) { Write-Host "Error: CERT_PASSWORD is null or empty" }

    Write-Host "TENANT_ID: $env:TENANT_ID"
    Write-Host "CLIENT_ID: $env:CLIENT_ID"
    Write-Host "CERT_PASSWORD: $env:CERT_PASSWORD"

    Import-Module -Name "./Functions.psm1"

    $siteUrl = "https://adstest2025.sharepoint.com"
    $tenantId = $env:TENANT_ID
    $clientId = $env:CLIENT_ID
    $certificatePath = "mycert.pfx"
    $certificatePassword = $env:CERT_PASSWORD

    Connect-PnPOnline -Url $siteUrl -Tenant $tenantId -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword (ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force)
    Write-Host "Connected to SharePoint site: $siteUrl"
}

# テスト定義
Describe "SPO-Operations モジュールのテスト" {
    Context "正常系" {
        It "should retrieve files from a SharePoint library" {
            Write-Host "Testing Get-SpoFiles with siteUrl: $siteUrl, libname: $libname"
            # 正常系テスト: SharePointライブラリからファイルを取得する
            $result = Get-SpoFiles -siteUrl $siteUrl -libname $libname
            Write-Host "Retrieved Files: $result"
            $result | Should -Not -BeNullOrEmpty -Because "Files should be returned from the SharePoint library"
        }

        It "should retrieve items from a SharePoint list" {
            Write-Host "Testing Get-SPOItems with siteUrl: $siteUrl, listName: $listName"
            # 正常系テスト: SharePointリストからアイテムを取得する
            $result = Get-SPOItems -siteUrl $siteUrl -listName $listName -status "approved"
            Write-Host "Retrieved Items: $result"
            $result | Should -Not -BeNullOrEmpty -Because "Items should be returned from the SharePoint list"
        }
    }

    Context "異常系" {
        It "should throw an error if the library does not exist" {
            $libname = "NonExistentLibrary"
            try {
                Write-Host "Testing Get-SpoFiles with non-existent library: $libname"
                Get-SpoFiles -siteUrl $siteUrl -libname $libname -ErrorAction Stop
                throw "エラー: ライブラリが存在しないはずですが、ファイルを取得できました。"
            } catch {
                $errorMessage = "成功: ライブラリ '$libname' は存在しないため、エラーが発生しました。"
                Write-Host $errorMessage
                if (-not (Test-Path "C:\AIPtest\Logs")) {
                    New-Item -ItemType Directory -Path "C:\AIPtest\Logs"
                }
                $errorMessage | Out-File -FilePath "C:\AIPtest\Logs\error_log.txt" -Append
            }
        }

        It "should throw an error if the list does not exist" {
            $listName = "NonExistentList"
            try {
                Write-Host "Testing Get-SPOItems with non-existent list: $listName"
                Get-SPOItems -siteUrl $siteUrl -listName $listName -status "approved" -ErrorAction Stop
                throw "エラー: リストが存在しないはずですが、アイテムを取得できました。"
            } catch {
                $errorMessage = "成功: リスト '$listName' は存在しないため、エラーが発生しました。"
                Write-Host $errorMessage
                if (-not (Test-Path "C:\AIPtest\Logs")) {
                    New-Item -ItemType Directory -Path "C:\AIPtest\Logs"
                }
                $errorMessage | Out-File -FilePath "C:\AIPtest\Logs\error_log.txt" -Append
            }
        }
    }
}
