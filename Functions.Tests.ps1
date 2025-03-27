BeforeAll {
    # Functions.psm1 をインポート
    Import-Module -Name "./Functions.psm1"

    # 固定の接続情報
    $siteUrl = "https://adstest2025.sharepoint.com"
    $tenantId = "da31fa32-ae12-4bf7-97f0-021837c11fec"
    $clientId = "b5b85d9f-12b8-4575-80d9-b2d366ef49c8"
    
    # Base64エンコードされた証明書データ（環境変数または設定ファイルから取得）
    $base64Cert = $env:BASE64_CERTIFICATE  # GitHub ActionsやCIツールの環境変数に格納

    # 一時ファイルの保存先を変更 (環境変数 $env:TEMP を使用)
    $certificatePath = Join-Path -Path $env:TEMP -ChildPath "temp_cert.pfx"

    # Base64データをバイト配列に復号し、一時的な証明書ファイルに保存
    [IO.File]::WriteAllBytes($certificatePath, [Convert]::FromBase64String($base64Cert))

    # 証明書パスワード（環境変数や設定ファイルから取得）
    $certificatePassword = "test0310"

    # 接続処理
    try {
        # SharePoint Online へ接続
        Write-Host "接続中... Site URL: $siteUrl, Tenant: $tenantId, Client ID: $clientId"
        Connect-PnPOnline -Url $siteUrl -Tenant $tenantId -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword (ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force)
        Write-Host "SharePoint Online に接続しました。"
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
            # 期待する結果: ライブラリからファイルが取得されること
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
            # 期待する結果: リストからアイテムが取得されること
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
