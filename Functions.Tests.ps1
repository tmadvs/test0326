# BeforeAll で接続設定と変数定義
BeforeAll {
    Import-Module -Name "$PSScriptRoot\Functions.psm1"

    # SharePointサイトに接続
    $global:siteUrl = "https://adstest2025.sharepoint.com"
    $global:tenantId = "da31fa32-ae12-4bf7-97f0-021837c11fec"
    $global:clientId = "b5b85d9f-12b8-4575-80d9-b2d366ef49c8"
    $global:certificatePath = "C:\AIPtest\test0310app.pfx"
    $global:certificatePassword = "test0310"
    
    Connect-PnPOnline -Url $siteUrl -Tenant $tenantId -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword (ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force)
    Write-Host "Connected to SharePoint site: $siteUrl"
}

# テスト定義
Describe "SPO-Operations モジュールのテスト" {
    Context "正常系" {
        It "should retrieve files from a SharePoint library" {
            # 正常系テスト: SharePointライブラリからファイルを取得する
            Write-Host "Testing Get-SpoFiles with siteUrl: $siteUrl, libname: testlib1"
            try {
                $result = Get-SpoFiles -siteUrl $siteUrl -libname "testlib1"
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
            Write-Host "Testing Get-SPOItems with siteUrl: $siteUrl, listName: Applist"
            try {
                $result = Get-SPOItems -siteUrl $siteUrl -listName "Applist" -status "approved"
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
