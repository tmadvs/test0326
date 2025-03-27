# Functions.Tests.ps1

# PnP PowerShellをインポート
Import-Module PnP.PowerShell

# BeforeAll: 接続処理
BeforeAll {
    # GitHub ActionsのSecretsから取得した情報
    $siteUrl = "https://adstest2025.sharepoint.com"  # 必要に応じてURLを変更
    $tenantId = $env:TENANT_ID
    $clientId = $env:CLIENT_ID
    $certificatePassword = $env:CERT_PASSWORD
    
    # GitHub ActionsのTEMPディレクトリに証明書を保存
    $certificatePath = Join-Path -Path $env:TEMP -ChildPath "temp_cert.pfx"

    # 証明書が生成されたか確認
    if (-not (Test-Path $certificatePath)) {
        Write-Host "証明書ファイルが生成されていません: $certificatePath"
        exit 1
    }

    # SharePointに接続
    try {
        Connect-PnPOnline -Url $siteUrl -Tenant $tenantId -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword (ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force)
        Write-Host "Connected to SharePoint site: $siteUrl"
    } catch {
        Write-Host "接続エラー: $($_.Exception.Message)"
        throw $_
    }
}

# テスト定義
Describe "SPO-Operations モジュールのテスト" {
    Context "正常系" {
        It "should retrieve files from a SharePoint library" {
            # 正常系テスト: SharePointライブラリからファイルを取得する
            $siteUrl = "https://adstest2025.sharepoint.com"
            $libname = "testlib1"
            try {
                $result = Get-SpoFiles -siteUrl $siteUrl -libname $libname
                Write-Host "Retrieved Files: $result"
                if ($result.Count -gt 0) {
                    Write-Host "取得したファイル:"
                    foreach ($file in $result) {
                        Write-Host "ファイル名: $($file.FileName), パス: $($file.FilePath)"
                    }
                }
                $result | Should -Not -BeNullOrEmpty -Because "Files should be returned from the SharePoint library"
            } catch {
                Write-Host "エラー: $($_.Exception.Message)"
                throw $_
            }
        }

        It "should retrieve items from a SharePoint list" {
            # 正常系テスト: SharePointリストからアイテムを取得する
            $siteUrl = "https://adstest2025.sharepoint.com"
            $listName = "Applist"
            try {
                $result = Get-SPOItems -siteUrl $siteUrl -listName $listName -status "approved"
                Write-Host "Retrieved Items: $result"
                if ($result.Count -gt 0) {
                    Write-Host "取得したアイテム:"
                    foreach ($item in $result) {
                        Write-Host "アイテム名: $($item['Title']), ステータス: $($item['Status'])"
                    }
                }
                $result | Should -Not -BeNullOrEmpty -Because "Items should be returned from the SharePoint list"
            } catch {
                Write-Host "エラー: $($_.Exception.Message)"
                throw $_
            }
        }
    }

    Context "異常系" {
        It "should throw an error if the library does not exist" {
            $siteUrl = "https://adstest2025.sharepoint.com"
            $libname = "NonExistentLibrary"
            try {
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
            $siteUrl = "https://adstest2025.sharepoint.com"
            $listName = "NonExistentList"
            try {
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
